//
//  MMposDetails.m
//  JLPay
//
//  Created by jielian on 16/5/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MMposDetails.h"

@implementation MMposDetails

+ (instancetype) sharedMposDetails {
    static MMposDetails* sharedIns;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedIns = [[MMposDetails alloc] init];
    });
    return sharedIns;
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
    
    /* binding: 总金额 */
    RAC(self, totalMoney) = [RACObserve(self, separatedDetailsOnDates) map:^NSNumber* (NSArray* details) {
        CGFloat totalMoney = 0;
        if (details) {
            for (NSArray* sectionDetails in details) {
                for (NSDictionary* node in sectionDetails) {
                    NSString* money = [node objectForKey:kMMposNodeMoney];
                    NSString* transType = [node objectForKey:kMMposNodeTxnType];
                    NSInteger payState = [[node objectForKey:kMMposNodeRespCode] integerValue];
                    NSInteger revoked = [[node objectForKey:kMMposNodeCancelFlag] integerValue];
                    NSInteger reversaled = [[node objectForKey:kMMposNodeRevsal_flag] integerValue];
                    if ([transType isEqualToString:@"消费"] && payState == 0 && revoked != 1 && reversaled != 1) {
                        totalMoney += [PublicInformation dotMoneyFromNoDotMoney:money].floatValue;
                    }
                }
            }
        }
        return @(totalMoney);
    }];
    
    /* binding: 所有的交易日期 */
    RAC(self, allDaysInOriginList) = [RACObserve(self, originDetails) map:^NSArray* (NSArray* details) {
        NSMutableArray* allDays = [NSMutableArray array];
        for (NSDictionary* node in details) {
            NSString* date = [node objectForKey:kMMposNodeDate];
            date = [NSString stringWithFormat:@"%@年%@月%@日",
                    [date substringToIndex:4],
                    [date substringWithRange:NSMakeRange(4, 2)],
                    [date substringWithRange:NSMakeRange(6, 2)]];
            
            if (![allDays containsObject:date]) {
                [allDays addObject:date];
            }
        }
        return allDays;
    }];
    
    /* binding: 所有的卡号 */
    RAC(self, allCardNosInOriginList) = [RACObserve(self, originDetails) map:^NSArray* (NSArray* details) {
        NSMutableArray* allCardNos = [NSMutableArray array];
        
        for (NSDictionary* node in details) {
            NSString* cardNo = [PublicInformation cuttingOffCardNo:[node objectForKey:kMMposNodeCardNo]];
            if (![allCardNos containsObject:cardNo]) {
                [allCardNos addObject:cardNo];
            }
        }
        
        return allCardNos;
    }];
    
    /* binding: 所有的交易类型 */
    RAC(self, allTransTypesInOriginList) = [RACObserve(self, originDetails) map:^NSArray* (NSArray* details) {
        NSMutableArray* allTranTypes = [NSMutableArray array];
        for (NSDictionary* node in details) {
            NSString* transType = [node objectForKey:kMMposNodeTxnType];
            if (![allTranTypes containsObject:transType]) {
                [allTranTypes addObject:transType];
            }
        }
        return allTranTypes;
    }];
    
    /* binding: 所有的金额 */
    RAC(self, allMoneysInOriginList) = [RACObserve(self, originDetails) map:^NSArray* (NSArray* details) {
        NSMutableArray* allMoneys = [NSMutableArray array];
        for (NSDictionary* node in details) {
            NSString* money = [@"￥" stringByAppendingString:[PublicInformation dotMoneyFromNoDotMoney:[node objectForKey:kMMposNodeMoney]]];
            if (![allMoneys containsObject:money]) {
                [allMoneys addObject:money];
            }
        }
        return allMoneys;
    }];
    
    /* observing: 排序组 */
    [RACObserve(self, originDetails) subscribeNext:^(NSArray* details) {
        @strongify(self);
        [self doSiftingOnSelectedIndexs:nil];
    }];
}


# pragma mask 1 public interface

// -- 日期
- (NSString*) dateAtDateIndex:(NSInteger)dateIndex {
    NSArray* detailsInDate = [self.separatedDetailsOnDates objectAtIndex:dateIndex];
    return [[detailsInDate objectAtIndex:0] objectForKey:kMMposNodeDate];
}

// -- 金额: 指定日期序号、内部序号
- (NSString*) moneyAtDateIndex:(NSInteger)dateIndex andInnerIndex:(NSInteger)innerIndex {
    NSArray* detailsInDate = [self.separatedDetailsOnDates objectAtIndex:dateIndex];
    NSDictionary* detailDode = [detailsInDate objectAtIndex:innerIndex];
    NSString* money = [PublicInformation dotMoneyFromNoDotMoney:[detailDode objectForKey:kMMposNodeMoney]];
    return [NSString stringWithFormat:@"%.02lf", money.floatValue];
}

// -- 交易类型: 后缀加上撤销、冲正、退货
- (NSString*) transTypeAtDateIndex:(NSInteger)dateIndex andInnerIndex:(NSInteger)innerIndex {
    NSArray* detailsInDate = [self.separatedDetailsOnDates objectAtIndex:dateIndex];
    NSDictionary* detailDode = [detailsInDate objectAtIndex:innerIndex];
    NSString* transType = [detailDode objectForKey:kMMposNodeTxnType];
    if ([[detailDode objectForKey:kMMposNodeCancelFlag] integerValue] == 1) {
        transType = [transType stringByAppendingString:@" (已撤销)"];
    }
    else if ([[detailDode objectForKey:kMMposNodeRevsal_flag] integerValue] == 1) {
        transType = [transType stringByAppendingString:@" (已冲正)"];
    }
    return transType;
}

