//
//  CustomNavigationController.h
//  JLPay
//
//  Created by jielian on 15/12/21.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//


// ------------------------
// 自定义导航器
// 主要用处:
//      1.自定义返回barButtonItem的返回事件
// ------------------------


#import <UIKit/UIKit.h>

@interface CustomNavigationController : UINavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
            viewControllersShouldPopToRoot:(NSArray*)viewControllers;


@end
