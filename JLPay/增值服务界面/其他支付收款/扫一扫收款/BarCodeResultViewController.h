//
//  BarCodeResultViewController.h
//  JLPay
//
//  Created by jielian on 15/11/9.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarCodeResultViewController : UIViewController

@property (nonatomic, retain) NSString* payCollectType; // 收款类型: 支付宝、微信
@property (nonatomic, retain) NSString* money; // 收款金额
@property (nonatomic, assign) BOOL result;

@end
