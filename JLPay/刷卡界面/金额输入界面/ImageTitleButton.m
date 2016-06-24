//
//  ImageTitleButton.m
//  JLPay
//
//  Created by jielian on 16/5/3.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "ImageTitleButton.h"

@implementation ImageTitleButton


- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubvews];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubvews];
    }
    return self;
}

- (void) addSubvews {
    [self addSubview:self.bImgLabel];
    [self addSubview:self.bTitleLabel];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat heightLabel = 15;
    CGFloat inset = 10;
    CGFloat imgScale = 0.38;
    
    NameWeakSelf(wself);
    
    self.bImgLabel.font = [UIFont iconFontWithSize:[@"ss" resizeFontAtHeight:self.frame.size.width * imgScale scale:0.95]];
    self.bTitleLabel.font = [UIFont boldSystemFontOfSize:[@"ss" resizeFontAtHeight:heightLabel scale:0.95]];

    [self.bImgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.mas_centerX);
        make.centerY.equalTo(wself.mas_top).offset(wself.frame.size.height * 0.4);
        make.width.height.equalTo(wself.mas_width).multipliedBy(imgScale);
    }];
    [self.bTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.mas_left);
        make.right.equalTo(wself.mas_right);
        make.top.equalTo(wself.bImgLabel.mas_bottom).offset(inset * 0.5);
        make.height.mas_equalTo(heightLabel);
    }];
    
    
}


# pragma mask 4 getter
- (UILabel *)bImgLabel {
    if (!_bImgLabel) {
        _bImgLabel = [UILabel new];
        _bImgLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _bImgLabel;
}
- (UILabel *)bTitleLabel {
    if (!_bTitleLabel) {
        _bTitleLabel = [UILabel new];
        _bTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _bTitleLabel;
}

@end
