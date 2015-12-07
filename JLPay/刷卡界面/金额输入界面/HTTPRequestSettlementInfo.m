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

@interface HTTPRequestSettlementInfo() <ASIHTTPRequestDelegate>

@property (nonatomic, assign) id<HTTPRequestSettlementInfoDelegate>delegate;
@property (nonatomic, retain) ASIFormDataRequest* httpRequester;

@end

@implementation HTTPRequestSettlementInfo



/* 申请结算信息，指定: 商户号、终端号 */
- (void) requestSettlementInfoWithBusinessNumber:(NSString*)businessNumber
                                  terminalNumber:(NSString*)terminalNumber
                                        delegate:(id<HTTPRequestSettlementInfoDelegate>)delegate
{
    self.delegate = delegate;
    // test......
    [self requestFinished:self.httpRequester];
//    [self requestFailed:self.httpRequester];
}

- (void)dealloc {
    self.delegate = nil;
    [self.httpRequester clearDelegatesAndCancel];
}

#pragma mask ---- HTTP 操作
/* 数据申请 */
- (void) startHttpRequestWithBusinessNumber:(NSString*)businessNumber
                             terminalNumber:(NSString*)terminalNumber
{
    [self.httpRequester setDelegate:self];
    [self.httpRequester addPostValue:businessNumber forKey:@""];
    [self.httpRequester addPostValue:terminalNumber forKey:@""];
    [self.httpRequester startAsynchronous];
}

/* 回调: 响应成功 */
- (void)requestFinished:(ASIHTTPRequest *)request {
    /* 解析出申请的数据 */
    NSMutableDictionary* requestData = [[NSMutableDictionary alloc] init];
    [requestData setObject:[NSNumber numberWithBool:YES] forKey:kSettleInfoNameT_0_Enable];
    [requestData setObject:@"0.05" forKey:kSettleInfoNameT_0_Fee];
    [requestData setObject:@"0.38" forKey:kSettleInfoNameT_1_Fee];
    [requestData setObject:@"10000" forKey:kSettleInfoNameAmountLimit];
    [requestData setObject:@"8000" forKey:kSettleInfoNameAmountAvilable];
    [requestData setObject:@"500" forKey:kSettleInfoNameMinCustAmount];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRequestedResult:settlementInfo:orErrorMessage:)]) {
        [self.delegate didRequestedResult:YES settlementInfo:requestData orErrorMessage:nil];
    }

    /* 关闭 */
    [self.httpRequester clearDelegatesAndCancel];
}

/* 回调: 响应失败 */
- (void)requestFailed:(ASIHTTPRequest *)request {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRequestedResult:settlementInfo:orErrorMessage:)]) {
        [self.delegate didRequestedResult:NO settlementInfo:nil orErrorMessage:@"网络异常,请检查网络"];
    }
    /* 关闭 */
    [self.httpRequester clearDelegatesAndCancel];
}

#pragma mask ---- getter
- (ASIFormDataRequest *)httpRequester {
    if (_httpRequester == nil) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/...",[PublicInformation getServerDomain],[PublicInformation getHTTPPort]];
        _httpRequester = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    }
    return _httpRequester;
}

@end
