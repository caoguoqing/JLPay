//
//  MOtherPayDetails.m
//  JLPay
//
//  Created by jielian on 16/5/16.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MOtherPayDetails.h"

@implementation MOtherPayDetails

+ (instancetype)sharedOtherPayDetails {
    static MOtherPayDetails* shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[MOtherPayDetails alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addKVOs];
    }
    return self;
}

- (void) addKVOs {
    @weakify(self);
    
    RAC(self, totalMoney) = [RACObserve(self, separatedDetailsOnDates) map:^id(NSArray<NSArray<NSDictionary*>*>* details) {
        CGFloat totalMoney = 0;
        for (NSArray* dateArray in details) {
            for (NSDictionary* node in dateArray) {
                NSString* money = [node objectForKey:kMOtherPayNodeTradeMoney];
                NSString* payType = [node objectForKey:kMOtherPayNodeOrderType];
                NSInteger payState = [[node objectForKey:kMOtherPayNodePayStatus] integerValue];
                NSInteger revoked = [[node objectForKey:kMOtherPayNodeRevokeStatus] integerValue];
                NSInteger reversaled = [[node objectForKey:kMOtherPayNodeReverseStatus] integerValue];
                NSInteger refunded = [[node objectForKey:kMOtherPayNodeRefundStatus] integerValue];
                if ([payType isEqualToString:@"A0"] || [payType isEqualToString:@"W0"]) {
                    if (payState == 0 && revoked != 0 && reversaled != 0 && refunded != 0) {
                        totalMoney += [PublicInformation dotMoneyFromNoDotMoney:money].floatValue;
                    }
                }
            }
        }
        return @(totalMoney);
    }];
    
    RAC(self, allDaysInOriginList) = [RACObserve(self, originDetails) map:^NSArray<NSString*>* (NSArray<NSDictionary*>* details) {
        NSMutableArray* allDays = [NSMutableArray array];
        for (NSDictionary* node in details) {
            NSString* tradeTime = [node objectForKey:kMOtherPayNodeTradeTime];
            tradeTime = [NSString stringWithFormat:@"%@年%@月%@日", [tradeTime substringToIndex:4], [tradeTime substringWithRange:NSMakeRange(4, 2)], [tradeTime substringWithRange:NSMakeRange(6, 2)]];
            if (![allDays containsObject:tradeTime]) {
                [allDays addObject:tradeTime];
            }
        }
        
        return allDays;
    }];
    
    RAC(self, allTransTypesInOriginList) = [RACObserve(self, originDetails) map:^NSArray<NSString*>* (NSArray<NSDictionary*>* details) {
        NSMutableArray* allTypes = [NSMutableArray array];
        for (NSDictionary* node in details) {
            NSString* type = [node objectForKey:kMOtherPayNodeOrderType];
            type = [self payTypeWithCode:type];
            if (![allTypes containsObject:type]) {
                [allTypes addObject:type];
            }
        }
        return allTypes;
    }];
    
    RAC(self, allMoneysInOriginList) = [RACObserve(self, originDetails) map:^NSArray<NSString*>* (NSArray<NSDictionary*>* details) {
        NSMutableArray* allMoneys = [NSMutableArray array];
        for (NSDictionary* node in details) {
            NSString* money = [@"￥" stringByAppendingString:[PublicInformation dotMoneyFromNoDotMoney:[node objectForKey:kMOtherPayNodeTradeMoney]]];
            if (![allMoneys containsObject:money]) {
                [allMoneys addObject:money];
            }
        }

        return allMoneys;
    }];
    
    /* 生成排序组 */
    [RACObserve(self, originDetails) subscribeNext:^(NSArray* details) {
        @strongify(self);
        [self doSiftingOnSelectedIndexs:nil];
    }];

}

# pragma mask 2 model 处理
// -- 日期
- (NSString*) dateAtDateIndex:(NSInteger)dateIndex {
    if (self.separatedDetailsOnDates && self.separatedDetailsOnDates.count > 0) {
        NSArray* dateArray = [self.separatedDetailsOnDates objectAtIndex:dateIndex];
        NSString* dateTime = [dateArray[0] objectForKey:kMOtherPayNodeTradeTime];
        return [dateTime substringToIndex:4+2+2];
    } else {
        return nil;
    }
}

