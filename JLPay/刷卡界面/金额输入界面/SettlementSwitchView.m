//
//  SettlementSwitchView.m
//  JLPay
//
//  Created by jielian on 15/12/4.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "SettlementSwitchView.h"
#import "PublicInformation.h"



@interface SettlementSwitchView()
@property (nonatomic, assign) SETTLEMENTTYPE curSettlementType;
@property (nonatomic, strong) UILabel* labelSettlementDisplay; // 显示标签
@property (nonatomic, strong) UIButton* buttonSwitch;   // 切换按钮

@end

@implementation SettlementSwitchView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.enableSwitching = NO;
        self.curSettlementType = [[ModelSettlementInformation sharedInstance] curSettlementType];
        
        [self addSubview:self.labelSettlementDisplay];
        [self addSubview:self.buttonSwitch];
        
        [self addObserver:self forKeyPath:@"enableSwitching" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"curSettlementType" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    // 重载包括: frame, 颜色, 字体等
    UIFont* fontLabelText = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:self.frame.size andScale:1.0]];
    self.labelSettlementDisplay.text = [self textSettlementDisplayWithType:self.curSettlementType];
    [self.labelSettlementDisplay setFont:fontLabelText];
    [self.labelSettlementDisplay sizeToFit];
    self.labelSettlementDisplay.layer.position = CGPointMake(0.0, 0.0);
    self.labelSettlementDisplay.layer.anchorPoint = CGPointMake(0.0, 0.0);
    self.labelSettlementDisplay.textColor = (!self.enableSwitching)?([UIColor colorWithWhite:0.3 alpha:1]):([UIColor grayColor]);
    
    [self.buttonSwitch.titleLabel setFont:fontLabelText];
    [self.buttonSwitch sizeToFit];
    CGRect bound = self.buttonSwitch.bounds;
    bound.size.height = self.frame.size.height;
    [self.buttonSwitch setBounds:bound];
    self.buttonSwitch.layer.position = CGPointMake(self.labelSettlementDisplay.bounds.size.width, 0.0);
    self.buttonSwitch.layer.anchorPoint = CGPointMake(0.0, 0.0);
    if (self.enableSwitching) {
        self.buttonSwitch.hidden = NO;
    } else {
        self.buttonSwitch.hidden = YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"enableSwitching"] ||
        [keyPath isEqualToString:@"curSettlementType"]
        )
    {
        // 重载视图
        [self setNeedsLayout];
    }
}

/* 切换回正常状态 */
- (void) switchNormal {
    switch (self.curSettlementType) {
        case SETTLEMENTTYPE_T_0:
            [self clickToSwichSettlementType];  // 要回调
            break;
        default:
            // do nothing
            break;
    }
}


#pragma mask ---- 点击切换
- (void) clickToSwichSettlementType {
    if (!self.enableSwitching) {
        return;
    }
    // 根据当前值切换
    [self switchSettlementType];
    // 回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSwitchedSettlementType:)]) {
        [self.delegate didSwitchedSettlementType:self.curSettlementType];
    }
}


#pragma mask ---- PRIVATE INTERFACE

/* 组织结算方式的提示文本 */
- (NSString*) textSettlementDisplayWithType:(SETTLEMENTTYPE)settlementType {
    NSString* text = nil;
    if (self.enableSwitching) {
        text = [NSString stringWithFormat:@"结算方式: %@,", [ModelSettlementInformation nameOfSettlementType:settlementType]];
    } else {
        text = [NSString stringWithFormat:@"结算方式: %@", [ModelSettlementInformation nameOfSettlementType:settlementType]];
    }
    return text;
}

/* 切换枚举值 */
- (void) switchSettlementType {
//    [[ModelSettlementInformation sharedInstance] switchingSettleType];
    self.curSettlementType = [[ModelSettlementInformation sharedInstance] curSettlementType];
}

#pragma mask ---- getter
- (UILabel *)labelSettlementDisplay {
    if (_labelSettlementDisplay == nil) {
        _labelSettlementDisplay = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelSettlementDisplay.textAlignment = NSTextAlignmentLeft;
    }
    return _labelSettlementDisplay;
}
- (UIButton *)buttonSwitch {
    if (_buttonSwitch == nil) {
        _buttonSwitch = [[UIButton alloc] initWithFrame:CGRectZero];
        [_buttonSwitch setTitle:@"切换" forState:UIControlStateNormal];
        [_buttonSwitch setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
        [_buttonSwitch addTarget:self action:@selector(clickToSwichSettlementType) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonSwitch;
}

@end
