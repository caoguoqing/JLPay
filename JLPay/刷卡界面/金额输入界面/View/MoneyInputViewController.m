//
//  MoneyInputViewController.m
//  JLPay
//
//  Created by jielian on 16/7/18.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MoneyInputViewController.h"
#import "Define_Header.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>
#import "VMNumberBtns.h"
#import "LeftImgRightTitleBtn.h"
#import "MLoginSavedResource.h"
#import "ModelDeviceBindedInformation.h"
#import "JCAlertView.h"
#import "DeviceConnectViewController.h"
#import "ModelSettlementInformation.h"
#import "BrushViewController.h"
#import "ModelRateInfoSaved.h"
#import "ModelBusinessInfoSaved.h"
#import "VMT_0InfoRequester.h"
#import "VMOtherPayType.h"
#import "CodeScannerViewController.h"
#import "LeftImgRightTitleBtn.h"

#import "EncodeString.h"



@implementation MoneyInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"商户收款";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    [self loadSubviews];
    [self layoutSubviews];
    [self addKVOs];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.tabBarController.tabBar.hidden = NO;
    [self.vmStlmentInfo.cmdRequestStlInfo execute:nil];
}


- (void) loadSubviews {
    [self.view addSubview:self.moneyLabel];
    [self.view addSubview:self.switchItemBackView];
    [self.view addSubview:self.leftImgView];
    [self.view addSubview:self.rightImgView];
    [self.view addSubview:self.switchItemScrollView];
    for (UIButton* btn in [VMNumberBtns sharedNumberInput].keyNumBtns) {
        [self.view addSubview:btn];
    }
    for (UIView* seperateView in self.seperatorViews) {
        [self.view addSubview:seperateView];
    }
}

- (void) layoutSubviews {
    CGFloat heightUnit = 50;
    CGFloat heightBtn = (self.view.frame.size.height - 64 - self.tabBarController.tabBar.frame.size.height - heightUnit) * 0.5 * 0.25;
    CGFloat inset = 5;
    CGFloat imgWidth = 30;
    
    NameWeakSelf(wself);
    
    [self.switchItemBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.bottom.equalTo(wself.view.mas_bottom).offset(- wself.tabBarController.tabBar.frame.size.height);
        make.height.mas_equalTo(55);
    }];
    
    [self.leftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.switchItemBackView.mas_left).offset(inset);
        make.centerY.equalTo(wself.switchItemBackView.mas_centerY);
        make.width.mas_equalTo(imgWidth);
        make.height.mas_equalTo(imgWidth);
    }];
    
    [self.rightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wself.switchItemBackView.mas_right).offset(-inset);
        make.centerY.equalTo(wself.switchItemBackView.mas_centerY);
        make.width.mas_equalTo(imgWidth);
        make.height.mas_equalTo(imgWidth);
    }];
    
    
    for (NSInteger index = NumBtnKeyDelete; index >= NumBtnKey1; index--) {
        UIButton* numberBtn = [[VMNumberBtns sharedNumberInput].keyNumBtns objectAtIndex:index - 1];
        [numberBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(wself.switchItemBackView.mas_top).offset(- heightBtn * (4 - (index - 1)/3 - 1));
            make.left.equalTo(wself.view.mas_left).offset(wself.view.frame.size.width * 1.f/3.f * ((index - 1) % 3));
            make.width.equalTo(wself.view.mas_width).multipliedBy(1.f/3.f);
            make.height.mas_equalTo(heightBtn);
        }];
    }
    
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.view.mas_top).offset(64);
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.bottom.equalTo([[[VMNumberBtns sharedNumberInput].keyNumBtns objectAtIndex:0] mas_top]);
    }];
    
    CGFloat widthSeperateView = 0.5;
    for (int i = 0; i < 4; i++ ) {
        UIView* seperateView = [self.seperatorViews objectAtIndex:i];
        UIButton* firstLeftNumberBtnAtLineIndex = [[[VMNumberBtns sharedNumberInput] keyNumBtns] objectAtIndex:i * 3];
        [seperateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wself.view.mas_left);
            make.right.equalTo(wself.view.mas_right);
            make.top.equalTo(firstLeftNumberBtnAtLineIndex.mas_top);
            make.height.mas_equalTo(widthSeperateView);
        }];
    }
    
    [self.seperatorViews[4] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.top.equalTo(wself.switchItemBackView.mas_top).offset(-widthSeperateView);
        make.height.mas_equalTo(widthSeperateView);
    }];
    
    for (int i = 5; i < self.seperatorViews.count; i++) {
        UIView* seperateView = [self.seperatorViews objectAtIndex:i];
        [seperateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo([[[[VMNumberBtns sharedNumberInput] keyNumBtns] objectAtIndex:0] mas_top]);
            make.bottom.equalTo(wself.switchItemBackView.mas_top);
            make.left.equalTo(wself.view.mas_left).offset(wself.view.frame.size.width * 1.f/3.f * (i - 5 + 1));
            make.width.mas_equalTo(widthSeperateView);
        }];
    }
}