// -- 交易时间: HH:mm:ss
- (NSString*) transTimeAtDateIndex:(NSInteger)dateIndex andInnerIndex:(NSInteger)innerIndex {
    NSArray* dateArray = [self.separatedDetailsOnDates objectAtIndex:dateIndex];
    NSString* dateTime = [dateArray[innerIndex] objectForKey:kMOtherPayNodeTradeTime];
    dateTime = [dateTime substringFromIndex:4+2+2];
    if (!dateTime || dateTime.length < 6) {
        return nil;
    } else {
        return [NSString stringWithFormat:@"%@:%@:%@",
                [dateTime substringToIndex:2],
                [dateTime substringWithRange:NSMakeRange(2, 2)],
                [dateTime substringWithRange:NSMakeRange(4, 2)]];
    }
}

// -- 金额(浮点型): 指定日期序号、内部序号
- (NSString*) moneyAtDateIndex:(NSInteger)dateIndex andInnerIndex:(NSInteger)innerIndex {
    NSArray* dateArray = [self.separatedDetailsOnDates objectAtIndex:dateIndex];
    NSDictionary* node = [dateArray objectAtIndex:innerIndex];
    NSString* money = [PublicInformation dotMoneyFromNoDotMoney:[node objectForKey:kMOtherPayNodeTradeMoney]];
    return [NSString stringWithFormat:@"%.02lf", money.floatValue];
}

// -- 交易类型: 后缀加上撤销、冲正、支付中
- (NSString*) transTypeAtDateIndex:(NSInteger)dateIndex andInnerIndex:(NSInteger)innerIndex {
    NSArray* dateArray = [self.separatedDetailsOnDates objectAtIndex:dateIndex];
    NSDictionary* node = [dateArray objectAtIndex:innerIndex];
    NSString* orderType = [node objectForKey:kMOtherPayNodeOrderType];
    NSInteger payFlag = [[node objectForKey:kMOtherPayNodePayStatus] integerValue];
    NSInteger revokeFlag = [[node objectForKey:kMOtherPayNodeRevokeStatus] integerValue];
    NSInteger reversFlag = [[node objectForKey:kMOtherPayNodeReverseStatus] integerValue];
    NSInteger refundFlag = [[node objectForKey:kMOtherPayNodeRefundStatus] integerValue];
    
    NSString* payType = [self payTypeWithCode:orderType];
    NSString* payState = [self payStateWithResCode:payFlag reverseCode:reversFlag revokeCode:revokeFlag refundCode:refundFlag];
    if (payState && payState.length > 0) {
        payType = [payType stringByAppendingFormat:@"(%@)", payState];
    }
    return payType;
}

// -- 订单编号: 用星号截取
- (NSString*) orderNoAtDateIndex:(NSInteger)dateIndex andInnerIndex:(NSInteger)innerIndex {
    NSArray* dateArray = [self.separatedDetailsOnDates objectAtIndex:dateIndex];
    NSDictionary* node = [dateArray objectAtIndex:innerIndex];

    NSString* orderNo = [node objectForKey:kMOtherPayNodeOrderNo];
    return [orderNo stringCuttingXingInRange:NSMakeRange(6, orderNo.length - 6 - 4)];
}

- (NSString*) payTypeWithCode:(NSString*)code {
    NSString* payType = nil;
    if ([code isEqualToString:@"A0"]) {
        payType = @"支付宝消费";
    }
    else if ([code isEqualToString:@"A1"]) {
        payType = @"支付宝冲正";
    }
    else if ([code isEqualToString:@"A2"]) {
        payType = @"支付宝消费撤销";
    }
    else if ([code isEqualToString:@"W0"]) {
        payType = @"微信消费";
    }
    else if ([code isEqualToString:@"W1"]) {
        payType = @"微信冲正";
    }
    else if ([code isEqualToString:@"W2"]) {
        payType = @"微信消费撤销";
    }
    return payType;
}

