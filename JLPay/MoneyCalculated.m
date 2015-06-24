//
//  MoneyCalculated.m
//  JLPay
//
//  Created by jielian on 15/6/24.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "MoneyCalculated.h"

@interface MoneyCalculated()
@property (nonatomic, assign) int       limit;              // 整数金额位数限制
@property (nonatomic, strong) NSString* moneyLeftOnDot;     // 整数金额
@property (nonatomic, strong) NSString* moneyRightOnDot;    // 小数金额
@property (nonatomic, strong) NSString* dotOrNot;           // 小数标志: 方便封装到字典 Y/N
@property (nonatomic, strong) NSString* dotIndex;           // 小数位:  方便封装到字典 0/1/2
@property (nonatomic, strong) NSMutableArray* moneyArray;   // 金额栈: 为了撤销
@property (nonatomic, readonly) NSString* money;
@end


@implementation MoneyCalculated
@synthesize limit;
@synthesize moneyLeftOnDot = _moneyLeftOnDot;
@synthesize moneyRightOnDot = _moneyRightOnDot;
@synthesize dotOrNot = _dotOrNot;
@synthesize dotIndex = _dotIndex;
@synthesize moneyArray = _moneyArray;
@synthesize money;

#pragma mask ---- 公共接口部分
// 初始化
- (id)initWithLimit:(int)maxLimit {
    self = [super init];
    if (self) {
        self.limit = maxLimit;
        // 先往金额栈压一个金额数据
        [self moneyStackPushing];
    }
    return self;
}
// 追加数字
- (NSString *)moneyByAddedNumber:(NSString *)number {
    BOOL changed = NO;
    /*
     设置小数标志
     追加到整数部分
     追加到小数部分
        判断小数现有多少位
     */
    if ([number isEqualToString:@"."]) {
        if (![self hasDot]) {
            [self setDot:YES];
            changed = YES;
        }
    } else { // 追加数字了
        if (![self hasDot]) {   // 整数
            if ([self outLimit]) {
                // 整数部分超限了就什么都不做
            } else {
                // 还要判断是否为0
                if ([self.moneyLeftOnDot length] == 1 && [self.moneyLeftOnDot isEqualToString:@"0"]) {
                    self.moneyLeftOnDot = number;
                } else {
                    self.moneyLeftOnDot = [self.moneyLeftOnDot stringByAppendingString:number];
                }
                changed = YES;
            }
        } else {                // 小数
            if ([self.dotIndex intValue] == 0) {            // 0th
                self.moneyRightOnDot = [number copy];
                [self dotIndexAdded];
                changed = YES;
            } else if ([self.dotIndex intValue] == 1) {     // 1th
                self.moneyRightOnDot = [self.moneyRightOnDot stringByAppendingString:number];
                [self dotIndexAdded];
                changed = YES;
            } else {                                        // 2th
                // 小数位只有2位,所以直接退出
            }
        }
    }
    if (changed) {
        [self moneyStackPushing];
    }
    return self.money;
}
// 撤销到上一步金额
- (NSString *)moneyByRevoked {
    NSLog(@"pull前:stack.count = [%d]", (int)self.moneyArray.count);
    // 弹出金额栈顶得金额
    [self moneyStackPulling];
    NSLog(@"pull后:stack.count = [%d]", (int)self.moneyArray.count);

    return self.money;
}

#pragma mask ---- 私有接口部分

/*****  小数标志操作区  *****/
// 判断是否有小数
- (BOOL) hasDot {
    if ([self.dotOrNot isEqualToString:@"Y"]) {
        return YES;
    } else {
        return NO;
    }
}
// 设置小数标志
- (void) setDot: (BOOL)yesOrNot {
    if (yesOrNot) {
        self.dotOrNot = @"Y";
    } else {
        self.dotOrNot = @"N";
    }
}


/*****  整数金额超限操作区  *****/
// 是否超限
- (BOOL) outLimit {
    int outlimit = (int)[self.moneyLeftOnDot length];
    if (outlimit >= self.limit) {
        return YES;
    } else {
        return NO;
    }
}


/*****  小数位数索引操作区  *****/
// 索引递加
- (void) dotIndexAdded {
    int index = [self.dotIndex intValue];
    index++;
    [self renewDotIndex:index];
}
// 设置索引
- (void) renewDotIndex: (int)index {
    self.dotIndex = [NSString stringWithFormat:@"%d", index];
}



/*****  金额栈操作区  *****/
// push
- (void) moneyStackPushing {
    NSMutableDictionary* moneyDic = [[NSMutableDictionary alloc] init];
    [moneyDic setObject:self.moneyLeftOnDot forKey:@"moneyLeftOnDot"];
    [moneyDic setObject:self.moneyRightOnDot forKey:@"moneyRightOnDot"];
    [moneyDic setObject:self.dotOrNot forKey:@"dotOrNot"];
    [moneyDic setObject:self.dotIndex forKey:@"dotIndex"];
    [self.moneyArray addObject:moneyDic];
    NSLog(@"push后的count = [%d]", self.moneyArray.count);
}
// pull
- (void) moneyStackPulling {
    if (self.moneyArray.count == 1) {
        return;
    }
    [self.moneyArray removeLastObject];
    NSDictionary* moneyDic = [self.moneyArray lastObject];
    self.moneyLeftOnDot = [moneyDic objectForKey:@"moneyLeftOnDot"];
    self.moneyRightOnDot = [moneyDic objectForKey:@"moneyRightOnDot"];
    self.dotIndex = [moneyDic objectForKey:@"dotIndex"];
    self.dotOrNot = [moneyDic objectForKey:@"dotOrNot"];
}


#pragma mask ---- setter & getter
// 整数金额
- (NSString *)moneyLeftOnDot {
    if (_moneyLeftOnDot == nil) {
        _moneyLeftOnDot = @"0";
    }
    return _moneyLeftOnDot;
}
// 小数金额
- (NSString *)moneyRightOnDot {
    if (_moneyRightOnDot == nil) {
        _moneyRightOnDot = @"0";
    }
    return _moneyRightOnDot;
}
// 小数标志
- (NSString *)dotOrNot {
    if (_dotOrNot == nil) {
        _dotOrNot = @"N";
    }
    return _dotOrNot;
}
// 小数位索引
- (NSString *)dotIndex {
    if (_dotIndex == nil) {
        _dotIndex = @"0";
    }
    return _dotIndex;
}
// 金额栈
- (NSMutableArray *)moneyArray {
    if (_moneyArray == nil) {
        _moneyArray = [[NSMutableArray alloc] init];
    }
    return _moneyArray;
}
// 返回金额
- (NSString *)money {
    NSString* newMoney = [self.moneyLeftOnDot stringByAppendingString:[NSString stringWithFormat:@".%@", self.moneyRightOnDot]];
    if ([self.moneyRightOnDot length] == 1) {
        newMoney = [newMoney stringByAppendingString:@"0"];
    }
    return newMoney;
}

@end
