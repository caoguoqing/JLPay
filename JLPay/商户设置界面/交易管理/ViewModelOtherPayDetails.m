//
//  ViewModelOtherPayDetails.m
//  JLPay
//
//  Created by jielian on 15/12/18.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ViewModelOtherPayDetails.h"
#import "PublicInformation.h"
#import "ModelDeviceBindedInformation.h"

static NSString* const kOthDetailsRequestBeginDate = @"queryBeginTime";
static NSString* const kOthDetailsRequestEndDate = @"queryEndTime";
static NSString* const kOthDetailsRequestTerminalNo = @"termNo";
static NSString* const kOthDetailsRequestBusinessNo = @"mchntNo";

static NSString* const kOthDetailsResponseDetailList = @"DetailList";

static NSString* const kOthDetailsKeyTxnNum = @"txnNum"; // 交易类型
static NSString* const kOthDetailsKeyCardAccpId = @"cardAccpId"; // 商户编号
static NSString* const kOthDetailsKeyTermSsn = @"termSsn"; // 终端流水
static NSString* const kOthDetailsKeyInstDate = @"instDate"; // 交易日期
static NSString* const kOthDetailsKeyInstTime = @"instTime"; // 交易时间
static NSString* const kOthDetailsKeyCardAccpTermId = @"cardAccpTermId"; // 终端编号
static NSString* const kOthDetailsKeySysSeqNum = @"sysSeqNum"; // 系统流水
static NSString* const kOthDetailsKeyCardAccpName = @"cardAccpName"; // 商户名称
static NSString* const kOthDetailsKeyOrderId = @"orderId"; // 订单号
static NSString* const kOthDetailsKeyChannelType = @"channelType"; // 渠道类型
static NSString* const kOthDetailsKeyRespCode = @"respCode"; // 响应码
static NSString* const kOthDetailsKeyAmtTrans = @"amtTrans"; // 交易金额

static NSString* const kOthDetailsTitleTxnType = @"交易类型";
static NSString* const kOthDetailsTitleBusinessName = @"商户名称";
static NSString* const kOthDetailsTitleTransAmount = @"交易金额";
static NSString* const kOthDetailsTitleTransDate = @"交易日期";
static NSString* const kOthDetailsTitleTransTime = @"交易时间";
static NSString* const kOthDetailsTitleTransState = @"交易状态";
static NSString* const kOthDetailsTitleSysSeqNo = @"系统流水号";



@interface ViewModelOtherPayDetails()
<HTTPInstanceDelegate>
{
    BOOL bFiltered__;
    NSString* sFilteredInputs__;
}
@property (nonatomic, assign) id<ViewModelOtherPayDetailsDelegate>delegate;

@property (nonatomic, retain) HTTPInstance* http;
@property (nonatomic, strong) NSArray* detailsOrigin;
@property (nonatomic, strong) NSMutableArray* detailsNeedDisplayed;

@end

@implementation ViewModelOtherPayDetails

- (instancetype)init {
    self = [super init];
    if (self) {
        bFiltered__ = NO;
        self.detailsNeedDisplayed = [[NSMutableArray alloc] init];
        
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/getTradeDetail",
                               [PublicInformation getServerDomain],
                               [PublicInformation getHTTPPort]];
        self.http = [[HTTPInstance alloc] initWithURLString:urlString];
    }
    return self;
}


/* 申请明细: 指定类型 */
- (void) requestDetailsWithDelegate:(id<ViewModelOtherPayDetailsDelegate>)delegate
                          beginTime:(NSString*)beginTime
                            endTime:(NSString*)endTime
{
    self.delegate = delegate;
    [self startHTTPRequestBeginDate:beginTime endDate:endTime];
}

/* 终止请求 */
- (void) terminateRequesting {
    [self.http terminateRequesting];
}

/* 清空数据 */
- (void) clearDetails {
    [self clearDetailsNeedDisplayed];
}


