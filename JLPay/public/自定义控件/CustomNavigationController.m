//
//  CustomNavigationController.m
//  JLPay
//
//  Created by jielian on 15/12/21.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "CustomNavigationController.h"


@interface CustomNavigationController()
<UINavigationBarDelegate>
@property (nonatomic, strong) NSArray* viewControllersShouldPopToRoot;

@end


@implementation CustomNavigationController



- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
            viewControllersShouldPopToRoot:(NSArray*)viewControllers
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.viewControllersShouldPopToRoot = [NSArray arrayWithArray:viewControllers];
    }
    return self;
}

#pragma mask ---- UINavigationBarDelegate 
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if ([self containsShouldPopViewController:[self topViewController]]) {
        [self popToRootViewControllerAnimated:YES];
    } else {
        [self popViewControllerAnimated:YES];
    }
    
    return YES;
}


#pragma mask ---- PRIVATE INTERFACE
- (BOOL) containsShouldPopViewController:(UIViewController*)viewController {
    BOOL contains = NO;
    for (UIViewController* innerVC in self.viewControllersShouldPopToRoot) {
        if ([innerVC class] == [viewController class]) {
            contains = YES;
            break;
        }
    }
    return contains;
}

@end
