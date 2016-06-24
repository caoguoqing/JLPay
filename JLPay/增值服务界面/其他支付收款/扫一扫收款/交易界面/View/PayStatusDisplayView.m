//
//  PayStatusDisplayView.m
//  JLPay
//
//  Created by jielian on 16/4/27.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "PayStatusDisplayView.h"

@implementation PayStatusDisplayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void) addSubviews {
    [self addSubview:self.imageView];
    [self addSubview:self.labelMoney];
    [self addSubview:self.labelGoodsName];
    [self addSubview:self.labelStatus];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self loadSubviews];
}

- (void) loadSubviews {
    CGRect frame = self.frame;
    CGFloat insetMin = 5;
    CGFloat heightImageView = frame.size.height * 0.28;
    CGFloat heightLabel = heightImageView * 0.5;
    CGFloat insetBig = (frame.size.height - heightImageView - heightLabel * 3 - insetMin * 2) * 0.5;
    
    NameWeakSelf(wself);
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.mas_top).offset(insetBig);
        make.centerX.equalTo(wself.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(heightImageView, heightImageView));
    }];
    
    [self.labelStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.imageView.mas_bottom).offset(insetMin * 2.4);
        make.left.equalTo(wself.mas_left);
        make.right.equalTo(wself.mas_right);
        make.height.mas_equalTo(heightLabel);
        wself.labelStatus.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:0.78]];
    }];
    
    [self.labelMoney mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.labelStatus.mas_bottom).offset(insetMin);
        make.left.equalTo(wself.mas_left);
        make.right.equalTo(wself.mas_right);
        make.height.mas_equalTo(heightLabel);
        wself.labelMoney.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:1.1]];
    }];
    
    [self.labelGoodsName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.labelMoney.mas_bottom).offset(0);
        make.left.equalTo(wself.mas_left);
        make.right.equalTo(wself.mas_right);
        make.height.mas_equalTo(heightLabel);
        wself.labelGoodsName.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:0.66]];
    }];
}


# pragma mask 4 getter 
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
    }
    return _imageView;
}
- (UILabel *)labelStatus {
    if (!_labelStatus) {
        _labelStatus = [UILabel new];
        _labelStatus.textAlignment = NSTextAlignmentCenter;
    }
    return _labelStatus;
}
- (UILabel *)labelMoney {
    if (!_labelMoney) {
        _labelMoney = [UILabel new];
        _labelMoney.textAlignment = NSTextAlignmentCenter;
        _labelMoney.textColor = [UIColor blackColor];
    }
    return _labelMoney;
}
- (UILabel *)labelGoodsName {
    if (!_labelGoodsName) {
        _labelGoodsName = [UILabel new];
        _labelGoodsName.textAlignment = NSTextAlignmentCenter;
        _labelGoodsName.textColor = [PublicInformation returnCommonAppColor:@"blueBlack"];
    }
    return _labelGoodsName;
}

@end
