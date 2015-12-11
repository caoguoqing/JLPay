//
//  AppDelegate.m
//  JLPay
//
//  Created by jielian on 15/3/30.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "AppDelegate.h"
#import "logViewController.h"
#import "Toast+UIView.h"
#import "Define_Header.h"
#import "ModelDeviceBindedInformation.h"
#import "CustomNavigationController.h"
#import "ViewNavigationMaker.h"

#define NotiName_DeviceState         @"NotiName_DeviceState"      // 设备插拔通知的名字

@interface AppDelegate ()

@end


@implementation AppDelegate



#pragma mask ::: 登陆成功后的跳转功能:跳转到 UITabBarViewController;
-(void)signInSuccessToLogin:(int)select{
    
    UITabBarController* tabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    [tabBarController.tabBar setTintColor:[PublicInformation returnCommonAppColor:@"red"]];
    
    NSMutableArray* navigationControllers = [[NSMutableArray alloc] init];
    [navigationControllers addObject:[ViewNavigationMaker newCustPayNavigation]];
    [navigationControllers addObject:[ViewNavigationMaker newBusinessNavigation]];
//    [navigationControllers addObject:[ViewNavigationMaker newAddServiceNavigation]];
    
    [tabBarController setViewControllers:navigationControllers];
    [tabBarController setSelectedIndex:select];
    
    [self.window setRootViewController:tabBarController];
}


#pragma mask ::: app 完成加载;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 因为根视图控制用的 storyboard 的,所以可以不用生成新的 keywindow
    self.window.rootViewController = [ViewNavigationMaker newLoginNavigation];
    
    return YES;
}

#pragma mask ::: 禁止横屏
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
