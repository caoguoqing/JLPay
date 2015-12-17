//
//  IntMoneyCalculating.m
//  JLPay
//
//  Created by jielian on 15/12/17.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "IntMoneyCalculating.h"

static NSInteger MaxMoneyLength = 6 + 2; // 金额整数部分最大长度

@interface IntMoneyCalculating()

@property (nonatomic, strong) NSMutableArray* moneyStack;

@end

@implementation IntMoneyCalculating


// 追加数字
- (NSString*) dotMoneyByAddedNumber: (NSString*)number {
    NSInteger newMoney = [self topValueOfStack];
    if (newMoney/(int)pow(10.0, MaxMoneyLength - 1) == 0) {
        newMoney = newMoney*10 + number.integerValue;
        [self pushStackNumber:newMoney];
    }
    return [self dotMoneyOfInteger:[self topValueOfStack]];
}

// 撤销到上一步
- (NSString*) dotMoneyByRevoked {
    [self pullStack];
    return [self dotMoneyOfInteger:[self topValueOfStack]];
    
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}


#pragma mask ---- PRIVATE INTERFACE
/* 入栈 */
- (void) pushStackNumber:(NSInteger)number {
    [self.moneyStack addObject:[NSNumber numberWithInt:number]];
}
/* 出栈 */
- (NSInteger) pullStack {
    NSInteger top = [self topValueOfStack];
    if (self.moneyStack.count > 1) {
        [self.moneyStack removeLastObject];
    }
    return top;
}
/* 栈顶值 */
- (NSInteger) topValueOfStack {
    return [[self.moneyStack lastObject] integerValue];
}

- (NSString*) dotMoneyOfInteger:(NSInteger)money {
    NSInteger intPart = money/100;
    NSInteger dotPart = money%100;
    return [NSString stringWithFormat:@"%d.%.02d",intPart,dotPart];
}



#pragma mask ---- getter
- (NSMutableArray *)moneyStack {
    if (_moneyStack == nil) {
        _moneyStack = [[NSMutableArray alloc] init];
        [_moneyStack addObject:[NSNumber numberWithInt:0]];
    }
    return _moneyStack;
}

@end
