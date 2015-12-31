//
//  HTTPRequestSettlementInfo.m
//  JLPay
//
//  Created by jielian on 15/12/7.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "HTTPRequestSettlementInfo.h"
#import "ASIFormDataRequest.h"
#import "PublicInformation.h"
#import "Define_Header.h"

static NSString* const kFieldNameRequestBusinessNum = @"mchtNo";

static NSString* const kFieldNameResponseCode = @"code";
static NSString* const kFieldNameResponseMessage = @"message";

static NSString* const kFieldNameResponseAllowFlag = @"allowFlag"; // 是否允许T+0
static NSString* const kFieldNameResponseDayTotal = @"dayTotal"; // 日总限额
static NSString* const kFieldNameResponseT0Fee = @"t0Fee"; // t+0费率
static NSString* const kFieldNameResponseCumMoney = @"cumMoney"; // 已刷T+0金额
static NSString* const kFieldNameResponseCompareMoney = @"compareMoney";// 比较金额(刷卡金额小于此需要+额外的手续费)
static NSString* const kFieldNameResponseExtraFee = @"extraFee";  // 额外的手续费

static NSString* const T_0MinCustMoney = @"1.50";

@interface HTTPRequestSettlementInfo() <ASIHTTPRequestDelegate>

@property (nonatomic, assign) id<HTTPRequestSettlementInfoDelegate>delegate;
@property (nonatomic, retain) ASIFormDataRequest* httpRequester;

@end



static HTTPRequestSettlementInfo* settlementRequester = nil;

@implementation HTTPRequestSettlementInfo

+ (instancetype)sharedInstance {
    @synchronized(self) {
        if (settlementRequester == nil) {
            settlementRequester = [[HTTPRequestSettlementInfo alloc] init];
        }
        return settlementRequester;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}
- (void)dealloc {
    self.delegate = nil;
    [self.httpRequester clearDelegatesAndCancel];
}


/* 申请结算信息，指定: 商户号、终端号 */
- (void) requestSettlementInfoWithBusinessNumber:(NSString*)businessNumber  delegate:(id<HTTPRequestSettlementInfoDelegate>)delegate
{
    self.delegate = delegate;
    [self startHttpRequestWithBusinessNumber:businessNumber];
}

- (void)requestTerminate {
    self.delegate = nil;
    [self.httpRequester clearDelegatesAndCancel];
    self.httpRequester = nil;
}



#pragma mask ---- HTTP 操作
/* 数据申请 */
- (void) startHttpRequestWithBusinessNumber:(NSString*)businessNumber
{
    [self.httpRequester addPostValue:businessNumber forKey:kFieldNameRequestBusinessNum];
    [self.httpRequester startAsynchronous];
}

/* 回调: 响应成功 */
- (void)requestFinished:(ASIHTTPRequest *)request {
    [request clearDelegatesAndCancel];
    /* 解析出申请的数据 */
    NSData* data = [request responseData];
    NSError* error;
    NSDictionary* responseInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (NeedPrintLog) {
        NSLog(@"查询到的结算信息:[%@]",responseInfo);
    }
    if (!error) {
        NSString* code = [responseInfo objectForKey:kFieldNameResponseCode];
        if (code.intValue == 0) {
            [self rebackSuccessInfo:[self settlementInfoAnalysedWithResponseInfo:responseInfo]];
        }
        else {
            [self rebackFailedMessage:[responseInfo objectForKey:kFieldNameResponseMessage]];
        }
    } else {
        [self rebackFailedMessage:@"解析结算信息失败"];
    }
    self.httpRequester = nil;
}

/* 回调: 响应失败 */
- (void)requestFailed:(ASIHTTPRequest *)request {
    [request clearDelegatesAndCancel];
    [self rebackFailedMessage:@"网络异常,请检查网络"];
    self.httpRequester = nil;
}


/* 解析响应数据 */
- (NSDictionary*) settlementInfoAnalysedWithResponseInfo:(NSDictionary*)responseInfo {
    NSMutableDictionary* settlementInfo = [[NSMutableDictionary alloc] init];
    // t+0标记
    NSString* t0flag = [responseInfo objectForKey:kFieldNameResponseAllowFlag];
    if (t0flag.intValue == 0) {
        [settlementInfo setObject:[NSNumber numberWithBool:YES] forKey:kSettleInfoNameT_0_Enable];
    } else {
        [settlementInfo setObject:[NSNumber numberWithBool:NO] forKey:kSettleInfoNameT_0_Enable];
    }
    // 日结算额
    NSString* dayTotal = [responseInfo objectForKey:kFieldNameResponseDayTotal];
    [settlementInfo setObject:[NSString stringWithFormat:@"%.02lf",[dayTotal floatValue]] forKey:kSettleInfoNameAmountLimit];
    // 日可刷限额
    NSString* cumMoney = [responseInfo objectForKey:kFieldNameResponseCumMoney];
    [settlementInfo setObject:[NSString stringWithFormat:@"%.02lf", dayTotal.floatValue - cumMoney.floatValue] forKey:kSettleInfoNameAmountAvilable];
    // t+0手续费
    NSString* t0Fee = [responseInfo objectForKey:kFieldNameResponseT0Fee];
    [settlementInfo setObject:[NSString stringWithFormat:@"%.02lf",t0Fee.floatValue] forKey:kSettleInfoNameT_0_Fee];
    // 比较金额
    NSString* compareMoney = [responseInfo objectForKey:kFieldNameResponseCompareMoney];
    [settlementInfo setObject:[NSString stringWithFormat:@"%.02lf",compareMoney.floatValue] forKey:kSettleInfoNameCompareMoney];
    // 额外手续费
    NSString* extraFee = [responseInfo objectForKey:kFieldNameResponseExtraFee];
    [settlementInfo setObject:[NSString stringWithFormat:@"%.02lf",extraFee.floatValue] forKey:kSettleInfoNameExtraFee];
    // 最低刷卡额
    [settlementInfo setObject:T_0MinCustMoney forKey:kSettleInfoNameMinCustAmount];

    return settlementInfo;
}


- (void) rebackSuccessInfo:(NSDictionary*)info {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRequestedSuccessWithSettlementInfo:)]) {
        [self.delegate didRequestedSuccessWithSettlementInfo:info];
    }
}
- (void) rebackFailedMessage:(NSString*)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRequestedFailedWithErrorMessage:)]) {
        [self.delegate didRequestedFailedWithErrorMessage:message];
    }
}


#pragma mask ---- getter
- (ASIFormDataRequest *)httpRequester {
    if (_httpRequester == nil) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/getT0Info",
                               [PublicInformation getServerDomain],
                               [PublicInformation getHTTPPort]];
        _httpRequester = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [_httpRequester setDelegate:self];
    }
    return _httpRequester;
}

@end
