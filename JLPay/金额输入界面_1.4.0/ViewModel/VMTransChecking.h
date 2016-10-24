//
//  VMTransChecking.h
//  JLPay
//
//  Created by jielian on 16/10/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMTransChecking : NSObject

/* mpos交易的检查和跳转 */
+ (void) mposTransCheckingAndHandling;

/* 微信支付交易的检查和跳转 */
+ (void) wechatPayCheckingAndHandling;

/* 支付宝支付交易的检查和跳转 */


@end
