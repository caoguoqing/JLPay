//
//  ViewNavigationMaker.h
//  JLPay
//
//  Created by jielian on 15/12/10.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomNavigationController.h"

@interface ViewNavigationMaker : NSObject

/* 创建一个收款导航器 */
+ (CustomNavigationController*) newCustPayNavigation;

/* 创建一个商户设置导航器 */
+ (CustomNavigationController*) newBusinessNavigation;

/* 创建一个增值服务导航器 */
+ (CustomNavigationController*) newAddServiceNavigation;

@end
