//
//  DisplayMoneyText.h
//  DisplayMoney
//
//  Created by 冯金龙 on 15/5/27.
//  Copyright (c) 2015年 冯金龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DisplayMoneyText : NSObject

// 设置小数点标记
- (void) setDot;

// 追加数字
- (void) addNumber: (NSString*)number;


// 返回保存的字符串金额: 两位小数点
- (NSString*) money;

// 设置金额
- (void) setNewMoneyString: (NSString*)moneyStr;

@end
