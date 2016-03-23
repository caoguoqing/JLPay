//
//  AppDelegate.m
//  JLPay
//
//  Created by jielian on 15/3/30.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "AppDelegate.h"
#import "CustPayViewController.h"
#import "logViewController.h"
#import "BrushViewController.h"
#import "settingViewController.h"
#import "CustomNavigationController.h"
#import "Toast+UIView.h"
#import "Define_Header.h"

#import "ModelDeviceBindedInformation.h"
#import "ModelAppInformation.h"


#define NotiName_DeviceState         @"NotiName_DeviceState"      // 设备插拔通知的名字
static NSUInteger const iTagAlertAppStoreInfoRequested = 198;

@interface AppDelegate ()
<UIAlertViewDelegate>
@end


@implementation AppDelegate


#pragma mask ::: 登陆成功后的跳转功能:跳转到 UITabBarViewController;
-(void)signInSuccessToLogin:(int)select{
    
    UITabBarController* tabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    [tabBarController.tabBar setTintColor:[PublicInformation returnCommonAppColor:@"red"]];
    
    NSMutableArray* navigationControllers = [[NSMutableArray alloc] init];
    [navigationControllers addObject:[self newNavigationOfCustPayVC]];
    [navigationControllers addObject:[self newNavigationOfBusinessVC]];
    
    [tabBarController setViewControllers:navigationControllers];
    [tabBarController setSelectedIndex:select];
    
    [self.window setRootViewController:tabBarController];
}
#pragma mask ::: 初始化主界面:分页控制器
- (UITabBarController*) mainTabBarControllerOfApp {
    UITabBarController* tabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    [tabBarController.tabBar setTintColor:[PublicInformation returnCommonAppColor:@"red"]];
    
    NSMutableArray* navigationControllers = [[NSMutableArray alloc] init];
    [navigationControllers addObject:[self newNavigationOfCustPayVC]];
    [navigationControllers addObject:[self newNavigationOfBusinessVC]];
    
    [tabBarController setViewControllers:navigationControllers];
    return tabBarController;
}


#pragma mask ::: app 完成加载;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window.rootViewController = [self newNavigationOfLoginVC];
    
    // 检查app版本
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkAppVersionAndAlert)
                                                 name:kNotiKeyAppStoreInfoRequested
                                               object:nil];
    [self requestAppStoreInfoIfBranchMaster];
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

#pragma mask ---- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == iTagAlertAppStoreInfoRequested) {
        if (buttonIndex == 1) {
            [self gotoAppStore];
        }
    }
}


#pragma mask ---- PRIVATE INTERFACE
/* 创建导航器: 登陆系列 */
- (UINavigationController*) newNavigationOfLoginVC {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    logViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"logVC"];
    UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navigation.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName]];
    return navigation;
}

/* 创建导航器: 刷卡系列 */
- (UINavigationController*) newNavigationOfCustPayVC {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CustPayViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"custPayVC"];
    BrushViewController* brushVC = [[BrushViewController alloc] init];
    
    CustomNavigationController* navigation = [[CustomNavigationController alloc] initWithRootViewController:viewController viewControllersShouldPopToRoot:@[brushVC]];
    
    [navigation.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName]];

    navigation.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"商户收款"
                                                          image:[UIImage imageNamed:@"iconaG"]
                                                  selectedImage:[UIImage imageNamed:@"icona"]];
    return navigation;
}
/* 创建导航器: 商户设置系列 */
- (UINavigationController*) newNavigationOfBusinessVC {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    settingViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"settingVC"];
    UINavigationController*  navigation = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navigation.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName]];

    navigation.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"商户管理"
                                                          image:[UIImage imageNamed:@"iconbG"]
                                                  selectedImage:[UIImage imageNamed:@"iconb"]];
    
    
    return navigation;
}
/* 创建导航器: 增值服务系列 */
- (UINavigationController*) newNavigationOfAdditionalVC {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    settingViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"additionalServiceVC"];
    UINavigationController*  navigation = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navigation.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName]];
    
    navigation.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"增值服务"
                                                          image:[UIImage imageNamed:@"iconcG"]
                                                  selectedImage:[UIImage imageNamed:@"iconc"]];
    
    
    return navigation;
}


// -- 获取 AppStore 版信息: 如果是master分支
- (void) requestAppStoreInfoIfBranchMaster {
    if (TAG_OF_BRANCH_EDITION == 0) { // master分支
        [[ModelAppInformation sharedInstance] requestAppStoreInfo];
    }
}
// -- 检查 AppStore 版本分支,提示更新
- (void) checkAppVersionAndAlert {
    NSString* curAppStoreVersion = [[ModelAppInformation sharedInstance] appStoreVersion];
    if (!curAppStoreVersion) {
        return;
    }
    NSString* curAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    curAppStoreVersion = [curAppStoreVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    curAppVersion = [curAppVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (curAppStoreVersion.integerValue > curAppVersion.integerValue) { // 比较当前版本
        [PublicInformation alertCancle:@"暂不升级"
                                 other:@"马上升级"
                                 title:@"发现新版本,是否升级?"
                               message:[[ModelAppInformation sharedInstance] appUpdatedDescription]
                                   tag:iTagAlertAppStoreInfoRequested
                              delegate:self];
    }
    
}
// -- 跳转appstore升级界面
- (void) gotoAppStore {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[ModelAppInformation URLStringInAppStore]]];
}


@end
