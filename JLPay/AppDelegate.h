//
//  AppDelegate.h
//  JLPay
//
//  Created by jielian on 15/3/30.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceManager.h"


#define APPMainDelegate  (AppDelegate*)[UIApplication sharedApplication].delegate

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

#pragma mask ::: 登陆成功后的跳转功能:跳转到 UITabBarViewController;
- (void)signInSuccessToLogin:(int)select;

#pragma mask ::: 初始化主界面:分页控制器
- (UITabBarController*) mainTabBarControllerOfApp ;


@end

