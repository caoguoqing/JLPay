//
//  ViewNavigationMaker.m
//  JLPay
//
//  Created by jielian on 15/12/10.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ViewNavigationMaker.h"
#import "logViewController.h"
#import "BrushViewController.h"
#import "CustPayViewController.h"
#import "settingViewController.h"
#import "AdditionalServicesViewController.h"


@implementation ViewNavigationMaker

/* 创建一个登陆导航器 */
+ (CustomNavigationController*) newLoginNavigation {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    logViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"logVC"];
    CustomNavigationController*  navigation = [[CustomNavigationController alloc] initWithRootViewController:viewController];
    return navigation;
}


/* 创建一个收款导航器 */
+ (CustomNavigationController*) newCustPayNavigation {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CustPayViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"custPayVC"];
    CustomNavigationController*  navigation = [[CustomNavigationController alloc] initWithRootViewController:viewController];
    
    navigation.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"商户收款"
                                                          image:[UIImage imageNamed:@"iconaG"]
                                                  selectedImage:[UIImage imageNamed:@"icona"]];
    
    
    [navigation setArrayOfPopRootViewControllers:@[[[BrushViewController alloc] init]]];
    
    return navigation;
}

/* 创建一个商户设置导航器 */
+ (CustomNavigationController*) newBusinessNavigation {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    settingViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"settingVC"];
    CustomNavigationController*  navigation = [[CustomNavigationController alloc] initWithRootViewController:viewController];
    
    navigation.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"商户管理"
                                                          image:[UIImage imageNamed:@"iconbG"]
                                                  selectedImage:[UIImage imageNamed:@"iconb"]];
    
    
    return navigation;
}

/* 创建一个增值服务导航器 */
+ (CustomNavigationController*) newAddServiceNavigation {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AdditionalServicesViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"additionalServiceVC"];
    CustomNavigationController*  navigation = [[CustomNavigationController alloc] initWithRootViewController:viewController];
    
    navigation.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"增值服务"
                                                          image:[UIImage imageNamed:@"iconcG"]
                                                  selectedImage:[UIImage imageNamed:@"iconc"]];
    
    
    return navigation;
}




@end
