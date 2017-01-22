//
//  JLViewNoData.m
//  JLPay
//
//  Created by jielian on 2017/1/19.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "JLViewNoData.h"
#import "Define_Header.h"
#import "Masonry.h"

@interface JLViewNoData()

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* titleLabel;

@end


@implementation JLViewNoData

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    NameWeakSelf(wself);
    CGFloat heightLabel = ScreenWidth * 30/320.f;
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(wself.mas_centerX);
        make.centerY.mas_equalTo(wself.mas_centerY).offset(- heightLabel * 0.5);
        make.width.height.mas_equalTo(wself.mas_width).multipliedBy(0.618);
    }];
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(wself.imageView.mas_bottom);
        make.height.mas_equalTo(heightLabel);
    }];
    
}



# pragma mask 4 getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noData"]];
    }
    return _imageView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"暂无数据";
        _titleLabel.textColor = [UIColor colorWithHex:0xe0e0e0 alpha:1];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:20];
    }
    return _titleLabel;
}

@end
