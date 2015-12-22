//
//  ViewModelMPOSDetails.m
//  JLPay
//
//  Created by jielian on 15/12/15.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ViewModelMPOSDetails.h"
#import "PublicInformation.h"
#import "Define_Header.h"


static NSString* const kDetailsFilterKeyCardNo = @"pan";
static NSString* const kDetailsFilterKeyAmount = @"amtTrans";

static NSString* const kDetailsKeyCardNo = @"pan";
static NSString* const kDetailsKeyAmount = @"amtTrans";
static NSString* const kDetailsKeyTxnType = @"txnNum";
static NSString* const kDetailsKeyDate = @"instDate";
static NSString* const kDetailsKeyTime = @"instTime";
static NSString* const kDetailsKeySysSeqNum = @"sysSeqNum";
static NSString* const kDetailsKeyCardAccpId = @"cardAccpId";
static NSString* const kDetailsKeyCardAccpName = @"cardAccpName";
static NSString* const kDetailsKeyCardAccpTermId = @"cardAccpTermId";
static NSString* const kDetailsKeyRetrivlRef = @"retrivlRef";
static NSString* const kDetailsKeyAcqInstIdCode = @"acqInstIdCode";
static NSString* const kDetailsKeyCancelFlag = @"cancelFlag";
static NSString* const kDetailsKeyRevsal_flag = @"revsal_flag";
static NSString* const kDetailsKeyRespCode = @"respCode";
static NSString* const kDetailsKeyFldReserved = @"fldReserved";
static NSString* const kDetailsKeyClearType = @"clearType";
static NSString* const kDetailsKeySettleFlag = @"settleFlag";
static NSString* const kDetailsKeySettleMoney = @"settleMoney";
static NSString* const kDetailsKeyRefuseReason = @"refuseReason";


static NSString* const kMPOSDetailTitleTxnType = @"交易类型";
static NSString* const kMPOSDetailTitleBusiNum = @"商户编号";
static NSString* const kMPOSDetailTitleBusiName = @"商户名称";
static NSString* const kMPOSDetailTitleTransAmount = @"交易金额";
static NSString* const kMPOSDetailTitleCardNum = @"交易卡号";
static NSString* const kMPOSDetailTitleTransDate = @"交易日期";
static NSString* const kMPOSDetailTitleTransTime = @"交易时间";
static NSString* const kMPOSDetailTitleTransState = @"交易状态";
static NSString* const kMPOSDetailTitleOrderNum = @"订单编号";
static NSString* const kMPOSDetailTitleTermNum = @"终端编号";
static NSString* const kMPOSDetailTitleSettleType = @"结算方式";
static NSString* const kMPOSDetailTitleSettleAmount = @"结算金额";
static NSString* const kMPOSDetailTitleSettleState = @"结算状态";
static NSString* const kMPOSDetailTitleRefuse = @"失败原因";


@interface ViewModelMPOSDetails()
<HTTPInstanceDelegate>
{
    BOOL filtered;
    NSString* filterInputed;
}
@property (nonatomic, strong) HTTPInstance* http;
@property (nonatomic, assign) id<ViewModelMPOSDetailsDelegate>delegate;

@property (nonatomic, retain) NSArray* detailsOrigin;
@property (nonatomic, strong) NSMutableArray* detailsDisplayed;


@end

@implementation ViewModelMPOSDetails

- (instancetype)init {
    self = [super init];
    if (self) {
        filtered = NO;
        self.detailsDisplayed = [[NSMutableArray alloc] init];
        
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/getMchntInfo",
                               [PublicInformation getServerDomain],
                               [PublicInformation getHTTPPort]];
        self.http = [[HTTPInstance alloc] initWithURLString:urlString];
    }
    return self;
}

/* 申请明细: 指定类型 */
- (void) requestDetailsWithDelegate:(id<ViewModelMPOSDetailsDelegate>)delegate
                          beginTime:(NSString*)beginTime
                            endTime:(NSString*)endTime
{
    
    self.delegate = delegate;
    [self.http startRequestingWithDelegate:self packingHandle:^(ASIFormDataRequest *http) {
        [http addRequestHeader:@"queryBeginTime" value:beginTime];
        [http addRequestHeader:@"queryEndTime" value:endTime];
        [http addRequestHeader:@"termNo" value:[PublicInformation returnTerminal]];
        [http addRequestHeader:@"mchntNo" value:[PublicInformation returnBusiness]];
    }];
}

