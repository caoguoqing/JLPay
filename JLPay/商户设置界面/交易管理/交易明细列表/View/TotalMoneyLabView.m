//
//  TotalMoneyLabView.m
//  JLPay
//
//  Created by jielian on 16/5/4.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "TotalMoneyLabView.h"

@implementation TotalMoneyLabView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubviews];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void) addSubviews {
    self.backgroundColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
    [self addSubview:self.titleLabel];
    [self addSubview:self.totalMoneyLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.frame.size.width == 0) {
        return;
    }
    [self makeConstraints];
}

- (void) makeConstraints {
    CGFloat heightTitleLabel = 20;
    CGFloat heightMoneyLabel = self.frame.size.height * 0.5;
    CGFloat inset = (self.frame.size.height - heightTitleLabel - heightMoneyLabel) * 0.5;
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:[@"test" resizeFontAtHeight:heightTitleLabel scale:0.78]];
    self.totalMoneyLabel.font = [UIFont boldSystemFontOfSize:[@"test" resizeFontAtHeight:heightMoneyLabel scale:1]];
    
    NameWeakSelf(wself);
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.mas_top).offset(inset);
        make.left.equalTo(wself.mas_left);
        make.right.equalTo(wself.mas_right);
        make.height.mas_equalTo(heightTitleLabel);
    }];
    [self.totalMoneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.titleLabel.mas_bottom);
        make.left.equalTo(wself.mas_left);
        make.right.equalTo(wself.mas_right);
        make.height.mas_equalTo(heightMoneyLabel);
    }];
}

# pragma mask 4 getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"交易总额";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}
- (UILabel *)totalMoneyLabel {
    if (!_totalMoneyLabel) {
        _totalMoneyLabel = [UILabel new];
        _totalMoneyLabel.text = @"￥0.00";
        _totalMoneyLabel.textAlignment = NSTextAlignmentCenter;
        _totalMoneyLabel.textColor = [UIColor whiteColor];
    }
    return _totalMoneyLabel;
}

@end
