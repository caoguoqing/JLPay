//
//  BusinessTBVHeadView.m
//  JLPay
//
//  Created by jielian on 16/6/22.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "BusinessTBVHeadView.h"
#import "Define_Header.h"
#import "Masonry.h"



@implementation BusinessTBVHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.headImgView];
        [self addSubview:self.businessNameLabel];
        [self addSubview:self.businessNoLabel];
        [self addSubview:self.checkStateBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NameWeakSelf(wself);
    CGFloat labelHeight = 20;
    CGFloat buttonHeight = 30;
    CGFloat buttonWidth = 60;
    
    self.businessNameLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:labelHeight scale:0.85]];
    self.businessNoLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:labelHeight scale:0.85]];
    self.headImgView.layer.cornerRadius = self.frame.size.height * 0.5;
    self.checkStateBtn.titleLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:buttonHeight scale:0.35]];
    
    self.checkStateBtn.layer.cornerRadius = buttonHeight * 0.5;
    
    [self.headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.mas_centerX);
        make.centerY.equalTo(wself.mas_centerY).offset( - labelHeight);
        make.height.equalTo(wself.mas_height).multipliedBy(0.5);
        make.width.equalTo(wself.headImgView.mas_height);
    }];
    [self.businessNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.mas_left);
        make.right.equalTo(wself.mas_right);
        make.top.equalTo(wself.headImgView.mas_bottom).offset(5);
        make.height.mas_equalTo(labelHeight);
    }];
    [self.businessNoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.mas_left);
        make.right.equalTo(wself.mas_right);
        make.top.equalTo(wself.businessNameLabel.mas_bottom);
        make.height.equalTo(wself.businessNameLabel.mas_height);
    }];
    [self.checkStateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(wself.headImgView.mas_centerY);
        make.centerX.equalTo(wself.mas_centerX).multipliedBy(1.6);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
    }];
}


# pragma mask 4 getter

- (UIImageView *)headImgView {
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"01_01"]];
        _headImgView.backgroundColor = [UIColor whiteColor];
    }
    return _headImgView;
}

- (UILabel *)businessNoLabel {
    if (!_businessNoLabel) {
        _businessNoLabel = [UILabel new];
        _businessNoLabel.textColor = [UIColor whiteColor];
        _businessNoLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _businessNoLabel;
}

- (UILabel *)businessNameLabel {
    if (!_businessNameLabel) {
        _businessNameLabel = [UILabel new];
        _businessNameLabel.textColor = [UIColor whiteColor];
        _businessNameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _businessNameLabel;
}

- (UIButton *)checkStateBtn {
    if (!_checkStateBtn) {
        _checkStateBtn = [UIButton new];
    }
    return _checkStateBtn;
}

@end
