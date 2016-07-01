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

@interface AppDelegate : UIResponder <UIApplicationDelegate,CBCentralManagerDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (nonatomic, strong) CBCentralManager* CBManager;



#pragma mask ::: 初始化主界面:分页控制器
- (UITabBarController*) mainTabBarControllerOfApp ;


@end