- (void) addKVOs {
    RAC(self.moneyLabel, text) = [[RACObserve([VMNumberBtns sharedNumberInput], intMoney) map:^NSString* (NSNumber* intMoney) {
        NSString* dotMoney = [PublicInformation dotMoneyFromNoDotMoney:[NSString stringWithFormat:@"%d", intMoney.intValue]];
        return [@"￥" stringByAppendingString:dotMoney];
    }] deliverOnMainThread];
    
    
    @weakify(self);
    [RACObserve(self.switchItemScrollView, page) subscribeNext:^(NSNumber* page) {
        @strongify(self);
        if ([page integerValue] == 1) {
            [self.leftImgView setImage:[UIImage imageNamed:@"JLPayGray"] forState:UIControlStateNormal];
            [self.rightImgView setImage:[UIImage imageNamed:@"微信支付2"] forState:UIControlStateNormal];
        }
        else if ([page integerValue] == 2) {
            [self.leftImgView setImage:[UIImage imageNamed:@"支付宝1"] forState:UIControlStateNormal];
            [self.rightImgView setImage:[UIImage imageNamed:@"JLPayGray"] forState:UIControlStateNormal];
        }
        else if ([page integerValue] == 3) {
            [self.leftImgView setImage:[UIImage imageNamed:@"微信支付2"] forState:UIControlStateNormal];
            [self.rightImgView setImage:[UIImage imageNamed:@"支付宝1"] forState:UIControlStateNormal];
        }
        else if ([page integerValue] == 4) {
            [self.leftImgView setImage:[UIImage imageNamed:@"支付宝1"] forState:UIControlStateNormal];
            [self.rightImgView setImage:[UIImage imageNamed:@"微信支付2"] forState:UIControlStateNormal];
        }
        else { // 0
            [self.leftImgView setImage:[UIImage imageNamed:@"微信支付2"] forState:UIControlStateNormal];
            [self.rightImgView setImage:[UIImage imageNamed:@"JLPayGray"] forState:UIControlStateNormal];
        }
    }];
    
}


# pragma mask 3 IBAction

- (IBAction) clickedSwitchBtn:(LeftImgRightTitleBtn*)switchBtn {
    NSString* btnTitle = switchBtn.rightTitleLabel.text;
    if ([btnTitle isEqualToString:SwitchBtnsSwipe]) {
        if ([self checkingInputsBeforeSwipe]) {
            [self pushSwipeOrOtherDisplayVC];
        }
    }
    else if ([btnTitle isEqualToString:SwitchBtnsWechat]) {
        [PublicInformation makeCentreToast:@"敬请期待，即将开通!"];

        // 先关闭微信支付
//        if ([self moneyInputed]) {
//            [self pushWechatPayVC];
//        }
    }
    else {
        [PublicInformation makeCentreToast:@"敬请期待，即将开通!"];
        
    }
}

- (IBAction) clickedLeftOrRightSwitchBtn:(UIButton*)sender {
    if (sender.tag == 0) {
        [self.switchItemScrollView switchToPage:self.switchItemScrollView.page - 1];
    } else {
        [self.switchItemScrollView switchToPage:self.switchItemScrollView.page + 1];
    }
}

- (BOOL) checkingInputsBeforeSwipe {
    return [self checkedStateBusiness] && [self moneyInputed] && [self blutoothPowerOn] && [self MposBinded] && [self hasAppointedBusinessOrRate] && [self enableT_0Trans];
}

/* 1. 审核状态 */
- (BOOL) checkedStateBusiness {
    BOOL checked = [MLoginSavedResource sharedLoginResource].checkedState == BusinessCheckedStateChecked;
    if (!checked) {
        [PublicInformation makeCentreToast:@"商户正在审核中，不允许交易"];
    }
    return checked;
}

