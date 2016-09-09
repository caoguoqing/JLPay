//
//  JLPWDInputsView.m
//  TestForJLPasswordView
//
//  Created by jielian on 16/8/15.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "JLPWDInputsView.h"
#import "UIColor+HexColor.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>


@implementation JLPWDInputsView

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

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = [UIColor colorWithHex:0xeeeeee alpha:1];
    
}

- (void) loadSubviews {
    [self addSubview:self.titleLabel];
    [self addSubview:self.seperatedLine1];
    for (int i = 0; i < self.pinLabels.count; i++) {
        [self addSubview:[self.pinLabels objectAtIndex:i]];
    }
    [self addSubview:self.sureBtn];
    [self addSubview:self.cancelBtn];
    
    [self addSubview:self.seperatedLine3];
    [self addSubview:self.seperatedLine2];
}




- (void)updateConstraints {
    
    CGFloat inset = 15;
    CGFloat widthLabel = self.frame.size.width * 0.618 * 1.f/(CGFloat)self.pinLabels.count;//44;
    
    __weak JLPWDInputsView* wself = self;
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wself.mas_left);
        make.right.mas_equalTo(wself.mas_right);
        make.top.mas_equalTo(wself.mas_top);
        make.height.mas_equalTo(wself.mas_height).multipliedBy(1/4.f);
        
    }];
    
    [self.seperatedLine1 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wself.mas_left).offset(inset);
        make.right.mas_equalTo(wself.mas_right).offset(-inset);
        make.top.mas_equalTo(wself.titleLabel.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wself.mas_left);
        make.right.mas_equalTo(wself.mas_centerX);
        make.bottom.mas_equalTo(wself.mas_bottom);
        make.height.mas_equalTo(wself.mas_height).multipliedBy(1/3.5f);
    }];
    
    [self.sureBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wself.cancelBtn.mas_right);
        make.right.mas_equalTo(wself.mas_right);
        make.bottom.mas_equalTo(wself.cancelBtn.mas_bottom);
        make.top.mas_equalTo(wself.cancelBtn.mas_top);
    }];
    
    [self.seperatedLine2 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wself.mas_left);
        make.right.mas_equalTo(wself.mas_right);
        make.top.mas_equalTo(wself.cancelBtn.mas_top);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.seperatedLine3 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(wself.cancelBtn.mas_top);
        make.bottom.mas_equalTo(wself.mas_bottom);
        make.centerX.mas_equalTo(wself.mas_centerX);
        make.width.mas_equalTo(0.5);
    }];
    
    for (int i = 0; i < self.pinLabels.count; i++) {
        UILabel* label = [self.pinLabels objectAtIndex:i];
        [label mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(wself.seperatedLine1.mas_bottom).offset(inset);
            make.bottom.mas_equalTo(wself.cancelBtn.mas_top).offset(-inset);
            make.centerX.mas_equalTo(wself.mas_centerX).offset((i - 3) * widthLabel + widthLabel * 0.5);
            make.width.mas_equalTo(widthLabel);
        }];
    }
    
    
    [super updateConstraints];
}





# pragma mask 2 KVO

- (void) addKVOs {
    @weakify(self);
    [RACObserve(self, pinInputs) subscribeNext:^(NSString* inputs) {
        @strongify(self);
        for (int i = 0; i < self.pinLabels.count; i++) {
            UILabel* label = [self.pinLabels objectAtIndex:i];
            NSInteger len = (inputs && inputs.length > 0) ? (inputs.length) : (0);
            label.text = (i < len) ? (@"*") : (@"-");
        }
    }];
    
//    RAC(self.sureBtn, enabled) = [RACObserve(self, pinInputs) map:^NSNumber* (NSString* pin) {
//        return @(pin && pin.length > 3);
//    }];
}

# pragma mask 4 getter

- (UIButton *)sureBtn {
    if (!_sureBtn) {
        _sureBtn = [UIButton new];
        [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor colorWithHex:HexColorTypeGreen alpha:1] forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor colorWithHex:HexColorTypeGreen alpha:0.3] forState:UIControlStateDisabled];
        [_sureBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        _sureBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    return _sureBtn;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton new];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.7] forState:UIControlStateHighlighted];
        _cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    return _cancelBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _titleLabel;
}

- (UIView *)seperatedLine1 {
    if (!_seperatedLine1) {
        _seperatedLine1 = [UIView new];
        _seperatedLine1.backgroundColor = [UIColor colorWithHex:HexColorTypeGreen alpha:1];
    }
    return _seperatedLine1;
}

- (UIView *)seperatedLine2 {
    if (!_seperatedLine2) {
        _seperatedLine2 = [UIView new];
        _seperatedLine2.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.7];
    }
    return _seperatedLine2;
}

- (UIView *)seperatedLine3 {
    if (!_seperatedLine3) {
        _seperatedLine3 = [UIView new];
        _seperatedLine3.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.7];
    }
    return _seperatedLine3;
}


- (NSArray *)pinLabels {
    if (!_pinLabels) {
        NSMutableArray* labels = [NSMutableArray array];
        for (int i = 0; i < 6; i++) {
            UILabel* label = [UILabel new];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
            label.font = [UIFont boldSystemFontOfSize:28];
            [labels addObject:label];
        }
        _pinLabels = [NSArray arrayWithArray:labels];
    }
    return _pinLabels;
}

@end