#pragma mask ---- 过滤器 -------- 需要修改
/* 过滤: 输入为金额或卡号后4位; 返回过滤结果*/
//- (BOOL) filterDetailsByInput:(NSString*)input;
//- (void) removeFilter;


#pragma mask ---- selector
/* 准备好获取数据源: 有过滤器的过滤出条件值 */
- (void) prepareSelector {
    [self loadDetailsFromOriginToNeedDisplayed];
}

/* 总笔数 */
- (NSInteger) totalCountOfTrans {
    return [self.detailsNeedDisplayed count];
}
/* 消费笔数 */
- (NSInteger) countOfNormalTrans {
    return [self.detailsNeedDisplayed count];
}
/* 撤销笔数 */
- (NSInteger) countofCancelTrans {
    return 0;
}
/* 总金额: int */
- (NSString*) totalAmountOfTrans {
    NSInteger intMoney = 0;
    for (int i = 0; i < [self totalCountOfTrans]; i++) {
        intMoney += [self moneyAtIndex:i].integerValue;
    }
    return [NSString stringWithFormat:@"%d",intMoney];
}

/* ----- 原始值 ----- */

/* 交易详情节点: 指定序号 */
- (NSDictionary*) nodeDetailAtIndex:(NSInteger)index {
    return [self.detailsNeedDisplayed objectAtIndex:index];
}

/* 金额: int 指定序号 */
- (NSString*) moneyAtIndex:(NSInteger)index {
    return [[self nodeDetailAtIndex:index] objectForKey:kOthDetailsKeyAmtTrans];
}

/* 交易类型: 指定序号 */
- (NSString*) transTypeAtIndex:(NSInteger)index {
    return [[self nodeDetailAtIndex:index] objectForKey:kOthDetailsKeyTxnNum];
}

/* 交易日期 */
- (NSString*) transDateAtIndex:(NSInteger)index {
    return [[self nodeDetailAtIndex:index] objectForKey:kOthDetailsKeyInstDate];
}

/* 交易时间 */
- (NSString*) transTimeAtIndex:(NSInteger)index {
    return [[self nodeDetailAtIndex:index] objectForKey:kOthDetailsKeyInstTime];
}


/* ----- 格式化值 ----- */
/* 交易时间: 指定序号 hh:mm:ss */
- (NSString*) formatTimeAtIndex:(NSInteger)index {
    NSString* transTime = [self transTimeAtIndex:index];
    if (transTime.length == 6) {
        transTime = [NSString stringWithFormat:@"%@:%@:%@",
                     [transTime substringToIndex:2],
                     [transTime substringWithRange:NSMakeRange(2, 2)],
                     [transTime substringFromIndex:2+2]];
    }
    else {
        transTime = nil;
    }
    return transTime ;
}
/* 交易日期: 指定序号 YYYY/MM/DD */
- (NSString*) formatDateAtIndex:(NSInteger)index {
    NSString* transDate = [self transDateAtIndex:index];
    if (transDate.length == 8) {
        transDate = [NSString stringWithFormat:@"%@/%@/%@",
                     [transDate substringToIndex:4],
                     [transDate substringWithRange:NSMakeRange(4, 2)],
                     [transDate substringFromIndex:4+2]];
    }
    else {
        transDate = nil;
    }
    return transDate;
}

