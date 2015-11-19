//
//  BalanceEnquiryViewController.m
//  JLPay
//
//  Created by jielian on 15/11/19.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "BalanceEnquiryViewController.h"
#import "PublicInformation.h"

@interface BalanceEnquiryViewController()

@property (nonatomic, strong) UILabel* labelCardType;   // 卡类型
@property (nonatomic, strong) UILabel* labelCardNo;     // 卡号
@property (nonatomic, strong) UILabel* labelAmountType; // 额度类型
@property (nonatomic, strong) UILabel* labelAmount;     // 余额


@end

@implementation BalanceEnquiryViewController


#pragma mask ---- 界面周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"余额";
    [self addSubviews];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    // 余额类型
    self.labelAmountType.text = [self amountTypeFromInfo];
    // 余额
    self.labelAmount.text = [NSString stringWithFormat:@"￥ %@",[self amountFromInfo]];
    // 卡号
    self.labelCardNo.text = [NSString stringWithFormat:@"%@(%@)",[self cardNoFromInfo],[self cardTypeFromInfo]];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mask ---- PRIVATE INTERFACE
/* 加载子视图 */
- (void) addSubviews {
    [self.view addSubview:self.labelAmountType];
    [self.view addSubview:self.labelAmount];
    [self.view addSubview:self.labelCardNo];

    
    CGFloat naviAndStatusHeight = [PublicInformation heightOfNavigationAndStatusInVC:self];
    CGFloat heightAmountType = 30;  // 金额类型高度
    CGFloat heightAmount = 45; // 金额高度
    CGFloat heightCardNo = 100; // 卡号高度
    CGFloat insetWidth = 30; // 宽度边界
    CGFloat insetHeight = 100; // 高度边界
    CGFloat widthCardNo = self.view.frame.size.width - insetWidth*2; // 卡号长度
    
    
    CGRect frame = CGRectMake(0,
                              naviAndStatusHeight + insetHeight,
                              self.view.frame.size.width,
                              heightAmountType);
    // 金额类型
    [self.labelAmountType setFrame:frame];
    [self.view addSubview:self.labelAmountType];
    
    // 金额
    frame.origin.y += frame.size.height;
    frame.size.height = heightAmount;
    [self.labelAmount setFrame:frame];
    
    // 卡号
    frame.origin.x = insetWidth;
    frame.origin.y += frame.size.height + insetWidth;
    frame.size.width = widthCardNo;
    frame.size.height = heightCardNo;
    [self.labelCardNo setFrame:frame];
}


/* 余额类型 */
- (NSString*) amountTypeFromInfo {
    NSString* amountType = nil;
    NSString* f54 = [self.transInfo valueForKey:@"54"];
    if (f54 && f54.length == 20) {
        amountType = [f54 substringToIndex:2];
    }
    if ([amountType isEqualToString:@"01"]) {
        amountType = @"账户金额";
    }
    else if ([amountType isEqualToString:@"02"]) {
        amountType = @"可用金额";
    }
    else if ([amountType isEqualToString:@"03"]) {
        amountType = @"拥有金额";
    }
    else if ([amountType isEqualToString:@"04"]) {
        amountType = @"应付金额";
    }
    else if ([amountType isEqualToString:@"40"]) {
        amountType = @"可用取款限额";
    }
    else if ([amountType isEqualToString:@"56"]) {
        amountType = @"可用转账限额";
    }
    else {
        amountType = @"余额";
    }
    return amountType;
}
/* 余额 */
- (NSString*) amountFromInfo {
    NSString* amount = nil;
    NSString* f54 = [self.transInfo valueForKey:@"54"];
    if (f54 && f54.length == 20) {
        amount = [f54 substringWithRange:NSMakeRange(f54.length - 12, 12)];
        amount = [PublicInformation dotMoneyFromNoDotMoney:amount];
    }
    return amount;
}
/* 卡类型 */
- (NSString*) cardTypeFromInfo {
    NSString* cardType = nil;
    NSString* f54 = [self.transInfo valueForKey:@"54"];
    if (f54 && f54.length == 20) {
        cardType = [f54 substringWithRange:NSMakeRange(2, 2)];
        NSLog(@"卡类型:[%@]",cardType);
        if ([cardType isEqualToString:@"10"]) {
            cardType = @"储蓄卡";
        }
        else if ([cardType isEqualToString:@"30"]) {
            cardType = @"信用卡";
        }
    }
    return cardType;
}
/* 卡号 */
- (NSString*) cardNoFromInfo {
    NSString* cardNo = [self.transInfo valueForKey:@"2"];
    cardNo = [PublicInformation cuttingOffCardNo:cardNo];
    return cardNo;
}

#pragma mask ---- getter
/* 金额类型 */
- (UILabel *)labelAmountType {
    if (_labelAmountType == nil) {
        _labelAmountType = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelAmountType.textAlignment = NSTextAlignmentCenter;
        _labelAmountType.textColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        _labelAmountType.font = [UIFont systemFontOfSize:20];
    }
    return _labelAmountType;
}
/* 金额 */
- (UILabel *)labelAmount {
    if (_labelAmount == nil) {
        _labelAmount = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelAmount.textAlignment = NSTextAlignmentCenter;
        _labelAmount.textColor = [PublicInformation returnCommonAppColor:@"green"];
        _labelAmount.font = [UIFont systemFontOfSize:40];
    }
    return _labelAmount;
}
/* 卡号 */
- (UILabel *)labelCardNo {
    if (_labelCardNo == nil) {
        _labelCardNo = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelCardNo.backgroundColor = [UIColor blueColor];
        _labelCardNo.textColor = [UIColor whiteColor];
        _labelCardNo.textAlignment = NSTextAlignmentCenter;
        _labelCardNo.font = [UIFont systemFontOfSize:30];
    }
    return _labelCardNo;
}


@end
