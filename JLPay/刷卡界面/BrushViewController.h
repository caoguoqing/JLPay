//
//  BrushViewController.h
//  JLPay
//
//  Created by jielian on 15/4/14.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrushViewController : UIViewController
@property (nonatomic, strong) NSString* stringOfTranType;               // 交易类型:消费、撤销、退货


@property (nonatomic, strong) NSString* sIntMoney;                      // 无小数点格式金额
@property (nonatomic, strong) NSString* sFloatMoney;                    // 有小数点格式金额

@end
