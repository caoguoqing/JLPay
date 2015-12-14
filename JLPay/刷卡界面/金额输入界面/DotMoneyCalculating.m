//
//  DotMoneyCalculating.m
//  JLPay
//
//  Created by jielian on 15/12/14.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "DotMoneyCalculating.h"


static NSInteger MaxMoneyLength = 6; // 金额整数部分最大长度

static NSString* kIntMoney = @"intMoney";
static NSString* kDotMoney = @"dotMoney";
static NSString* kDotFlag = @"dotFlag";


@interface DotMoneyCalculating()
{
    NSInteger intMoney;
    NSInteger dotMoney;
    BOOL dotFlag;
}
@property (nonatomic, strong) NSMutableArray* moneyStack;

@end


@implementation DotMoneyCalculating

- (instancetype)init {
    self = [super init];
    if (self) {
        intMoney = 0;
        dotMoney = 0;
        dotFlag = NO;
        [self pushMoneyStack];
    }
    return self;
}


#pragma mask ---- PUBLIC INTERFACE

// 追加数字
- (NSString*) moneyByAddedNumber: (NSString*)number {
    [self handleWithInput:number];
    return [self curDotMoney];
}

// 撤销到上一步
- (NSString*) moneyByRevoked {
    // 执行撤销
    [self pullMoneyStack];
    return [self curDotMoney];
}


#pragma mask ---- PRIVATE INTERFACE

/* 计算当前金额 */
- (NSString*) curDotMoney {
    NSMutableString* money = [[NSMutableString alloc] init];
    [money appendFormat:@"%d.", intMoney];
    [money appendFormat:@"%02d", dotMoney];
    return money;
}


/* 处理输入 */
- (void) handleWithInput:(NSString*)inputNumber {
    BOOL updated = NO;
    if ([inputNumber isEqualToString:@"."]) {
        if (!dotFlag) {
            dotFlag = YES;
        }
    }
    else {
        if (dotFlag) {
            updated = [self appendedDotMoneyWithNumber:inputNumber];
        }
        else {
            updated = [self appendedIntMoneyWithNumber:inputNumber];
        }
    }
    
    // 需要更新时才压入栈
    if (updated) {
        [self pushMoneyStack];
    }
}

/* 整数部分: 是否追加 */
- (BOOL) appendedIntMoneyWithNumber:(NSString*)number {
    BOOL appended = NO;
    if ([self limitingIntMoney]) {
        intMoney = intMoney*10 + [number integerValue];
        appended = YES;
    }
    return appended;
}
/* 分数部分: 是否追加 */
- (BOOL) appendedDotMoneyWithNumber:(NSString*)number {
    BOOL appended = NO;
    if ([self limitingDotMoney]) {
        dotMoney = dotMoney*10 + [number integerValue];
        appended = YES;
    }
    return appended;
}

/* 整数部分是否在限制内 */
- (BOOL) limitingIntMoney {
    BOOL limiting = YES;
    if (intMoney / (int)pow(10, MaxMoneyLength - 1) > 0) {
        limiting = NO;
    }
    return limiting;
}
/* 小数部分是否在限制内 */
- (BOOL) limitingDotMoney {
    BOOL limiting = YES;
    if (dotMoney / (int)pow(10, 2 - 1) > 0) {
        limiting = NO;
    }
    return limiting;
}


/* 打包: 当前金额数据 */
- (NSDictionary*) packingCurMoney {
    NSMutableDictionary* packing = [[NSMutableDictionary alloc] init];
    [packing setObject:[NSNumber numberWithInteger:intMoney] forKey:kIntMoney];
    [packing setObject:[NSNumber numberWithInteger:dotMoney] forKey:kDotMoney];
    [packing setObject:[NSNumber numberWithBool:dotFlag] forKey:kDotFlag];
    return packing;
}
/* 拆包: 指定字典 */
- (void) unpacking:(NSDictionary*)package {
    intMoney = [[package objectForKey:kIntMoney] integerValue];
    dotMoney = [[package objectForKey:kDotMoney] integerValue];
    dotFlag = [[package objectForKey:kDotFlag] boolValue];
}

/* 栈操作: push */
- (void) pushMoneyStack {
    [self.moneyStack addObject:[self packingCurMoney]];
}
/* 栈操作: pull */
- (void) pullMoneyStack {
    if (self.moneyStack.count > 0) {
        NSDictionary* lastMoneyNode = [self.moneyStack lastObject];
        [self.moneyStack removeLastObject];
        if (self.moneyStack.count == 0) {
            [self.moneyStack addObject:lastMoneyNode];
        }
        [self unpacking:[self.moneyStack lastObject]];
    }
}


#pragma mask ---- getter
- (NSMutableArray *)moneyStack {
    if (_moneyStack == nil) {
        _moneyStack = [[NSMutableArray alloc] init];
    }
    return _moneyStack;
}



@end
