//
//  MoneyCalculated.h
//  JLPay
//
//  Created by jielian on 15/6/24.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoneyCalculated : NSObject

// 初始化:带整数金额限制位
- (id) initWithLimit: (int)maxLimit;

// 追加数字
- (NSString*) moneyByAddedNumber: (NSString*)number;

// 撤销到上一步
- (NSString*) moneyByRevoked;

@end
