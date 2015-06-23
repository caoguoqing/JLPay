//
//  DisplayMoneyText.m
//  DisplayMoney
//
//  Created by 冯金龙 on 15/5/27.
//  Copyright (c) 2015年 冯金龙. All rights reserved.
//

#import "DisplayMoneyText.h"

#define Print_flag              1

@interface DisplayMoneyText()
@property (nonatomic)           NSString* moneyString;          // 算值属性:计算出完整的金额字符串
@property (nonatomic)           BOOL      dotFlag;              // 小数点标志
@property (nonatomic,assign)    NSInteger dotIndex;             // 小数位数
@property (nonatomic,strong)    NSString* leftNumbersAtDot;     // 小数点左边数字串
@property (nonatomic,strong)    NSString* rightNumbersAtDot;    // 小数点右边数字串

@end



@implementation DisplayMoneyText
@synthesize moneyString         = _moneyString;
@synthesize dotFlag             = _dotFlag;
@synthesize leftNumbersAtDot    = _leftNumbersAtDot;
@synthesize rightNumbersAtDot   = _rightNumbersAtDot;
@synthesize dotIndex            = _dotIndex;


- (instancetype)init
{
    self = [super init];
    if (self) {
        _dotFlag                = NO;
        _leftNumbersAtDot       = @"0";
        _rightNumbersAtDot      = @"0";
//        _moneyString            = [[_leftNumbersAtDot stringByAppendingString:@"."] stringByAppendingString:_rightNumbersAtDot];
        _dotIndex               = 0;
    }
    return self;
}

// 设置小数点标记
- (void) setDot{
    if (!self.dotFlag) {
        self.dotFlag            = YES;
    }
}

// 追加数字
- (void) addNumber: (NSString*)number{
    
    if (!self.dotFlag) {            // 无小数位
        if ([self.leftNumbersAtDot isEqualToString:@"0"]) {
            self.leftNumbersAtDot   = [number copy];
        } else {
            self.leftNumbersAtDot   = [self.leftNumbersAtDot stringByAppendingString:number];
        }
    }
    else {                          // 有小数位
        if (self.dotIndex == 0) {
            self.rightNumbersAtDot  = [number stringByAppendingString:@"0"];
            self.dotIndex ++;
        } else if (self.dotIndex == 1) {
            NSString* dotNum1       = [self.rightNumbersAtDot substringToIndex:1];
            self.rightNumbersAtDot  = [dotNum1 stringByAppendingString:number];
            self.dotIndex ++;
        }
    }
    self.moneyString                = [[self.leftNumbersAtDot stringByAppendingString:@"."] stringByAppendingString:self.rightNumbersAtDot];
    if (Print_flag) {
        NSLog(@";;;;;;;;;;;;;;;;; dotIndex = [%d]", self.dotIndex);
    }
}


// 返回保存的字符串金额: 两位小数点
- (NSString*) money{
    NSString* money                 = [self.moneyString copy];
    return money;
}
// 设置金额
- (void) setNewMoneyString: (NSString*)moneyStr{
    
    NSString* leftNumbers           = [moneyStr substringToIndex:[moneyStr rangeOfString:@"."].location];
    NSString* rightNumbers          = [moneyStr substringFromIndex:[moneyStr rangeOfString:@"."].location + 1];
    
    self.leftNumbersAtDot           = [leftNumbers copy];
    self.rightNumbersAtDot          = [rightNumbers copy];
    
    self.moneyString                = [moneyStr copy];

    
    
    // 如果小数点后都是0且 dotFlag == yes，则置为 no
    if (![self moneyHasDotNumber] ) {
        if (self.dotFlag)
            self.dotFlag                = NO;
        self.dotIndex               = 0;
    }
    // 如果小数点后有非0且 dotFlag == no ，则置为 yes
    else if ([self moneyHasDotNumber] ) {
        if (!self.dotFlag)
            self.dotFlag                = YES;
        NSString* dotNum2           = [self.rightNumbersAtDot substringFromIndex:1];
        if (![dotNum2 isEqualToString:@"0"]) {
            self.dotIndex           = 2;
        } else {
            self.dotIndex           = 1;
        }
    }
    if (Print_flag) {
        NSLog(@";;;;;;;;;;;;;;;;; dotIndex = [%d], money = [%@], right = [%@]", self.dotIndex, self.moneyString, self.rightNumbersAtDot);
        
    }
}


// 如果小数位全为0，返回 NO, 否则返回 YES
- (BOOL) moneyHasDotNumber {
    BOOL flag = NO;
    
    NSString* dotNumbers            = [self.moneyString substringFromIndex:[self.moneyString rangeOfString:@"."].location + 1];
    NSString* number1               = [dotNumbers substringToIndex:1];
    NSString* number2               = [dotNumbers substringFromIndex:1];
    if (Print_flag) {
        NSLog(@"number1 = [%@]", number1);
        NSLog(@"number2 = [%@]", number2);

    }
    if ([number1 isEqualToString:@"0"] && [number2 isEqualToString:@"0"])
        flag                        = NO;
    else
        flag                        = YES;
    
    return flag;
}

// 获取小数点标志
- (BOOL)hasDot {
    return self.dotFlag;
}

// 返回金额小数点左边的金额
- (NSString *)returnLeftNumbersAtDot {
    return [self.leftNumbersAtDot copy];
}
// 返回小数点右边的金额
- (NSString*) returnRightNumbersAtDot {
    return [self.rightNumbersAtDot copy];
}


@end
