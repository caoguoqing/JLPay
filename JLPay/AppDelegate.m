//
//  AppDelegate.m
//  JLPay
//
//  Created by jielian on 15/3/30.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "AppDelegate.h"
#import <UINavigationBar+Awesome.h>
#import "ModelAppInformation.h"
#import <RESideMenu.h>
#import "LeftMenuViewController.h"
#import "MainTransViewController.h"




@implementation AppDelegate

#pragma mask ::: app 完成加载;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /* 检查更新 */
    [ModelAppInformation checkAppUpdated];
    
    /* 定义导航栏的样式 */
    [self resetAwesomNavigationBarStyle];
    
    /* 捕获异常错误日志 */
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    /* 加载主页面 */
    self.window.rootViewController = [self mainViewController];
    
    /* 主要用来监控蓝牙开启状态 */
    self.CBManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    return YES;
}


/* app主界面控制器 */
- (UIViewController*) mainViewController {
    LeftMenuViewController* leftVC = [[LeftMenuViewController alloc] init];
    MainTransViewController* mainVC = [[MainTransViewController alloc] init];
    RESideMenu* sideMenuVC = [[RESideMenu alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:mainVC] leftMenuViewController:leftVC rightMenuViewController:nil];
    sideMenuVC.scaleMenuView = NO;
    sideMenuVC.contentViewShadowEnabled = YES;
    sideMenuVC.parallaxEnabled = NO;
    
    return sideMenuVC;
}


/* 定义导航栏的样式 */
- (void) resetAwesomNavigationBarStyle {
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] lt_setBackgroundColor:[UIColor colorWithHex:0x27384b alpha:1]];
}


#pragma mask ::: 禁止横屏
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

# pragma mask ::: 捕获详细的内存崩溃日志
void uncaughtExceptionHandler(NSException* exception){
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@",[exception callStackSymbols]);
}



#pragma mask ---- CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStateUnknown:
            JLPrint(@"--- blueTooth state changed [CBManagerStateUnknown]");
            break;
        case CBManagerStateResetting:
            JLPrint(@"--- blueTooth state changed [CBManagerStateResetting]");
            break;
        case CBManagerStateUnsupported:
            JLPrint(@"--- blueTooth state changed [CBManagerStateUnsupported]");
            break;
        case CBManagerStateUnauthorized:
            JLPrint(@"--- blueTooth state changed [CBManagerStateUnauthorized]");
            break;
        case CBManagerStatePoweredOff:
            JLPrint(@"--- blueTooth state changed [CBManagerStatePoweredOff]");
            break;
        case CBManagerStatePoweredOn:
            JLPrint(@"--- blueTooth state changed [CBManagerStatePoweredOn]");
            break;

        default:
            break;
    }
}



@end
