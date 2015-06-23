//
//  DisplayMoneyText.h
//  DisplayMoney
//
//  Created by 冯金龙 on 15/5/27.
//  Copyright (c) 2015年 冯金龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DisplayMoneyText : NSObject


// 返回金额
// 追加输入的数字
// 设置已有的金额




// 设置小数点标记
- (void) setDot;
- (BOOL) hasDot;

// 追加数字
- (void) addNumber: (NSString*)number;


// 返回保存的字符串金额: 两位小数点
- (NSString*) money;

// 设置金额文本
- (void) setNewMoneyString: (NSString*)moneyStr;

// 返回小数点左边的金额
- (NSString*) returnLeftNumbersAtDot;
// 返回小数点右边的金额
- (NSString*) returnRightNumbersAtDot;

@end
