//
//  MViewSwitchManager.m
//  JLPay
//
//  Created by jielian on 16/10/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MViewSwitchManager.h"
#import <RESideMenu.h>
#import "MainTransViewController.h"
#import "LeftMenuViewController.h"

#import "JLSignInViewController.h"
#import "DeviceConnectViewController.h"
#import "TransDetailListViewController.h"
#import "MoreBusinessOrRateVC.h"
#import "T0CardListViewController.h"
#import "HelperAndAboutTableViewController.h"
#import "ChangePinViewController.h"
#import "MyBusinessViewController.h"

@interface MViewSwitchManager()

@property (nonatomic, copy) void (^ finishedBlock) (void);

@property (nonatomic, copy) void (^ canceledBlock) (void);

@end

@implementation MViewSwitchManager

+ (instancetype)manager {
    static MViewSwitchManager* switchManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        switchManager = [[MViewSwitchManager alloc] init];
    });
    return switchManager;
}

+ (UIViewController *)mainViewController {
    return [[[[UIApplication sharedApplication] delegate] window] rootViewController];
}


/* 跳转: 登录 */
- (void)gotoLogin {
    NameWeakSelf(wself);
    JLSignInViewController*  signinVC = [[JLSignInViewController alloc] initWithLoginFinished:^{
        [wself refrashMainViewControllerDatas];
    } onCanceled:^{
        
    }];
    
    [[MViewSwitchManager mainViewController] presentViewController:[[UINavigationController alloc] initWithRootViewController:signinVC] animated:YES completion:^{
        
    }];
}

/* 跳转: 交易明细 */
- (void) gotoBillList {
    TransDetailListViewController* billListVC = [[TransDetailListViewController alloc] init];
    [[MViewSwitchManager mainViewController] presentViewController:[[UINavigationController alloc] initWithRootViewController:billListVC] animated:YES completion:nil];
}

/* 跳转: 绑定设备 */
- (void) gotoDeviceBinding {
    NameWeakSelf(wself);
    DeviceConnectViewController* deviceConnectVC = [[DeviceConnectViewController alloc] initWithConnected:^{
        [wself refrashMainViewControllerDatas];
    } orCanceled:^{
        
    }];
    [[MViewSwitchManager mainViewController] presentViewController:[[UINavigationController alloc] initWithRootViewController:deviceConnectVC] animated:YES completion:nil];
}

/* 跳转: 刷卡 */
- (void) gotoTransWithMPos {
    
}

/* 跳转: 多商户 */
- (void) gotoBusinessSwitch {
    NameWeakSelf(wself);
    MoreBusinessOrRateVC* moreBusiOrRateVC = [[MoreBusinessOrRateVC alloc] initWithSelectFinished:^{
        [wself refrashMainViewControllerDatas];
    } orCanceled:^{
        [wself refrashMainViewControllerDatas];
    }];
    [[MViewSwitchManager mainViewController] presentViewController:[[UINavigationController alloc] initWithRootViewController:moreBusiOrRateVC] animated:YES completion:nil];
}

/* 跳转: 我的卡包 */
- (void) gotoMyCreditcardChecking {
    T0CardListViewController* t_0CardListVC = [[T0CardListViewController alloc] init];
    [[MViewSwitchManager mainViewController] presentViewController:[[UINavigationController alloc] initWithRootViewController:t_0CardListVC] animated:YES completion:nil];
}

/* 跳转: 修改密码 */
- (void) gotoPasswordExchanging {
    NameWeakSelf(wself);
    ChangePinViewController* changePinVC = [[ChangePinViewController alloc] initWithChangeFinished:^{
        [MCacheSavedLogin cache].userName = nil;
        [wself refrashMainViewControllerDatas];
        [wself gotoLogin];
    } orCanceled:^{
        
    }];
    [[MViewSwitchManager mainViewController] presentViewController:[[UINavigationController alloc] initWithRootViewController:changePinVC] animated:YES completion:nil];
}

/* 跳转: 我的商户 */
- (void) gotoMyBusiness {
    NameWeakSelf(wself);
    MyBusinessViewController* myBusinessVC = [[MyBusinessViewController alloc] initWithFinished:^{
        [wself refrashMainViewControllerDatas];
    } orCanceled:^{
        [wself refrashMainViewControllerDatas];
    }];
    [[MViewSwitchManager mainViewController] presentViewController:[[UINavigationController alloc] initWithRootViewController:myBusinessVC] animated:YES completion:nil];;
}


/* 跳转: 帮助与关于 */
- (void) gotoAssistance {
    HelperAndAboutTableViewController* assistaceVC = [[HelperAndAboutTableViewController alloc] init];
    [[MViewSwitchManager mainViewController] presentViewController:[[UINavigationController alloc] initWithRootViewController:assistaceVC]
                                                          animated:YES completion:nil];
}


/* 重新刷新主界面+菜单界面的数据 */
- (void) refrashMainViewControllerDatas {
    RESideMenu* sideMenuVC = (RESideMenu*)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    LeftMenuViewController* leftMenuVC = (LeftMenuViewController*)[sideMenuVC leftMenuViewController];
    UINavigationController* mainNavigationVC = (UINavigationController*)[sideMenuVC contentViewController];
    MainTransViewController* mainVC = (MainTransViewController*)[[mainNavigationVC viewControllers] firstObject];
    
    [leftMenuVC reloadDatas];
    [mainVC reloadDatas];
}



@end
