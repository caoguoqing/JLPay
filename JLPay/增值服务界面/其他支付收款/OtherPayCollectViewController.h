//
//  OtherPayCollectViewController.h
//  JLPay
//
//  Created by jielian on 15/10/30.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

//const NSString* PayCollectTypeAlipay = @"支付宝收款";
//const NSString* PayCollectTypeWeChatPay = @"微信收款";

#define PayCollectTypeAlipay            @"支付宝收款"
#define PayCollectTypeWeChatPay         @"微信收款"


@interface OtherPayCollectViewController : UIViewController

@property (nonatomic, assign) NSString* payCollectType;

@end
