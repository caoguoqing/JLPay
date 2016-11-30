//
//  MTVC_screenView.m
//  CustomViewMaker
//
//  Created by jielian on 16/9/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MTVC_screenView.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>
#import "Define_Header.h"


@interface MTVC_screenView()

@end

@implementation MTVC_screenView


- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadSubviews];
        [self addKVOs];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubviews];
        [self addKVOs];
    }
    return self;
}

- (void) loadSubviews {
    [self addSubview:self.moneyLabel];
    [self addSubview:self.settlementSwitchBtn];
    [self addSubview:self.businessLabel];
    [self addSubview:self.deviceConnectBtn];
}

- (void) addKVOs {
    @weakify(self);
    
    [RACObserve(self, deviceBtnAttriTitle) subscribeNext:^(id x) {
        @strongify(self);
        [self.deviceConnectBtn setAttributedTitle:x forState:UIControlStateNormal];
    }];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.moneyLabel.font = [UIFont boldSystemFontOfSize:[@"test" resizeFontAtHeight:self.moneyLabel.bounds.size.height scale:1]];
    
    CGFloat height = self.settlementSwitchBtn.frame.size.height;
    self.settlementSwitchBtn.layer.cornerRadius = height * 0.5;
    self.settlementSwitchBtn.titleLabel.font = [UIFont boldSystemFontOfSize:[NSString resizeFontAtHeight:height scale:0.6]];
    self.settlementSwitchBtn.switchLabel.font = [UIFont iconFontWithSize:[NSString resizeFontAtHeight:height scale:0.5]];
}


- (void)updateConstraints {
    CGFloat littleLabelHeight = [UIScreen mainScreen].bounds.size.height * 20/568.f;
    CGFloat moneyLabHeight = [UIScreen mainScreen].bounds.size.height * 35/568.f;
    CGFloat settleTypeLabWidth = [UIScreen mainScreen].bounds.size.width * 52/320.f;
    CGFloat inset = [UIScreen mainScreen].bounds.size.height * 15/568.f;
    
    
    __weak typeof(self) wself = self;
    
    
    [self.moneyLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.centerY.mas_equalTo(wself.mas_centerY);
        make.height.mas_equalTo(moneyLabHeight);
    }];
    
    [self.settlementSwitchBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(inset);
        make.height.mas_equalTo(littleLabelHeight);
        make.width.mas_equalTo(settleTypeLabWidth);
    }];

    
    [self.businessLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(inset);
        make.bottom.mas_equalTo(- inset);
        make.height.mas_equalTo(littleLabelHeight);
        make.right.mas_equalTo(0);
    }];
    
    
    [self.deviceConnectBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(- inset);
        make.left.mas_equalTo(wself.mas_centerX).offset(inset);
        make.top.mas_equalTo(wself.settlementSwitchBtn.mas_top);
        make.bottom.mas_equalTo(wself.settlementSwitchBtn.mas_bottom);
    }];
    
    [super updateConstraints];
}





# pragma mask 4 getter

- (UILabel *)moneyLabel {
    if (!_moneyLabel) {
        _moneyLabel = [UILabel new];
        _moneyLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _moneyLabel;
}


- (MTVC_settlementSwitchBtn *)settlementSwitchBtn {
    if (!_settlementSwitchBtn) {
        _settlementSwitchBtn = [[MTVC_settlementSwitchBtn alloc] init];
        _settlementSwitchBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _settlementSwitchBtn.layer.borderWidth = 1.f;
    }
    return _settlementSwitchBtn;
}

- (UILabel *)businessLabel {
    if (!_businessLabel) {
        _businessLabel = [UILabel new];
    }
    return _businessLabel;
}


- (UIButton *)deviceConnectBtn {
    if (!_deviceConnectBtn) {
        _deviceConnectBtn = [UIButton new];
        [_deviceConnectBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_deviceConnectBtn setTitleColor:[UIColor colorWithWhite:0.2 alpha:0.3] forState:UIControlStateHighlighted];
    }
    return _deviceConnectBtn;
}

@end
