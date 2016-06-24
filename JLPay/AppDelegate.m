//
//  AppDelegate.m
//  JLPay
//
//  Created by jielian on 15/3/30.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "AppDelegate.h"
#import "CustPayViewController.h"
#import "JLSignInViewController.h"

#import "BrushViewController.h"
#import "BusinessManageViewController.h"
#import "CustomNavigationController.h"
#import "Toast+UIView.h"
#import "Define_Header.h"

#import "ModelDeviceBindedInformation.h"
#import "ModelAppInformation.h"

#import <UINavigationBar+Awesome.h>


#define NotiName_DeviceState         @"NotiName_DeviceState"      // 设备插拔通知的名字
static NSUInteger const iTagAlertAppStoreInfoRequested = 198;

@interface AppDelegate ()
<UIAlertViewDelegate>
@end


@implementation AppDelegate


#pragma mask ::: 初始化主界面:分页控制器
- (UITabBarController*) mainTabBarControllerOfApp {
    UITabBarController* tabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    [tabBarController.tabBar setTintColor:[PublicInformation returnCommonAppColor:@"red"]];
    
    NSMutableArray* navigationControllers = [[NSMutableArray alloc] init];
    [navigationControllers addObject:[self newNavigationOfCustPayVC]];
    [navigationControllers addObject:[self newNavigationOfBusinessVC]];
//    [navigationControllers addObject:[self newNavigationOfAdditionalVC]];
    
    [tabBarController setViewControllers:navigationControllers];
    return tabBarController;
}

void uncaughtExceptionHandler(NSException*exception){
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@",[exception callStackSymbols]);
    // Internal error reporting
}

#pragma mask ::: app 完成加载;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /* 定义导航栏的样式 */
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjects:@[[UIColor whiteColor]]
                                                                                     forKeys:@[NSForegroundColorAttributeName]]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] lt_setBackgroundColor:[UIColor colorWithHex:HexColorTypeThemeRed alpha:1]];

    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
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
    JLSignInViewController* signInVC = [[JLSignInViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:signInVC];
    return navigation;
}

/* 创建导航器: 刷卡系列 */
- (UINavigationController*) newNavigationOfCustPayVC {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CustPayViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"custPayVC"];
    BrushViewController* brushVC = [[BrushViewController alloc] init];
    
    CustomNavigationController* navigation = [[CustomNavigationController alloc] initWithRootViewController:viewController viewControllersShouldPopToRoot:@[brushVC]];
    
    navigation.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"商户收款"
                                                          image:[UIImage imageNamed:@"iconaG"]
                                                  selectedImage:[UIImage imageNamed:@"icona"]];
    return navigation;
}
/* 创建导航器: 商户设置系列 */
- (UINavigationController*) newNavigationOfBusinessVC {
    BusinessManageViewController* businessManageVC = [[BusinessManageViewController alloc] initWithNibName:nil bundle:nil];

    UINavigationController*  navigation = [[UINavigationController alloc] initWithRootViewController:businessManageVC];
    navigation.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"商户管理"
                                                          image:[UIImage imageNamed:@"iconbG"]
                                                  selectedImage:[UIImage imageNamed:@"iconb"]];
    
    
    return navigation;
}
/* 创建导航器: 增值服务系列 */
- (UINavigationController*) newNavigationOfAdditionalVC {
    BusinessManageViewController* businessManageVC = [[BusinessManageViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController*  navigation = [[UINavigationController alloc] initWithRootViewController:businessManageVC];
    
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
