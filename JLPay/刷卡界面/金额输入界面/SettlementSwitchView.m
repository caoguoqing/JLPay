//
//  SettlementSwitchView.m
//  JLPay
//
//  Created by jielian on 15/12/4.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "SettlementSwitchView.h"
#import "PublicInformation.h"


static NSString* const stringSettlementT_1 = @"T+1";
static NSString* const stringSettlementT_0 = @"T+0";


@interface SettlementSwitchView()
{
    SETTLEMENTTYPE curSettlementTYpe;
}
@property (nonatomic, strong) UILabel* labelSettlementDisplay; // 显示标签
@property (nonatomic, strong) UIButton* buttonSwitch;   // 切换按钮

@end

@implementation SettlementSwitchView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        curSettlementTYpe = SETTLEMENTTYPE_T_1;
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
    self.labelSettlementDisplay.textColor = (self.enableSwitching)?([UIColor colorWithWhite:0.3 alpha:1]):([UIColor grayColor]);
    self.labelSettlementDisplay.text = [self textSettlementDisplayWithType:curSettlementTYpe];

    
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

/* 切换回正常状态 */
- (void) switchNormal {
    switch (curSettlementTYpe) {
        case SETTLEMENTTYPE_T_0:
            [self clickToSwichSettlementType];
            break;
        case SETTLEMENTTYPE_T_1:
            // do nothing
            break;
        default:
            // do nothing
            break;
    }
}


#pragma mask ---- 点击切换
- (void) clickToSwichSettlementType {
    // 根据当前值切换
    curSettlementTYpe = curSettlementTYpe << 1;
    if (![self enumExistsSettlemenType:curSettlementTYpe]) {
        curSettlementTYpe = SETTLEMENTTYPE_T_1;
    }
    // 更新显示文本
    [self.labelSettlementDisplay setText:[self textSettlementDisplayWithType:curSettlementTYpe]];
    [self setNeedsLayout];
    // 回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSwitchedSettlementType:)]) {
        [self.delegate didSwitchedSettlementType:curSettlementTYpe];
    }
}

#pragma mask ---- 获取结算方式的描述文本
/* 当前结算方式文本: 指定结算方式枚举量 */
- (NSString*) textCurrentSettlementType:(SETTLEMENTTYPE)settlementType {
    NSString* text = nil;
    switch (settlementType) {
        case SETTLEMENTTYPE_T_0:
            text = stringSettlementT_0;
            break;
        case SETTLEMENTTYPE_T_1:
            text = stringSettlementT_1;
            break;
        default:
            text = stringSettlementT_1;
            break;
    }
    return text;
}

#pragma mask ---- PRIVATE INTERFACE

/* 组织结算方式的提示文本 */
- (NSString*) textSettlementDisplayWithType:(SETTLEMENTTYPE)settlementType {
    NSString* text = nil;
    if (self.enableSwitching) {
        text = [NSString stringWithFormat:@"结算方式: %@,", [self textCurrentSettlementType:settlementType]];
    } else {
        text = [NSString stringWithFormat:@"结算方式: %@", [self textCurrentSettlementType:settlementType]];
    }
    return text;
}
/* 检查枚举是否存在指定的类型 */
- (BOOL) enumExistsSettlemenType:(NSInteger)type {
    BOOL exists = NO;
    switch (type) {
        case SETTLEMENTTYPE_T_0:
        case SETTLEMENTTYPE_T_1:
            exists = YES;
            break;
        default:
            break;
    }
    return exists;
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
