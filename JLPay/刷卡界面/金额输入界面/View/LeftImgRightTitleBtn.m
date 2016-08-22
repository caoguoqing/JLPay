//
//  LeftImgRightTitleBtn.m
//  JLPay
//
//  Created by jielian on 16/7/18.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "LeftImgRightTitleBtn.h"
#import "Masonry.h"
#import "Define_Header.h"



@implementation LeftImgRightTitleBtn

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadSubviews];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void) loadSubviews {
    [self addSubview:self.leftImgView];
    [self addSubview:self.rightTitleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NameWeakSelf(wself);
    
    [self.rightTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.mas_centerX);
        make.top.equalTo(wself.mas_top);
        make.bottom.equalTo(wself.mas_bottom);
        CGSize textSize = [wself.rightTitleLabel.text sizeWithAttributes:@{NSFontAttributeName:wself.rightTitleLabel.font}];
        make.width.mas_equalTo(textSize.width + 10);
    }];
    
    [self.leftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wself.rightTitleLabel.mas_left);
        make.centerY.equalTo(wself.mas_centerY);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
}


# pragma mask 4 getter

- (UIImageView *)leftImgView {
    if (!_leftImgView) {
        _leftImgView = [UIImageView new];
    }
    return _leftImgView;
}

- (UILabel *)rightTitleLabel {
    if (!_rightTitleLabel) {
        _rightTitleLabel = [UILabel new];
        _rightTitleLabel.textAlignment = NSTextAlignmentCenter;
        _rightTitleLabel.textColor = [UIColor whiteColor];
        _rightTitleLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    return _rightTitleLabel;
}


@end
