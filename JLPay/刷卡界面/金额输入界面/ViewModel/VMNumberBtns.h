//
//  VMNumberBtns.h
//  JLPay
//
//  Created by jielian on 16/7/18.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NumBtnKey) {
    NumBtnKey1          = 1,
    NumBtnKey2          = 2,
    NumBtnKey3          = 3,
    NumBtnKey4          = 4,
    NumBtnKey5          = 5,
    NumBtnKey6          = 6,
    NumBtnKey7          = 7,
    NumBtnKey8          = 8,
    NumBtnKey9          = 9,
    NumBtnKey0          = 10,
    NumBtnKeyClear      = 11,
    NumBtnKeyDelete     = 12
};



@interface VMNumberBtns : NSObject

/* 金额输入、刷卡界面共用 */
+ (instancetype) sharedNumberInput;

@property (nonatomic, assign) NSInteger intMoney;                           /* 整数金额: 用来计算 */

@property (nonatomic, strong) NSMutableArray* keyNumBtns;                    /* 按钮组 */

@end
