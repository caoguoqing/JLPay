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

#define NotiName_DeviceState         @"NotiName_DeviceState"      // 设备插拔通知的名字

@interface AppDelegate ()

@end


@implementation AppDelegate
//@synthesize device                      = _device;


/*
 *登陆成功后进入Tabbar
 */
#pragma mask ::: 登陆成功后的跳转功能:跳转到 UITabBarViewController;
-(void)signInSuccessToLogin:(int)select{
    self.window.userInteractionEnabled=YES;
    
    UIStoryboard *storyboard            = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UITabBarController* tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"tabbar"];
    // 进入的初始界面为第二个
    tabBarController.selectedViewController = [tabBarController.viewControllers objectAtIndex:1];
    
    self.window.rootViewController      = tabBarController;
    
    // tabBarItem 的默认图片可以在 storyBoard 中设置, 但是 selected 图片还是要在代码中动态创建
    NSArray* selectedImageArray         = [NSArray arrayWithObjects:@"icona", @"iconb", @"iconc", nil];
    for (int i = 0; i< tabBarController.tabBar.items.count; i++) {
        UITabBarItem* item              = [tabBarController.tabBar.items objectAtIndex:i];
        item.selectedImage              = [[UIImage imageNamed:[selectedImageArray objectAtIndex:i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    // 当点击了 tabBarItem 后，对应的 文字描述 也要变成红色
    tabBarController.tabBar.tintColor   = [UIColor colorWithRed:238.0/255.0 green:40.0/255.0 blue:50.0/255.0 alpha:1];
    
//    [[NSUserDefaults standardUserDefaults] setValue:@"无" forKey:SelectedTerminalNum];

}
// 跳转到指定的界面
- (void) loadInViewController:(UIViewController*)viewController {
    self.window.rootViewController      = viewController;
}


#pragma mask ::: app 的入口;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
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
