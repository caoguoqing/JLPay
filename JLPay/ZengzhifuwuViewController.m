//
//  ZengzhifuwuViewController.m
//  JLPay
//
//  Created by jielian on 15/8/16.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "ZengzhifuwuViewController.h"

@interface ZengzhifuwuViewController ()
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) NSArray* arrayTitles;
@property (nonatomic, strong) NSMutableDictionary* dictTitlesAndViews;
@property (nonatomic, strong) NSMutableDictionary* dictTitlesAndDesc;
@end

@implementation ZengzhifuwuViewController

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
        _arrayTitles = [NSArray arrayWithObjects:@"增值服务",nil];
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
            if ([text isEqualToString:@"增值服务"]) {
                desc = @"增值服务的功能后期版本会陆续更新;敬请期待.";
            }
            [_dictTitlesAndDesc setObject:desc forKey:text];
        }
    }
    return _dictTitlesAndDesc;
}

@end
