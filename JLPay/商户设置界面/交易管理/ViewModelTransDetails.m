//
//  ViewModelTransDetails.m
//  JLPay
//
//  Created by jielian on 15/11/12.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ViewModelTransDetails.h"
#import "ASIFormDataRequest.h"
#import "TransDetailsViewController.h"
#import "PublicInformation.h"


@interface ViewModelTransDetails()<ASIHTTPRequestDelegate>
{
    BOOL filter;
}

@property (nonatomic, strong) NSString* platformName;
@property (nonatomic, retain) ASIFormDataRequest* http;
@property (nonatomic, strong) NSMutableArray* transDetails;
@property (nonatomic, strong) NSMutableArray* filterDetails;

@property (nonatomic, assign) id<ViewModelTransDetailsDelegate> delegate;


@end



@implementation ViewModelTransDetails


#pragma mask ---- PUBLIC INTERFACE
/* 申请明细: 指定类型 */
- (void) requestDetailsWithPlatform:(NSString*)platform
                        andDelegate:(id<ViewModelTransDetailsDelegate>)delegate
                          beginTime:(NSString*)beginTime
                            endTime:(NSString*)endTime
                           terminal:(NSString*)terminal
                          bussiness:(NSString*)bussiness
{
    self.platformName = platform;
    self.delegate = delegate;
    
    self.http = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[self urlStringWithPlatform:platform]]];
    [self.http setDelegate:self];
    if ([platform isEqualToString:NameTradePlatformMPOSSwipe]) {
        [self.http addRequestHeader:@"queryBeginTime" value:beginTime];
        [self.http addRequestHeader:@"queryEndTime" value:endTime];
        [self.http addRequestHeader:@"termNo" value:terminal];
        [self.http addRequestHeader:@"mchntNo" value:bussiness];
    }
    else if ([platform isEqualToString:NameTradePlatformOtherPay]) {
        [self.http addPostValue:beginTime forKey:@"queryBeginTime"];
        [self.http addPostValue:endTime forKey:@"queryEndTime"];
        [self.http addPostValue:terminal forKey:@"termNo"];
        [self.http addPostValue:bussiness forKey:@"mchntNo"];
    }
    
    [self.transDetails removeAllObjects];
    [self.filterDetails removeAllObjects];
    [self.http startAsynchronous];
    
}
- (NSString*) urlStringWithPlatform:(NSString*)platform {
    NSString* url = nil;
    if ([platform isEqualToString:NameTradePlatformMPOSSwipe]) {
        url = [NSString stringWithFormat:@"http://%@:%@/jlagent/getMchntInfo",
               [PublicInformation getServerDomain], [PublicInformation getHTTPPort]];
    }
    else if ([platform isEqualToString:NameTradePlatformOtherPay]) {
        url = [NSString stringWithFormat:@"http://%@:%@/jlagent/getTradeDetail",
               [PublicInformation getServerDomain], [PublicInformation getHTTPPort]];
    }
    return url;
}

/* 终止请求 */
- (void) terminateRequesting {
    [self.http clearDelegatesAndCancel];
}



/* 清空数据 */
- (void) clearDetails
{
    if (self.transDetails && self.transDetails.count > 0) {
        [self.transDetails removeAllObjects];
    }
    if (self.filterDetails && self.filterDetails.count > 0) {
        [self.filterDetails removeAllObjects];
    }
    [self.http clearDelegatesAndCancel];
    filter = NO;
}


/* 过滤: 输入为金额或卡号后4位 */
- (BOOL) filterDetailsByInput:(NSString*)input
{
    BOOL filterReuslt = YES;
    filter = NO;
    [self.filterDetails removeAllObjects];
    
    // 将所有匹配上卡号后4位的节点追加到过滤数组
    for (int i = 0; i < [self totalCountOfTrans]; i++) {
        NSString* cardNum = [self cardNumAtIndex:i];
        if ([cardNum hasSuffix:input]) {
            [self.filterDetails addObject:[self.transDetails objectAtIndex:i]];
        }
    }
    // 第一步查询为空才进行下一步查询
    if (self.filterDetails.count == 0) {
        // 将所有匹配上金额的节点追加到过滤数组
        for (int i = 0; i < [self totalCountOfTrans]; i++) {
            NSString* amount = [self moneyAtIndex:i];
            if (amount.floatValue == input.floatValue) {
                [self.filterDetails addObject:[self.transDetails objectAtIndex:i]];
            }
        }
    }
    
    if (self.filterDetails.count == 0) {
        filterReuslt = NO;
    }
    filter = YES;
    return filterReuslt;
}

