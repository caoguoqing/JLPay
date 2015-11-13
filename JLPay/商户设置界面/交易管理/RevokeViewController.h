//
//  RevokeViewController.h
//  JLPay
//
//  Created by jielian on 15/6/11.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RevokeViewController : UIViewController

@property (nonatomic, strong) NSDictionary* dataDic;

@property (nonatomic, retain) NSString* tradePlatform; // 交易平台(要获取的交易明细类别:刷卡、第三方)


@end