/* 终止请求 */
- (void) terminateRequesting {
    [self.http terminateRequesting];
}

/* 清空数据 */
- (void) clearDetails {
    [self clearDetailsDisplayed];
}


#pragma mask ---- HTTPInstanceDelegate
- (void)httpInstance:(HTTPInstance *)httpInstance didRequestingFinishedWithInfo:(NSDictionary *)info {
    self.detailsOrigin = [NSArray arrayWithArray:[info objectForKey:@"MchntInfoList"]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRequestingSuccessful)]) {
        [self.delegate didRequestingSuccessful];
    }
}
- (void)httpInstance:(HTTPInstance *)httpInstance didRequestingFailedWithError:(NSDictionary *)errorInfo {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRequestingFailWithCode:andMessage:)]) {
        [self.delegate didRequestingFailWithCode:[[errorInfo objectForKey:kHTTPInstanceErrorCode] intValue]
                                      andMessage:[errorInfo objectForKey:kHTTPInstanceErrorMessage]];
    }
}

#pragma mask ---- 过滤器操作-public

/* 过滤: 输入为金额或卡号后4位; 返回过滤结果*/
- (BOOL) filterDetailsByInput:(NSString*)input {
    filterInputed = input;
    filtered = [self filteredByInput];
    return filtered;
}

/* 移除过滤器 */
- (void) removeFilter {
    filtered = NO;
}

#pragma mask ---- 过滤器操作-private

/* 校验过滤值 */
- (BOOL) filteredByInput {
    BOOL isFiltered = NO;
    if (self.detailsOrigin && self.detailsOrigin.count > 0) {
        for (NSDictionary* detail in self.detailsOrigin) {
            isFiltered = [self filteringNode:detail];
            if (isFiltered) {
                break;
            }
        }
    }
    return isFiltered;
}

/* 过滤到节点 */
- (BOOL) filteringNode:(NSDictionary*)node {
    BOOL isFiltered = NO;
    isFiltered = [[node objectForKey:kDetailsFilterKeyCardNo] hasSuffix:filterInputed];
    if (!isFiltered) {
        isFiltered = (filterInputed.floatValue == [[node objectForKey:kDetailsFilterKeyAmount] floatValue]);
    }
    return isFiltered;
}


#pragma mask ---- 数据源操作-PUBLIC
/* 准备好获取数据源: 有过滤器的过滤出条件值 */
- (void) prepareSelector {
    [self loadDetailsDisplayed];
}

/* 总笔数 */
- (NSInteger) totalCountOfTrans {
    return [self.detailsDisplayed count];
}
/* 消费笔数 */
- (NSInteger) countOfNormalTrans {
    NSInteger count = 0;
    for (NSInteger i = 0; i < [self totalCountOfTrans]; i++) {
        if ([[self transTypeAtIndex:i] isEqualToString:@"消费"] ) {
            count++;
        }
    }
    return count;
}
/* 撤销笔数 */
- (NSInteger) countofCancelTrans {
    NSInteger count = 0;
    for (NSInteger i = 0; i < [self totalCountOfTrans]; i++) {
        if ([[self transTypeAtIndex:i] isEqualToString:@"消费撤销"] ) {
            count++;
        }
    }
    return count;
}
/* 总金额 */
- (NSString*) totalAmountOfTrans {
    NSInteger totalAmount = 0;
    for (NSInteger i = 0; i < [self totalCountOfTrans]; i++) {
        if ([[self transTypeAtIndex:i] isEqualToString:@"消费"] && // 只计算消费:未撤销、未冲正
            [[self cancelFlagAtIndex:i] integerValue] == 0 &&
            [[self revsalFlagAtIndex:i] integerValue] == 0
            )
        {
            totalAmount += [[self moneyAtIndex:i] integerValue];
        }
    }
    return [NSString stringWithFormat:@"%d",totalAmount];
}

/* 卡号: 指定序号 */
- (NSString*) cardNumAtIndex:(NSInteger)index {
    return [[self nodeDetailAtIndex:index] objectForKey:kDetailsKeyCardNo];
}

/* 金额: 指定序号 */
- (NSString*) moneyAtIndex:(NSInteger)index {
    return [[self nodeDetailAtIndex:index] objectForKey:kDetailsKeyAmount];
}

/* 交易类型: 指定序号 */
- (NSString*) transTypeAtIndex:(NSInteger)index {
    return [[self nodeDetailAtIndex:index] objectForKey:kDetailsKeyTxnType];
}