/* 总笔数 */
- (NSInteger) totalCountOfTrans
{
    NSInteger count = 0;
    if (!filter) {
        count = self.transDetails.count;
    } else {
        count = self.filterDetails.count;
    }
    return count;
}
/* 消费笔数 */
- (NSInteger) countOfNormalTrans
{
    NSInteger count = 0;
    if ([self.platformName isEqualToString:NameTradePlatformMPOSSwipe]) {
        for (int i = 0; i < [self totalCountOfTrans]; i++) {
            NSString* transType = [self transTypeAtIndex:i];
            if ([transType isEqualToString:@"消费"] ) {
                count++;
            }
        }
    }
    else if ([self.platformName isEqualToString:NameTradePlatformOtherPay]) {
        count = [self totalCountOfTrans];
    }
    return count;
}
/* 撤销笔数 */
- (NSInteger) countofCancelTrans
{
    NSInteger count = 0;
    if ([self.platformName isEqualToString:NameTradePlatformMPOSSwipe]) {
        for (int i = 0; i < [self totalCountOfTrans]; i++) {
            NSString* transType = [self transTypeAtIndex:i];
            if ([transType isEqualToString:@"消费撤销"] ) {
                count++;
            }
        }
    }
    return count;
}
/* 总金额 */
- (double) totalAmountOfTrans
{
    double amount = 0.0;
    if ([self.platformName isEqualToString:NameTradePlatformMPOSSwipe]) {
        for (int i = 0; i < [self totalCountOfTrans]; i++) {
            NSString* transType = [self transTypeAtIndex:i];
            if ([transType isEqualToString:@"消费"] &&  // 只有未撤销未冲正的成功消费才计入总金额
                ![self cancelFlagAtIndex:i] &&
                ![self revsalFlagAtIndex:i]
                )
            {
                amount += [self moneyAtIndex:i].floatValue;
            }
        }
    }
    else if ([self.platformName isEqualToString:NameTradePlatformOtherPay]) {
        for (int i = 0; i < [self totalCountOfTrans]; i++) {
            amount += [self moneyAtIndex:i].floatValue;
        }
    }
    return amount;
}


/* 条数 */
- (NSInteger) countOfDetails
{
    NSInteger count = 0;
    if (!filter) {
        count = self.transDetails.count;
    } else {
        count = self.filterDetails.count;
    }
    return count;
}

