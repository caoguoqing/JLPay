//
//  CustomNavigationController.m
//  JLPay
//
//  Created by jielian on 15/12/10.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "CustomNavigationController.h"

@interface CustomNavigationController()
<UINavigationBarDelegate>

@property (nonatomic, strong) NSArray* viewControllersShouldPopRoot;

@end

@implementation CustomNavigationController



- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName]];
    }
    return self;
}

- (void)setArrayOfPopRootViewControllers:(NSArray *)viewControllers {
    if (!viewControllers || viewControllers.count == 0) {
        return;
    }
    self.viewControllersShouldPopRoot = [NSArray arrayWithArray:viewControllers];
}

#pragma mask ---- UINavigationBarDelegate
/* 即将回退 */
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    NSLog(@"\n\n-----\n%s\ntitle=[%@]\ntopViewController=[%@]\n------\n",__func__,item.title,[self topViewController]);
    
    if ([self containedInViewControllersOfViewController:[self topViewController]]) {
        [self popToRootViewControllerAnimated:YES];
        return YES;
    }
    else {
        [self popViewControllerAnimated:YES];
        return YES;
    }
}


- (BOOL) containedInViewControllersOfViewController:(UIViewController*)viewController {
    BOOL contained = NO;
    if (self.viewControllersShouldPopRoot) {
        for (UIViewController* viewC in self.viewControllersShouldPopRoot) {
            if (viewController.class == viewC.class) {
                contained = YES;
                break;
            }
        }
    }
    return contained;
}


@end
