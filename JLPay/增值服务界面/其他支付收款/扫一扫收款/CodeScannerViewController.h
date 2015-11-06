//
//  CodeScannerViewController.h
//  JLPay
//
//  Created by jielian on 15/11/6.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CodeScannerViewController : UIViewController


@property (nonatomic, retain) NSString* payCollectType; // 收款类型: 支付宝、微信
@property (nonatomic, retain) NSString* money; // 收款金额

@end
