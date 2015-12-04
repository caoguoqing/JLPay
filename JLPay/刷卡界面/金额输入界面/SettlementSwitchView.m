//
//  SettlementSwitchView.m
//  JLPay
//
//  Created by jielian on 15/12/4.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "SettlementSwitchView.h"
#import "PublicInformation.h"


static NSString* const stringSettlementOrigin = @"结算方式: ";
static NSString* const stringSettlementT_1 = @"T+1";
static NSString* const stringSettlementT_0 = @"T+0";
static NSString* const stringSettlementD_1 = @"D+1";
static NSString* const stringSettlementD_0 = @"D+0";

@interface SettlementSwitchView()

@property (nonatomic, strong) UILabel* labelSettlementDisplay; // 显示标签
@property (nonatomic, strong) UIButton* buttonSwitch;   // 切换按钮

@end

@implementation SettlementSwitchView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.labelSettlementDisplay];
        [self addSubview:self.buttonSwitch];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    UIFont* fontLabelText = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:self.frame.size andScale:1.0]];
    [self.labelSettlementDisplay setFont:fontLabelText];
    [self.labelSettlementDisplay sizeToFit];
    self.labelSettlementDisplay.layer.position = CGPointMake(0.0, 0.0);
    self.labelSettlementDisplay.layer.anchorPoint = CGPointMake(0.0, 0.0);
    
    [self.buttonSwitch.titleLabel setFont:fontLabelText];
    [self.buttonSwitch sizeToFit];
    self.buttonSwitch.layer.position = CGPointMake(self.labelSettlementDisplay.bounds.size.width, 0.0);
    self.buttonSwitch.layer.anchorPoint = CGPointMake(0.0, 0.0);
}

#pragma mask ---- getter
- (UILabel *)labelSettlementDisplay {
    if (_labelSettlementDisplay == nil) {
        _labelSettlementDisplay = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelSettlementDisplay.text = [NSString stringWithFormat:@"%@%@,",stringSettlementOrigin,stringSettlementT_1];
        _labelSettlementDisplay.textColor = [UIColor blackColor];
        _labelSettlementDisplay.textAlignment = NSTextAlignmentLeft;
    }
    return _labelSettlementDisplay;
}
- (UIButton *)buttonSwitch {
    if (_buttonSwitch == nil) {
        _buttonSwitch = [[UIButton alloc] initWithFrame:CGRectZero];
        [_buttonSwitch setTitle:@"切换" forState:UIControlStateNormal];
        [_buttonSwitch setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    return _buttonSwitch;
}

@end
