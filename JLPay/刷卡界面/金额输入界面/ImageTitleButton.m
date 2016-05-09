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
    [self addSubview:self.bImageView];
    [self addSubview:self.bTitleLabel];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat widthImageView = self.frame.size.width * 0.35;
    CGFloat heightLabel = widthImageView * 0.5;
    CGFloat inset = 10;
    
    NameWeakSelf(wself);
    
    [self.bImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.mas_centerX);
        make.bottom.equalTo(wself.mas_centerY).offset(0);
        make.width.mas_equalTo(widthImageView);
        make.height.mas_equalTo(widthImageView);
    }];
    [self.bTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.mas_left);
        make.right.equalTo(wself.mas_right);
        make.top.equalTo(wself.bImageView.mas_bottom).offset(inset * 1);
        make.height.mas_equalTo(heightLabel);
        wself.bTitleLabel.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:1]];
    }];
    
}


# pragma mask 4 getter
- (UIImageView *)bImageView {
    if (!_bImageView) {
        _bImageView = [UIImageView new];
    }
    return _bImageView;
}
- (UILabel *)bTitleLabel {
    if (!_bTitleLabel) {
        _bTitleLabel = [UILabel new];
        _bTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _bTitleLabel;
}

@end
