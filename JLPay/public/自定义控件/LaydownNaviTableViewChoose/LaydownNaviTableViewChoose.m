//
//  LaydownNaviTableViewChoose.m
//  JLPay
//
//  Created by jielian on 16/8/24.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "LaydownNaviTableViewChoose.h"



@interface LaydownNaviTableViewChoose()

@property (nonatomic, strong) UIView* bgView; /* 背景: 黑色透明 */

@property (nonatomic, weak) UIView* dispView;


@end




@implementation LaydownNaviTableViewChoose

# pragma mask 0 public funcs 

- (void)show {
    [self.dispView addSubview:self];
    self.hidden = NO;
    
    __weak LaydownNaviTableViewChoose* wself = self;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.bgView.alpha = 0.4;
        
        CGRect frame = wself.dataTableView.frame;
        frame.origin.y = 0;
        wself.dataTableView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hide {
    __weak LaydownNaviTableViewChoose* wself = self;

    [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.bgView.alpha = 0.0;
        
        CGRect frame = wself.dataTableView.frame;
        frame.origin.y -= frame.size.height;
        wself.dataTableView.frame = frame;
    } completion:^(BOOL finished) {
        [wself removeFromSuperview];
        wself.hidden = YES;
    }];
}



# pragma mask 4 生命周期和布局

- (instancetype)initWithSuperView:(UIView *)superView {
    self = [super init];
    if (self) {
        self.dispView = superView;
        CGFloat height = [UIScreen mainScreen].bounds.size.height - 64;
        self.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, height);
        [self loadSubviews];
        [self setLayoutsOfSubviews];
        self.hidden = YES;
    }
    return self;
}


- (void) loadSubviews {
    [self addSubview:self.bgView];
    [self addSubview:self.dataTableView];
}

- (void) setLayoutsOfSubviews {
    CGRect frame = self.bounds;
    
    [self.bgView setFrame:frame];
    
    frame.origin.y -= frame.size.height;
    [self.dataTableView setFrame:frame];

}


# pragma mask 4 getter

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0.0;
    }
    return _bgView;
}


- (UITableView *)dataTableView {
    if (!_dataTableView) {
        _dataTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _dataTableView.backgroundColor = [UIColor clearColor];
        _dataTableView.tableFooterView = [UIView new];
        
    }
    return _dataTableView;
}


@end