/* 交易时间8位: 指定序号 */
- (NSString*) transTimeAtIndex:(NSInteger)index {
    NSString* time = [[self nodeDetailAtIndex:index] objectForKey:kDetailsKeyTime];
    time = [NSString stringWithFormat:@"%@:%@:%@",
            [time substringToIndex:2],
            [time substringWithRange:NSMakeRange(2, 2)],
            [time substringFromIndex:4]];
    return time;
}
/* 交易日期: 指定序号 YYYY/MM/DD */
- (NSString*) formatDateAtIndex:(NSInteger)index {
    NSString* dateString = [self transDateAtIndex:index];
    dateString = [NSString stringWithFormat:@"%@/%@/%@",
                  [dateString substringToIndex:4],
                  [dateString substringWithRange:NSMakeRange(4, 2)],
                  [dateString substringFromIndex:4+2]];
    return dateString;
}


/* 交易日期8位: 指定序号 */
- (NSString*) transDateAtIndex:(NSInteger)index {
    return [[self nodeDetailAtIndex:index] objectForKey:kDetailsKeyDate];
}

/* 撤销类型 */
- (NSString*) cancelFlagAtIndex:(NSInteger)index {
    return [[self nodeDetailAtIndex:index] objectForKey:kDetailsKeyCancelFlag];
}

/* 冲正类型 */
- (NSString*) revsalFlagAtIndex:(NSInteger)index {
    return [[self nodeDetailAtIndex:index] objectForKey:kDetailsKeyRevsal_flag];
}



/* 交易详情节点: 指定序号 */
- (NSDictionary*) nodeDetailAtIndex:(NSInteger)index {
    if (NeedPrintLog) {
        NSLog(@"序号[%d]的明细节点{%@}",index,[self.detailsDisplayed objectAtIndex:index]);
    }
    return [self.detailsDisplayed objectAtIndex:index];
}


/* 显示字段名数组: 交易详情 */
+ (NSArray*) titlesNeedDisplayedForNode:(NSDictionary*)detailNode {
    NSMutableArray* titles = [[NSMutableArray alloc] init];
    [titles addObject:kMPOSDetailTitleTxnType];
    [titles addObject:kMPOSDetailTitleBusiNum];
    [titles addObject:kMPOSDetailTitleBusiName];
    [titles addObject:kMPOSDetailTitleTransAmount];
    [titles addObject:kMPOSDetailTitleCardNum];
    [titles addObject:kMPOSDetailTitleTransDate];
    [titles addObject:kMPOSDetailTitleTransTime];
    [titles addObject:kMPOSDetailTitleTransState];
    [titles addObject:kMPOSDetailTitleOrderNum];
    [titles addObject:kMPOSDetailTitleTermNum];
    [titles addObject:kMPOSDetailTitleSettleType];
    
    if ([[detailNode objectForKey:kDetailsKeyClearType] intValue] == 3) { // T+0
        [titles addObject:kMPOSDetailTitleSettleAmount];
        [titles addObject:kMPOSDetailTitleSettleState];
        if ([[detailNode objectForKey:kDetailsKeySettleFlag] intValue] == 2) { // 拒绝结算
            [titles addObject:kMPOSDetailTitleRefuse];
        }
    }

    return titles;
}
/* 显示字段名对应的值 */
+ (NSString*) valueForTitleNeedDisplayed:(NSString*)title ofNode:(NSDictionary*)detailNode {
    NSString* value = nil;
    NSString* key = [[self newTilesAndKeysNeedDisplayed] objectForKey:title];
    value = [detailNode objectForKey:key];
    
    if ([title isEqualToString:kMPOSDetailTitleTransAmount]) { // 交易金额
        value = [PublicInformation dotMoneyFromNoDotMoney:value];
        value = [value stringByAppendingString:@"元"];
    }
    else if ([title isEqualToString:kMPOSDetailTitleCardNum]) { // 卡号
        value = [PublicInformation cuttingOffCardNo:value];
    }
    else if ([title isEqualToString:kMPOSDetailTitleTransTime]) { // 交易时间
        value = [NSString stringWithFormat:@"%@:%@:%@",
                 [value substringToIndex:2],
                 [value substringWithRange:NSMakeRange(2, 2)],
                 [value substringFromIndex:2+2]
                 ];
    }
    else if ([title isEqualToString:kMPOSDetailTitleTransState]) { // 交易状态
        if ([[detailNode objectForKey:kDetailsKeyCancelFlag] intValue] != 0) {
            value = @"已撤销";
        }
        else if ([[detailNode objectForKey:kDetailsKeyRevsal_flag] intValue] != 0) {
            value = @"已冲正";
        }
        else if (value.intValue == 0) {
            value = @"交易成功";
        }
        else {
            value = @"交易失败";
        }
    }
    else if ([title isEqualToString:kMPOSDetailTitleSettleType]) { // 结算方式
        if (value.intValue == 0) {
            value = @"T+1";
        }
        else if (value.intValue == 1) {
            value = @"D+1(商户出手续费)";
        }
        else if (value.intValue == 2) {
            value = @"D+1(代理商出手续费)";
        }
        else if (value.intValue == 3) {
            value = @"T+0";
        }
        else if (value.intValue == 4) {
            value = @"D+0";
        }
    }
    else if ([title isEqualToString:kMPOSDetailTitleSettleState]) { // 结算状态
        if (value.intValue == 0) {
            value = @"已结算";
        }
        else if (value.intValue == 1) {
            value = @"正在结算";
        }
        else if (value.intValue == 2) {
            value = @"结算失败";
        }
    }
    else if ([title isEqualToString:kMPOSDetailTitleSettleAmount]) { // 结算金额:单位为元
        value = [NSString stringWithFormat:@"%.02lf元",value.floatValue];
    }
    else if ([title isEqualToString:kMPOSDetailTitleTransDate]) { // 交易日期
        value = [NSString stringWithFormat:@"%@/%@/%@",
                 [value substringToIndex:4],
                 [value substringWithRange:NSMakeRange(4, 2)],
                 [value substringFromIndex:4+2]
                 ];
    }
    else {
        value = [detailNode objectForKey:key];
    }
    
    return value;
}