/* 卡号: 指定序号 */
- (NSString*) cardNumAtIndex:(NSInteger)index
{
    NSString* cardNum = nil;
    NSDictionary* dataNode = nil;
    if (!filter) {
        dataNode = [self.transDetails objectAtIndex:index];
    } else {
        dataNode = [self.filterDetails objectAtIndex:index];
    }
    if ([self.platformName isEqualToString:NameTradePlatformMPOSSwipe]) {
        if (dataNode) {
            cardNum = [dataNode valueForKey:@"pan"];
            cardNum = [PublicInformation cuttingOffCardNo:cardNum];
        }
    }
    else if ([self.platformName isEqualToString:NameTradePlatformOtherPay]) {
        // 第三方支付没有卡号，用渠道类型展示
        if (dataNode) {
            cardNum = [dataNode valueForKey:@"channelType"];
            if ([[cardNum substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"3"]) {
                cardNum = @"微信";
            }
            else if ([[cardNum substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"4"]) {
                cardNum = @"支付宝";
            }
        }
    }
    return cardNum;
}

/* 金额: 指定序号 */
- (NSString*) moneyAtIndex:(NSInteger)index
{
    NSString* money = nil;
    NSDictionary* dataNode = nil;
    if (!filter) {
        dataNode = [self.transDetails objectAtIndex:index];
    } else {
        dataNode = [self.filterDetails objectAtIndex:index];
    }
    NSString* key = nil;
    if ([self.platformName isEqualToString:NameTradePlatformMPOSSwipe]) {
        key = @"amtTrans";
    }
    else if ([self.platformName isEqualToString:NameTradePlatformOtherPay]) {
        key = @"amtTrans";
    }
    if (dataNode) {
        money = [dataNode valueForKey:key];
        money = [PublicInformation dotMoneyFromNoDotMoney:money];
    }
    return money;
}

/* 交易类型: 指定序号 */
- (NSString*) transTypeAtIndex:(NSInteger)index
{
    NSString* transType = nil;
    NSDictionary* dataNode = nil;
    if (!filter) {
        dataNode = [self.transDetails objectAtIndex:index];
    } else {
        dataNode = [self.filterDetails objectAtIndex:index];
    }
    NSString* key = nil;
    if ([self.platformName isEqualToString:NameTradePlatformMPOSSwipe]) {
        key = @"txnNum";
    }
    else if ([self.platformName isEqualToString:NameTradePlatformOtherPay]) {
        key = @"txnNum";
    }
    if (dataNode) {
        transType = [dataNode valueForKey:key];
    }
    return transType;
}

/* 交易时间6位: 指定序号 */
- (NSString*) transTimeAtIndex:(NSInteger)index
{
    NSString* transTime = nil;
    NSDictionary* dataNode = nil;
    if (!filter) {
        dataNode = [self.transDetails objectAtIndex:index];
    } else {
        dataNode = [self.filterDetails objectAtIndex:index];
    }
    NSString* key = nil;
    if ([self.platformName isEqualToString:NameTradePlatformMPOSSwipe]) {
        key = @"instTime";
    }
    else if ([self.platformName isEqualToString:NameTradePlatformOtherPay]) {
        key = @"instTime";
    }
    if (dataNode) {
        transTime = [dataNode valueForKey:key];
        NSString* formatTime = [NSString stringWithFormat:@"%@:%@:%@",[transTime substringToIndex:2],[transTime substringWithRange:NSMakeRange(2, 2)],[transTime substringFromIndex:4]];
        transTime = formatTime;
    }
    return transTime;
}

/* 交易日期8位: 指定序号 */
- (NSString*) transDateAtIndex:(NSInteger)index
{
    NSString* transDate = nil;
    NSDictionary* dataNode = nil;
    if (!filter) {
        dataNode = [self.transDetails objectAtIndex:index];
    } else {
        dataNode = [self.filterDetails objectAtIndex:index];
    }
    NSString* key = nil;
    if ([self.platformName isEqualToString:NameTradePlatformMPOSSwipe]) {
        key = @"instDate";
    }
    else if ([self.platformName isEqualToString:NameTradePlatformOtherPay]) {
        key = @"instDate";
    }
    if (dataNode) {
        transDate = [dataNode valueForKey:key];
    }
    return transDate;
}

#pragma mask ---- PRIVATE INTERFACE
/* 撤销标志 */
- (BOOL) cancelFlagAtIndex:(NSInteger)index{
    BOOL isCanceled = NO;
    NSDictionary* dataNode = nil;
    if (!filter) {
        dataNode = [self.transDetails objectAtIndex:index];
    } else {
        dataNode = [self.filterDetails objectAtIndex:index];
    }
    if ([self.platformName isEqualToString:NameTradePlatformMPOSSwipe]) {
        NSString* cancelFlag = [dataNode valueForKey:@"cancelFlag"];
        if (cancelFlag.intValue != 0) {
            isCanceled = YES;
        }
    }
    return isCanceled;
}
/* 冲正标志 */
- (BOOL) revsalFlagAtIndex:(NSInteger)index {
    BOOL isRevsal = NO;
    NSDictionary* dataNode = nil;
    if (!filter) {
        dataNode = [self.transDetails objectAtIndex:index];
    } else {
        dataNode = [self.filterDetails objectAtIndex:index];
    }
    if ([self.platformName isEqualToString:NameTradePlatformMPOSSwipe]) {
        NSString* revsalFlag = [dataNode valueForKey:@"revsal_flag"];
        if (revsalFlag.intValue != 0) {
            isRevsal = YES;
        }
    }
    return isRevsal;
}

/* 交易详情节点: 指定序号 */
- (NSDictionary*) nodeDetailAtIndex:(NSInteger)index {
    NSDictionary* node = nil;
    if (!filter) {
        node = [self.transDetails objectAtIndex:index];
    } else {
        node = [self.filterDetails objectAtIndex:index];
    }
    return node;
}




#pragma mask ---- ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSData* responseData = [request responseData];
    NSDictionary* httpResponseHeaders = [request responseHeaders];

    [request clearDelegatesAndCancel];
    NSDictionary* dataDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
    if (!dataDict) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(viewModel:didRequestResult:withMessage:)]) {
            [self.delegate viewModel:self didRequestResult:NO withMessage:@"解析响应数据失败"];
        }
    } else {
        NSString* retcode = [httpResponseHeaders valueForKey:@"HttpResult"];
        if ([retcode intValue] != 0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(viewModel:didRequestResult:withMessage:)]) {
                [self.delegate viewModel:self didRequestResult:NO withMessage:[httpResponseHeaders valueForKey:@"HttpMessage"]];
            }
        } else {
            NSArray* requestArray = nil;
            if ([self.platformName isEqualToString:NameTradePlatformMPOSSwipe]) {
                requestArray = [dataDict valueForKey:@"MchntInfoList"];
            }
            else if ([self.platformName isEqualToString:NameTradePlatformOtherPay]) {
                requestArray = [dataDict valueForKey:@"DetailList"];
            }
            if (!requestArray || requestArray.count == 0) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(viewModel:didRequestResult:withMessage:)]) {
                    [self.delegate viewModel:self didRequestResult:NO withMessage:@"交易明细为空"];
                }
            } else {
                [self.transDetails addObjectsFromArray:requestArray];
                if (self.delegate && [self.delegate respondsToSelector:@selector(viewModel:didRequestResult:withMessage:)]) {
                    [self.delegate viewModel:self didRequestResult:YES withMessage:nil];
                }
            }
        }
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request {
    [request clearDelegatesAndCancel];
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewModel:didRequestResult:withMessage:)]) {
        [self.delegate viewModel:self didRequestResult:NO withMessage:@"网络异常，请检查网络"];
    }
}

#pragma mask ---- 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        filter = NO;
    }
    return self;
}
- (void)dealloc {
    self.delegate = nil;
    if (self.http) {
        [self.http clearDelegatesAndCancel];
    }
}

#pragma mask ---- getter 
- (NSMutableArray *)transDetails {
    if (_transDetails == nil) {
        _transDetails = [[NSMutableArray alloc] init];
    }
    return _transDetails;
}
- (NSMutableArray *)filterDetails {
    if (_filterDetails == nil) {
        _filterDetails = [[NSMutableArray alloc] init];
    }
    return _filterDetails;
}
@end
