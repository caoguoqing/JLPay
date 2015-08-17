//
//  BangdingViewController.m
//  JLPay
//
//  Created by jielian on 15/8/14.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "BangdingViewController.h"

@interface BangdingViewController ()
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) NSArray* arrayTitles;
@property (nonatomic, strong) NSMutableDictionary* dictTitlesAndViews;
@property (nonatomic, strong) NSMutableDictionary* dictTitlesAndDesc;
@end

@implementation BangdingViewController
@synthesize scrollView = _scrollView;
@synthesize dictTitlesAndViews = _dictTitlesAndViews;
@synthesize dictTitlesAndDesc = _dictTitlesAndDesc;
@synthesize arrayTitles = _arrayTitles;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    // 给滚动视图加载子视图
    [self loadSubViewsInScrollView:self.scrollView];
    [self.view addSubview:self.scrollView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat naviAndStatus = [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.bounds.size.height;
    CGRect frame = CGRectMake(0,
                              naviAndStatus,
                              self.view.bounds.size.width,
                              self.view.bounds.size.height - naviAndStatus - tabBarHeight);
    // 设置滚动视图的布局
    self.scrollView.frame = frame;
}
- (void) loadSubViewsInScrollView:(UIScrollView*)scrollView {
    CGFloat inset = 15;
    CGFloat textHeight = 30;
    CGRect frame = CGRectMake(inset, inset, self.view.frame.size.width - inset*2, textHeight);
    for (NSString* text in self.arrayTitles) {
        // UILabel
        UILabel* label = [[UILabel alloc] initWithFrame:frame];
        [label setNumberOfLines:0];
        label.text = [self.dictTitlesAndDesc valueForKey:text];
        [label sizeToFit];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize size = [label.text sizeWithAttributes:[NSDictionary dictionaryWithObject:label.font forKey:NSFontAttributeName]];

        if (size.width > frame.size.width) {
            int bigW = (int)size.width;
            int littleW = (int)frame.size.width;
            int cent = (bigW % littleW > 0)?(bigW/littleW + 1):(bigW/littleW);
            frame.size.height *= cent;
            label.frame = frame;
        }
        [scrollView addSubview:label];
        // UIImageView
        frame.origin.x += inset;
        frame.origin.y += frame.size.height;
        frame.size.width = self.view.bounds.size.width - inset*2 * 2;
        UIImage* image = [UIImage imageNamed:text];
        frame.size.height = frame.size.width * image.size.height/image.size.width;
        UIImageView* imageView = [self.dictTitlesAndViews objectForKey:text];
        imageView.frame = frame;
        imageView.image = image;
        [scrollView addSubview:imageView];

        frame.origin.x = inset;
        frame.origin.y += frame.size.height + inset;
        frame.size.width = self.view.bounds.size.width - inset*2;
        frame.size.height = textHeight;
    }

    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, frame.origin.y);
}

#pragma mask ---- private interface

#pragma mask ---- getter & setter
- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    }
    return _scrollView;
}
- (NSArray *)arrayTitles {
    if (_arrayTitles == nil) {
        _arrayTitles = [NSArray arrayWithObjects:@"商户管理主界面",@"选择设备类型",@"绑定设备", nil];
    }
    return _arrayTitles;
}
- (NSMutableDictionary *)dictTitlesAndViews {
    if (_dictTitlesAndViews == nil) {
        _dictTitlesAndViews = [[NSMutableDictionary alloc] init];
        for (NSString* text in self.arrayTitles) {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageView.layer.borderWidth = 0.5;
            imageView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
            [_dictTitlesAndViews setObject:imageView forKey:text];
        }
    }
    return _dictTitlesAndViews;
}
- (NSMutableDictionary *)dictTitlesAndDesc {
    if (_dictTitlesAndDesc == nil) {
        _dictTitlesAndDesc = [[NSMutableDictionary alloc] init];
        for (NSString* text in self.arrayTitles) {
            NSString* desc = nil;
            if ([text isEqualToString:@"商户管理主界面"]) {
                desc = @"1.点击'绑定机具'选项框进行绑定操作;如果已经已经绑定过设备,进入app主页是'刷卡'主界面;否则会直接跳转到2绑定界面";
            } else if ([text isEqualToString:@"选择设备类型"]) {
                desc = @"2.绑定机具前要先选择要绑定的设备的设备类型";
            } else if ([text isEqualToString:@"绑定设备"]) {
                desc = @"3.一台手机同时只能绑定一个终端号和一个设备号;如果切换了账号或切换了设备,要重新绑定";
            }
            [_dictTitlesAndDesc setObject:desc forKey:text];
        }
    }
    return _dictTitlesAndDesc;
}

@end
