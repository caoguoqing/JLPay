//
//  TransDetailsViewController.h
//  JLPay
//
//  Created by jielian on 15/7/28.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>


#define NameTradePlatformMPOSSwipe  @"NameTradePlatformMPOSSwipe__"         // pos刷卡
#define NameTradePlatformOtherPay   @"NameTradePlatformOtherPay__"          // 第三方: 支付宝+微信



@interface TransDetailsViewController : UIViewController

@property (nonatomic, retain) NSString* tradePlatform; // 交易平台(要获取的交易明细类别:刷卡、第三方)


@end
