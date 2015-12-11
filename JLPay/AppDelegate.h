//
//  AppDelegate.h
//  JLPay
//
//  Created by jielian on 15/3/30.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceManager.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

#pragma mask ::: 登陆成功后的跳转功能:跳转到 UITabBarViewController;
- (void)signInSuccessToLogin:(int)select;

@end