// -- 卡号: 用星号截取
- (NSString*) cardNoAtDateIndex:(NSInteger)dateIndex andInnerIndex:(NSInteger)innerIndex {
    NSArray* detailsInDate = [self.separatedDetailsOnDates objectAtIndex:dateIndex];
    NSDictionary* detailDode = [detailsInDate objectAtIndex:innerIndex];
    NSString* cardNo = [detailDode objectForKey:kMMposNodeCardNo];
    if (cardNo && cardNo.length > 6 + 4) {
        cardNo = [PublicInformation cuttingOffCardNo:cardNo];
    }
    return cardNo;
}

// -- 交易时间: HH:mm:ss
- (NSString*) transTimeAtDateIndex:(NSInteger)dateIndex andInnerIndex:(NSInteger)innerIndex {
    NSArray* detailsInDate = [self.separatedDetailsOnDates objectAtIndex:dateIndex];
    NSDictionary* detailDode = [detailsInDate objectAtIndex:innerIndex];
    NSString* transTime = [detailDode objectForKey:kMMposNodeTime];
    if (transTime && transTime.length >= 6) {
        transTime = [NSString stringWithFormat:@"%@:%@:%@",
                     [transTime substringToIndex:2],
                     [transTime substringWithRange:NSMakeRange(2, 2)],
                     [transTime substringWithRange:NSMakeRange(4, 2)]];
    }
    return transTime;
}



# pragma mask 2 过滤

- (void) doSiftingOnSelectedIndexs:(NSArray<NSArray<NSNumber *> *> *)selectedIndexs {
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
        else if (i == 1) {      /* 组合条件组: 卡号 */
            NSArray* indexs = [selectedIndexs objectAtIndex:i];
            for (NSNumber* index in indexs) {
                [sectionConditions addObject:[self.allCardNosInOriginList objectAtIndex:index.integerValue]];
            }

        }
        else if (i == 2) {      /* 组合条件组: 交易类型 */
            NSArray* indexs = [selectedIndexs objectAtIndex:i];
            for (NSNumber* index in indexs) {
                [sectionConditions addObject:[self.allTransTypesInOriginList objectAtIndex:index.integerValue]];
            }

        }
        else if (i == 3) {      /* 组合条件组: 金额 */
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
        BOOL sifted = YES;
        NSString* date = [node objectForKey:kMMposNodeDate];
        NSString* cardNo = [node objectForKey:kMMposNodeCardNo];
        NSString* txnType = [node objectForKey:kMMposNodeTxnType];
        NSString* money = [node objectForKey:kMMposNodeMoney];
        
        NSArray* datesCon = [transformatedConditions objectAtIndex:0];
        if (sifted && datesCon && datesCon.count > 0) {
            sifted = NO;
            for (NSString* dateCon in datesCon) {
                if ([dateCon isEqualToString:date]) {
                    sifted = YES;
                    break;
                }
            }
        }
        
        NSArray* cardNosCon = [transformatedConditions objectAtIndex:1];
        if (sifted && cardNosCon && cardNosCon.count > 0) {
            sifted = NO;
            for (NSString* cardNoCon in cardNosCon) {
                if ([cardNoCon isEqualToString:[PublicInformation cuttingOffCardNo:cardNo]]) {
                    sifted = YES;
                    break;
                }
            }
        }
        
        NSArray* txnTypesCon = [transformatedConditions objectAtIndex:2];
        if (sifted && txnTypesCon && txnTypesCon.count > 0) {
            sifted = NO;
            for (NSString* txnTypeCon in txnTypesCon) {
                if ([txnTypeCon isEqualToString:txnType]) {
                    sifted = YES;
                    break;
                }
            }
        }
        
        NSArray* moneysCon = [transformatedConditions objectAtIndex:3];
        if (sifted && moneysCon && moneysCon.count > 0) {
            sifted = NO;
            for (NSString* moneyCon in moneysCon) {
                if (moneyCon.integerValue == money.integerValue) {
                    sifted = YES;
                    break;
                }
            }
        }
        
        if (sifted) {
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
    NSString* date = [node objectForKey:kMMposNodeDate];
    NSMutableArray* existDateArray = nil;
    for (NSMutableArray* dateArray in array) {
        if ([date isEqualToString:[[dateArray objectAtIndex:0] objectForKey:kMMposNodeDate]]) {
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
        NSString* time1 = [obj1 objectForKey:kMMposNodeTime];
        NSString* time2 = [obj2 objectForKey:kMMposNodeTime];
        return [time1 compare:time2] == NSOrderedDescending; // 升序
    }];
}
- (void) sortingOrderedDescendingDateOnArray:(NSMutableArray*)array {
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString* date1 = [[obj1 objectAtIndex:0] objectForKey:kMMposNodeDate];
        NSString* date2 = [[obj2 objectAtIndex:0] objectForKey:kMMposNodeDate];
        return [date1 compare:date2] == NSOrderedAscending; // 降序
    }];
}


# pragma mask 4 getter

- (NSArray *)mainSiftTitles {
    if (!_mainSiftTitles) {
        _mainSiftTitles = @[@"日期",@"卡号",@"交易类型",@"金额"];
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
