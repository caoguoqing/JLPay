//
//  CustomNavigationController.h
//  JLPay
//
//  Created by jielian on 15/12/10.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNavigationController : UINavigationController

/* 指定视图控制器数组: 回退时回退到根视图界面 */
- (void) setArrayOfPopRootViewControllers:(NSArray*)viewControllers;

@end