/* 显示字段名数组: 交易详情 */
+ (NSArray*) titlesNeedDisplayedForNode:(NSDictionary*)detailNode {
    return @[kOthDetailsTitleTxnType,
             kOthDetailsTitleBusinessName,
             kOthDetailsTitleTransAmount,
             kOthDetailsTitleTransDate,
             kOthDetailsTitleTransTime,
             kOthDetailsTitleTransState,
             kOthDetailsTitleSysSeqNo];
}
/* 显示字段名对应的值 */
+ (NSString*) valueForTitleNeedDisplayed:(NSString*)title ofNode:(NSDictionary*)detailNode {
    NSString* value = [detailNode objectForKey:[[self dictionaryTitlesToKeys] objectForKey:title]];
    if ([title isEqualToString:kOthDetailsKeyAmtTrans]) {
        value = [NSString stringWithFormat:@"%@元",[PublicInformation dotMoneyFromNoDotMoney:value]];
    }
    else if ([title isEqualToString:kOthDetailsTitleTransDate]) {
        value = [NSString stringWithFormat:@"%@/%@/%@",
                 [value substringToIndex:4],
                 [value substringWithRange:NSMakeRange(4, 2)],
                 [value substringFromIndex:4+2]];
    }
    else if ([title isEqualToString:kOthDetailsTitleTransTime]) {
        value = [NSString stringWithFormat:@"%@:%@:%@",
                 [value substringToIndex:2],
                 [value substringWithRange:NSMakeRange(2, 2)],
                 [value substringFromIndex:2+2]];
    }
    else if ([title isEqualToString:kOthDetailsTitleTransState]) {
        if (value.intValue == 0) {
            value = @"交易成功";
        } else {
            value = @"交易失败";
        }
    }
    return value;
}


#pragma mask ---- PRIVATE INTERFACE

#pragma mask HTTP && HTTPInstanceDelegate
- (void) startHTTPRequestBeginDate:(NSString*)beginDate endDate:(NSString*)endDate {
    [self.http startRequestingWithDelegate:self packingHandle:^(ASIFormDataRequest *http) {
        [http addPostValue:beginDate forKey:kOthDetailsRequestBeginDate];
        [http addPostValue:endDate forKey:kOthDetailsRequestEndDate];
        [http addPostValue:[ModelDeviceBindedInformation terminalNoBinded] forKey:kOthDetailsRequestTerminalNo];
        [http addPostValue:[ModelDeviceBindedInformation businessNoBinded] forKey:kOthDetailsRequestBusinessNo];
    }];
}
- (void)httpInstance:(HTTPInstance *)httpInstance didRequestingFinishedWithInfo:(NSDictionary *)info
{
    NSLog(@"查询的第三方支付明细:[%@]",info);
    self.detailsOrigin = [NSArray arrayWithArray:[info objectForKey:kOthDetailsResponseDetailList]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRequestingSuccessful)]) {
        [self.delegate didRequestingSuccessful];
    }
}
- (void)httpInstance:(HTTPInstance *)httpInstance didRequestingFailedWithError:(NSDictionary *)errorInfo
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRequestingFailWithCode:andMessage:)]) {
        [self.delegate didRequestingFailWithCode:[[errorInfo objectForKey:kHTTPInstanceErrorCode] intValue]
                                      andMessage:[errorInfo objectForKey:kHTTPInstanceErrorMessage]];
    }
}

/* 清空缓存 */
- (void) clearDetailsNeedDisplayed {
    if (self.detailsNeedDisplayed.count > 0) {
        [self.detailsNeedDisplayed removeAllObjects];
    }
}

/* 转移原始数据到显示数据里 */
- (void) loadDetailsFromOriginToNeedDisplayed {
    [self clearDetailsNeedDisplayed];
    if (bFiltered__) {
        
    }
    else {
        [self.detailsNeedDisplayed addObjectsFromArray:self.detailsOrigin];
    }
}

/* 字典: title -> key */
+ (NSDictionary*) dictionaryTitlesToKeys {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:kOthDetailsKeyTxnNum forKey:kOthDetailsTitleTxnType];
    [dict setObject:kOthDetailsKeyCardAccpId forKey:kOthDetailsTitleBusinessName];
    [dict setObject:kOthDetailsKeyAmtTrans forKey:kOthDetailsTitleTransAmount];
    [dict setObject:kOthDetailsKeyInstDate forKey:kOthDetailsTitleTransDate];
    [dict setObject:kOthDetailsKeyInstTime forKey:kOthDetailsTitleTransTime];
    [dict setObject:kOthDetailsKeyRespCode forKey:kOthDetailsTitleTransState];
    [dict setObject:kOthDetailsKeySysSeqNum forKey:kOthDetailsTitleSysSeqNo];
    
    return dict;
}

@end