- (NSString*) payStateWithResCode:(NSInteger)resCode
                      reverseCode:(NSInteger)reverseCode
                       revokeCode:(NSInteger)revokeCode
                       refundCode:(NSInteger)refundCode {
    NSString* payState = nil;
    if (resCode == 0) {
        if (!reverseCode) {
            payState = @"已冲正";
        }
        else if (!revokeCode) {
            payState = @"已撤销";
        }
        else if (!refundCode) {
            payState = @"已退货";
        }
    }
    else if (resCode == 9) {
        payState = @"支付中";
    }
    else {
        payState = @"支付失败";
    }
    return payState;
}


# pragma mask 2 过滤
// -- 执行过滤: 指定条件序号
- (void) doSiftingOnSelectedIndexs:(NSArray<NSArray<NSNumber*>*>*)selectedIndexs {
    // 先过滤
    [self.siftedDetails removeAllObjects];
    
    BOOL hasIndexs = NO;
    for (NSArray* indexs in selectedIndexs) {
        if (indexs.count > 0) {
            hasIndexs = YES;
            break;
        }
    }
    
    if (hasIndexs) {
        [self.siftedDetails addObjectsFromArray:[self siftedDetailsWithConditions:[self transformatedConditionsBySelecetedIndexs:selectedIndexs]]];
    } else {
        [self.siftedDetails addObjectsFromArray:self.originDetails];
    }
    // 紧接着排序
    self.separatedDetailsOnDates = [self sortedArrayInDatesFromSource:self.siftedDetails];
}

// 1. 转换出所有的过滤条件组
- (NSArray<NSArray<NSString*>*>*) transformatedConditionsBySelecetedIndexs:(NSArray<NSArray<NSNumber *> *> *)selectedIndexs {
    NSMutableArray* transformatedConditions = [NSMutableArray arrayWithCapacity:self.mainSiftTitles.count];
    JLPrint(@"选择到的过滤条件集:[%@]",selectedIndexs);
    
    for (int i = 0; i < selectedIndexs.count; i ++) {
        NSMutableArray* sectionConditions = [NSMutableArray array];
        
        if (i == 0) {           /* 组合条件组: 日期 */
            NSArray* indexs = [selectedIndexs objectAtIndex:i];
            for (NSNumber* index in indexs) {
                NSString* date = [self.allDaysInOriginList objectAtIndex:index.integerValue];
                date = [NSString stringWithFormat:@"%@%@%@",[date substringToIndex:4], [date substringWithRange:NSMakeRange(4+1, 2)], [date substringWithRange:NSMakeRange(4+1+2+1, 2)]];
                [sectionConditions addObject:date];
            }
        }
        else if (i == 1) {      /* 组合条件组: 交易类型 */
            NSArray* indexs = [selectedIndexs objectAtIndex:i];
            for (NSNumber* index in indexs) {
                [sectionConditions addObject:[self.allTransTypesInOriginList objectAtIndex:index.integerValue]];
            }
        }
        else if (i == 2) {      /* 组合条件组: 金额 */
            NSArray* indexs = [selectedIndexs objectAtIndex:i];
            for (NSNumber* index in indexs) {
                NSString* money = [self.allMoneysInOriginList objectAtIndex:index.integerValue];
                money = [PublicInformation intMoneyFromDotMoney:[money substringFromIndex:1]];
                [sectionConditions addObject:money];
            }
        }
        
        [transformatedConditions addObject:sectionConditions];
    }
    JLPrint(@"过滤条件集:[%@]",transformatedConditions);
    return transformatedConditions;
}

