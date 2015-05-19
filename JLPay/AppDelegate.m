//
//  AppDelegate.m
//  JLPay
//
//  Created by jielian on 15/3/30.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


/*
 *登陆成功后进入Tabbar
 */
-(void)signInSuccessToLogin:(int)select{
    self.window.userInteractionEnabled=YES;
    
    UIStoryboard *storyboard            = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    self.window.rootViewController      = [storyboard instantiateViewControllerWithIdentifier:@"tabbar"];
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSArray* imageArray                 = [NSArray arrayWithObjects:@"icona", @"iconb", @"iconc", nil];
    NSArray* imageSelectedArray         = [NSArray arrayWithObjects:@"icona_", @"iconb_", @"iconc_", nil];
    
    
    
    UIStoryboard *storyBoard            = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UITabBarController *tabBarCtr       = [storyBoard instantiateViewControllerWithIdentifier:@"tabbar"];
//    UITabBarController *tabBarCtr       = self.window.rootViewController;
    // 自定义 tabBarItem 的图片
    for (int i = 0; i<tabBarCtr.tabBar.items.count; i++) {
        UITabBarItem* item              = [tabBarCtr.tabBar.items objectAtIndex:i];
        item.selectedImage              = [[UIImage imageNamed:[imageSelectedArray objectAtIndex:i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.image                      = [[UIImage imageNamed:[imageArray objectAtIndex:i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    
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
