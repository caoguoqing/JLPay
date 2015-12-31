//
//  PullRefrashView.m
//  JLPay
//
//  Created by jielian on 15/11/27.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "PullRefrashView.h"
#import "PublicInformation.h"

@interface PullRefrashView()
{
    NSString* pullUpText;
    NSString* pullDownText;
    NSString* waitingText;
    CGFloat heightContentView;
    CGFloat heightLabel;
    BOOL refreshing;
}
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) UIActivityIndicatorView* activity;
@property (nonatomic, strong) UILabel* textLabel;

@end

@implementation PullRefrashView


/* 调为下拉状态 */
- (void) turnPullUp {
    refreshing = NO;
    self.activity.hidden = YES;
    [self.activity stopAnimating];
    self.imageView.hidden = NO;
    self.textLabel.text = pullUpText;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    }];
}

/* 调为上拉状态 */
- (void) turnPullDown {
    refreshing = NO;
    self.activity.hidden = YES;
    [self.activity stopAnimating];
    self.imageView.hidden = NO;
    self.textLabel.text = pullDownText;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.imageView.transform = CGAffineTransformIdentity;
    }];
}
/* 调为等待状态 */
- (void) turnWaiting {
    self.activity.hidden = NO;
    self.imageView.hidden = YES;
    [self.activity startAnimating];
    self.textLabel.text = waitingText;
    refreshing = YES;
}

/* 查询状态 */
- (BOOL) isRefreshing {
    return refreshing;
}


#pragma mask ---- 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        heightContentView = 40.0;
        heightLabel = 20;
        pullUpText = @"松开即可刷新";
        pullDownText = @"下拉即可刷新";
        waitingText = @"努力加载中";
        refreshing = NO;
        [self addSubview:self.imageView];
        [self addSubview:self.textLabel];
        [self addSubview:self.activity];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat inset = 5.0;
    CGSize textSize = [self sizeOfText];
    CGFloat widthLabel = textSize.width;
    CGFloat widthImage = heightContentView;
    
    CGRect frame = CGRectMake((self.frame.size.width - widthImage - widthLabel - inset)/2.0,
                              (self.frame.size.height - heightContentView)/2.0,
                              widthImage,
                              widthImage);
    [self.imageView setFrame:frame];
    [self.activity setFrame:frame];
    
    frame.origin.x += frame.size.width + inset;
    frame.origin.y = (self.frame.size.height - heightLabel)/2.0;
    frame.size.width = widthLabel;
    frame.size.height = heightLabel;
    [self.textLabel setFrame:frame];
    
}


#pragma mask ---- PRIVATE INTERFACE
- (CGSize) sizeOfText {
    CGSize size = CGSizeZero;
    size = [self.textLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:self.textLabel.font forKey:NSFontAttributeName]];
    return size;
}


#pragma mask ---- getter
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.image = [UIImage imageNamed:@"grayPullArrow"];
    }
    return _imageView;
}
- (UILabel *)textLabel {
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.text = pullDownText;
        _textLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
        _textLabel.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:1]];
    }
    return _textLabel;
}
- (UIActivityIndicatorView *)activity {
    if (_activity == nil) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activity;
}

@end
