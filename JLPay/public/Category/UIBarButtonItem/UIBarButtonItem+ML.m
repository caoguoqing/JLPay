//
//  UIBarButtonItem+ML.m
//  JLPay
//
//  Created by jielian on 2017/1/13.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "UIBarButtonItem+ML.h"
#import "Define_Header.h"

@implementation UIBarButtonItem (ML)


/* 回退场景: pop */
+ (instancetype) backBarBtnWithVC:(UIViewController*)superVC color:(UIColor*)color {
    CGFloat height = 22;
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, height, height)];
    [btn setTitle:[NSString fontAwesomeIconStringForEnum:FAChevronLeft] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.4] forState:UIControlStateHighlighted];
    btn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:height scale:1]];
    [btn addTarget:superVC.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    return [[self alloc] initWithCustomView:btn];
}

/* 回主场景: dismiss */
//+ (instancetype) homeBarBtnWithVC:(UIViewController*)superVC color:(UIColor*)color {
//    CGFloat height = 22;
//    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, height, height)];
//    [btn setTitle:[NSString fontAwesomeIconStringForEnum:FAHome] forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.4] forState:UIControlStateHighlighted];
//    btn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:height scale:1]];
//    [btn addTarget:superVC.navigationController action:@selector(dismissViewControllerAnimated:completion:) forControlEvents:UIControlEventTouchUpInside];
//    return [[self alloc] initWithCustomView:btn];
//}


@end
