//
//  PullListSegView.m
//  JLPay
//
//  Created by jielian on 16/3/3.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//


#import "PullListSegView.h"


@interface PullListSegView()
{
    CGFloat     animationDuration;
    NSInteger   iMaxDisplayCount;
    CGFloat     fWidthOfTri;
    CGFloat     fHeightOfTri;
}
@end

@implementation PullListSegView

#pragma mask 1 public interface 
- (void)showAnimation {
    [self.tableView reloadData];
    [self setNeedsLayout];
    [self setNeedsDisplay];
    [self animationShow];
}
- (void)hiddenAnimation {
    [self animationHidden];
}


#pragma mask 3 private interface
// -- animation: show
- (void) animationShow {
    self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}
// -- animation: hidden
- (void) animationHidden {
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        self.transform = CGAffineTransformIdentity;
    }];
}

#pragma mask 4 geter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorInset = UIEdgeInsetsMake(15, 0, 0, 15);
        _tableView.rowHeight = 37.f;
    }
    return _tableView;
}


#pragma mask 0 生命周期,和布局
- (instancetype) init {
    self = [super init];
    if (self) {
        [self initialProperties];
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.97;
        [self loadSubViews];
    }
    return self;
}

- (void) initialProperties {
    animationDuration = 0.3;
    iMaxDisplayCount = 5;
    fWidthOfTri = 20.f;
    fHeightOfTri = 20.f * 2.f/3.f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = fHeightOfTri;
    NSInteger dataSourceCount = [self.tableView numberOfRowsInSection:0];
    if (dataSourceCount >= iMaxDisplayCount) {
        height += iMaxDisplayCount * self.tableView.rowHeight;
    } else {
        height += dataSourceCount * self.tableView.rowHeight;
    }
    
    CGRect frame = self.frame;
    frame.size.height = height;
    [self setFrame:frame];
    
    frame.origin.x = 0;
    frame.origin.y = fHeightOfTri;
    frame.size.height -= fHeightOfTri;
    [self.tableView setFrame:frame];
}

- (void) loadSubViews {
    [self addSubview:self.tableView];
}

- (void)drawRect:(CGRect)rect {
    CGFloat centerX = rect.size.width/2.f;
    // 三角
    UIBezierPath* triPath = [UIBezierPath bezierPath];
    [triPath moveToPoint:CGPointMake(centerX, 0)];
    [triPath addLineToPoint:CGPointMake(centerX - fWidthOfTri/2.f, fHeightOfTri)];
    [triPath addLineToPoint:CGPointMake(centerX + fWidthOfTri/2.f, fHeightOfTri)];
    [triPath closePath];
    UIColor* fillColor = [UIColor colorWithWhite:0.2 alpha:0.9];
    [fillColor setFill];
    [triPath fill];
    // 矩形
    CGRect rectFrame = CGRectMake(0, fHeightOfTri, rect.size.width, rect.size.height - fHeightOfTri);
    UIBezierPath* rectPath = [UIBezierPath bezierPathWithRoundedRect:rectFrame cornerRadius:5.f];
    [rectPath fill];
}


@end
