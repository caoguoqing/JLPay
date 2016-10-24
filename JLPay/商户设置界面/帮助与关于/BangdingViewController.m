//
//  BangdingViewController.m
//  JLPay
//
//  Created by jielian on 15/8/14.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//



/* -------------------------
 * 最开始仅用于描述绑定设备流程的;
 * 后来改为通用界面，用于描述绑定设备、刷卡指引、交易明细等流程；
 * -------------------------*/

#import "BangdingViewController.h"

@interface BangdingViewController ()
<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIPageControl* pageController;
@end

@implementation BangdingViewController
@synthesize scrollView = _scrollView;
@synthesize dictTitlesAndDesc = _dictTitlesAndDesc;
@synthesize arrayTitles = _arrayTitles;
@synthesize pageController = _pageController;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    // 给滚动视图加载子视图
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.pageController];
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:1]];
    
    
    CGFloat naviAndStatus = [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.bounds.size.height;
    CGFloat pageControlHeight = 20;
    CGRect frame = CGRectMake(0,
                              naviAndStatus,
                              self.view.bounds.size.width,
                              self.view.bounds.size.height - naviAndStatus - tabBarHeight - pageControlHeight);
    // 设置滚动视图的布局
    self.scrollView.frame = frame;
    [self loadSubViewsInScrollView:self.scrollView];
    
    frame.origin.y += frame.size.height;
    frame.size.height = pageControlHeight;
    [self.pageController setFrame:frame];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
// 给滚动视图添加子视图
- (void) loadSubViewsInScrollView:(UIScrollView*)scrollView {
    CGFloat contentWidth = 0.0;
    CGRect inFrame = scrollView.bounds;
    for (NSString* text in self.arrayTitles) {
        UIImage* image = [UIImage imageNamed:text];
        NSString* title = [self.dictTitlesAndDesc valueForKey:text];
        UIView* innerView = [self newViewForSingalPageFrame:inFrame withTitle:title andImage:image];
        [scrollView addSubview:innerView];
        contentWidth += scrollView.frame.size.width;
        inFrame.origin.x += inFrame.size.width;
    }

    scrollView.contentSize = CGSizeMake(contentWidth, scrollView.frame.size.height);
}

#pragma mask ---- UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint curOffsetPoint = scrollView.contentOffset;
    [self.pageController setCurrentPage:(curOffsetPoint.x / scrollView.frame.size.width)];
}

#pragma mask ---- private interface
// 新建一个组合视图:label+imageView
- (UIView*) newViewForSingalPageFrame:(CGRect)frame
                            withTitle:(NSString*)title
                             andImage:(UIImage*)image
{
    UIView* view = [[UIView alloc] initWithFrame:frame];
    CGFloat inset = 5.0;

    /* 描述 */
    CGRect innerFrame = CGRectMake(inset, 0, frame.size.width - inset * 2, 40);
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:innerFrame];
    [titleLabel setText:title];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.numberOfLines = 0;
    [view addSubview:titleLabel];
    
    /* 图片 */
    CGFloat imageHeight = frame.size.height - innerFrame.origin.y - innerFrame.size.height - inset*2;
    CGFloat imageWidth = imageHeight * image.size.width/image.size.height;
    if (imageWidth > frame.size.width - inset * 2) {
        imageWidth = frame.size.width - inset * 2;
        imageHeight = imageWidth * image.size.height/image.size.width;
    }
    innerFrame.origin.x = (frame.size.width - imageWidth)/2.0;
    innerFrame.origin.y += innerFrame.size.height + inset;
    innerFrame.size.width = imageWidth;
    innerFrame.size.height = imageHeight;
    UIImageView* iamgeView = [[UIImageView alloc] initWithFrame:innerFrame];
    iamgeView.layer.borderColor = [UIColor grayColor].CGColor;
    iamgeView.layer.borderWidth = 0.3;
    iamgeView.image = image;
    [view addSubview:iamgeView];
    
    return view;
}

// 切换页面
- (void) pageChangeInPageControl:(UIPageControl*)pageControl {
    CGFloat curX = pageControl.currentPage * self.scrollView.frame.size.width;
    CGRect movingRect = CGRectMake(curX, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [self.scrollView scrollRectToVisible:movingRect animated:YES];
}

#pragma mask ---- getter & setter
- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setDelegate:self];
    }
    return _scrollView;
}


- (UIPageControl *)pageController {
    if (_pageController == nil) {
        _pageController = [[UIPageControl alloc] initWithFrame:CGRectZero];
        [_pageController setHidesForSinglePage:YES];
        [_pageController setNumberOfPages:self.arrayTitles.count];
        [_pageController setCurrentPage:0];
        [_pageController addTarget:self action:@selector(pageChangeInPageControl:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageController;
}

@end