// 2. 过滤出结果集
- (NSArray*) siftedDetailsWithConditions:(NSArray<NSArray<NSString*>*>*)transformatedConditions {
    NSMutableArray* siftedDetails = [NSMutableArray array];
    for (NSDictionary* node in self.originDetails) {
        NSString* date = [[node objectForKey:kMOtherPayNodeTradeTime] substringToIndex:8];
        NSString* txnType = [node objectForKey:kMOtherPayNodeOrderType];
        NSString* money = [node objectForKey:kMOtherPayNodeTradeMoney];
        
        NSArray* dateConArray = [transformatedConditions objectAtIndex:0];
        NSArray* txnTypeConArray = [transformatedConditions objectAtIndex:1];
        NSArray* moneyConArray = [transformatedConditions objectAtIndex:2];
        
        BOOL dateSifed = NO;
        BOOL txnTypeSifed = NO;
        BOOL moneySifed = NO;
        
        if (!dateConArray || dateConArray.count == 0) {
            dateSifed = YES;
        } else {
            for (NSString* dateInCon in dateConArray) {
                if ([dateInCon isEqualToString:date]) {
                    dateSifed = YES;
                    break;
                }
            }
        }
        
        if (dateSifed) {
            if (!txnTypeConArray || txnTypeConArray.count == 0) {
                txnTypeSifed = YES;
            } else {
                for (NSString* txnTypeInCon in txnTypeConArray) {
                    if ([txnTypeInCon isEqualToString:[self payTypeWithCode:txnType]]) {
                        txnTypeSifed = YES;
                        break;
                    }
                }
            }
        }
        if (txnTypeSifed) {
            if (!moneyConArray || moneyConArray.count == 0) {
                moneySifed = YES;
            } else {
                for (NSString* moneyInCon in moneyConArray) {
                    if ([moneyInCon isEqualToString:money]) {
                        moneySifed = YES;
                        break;
                    }
                }
            }
        }
        
        if (dateSifed && txnTypeSifed && moneySifed) {
            [siftedDetails addObject:node];
        }
    }
    
    return siftedDetails;
}

# pragma mask 3 排序
- (NSArray*) sortedArrayInDatesFromSource:(NSArray*)source {
    NSMutableArray* sortedArrayInDates = [NSMutableArray array];
    /* 1. 按日期建组 */
    for (NSDictionary* node in source) {
        [self insertIntoDateArrayWithNode:node byArray:sortedArrayInDates];
    }
    /* 2. 排序日期组内部序 */
    for (NSMutableArray* dateArray in sortedArrayInDates) {
        [self sortingOrderedDescendingTimeOnArray:dateArray];
    }
    /* 3. 排序日期组序 */
    [self sortingOrderedDescendingDateOnArray:sortedArrayInDates];
    return sortedArrayInDates;
}

- (void) insertIntoDateArrayWithNode:(NSDictionary*)node byArray:(NSMutableArray*)array {
    /* new date array if not exists, and inset it */
    NSString* date = [[node objectForKey:kMOtherPayNodeTradeTime] substringToIndex:4+2+2];
    NSMutableArray* existDateArray = nil;
    for (NSMutableArray* dateArray in array) {
        if ([date isEqualToString:[[[dateArray objectAtIndex:0] objectForKey:kMOtherPayNodeTradeTime] substringToIndex:4+2+2]]) {
            existDateArray = dateArray;
            break;
        }
    }
    if (!existDateArray) {
        existDateArray = [NSMutableArray array];
        [array addObject:existDateArray];
    }
    [existDateArray addObject:node];
}

- (void) sortingOrderedDescendingTimeOnArray:(NSMutableArray*)array {
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString* time1 = [[obj1 objectForKey:kMOtherPayNodeTradeTime] substringFromIndex:4+2+2];
        NSString* time2 = [[obj2 objectForKey:kMOtherPayNodeTradeTime] substringFromIndex:4+2+2];
        return [time1 compare:time2] == NSOrderedDescending; // 升序
    }];
}
- (void) sortingOrderedDescendingDateOnArray:(NSMutableArray*)array {
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString* date1 = [[[obj1 objectAtIndex:0] objectForKey:kMOtherPayNodeTradeTime] substringToIndex:4+2+2];
        NSString* date2 = [[[obj2 objectAtIndex:0] objectForKey:kMOtherPayNodeTradeTime] substringToIndex:4+2+2];
        return [date1 compare:date2] == NSOrderedAscending; // 降序
    }];
}

# pragma mask 4 getter

- (NSArray *)mainSiftTitles {
    if (!_mainSiftTitles) {
        _mainSiftTitles = @[@"日期",@"交易类型",@"金额"];
    }
    return _mainSiftTitles;
}
- (NSMutableArray *)siftedDetails {
    if (!_siftedDetails) {
        _siftedDetails = [NSMutableArray array];
    }
    return _siftedDetails;
}


@end