/* 2. 金额输入 */
- (BOOL) moneyInputed {
    BOOL inpueted = [VMNumberBtns sharedNumberInput].intMoney > 0;
    if (!inpueted) {
        [PublicInformation makeCentreToast:@"请输入金额!"];
    }
    return inpueted;
}

/* 3. 蓝牙打开 */
- (BOOL) blutoothPowerOn {
    AppDelegate* appDelegate = APPMainDelegate;
    BOOL powerOn = appDelegate.CBManager.state == CBCentralManagerStatePoweredOn;
    if (!powerOn) {
        [PublicInformation makeCentreToast:@"手机蓝牙未打开,请打开蓝牙!"];
    }
    return powerOn;
}

/* 4. 绑定设备 */
- (BOOL) MposBinded {
    BOOL binded = [ModelDeviceBindedInformation hasBindedDevice];
    if (!binded) {
        NameWeakSelf(wself);
        [JCAlertView showTwoButtonsWithTitle:@"未绑定设备" Message:@"是否跳转'绑定设备'界面去绑定设备?" ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"取消" Click:nil
                                  ButtonType:JCAlertViewButtonTypeWarn ButtonTitle:@"去绑定" Click:^{
                                      [wself.navigationController pushViewController:[[DeviceConnectViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
                                  }];
    }
    return binded;
}

/* 5. 费率、商户提示 */
- (BOOL) hasAppointedBusinessOrRate {
    NameWeakSelf(wself);
    if ([[ModelSettlementInformation sharedInstance] curSettlementType] == SETTLEMENTTYPE_T_1) {
        if ([MLoginSavedResource sharedLoginResource].N_business_enable && [ModelBusinessInfoSaved beenSaved]) {
            NSString* alert = [NSString stringWithFormat:@"已设置指定商户:\n[%@]\n[%@]\n是否继续消费?", [ModelBusinessInfoSaved businessName],[ModelBusinessInfoSaved rateTypeSelected]];
            [JCAlertView showTwoButtonsWithTitle:@"温馨提示" Message:alert ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"取消" Click:^{
            } ButtonType:JCAlertViewButtonTypeDefault ButtonTitle:@"继续" Click:^{
                [wself pushSwipeOrOtherDisplayVC];
            }];
            return NO;
        }
        else if ([MLoginSavedResource sharedLoginResource].N_fee_enable && [ModelRateInfoSaved beenSaved]) {
            NSString* alert = [NSString stringWithFormat:@"已设置指定费率:\n[%@]\n[%@]\n是否继续消费?", [ModelRateInfoSaved rateTypeSelected],[ModelRateInfoSaved cityName]];
            [JCAlertView showTwoButtonsWithTitle:@"温馨提示" Message:alert ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"取消" Click:^{
            } ButtonType:JCAlertViewButtonTypeDefault ButtonTitle:@"继续" Click:^{
                [wself pushSwipeOrOtherDisplayVC];
            }];
            return NO;
        }
        else {
            return YES;
        }
    } else {
        return YES;
    }
}

/* 6. T+0信息及 */
- (BOOL) enableT_0Trans {
    BOOL enable = YES;
    NameWeakSelf(wself);
    // 检查当前输入金额是否超限,超限的话要重置为T+1
    CGFloat curInputedMoney = [PublicInformation dotMoneyFromNoDotMoney:[NSString stringWithFormat:@"%ld",[VMNumberBtns sharedNumberInput].intMoney]].floatValue;
    CGFloat T_0MinLimitMoney = [[VMT_0InfoRequester sharedInstance] amountMinCust].floatValue;
    CGFloat T_0AvilabelMoney = [[VMT_0InfoRequester sharedInstance] amountAvilable].floatValue;
    
    if (curInputedMoney < T_0MinLimitMoney) {
        // 不允许交易
        enable = NO;
        NSString* message = [NSString stringWithFormat:@"交易金额必须大于T+0最小刷卡额度:￥%.02lf", T_0MinLimitMoney];
        [JCAlertView showOneButtonWithTitle:@"拒绝交易" Message:message ButtonType:JCAlertViewButtonTypeDefault ButtonTitle:@"确定" Click:^{
        }];
    }
    else if (curInputedMoney > T_0AvilabelMoney) {
        [[ModelSettlementInformation sharedInstance] setCurSettlementType:SETTLEMENTTYPE_T_1];
    }
    else {
        // 提示T+0结算信息
        enable = NO;
        CGFloat T_0LimitMoney = [[VMT_0InfoRequester sharedInstance] amountLimit].floatValue;
        CGFloat T_0MoreFee = [[VMT_0InfoRequester sharedInstance] T_0ExtraFee].floatValue;
        NSString* message = [NSString stringWithFormat:@"单日限额:￥%.02lf\n单笔最小限额:￥%.02lf\n单日可刷额度:￥%.02lf\n转账手续费:￥%.02lf",T_0LimitMoney,T_0MinLimitMoney,T_0AvilabelMoney,T_0MoreFee];
        [JCAlertView showTwoButtonsWithTitle:@"T+0温馨提示" Message:message ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"取消" Click:^{
        } ButtonType:JCAlertViewButtonTypeDefault ButtonTitle:@"继续" Click:^{
            [wself pushSwipeOrOtherDisplayVC];
        }];
    }
    return enable;
}


- (void) pushSwipeOrOtherDisplayVC {
    UIViewController* viewController = nil;
    // 跳转刷卡界面
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    viewController = [storyboard instantiateViewControllerWithIdentifier:@"brush"];
    BrushViewController* viewcon = (BrushViewController*)viewController;
    [viewcon setStringOfTranType:TranType_Consume];
    [viewcon setSFloatMoney:[self.moneyLabel.text substringFromIndex:1]];
    [viewcon setSIntMoney:[NSString stringWithFormat:@"%012ld", (long)[[VMNumberBtns sharedNumberInput] intMoney]]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:viewController animated:YES];
        [VMNumberBtns sharedNumberInput].intMoney = 0;
    });
}

- (void) pushWechatPayVC {
    /* 填充支付需要的信息 */
    [[VMOtherPayType sharedInstance] setPayAmount:[self.moneyLabel.text substringFromIndex:1]];
    [[VMOtherPayType sharedInstance] setCurPayType:OtherPayTypeWechat];
    
    /* 跳转 */
    [self.navigationController pushViewController:[[CodeScannerViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
    [VMNumberBtns sharedNumberInput].intMoney = 0;
}


# pragma mask 4 getter

- (UILabel *)moneyLabel {
    if (!_moneyLabel) {
        _moneyLabel = [UILabel new];
        _moneyLabel.textAlignment = NSTextAlignmentCenter;
        _moneyLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
        _moneyLabel.font = [UIFont boldSystemFontOfSize:33];
    }
    return _moneyLabel;
}


- (UIButton *)leftImgView {
    if (!_leftImgView) {
        _leftImgView = [UIButton new];
        _leftImgView.tag = 0;
        [_leftImgView addTarget:self action:@selector(clickedLeftOrRightSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _leftImgView;
}

- (UIButton *)rightImgView {
    if (!_rightImgView) {
        _rightImgView = [UIButton new];
        _rightImgView.tag = 1;
        [_rightImgView addTarget:self action:@selector(clickedLeftOrRightSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightImgView;
}

- (UIView *)switchItemBackView {
    if (!_switchItemBackView) {
        _switchItemBackView = [UIView new];
        _switchItemBackView.backgroundColor = [UIColor colorWithHex:0xeeeeee alpha:1];
    }
    return _switchItemBackView;
}


- (SwitchBtnsScrollView *)switchItemScrollView {
    if (!_switchItemScrollView) {
        _switchItemScrollView = [[SwitchBtnsScrollView alloc]
                                 initWithFrame:CGRectMake(5+30+5,
                                                          self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - 55,
                                                          self.view.frame.size.width - (5+30+5) * 2,
                                                          55)];
        for (UIButton* btn in _switchItemScrollView.switchItemBtns) {
            [btn addTarget:self action:@selector(clickedSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _switchItemScrollView;
}



- (NSMutableArray *)seperatorViews {
    if (!_seperatorViews) {
        _seperatorViews = [NSMutableArray array];
        /* 横:5条, 竖:2条 */
        for (int i = 0; i < 5 * 2; i++) {
            UIView* seperateView = [UIView new];
            seperateView.backgroundColor = [UIColor colorWithHex:HexColorTypeBlackGray alpha:0.618];
            [_seperatorViews addObject:seperateView];
        }
    }
    return _seperatorViews;
}

- (VMSettlementInfoRequestor *)vmStlmentInfo {
    if (!_vmStlmentInfo) {
        _vmStlmentInfo = [[VMSettlementInfoRequestor alloc] init];
    }
    return _vmStlmentInfo;
}


@end