#pragma mask ---- 数据源操作-PRIVATE

/* 清空显示列表 */
- (void) clearDetailsDisplayed {
    if (self.detailsDisplayed.count > 0) {
        [self.detailsDisplayed removeAllObjects];
    }
}

/* 加载显示用的明细列表 */
- (void) loadDetailsDisplayed {
    [self clearDetailsDisplayed];
    if (filtered) {
        for (NSDictionary* detail in self.detailsOrigin) {
            if ([self filteringNode:detail]) {
                [self.detailsDisplayed addObject:detail];
            }
        }
    }
    else {
        if (self.detailsOrigin) {
            [self.detailsDisplayed addObjectsFromArray:self.detailsOrigin];
        }
    }
}

+ (NSDictionary*) newTilesAndKeysNeedDisplayed {
    NSMutableDictionary* titlesAndKeys = [[NSMutableDictionary alloc] init];
    [titlesAndKeys setObject:kDetailsKeyTxnType forKey:kMPOSDetailTitleTxnType];
    [titlesAndKeys setObject:kDetailsKeyCardAccpId forKey:kMPOSDetailTitleBusiNum];
    [titlesAndKeys setObject:kDetailsKeyCardAccpName forKey:kMPOSDetailTitleBusiName];
    [titlesAndKeys setObject:kDetailsKeyAmount forKey:kMPOSDetailTitleTransAmount];
    [titlesAndKeys setObject:kDetailsKeyCardNo forKey:kMPOSDetailTitleCardNum];
    [titlesAndKeys setObject:kDetailsKeyDate forKey:kMPOSDetailTitleTransDate];
    [titlesAndKeys setObject:kDetailsKeyTime forKey:kMPOSDetailTitleTransTime];
    [titlesAndKeys setObject:kDetailsKeyRespCode forKey:kMPOSDetailTitleTransState];
    [titlesAndKeys setObject:kDetailsKeyRetrivlRef forKey:kMPOSDetailTitleOrderNum];
    [titlesAndKeys setObject:kDetailsKeyCardAccpTermId forKey:kMPOSDetailTitleTermNum];
    [titlesAndKeys setObject:kDetailsKeyClearType forKey:kMPOSDetailTitleSettleType];
    [titlesAndKeys setObject:kDetailsKeySettleFlag forKey:kMPOSDetailTitleSettleState];
    [titlesAndKeys setObject:kDetailsKeySettleMoney forKey:kMPOSDetailTitleSettleAmount];
    [titlesAndKeys setObject:kDetailsKeyRefuseReason forKey:kMPOSDetailTitleRefuse];
    return titlesAndKeys;
}

@end
