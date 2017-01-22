//
//  TLVC_vmListFilter.m
//  JLPay
//
//  Created by jielian on 2017/1/13.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "TLVC_vmListFilter.h"
#import <ReactiveCocoa.h>
#import "TLVC_mDetailMpos.h"
#import "Define_Header.h"

@interface TLVC_vmListFilter()

// 保存已选择的过滤条件
@property (nonatomic, strong) NSMutableArray* listFilterDates;
@property (nonatomic, strong) NSMutableArray* listFilterCardNos;
@property (nonatomic, strong) NSMutableArray* listFilterTransTypes;
@property (nonatomic, strong) NSMutableArray* listFilterTransMoneys;

@end


@implementation TLVC_vmListFilter

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addKVO];
    }
    return self;
}


- (void) addKVO {
    /* 生成副选项数据源-当更新了源数据 */
    @weakify(self);
    RAC(self, subItems) = [RACObserve(self, originList) map:^id(NSArray* originList) {
        NSMutableArray* dates = [NSMutableArray array];
        NSMutableArray* cardNos = [NSMutableArray array];
        NSMutableArray* transTypes = [NSMutableArray array];
        NSMutableArray* transMoneys = [NSMutableArray array];
        
        [originList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            TLVC_mDetailMpos* mposNode = (TLVC_mDetailMpos*)obj;
            if (![dates containsObject:[self transformedWithDate:mposNode.instDate]]) {
                [dates addObject:[self transformedWithDate:mposNode.instDate]];
            }
            if (![cardNos containsObject:[self transformedWithCardNo:mposNode.pan]]) {
                [cardNos addObject:[self transformedWithCardNo:mposNode.pan]];
            }
            if (![transTypes containsObject:mposNode.txnNum]) {
                [transTypes addObject:mposNode.txnNum];
            }
            if (![transMoneys containsObject:[self transformedWithMoney:mposNode.amtTrans]]) {
                [transMoneys addObject:[self transformedWithMoney:mposNode.amtTrans]];
            }
        }];
        
        return @[dates, cardNos, transTypes, transMoneys];
    }];
    
    // 源数据更新，过滤数据也要更新
    RAC(self, filteredList) = RACObserve(self, originList);
    
}


# pragma mask 2 tools

- (void) conditionsWithFiltered {
    [self.listFilterDates removeAllObjects];
    [self.listFilterCardNos removeAllObjects];
    [self.listFilterTransTypes removeAllObjects];
    [self.listFilterTransMoneys removeAllObjects];

    for (int i = 0; i < self.subItems[0].count; i++) {
        if ([[[self.filteredIndexes objectAtIndex:0] objectAtIndex:i] boolValue])
            [self.listFilterDates addObject:[self.subItems[0] objectAtIndex:i]];
    }
    for (int i = 0; i < self.subItems[1].count; i++) {
        if ([[[self.filteredIndexes objectAtIndex:1] objectAtIndex:i] boolValue])
            [self.listFilterCardNos addObject:[self.subItems[1] objectAtIndex:i]];
    }
    for (int i = 0; i < self.subItems[2].count; i++) {
        if ([[[self.filteredIndexes objectAtIndex:2] objectAtIndex:i] boolValue])
            [self.listFilterTransTypes addObject:[self.subItems[2] objectAtIndex:i]];
    }
    for (int i = 0; i < self.subItems[3].count; i++) {
        if ([[[self.filteredIndexes objectAtIndex:3] objectAtIndex:i] boolValue])
            [self.listFilterTransMoneys addObject:[self.subItems[3] objectAtIndex:i]];
    }
}

/* 转译: 日期 */
- (NSString*) transformedWithDate:(NSString*)date {
    return [NSString stringWithFormat:@"%@年%@月%@日",
            [date substringWithRange:NSMakeRange(0, 4)],
            [date substringWithRange:NSMakeRange(4, 2)],
            [date substringWithRange:NSMakeRange(6, 2)]];
}
/* 转译: 日期 */
- (NSString*) transformedWithCardNo:(NSString*)cardNo {
    return [PublicInformation cuttingOffCardNo:cardNo];
}
/* 转译: 日期 */
- (NSString*) transformedWithMoney:(NSString*)money {
    return [NSString stringWithFormat:@"￥%@", [PublicInformation dotMoneyFromNoDotMoney:money]];
}


# pragma mask 4 getter
- (RACCommand *)cmd_filtering {
    if (!_cmd_filtering) {
        @weakify(self);
        _cmd_filtering = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                
                /* 执行过滤:  */
                NSMutableArray* filteredList = [NSMutableArray array];
                [self conditionsWithFiltered];
                for (TLVC_mDetailMpos* node in self.originList) {
                    /* 子选项 */
                    BOOL enableDa = self.listFilterDates.count > 0 ? [self.listFilterDates containsObject:[self transformedWithDate:node.instDate]] : YES;
                    BOOL enableCa = self.listFilterCardNos.count > 0 ? [self.listFilterCardNos containsObject:[self transformedWithCardNo:node.pan]] : YES;
                    BOOL enableTy = self.listFilterTransTypes.count > 0 ? [self.listFilterTransTypes containsObject:node.txnNum] : YES;
                    BOOL enableTm = self.listFilterTransMoneys.count > 0 ? [self.listFilterTransMoneys containsObject:[self transformedWithMoney:node.amtTrans]] : YES;

                    if (enableDa && enableCa && enableTy && enableTm) {
                        [filteredList addObject:node];
                    }
                }
                self.filteredList = [filteredList copy];
                [subscriber sendCompleted];
                return nil;
            }] replayLast] materialize];
        }];
    }
    return _cmd_filtering;
}

- (NSArray *)mainItems {
    if (!_mainItems) {
        /* 如果是mpos交易 */
        _mainItems = @[@"日期",@"卡号",@"交易类型",@"交易金额"];
        /* 如果是other交易, */
    }
    return _mainItems;
}
- (NSMutableArray *)listFilterDates {
    if (!_listFilterDates) {
        _listFilterDates = [NSMutableArray array];
    }
    return _listFilterDates;
}
- (NSMutableArray *)listFilterCardNos {
    if (!_listFilterCardNos) {
        _listFilterCardNos = [NSMutableArray array];
    }
    return _listFilterCardNos;
}
- (NSMutableArray *)listFilterTransTypes {
    if (!_listFilterTransTypes) {
        _listFilterTransTypes = [NSMutableArray array];
    }
    return _listFilterTransTypes;
}
- (NSMutableArray *)listFilterTransMoneys {
    if (!_listFilterTransMoneys) {
        _listFilterTransMoneys = [NSMutableArray array];
    }
    return _listFilterTransMoneys;
}

@end
