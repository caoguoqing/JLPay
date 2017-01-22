//
//  TLVC_vTotalDetailView.m
//  JLPay
//
//  Created by jielian on 2017/1/13.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "TLVC_vTotalDetailView.h"
#import "Define_Header.h"
#import "Masonry.h"


@implementation TLVC_vTotalDetailView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHex:0x27384b alpha:1];
        [self loadSubviews];
    }
    return self;
}

- (void) loadSubviews {
    [self addSubview:self.titleLabel];
    [self addSubview:self.totalMoneyLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NameWeakSelf(wself);
    CGFloat heightTitle = ScreenWidth * 20/320.f;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(wself.mas_centerY).multipliedBy(2 * (1 - 0.618));
        make.height.mas_equalTo(heightTitle);
    }];
    [self.totalMoneyLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(wself.titleLabel.mas_bottom);
        make.height.mas_equalTo(wself.mas_height).multipliedBy(0.3);
    }];
}


# pragma mask 4 getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"交易总额";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UILabel *)totalMoneyLabel {
    if (!_totalMoneyLabel) {
        _totalMoneyLabel = [UILabel new];
        _totalMoneyLabel.textAlignment = NSTextAlignmentCenter;
        _totalMoneyLabel.font = [UIFont boldSystemFontOfSize:32];
        _totalMoneyLabel.textColor = [UIColor whiteColor];
    }
    return _totalMoneyLabel;
}

@end
