//
//  ViewModelMPOSDetails.m
//  JLPay
//
//  Created by jielian on 15/12/15.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ViewModelMPOSDetails.h"
#import "PublicInformation.h"


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
static NSString* const kDetailsKeyardAccpTermId = @"cardAccpTermId";
static NSString* const kDetailsKeyRetrivlRef = @"retrivlRef";
static NSString* const kDetailsKeyAcqInstIdCode = @"acqInstIdCode";
static NSString* const kDetailsKeyCancelFlag = @"cancelFlag";
static NSString* const kDetailsKeyRevsal_flag = @"revsal_flag";
static NSString* const kDetailsKeyRespCode = @"respCode";
static NSString* const kDetailsKeyFldReserved = @"fldReserved";
static NSString* const kDetailsKeyClearType = @"clearType";
static NSString* const kDetailsKeySettleFlag = @"settleFlag";
static NSString* const kDetailsKeyRefuseReason = @"refuseReason";


@interface ViewModelMPOSDetails()
<HTTPInstanceDelegate>
{
    BOOL filtered;
    NSString* filterInputed;
    NSString* requestBeginTime;
    NSString* requestEndTime;
    NSString* requestTerminal;
    NSString* requestBusiness;
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
                           terminal:(NSString*)terminal
                           business:(NSString*)business
{
    
    self.delegate = delegate;
    requestBeginTime = beginTime;
    requestEndTime = endTime;
    requestTerminal = terminal;
    requestBusiness = business;
    
    [self.http startRequestingWithDelegate:self];
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
- (void)willPackParamsOnRequester:(ASIHTTPRequest *)http {
    [http addRequestHeader:@"queryBeginTime" value:requestBeginTime];
    [http addRequestHeader:@"queryEndTime" value:requestEndTime];
    [http addRequestHeader:@"termNo" value:requestTerminal];
    [http addRequestHeader:@"mchntNo" value:requestBusiness];
}

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
    return [self.detailsDisplayed objectAtIndex:index];
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

@end
