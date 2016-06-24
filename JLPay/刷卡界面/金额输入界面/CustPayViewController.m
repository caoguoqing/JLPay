//
//  CustPayViewController.m
//  JLPay
//
//  Created by jielian on 15/5/15.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "CustPayViewController.h"
#import "Define_Header.h"
#import "BrushViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "DeleteButton.h"
#import "Packing8583.h"
#import "SettlementInfoViewController.h"
#import "ModelDeviceBindedInformation.h"
#import "ModelSettlementInformation.h"
#import "MLoginSavedResource.h"
#import "IntMoneyCalculating.h"
#import "ImageTitleButton.h"
#import "VMOtherPayType.h"
#import "CodeScannerViewController.h"
#import "DeviceSignInViewController.h"
#import <LTNavigationBar/UINavigationBar+Awesome.h>

#import "ModelRateInfoSaved.h"
#import "ModelBusinessInfoSaved.h"
#import "JCAlertView.h"
#import "VMT_0InfoRequester.h"



@interface CustPayViewController ()
<CBCentralManagerDelegate>
{
    BOOL blueToothPowerOn;              // 蓝牙打开状态标记
    CBCentralManager* blueManager;      // 蓝牙设备操作入口
}
@property (nonatomic, strong) UILabel* labelDisplayMoney;                   // 金额显示标签栏
@property (nonatomic, strong) UIView* backViewOfMoney;                      // 用来优化结算方式视图的点击体验

@property (nonatomic, strong) IntMoneyCalculating* intMoneyCalculating;     // VM-金额计算器

@property (nonatomic, strong) ImageTitleButton* swipeButton;                // 刷卡按钮
@property (nonatomic, strong) ImageTitleButton* wechatPayButton;;           // 微信支付按钮
@property (nonatomic, strong) ImageTitleButton* alipayButton;               // 支付宝支付按钮


@end

@implementation CustPayViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubViews];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    
    blueToothPowerOn = NO;
    blueManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = NO;
    
    // 申请结算信息,并重置当前结算方式
    if ([MLoginSavedResource sharedLoginResource].T_0_enable && BranchAppName != 3) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self startHTTPRequestForSettlementInfo];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[VMT_0InfoRequester sharedInstance] requestTerminate];
}

#pragma mask ---- HTTP
/* 请求数据 */
- (void) startHTTPRequestForSettlementInfo {
    if ([ModelDeviceBindedInformation hasBindedDevice]) {
        [[VMT_0InfoRequester sharedInstance] requestT_0InformationWithBusinessNumbser:[ModelDeviceBindedInformation businessNoBinded] onSucBlocK:^{
            VMT_0InfoRequester* vmT0Requester = [VMT_0InfoRequester sharedInstance];
            // 查询的结果暂时不做任何处理，在点击刷卡时，再判断进行处理
            if ([vmT0Requester enableT_0]) {
                JLPrint(@"---查询了商户的结算信息:允许T+0");
                [ModelSettlementInformation sharedInstance].curSettlementType = SETTLEMENTTYPE_T_0;
            } else {
                [ModelSettlementInformation sharedInstance].curSettlementType = SETTLEMENTTYPE_T_1;
            }
        } onErrorBlock:^(NSError *error) {
            [ModelSettlementInformation sharedInstance].curSettlementType = SETTLEMENTTYPE_T_1;
        }];
    }
}

#pragma mask ---- CBCentrolManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        blueToothPowerOn = YES;
    } else {
        blueToothPowerOn = NO;
    }
}

#pragma mask ::: 数字按键组的分割线
- (void) drawLineInRect : (CGRect)rect {
    CGFloat lineWidth = 0.5;
    CGFloat horizontalWidth = rect.size.width * 3/4.0;  // 水平
    CGRect frame = CGRectMake(rect.origin.x, rect.origin.y, horizontalWidth, lineWidth);
    // 横线
    for (int i = 0; i < 5; i++) {
        UIView* line = [[UIView alloc] initWithFrame:frame];
        line.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
        frame.origin.y += rect.size.height/4.0;
        if (i == 4) {
            frame.origin.y -= frame.size.height;
        }
        [self.view addSubview:line];
    }
    frame.origin.y = rect.origin.y;
    frame.size.width = lineWidth;
    frame.size.height = rect.size.height;
    // 竖线
    for (int j = 0; j < 5; j++) {
        UIView* line = [[UIView alloc] initWithFrame:frame];
        line.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
        frame.origin.x += rect.size.width/4.0;
        [self.view addSubview:line];
    }
}


- (IBAction) outBrush:(UIButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
}
- (IBAction) beginBrush:(UIButton*)sender {
    sender.transform                    = CGAffineTransformMakeScale(0.98, 0.98);
}

- (IBAction) touchDown:(UIButton*)sender {
    sender.transform                    = CGAffineTransformMakeScale(0.99, 0.99);
    sender.backgroundColor              = [UIColor colorWithWhite:0.7 alpha:0.5];
}

#pragma mask  ---- 数字按钮组的点击事件
- (IBAction) clickNumerButton:(UIButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
    sender.backgroundColor              = [UIColor clearColor];
    // 向金额对象压入输入的数字
    NSString* number = [sender.titleLabel text];
    if ([number isEqualToString:@"C"]) {
        self.labelDisplayMoney.text = [self moneyClearZero];
    }
    else {
        self.labelDisplayMoney.text = [self.intMoneyCalculating dotMoneyByAddedNumber:sender.titleLabel.text];
    }
}


#pragma mask  ---- 撤销按钮的点击事件
- (IBAction) touchUpDelete:(DeleteButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
    sender.backgroundColor              = [UIColor clearColor];
    // 获取撤销后的上一次输入的金额
    self.labelDisplayMoney.text = [self.intMoneyCalculating dotMoneyByRevoked];
}

/*************************************
 * 功  能 : 撤销按钮的长按事件;清除所有金额；
 * 参  数 :
 * 返  回 :
 *************************************/
- (IBAction)longPressButtonOfDelete:(UILongPressGestureRecognizer*)sender {
    self.labelDisplayMoney.text = [self moneyClearZero];
    if (sender.state == UIGestureRecognizerStateEnded) {
        sender.view.transform           = CGAffineTransformIdentity;
        sender.view.backgroundColor     = [UIColor clearColor];
    }
}

- (IBAction) touchUpOut:(UIButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
    sender.backgroundColor              = [UIColor clearColor];
}

- (IBAction) touchDownSimple:(UIButton*)sender {
    sender.transform                    = CGAffineTransformMakeScale(0.97, 0.97);
}
- (IBAction) touchUpSimple:(UIButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
}
- (IBAction) touchOutSimple:(UIButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
}



#pragma mark  ------点击了刷卡按钮: 跳转刷卡界面
/*************************************
 * 功  能 : 刷卡按钮的点击事件:跳转到刷卡界面;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (IBAction)toBrushClick:(UIButton *)sender {
    sender.transform = CGAffineTransformIdentity;
    if ([self checkInputsBeforeSwipe]) {
        [self pushSwipeOrOtherDisplayVC];
    }
}

- (IBAction) toWechatPay:(UIButton*)sender {
    [PublicInformation makeCentreToast:@"敬请期待，即将开通!"];
    return;
    /* ----- 先屏蔽掉微信功能，等通道稳定再开放 */
//    if ([self.labelDisplayMoney.text floatValue] < 0.0001) {
//        [PublicInformation makeToast:@"请输入金额!"];
//        return;
//    }
//    
//    /* 填充支付需要的信息 */
//    [[VMOtherPayType sharedInstance] setPayAmount:[NSString stringWithFormat:@"%.02lf",self.labelDisplayMoney.text.floatValue]];
//    [[VMOtherPayType sharedInstance] setCurPayType:OtherPayTypeWechat];
//    
//    /* 跳转 */
//    [self.navigationController pushViewController:[[CodeScannerViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
//    
//    // 重置金额
//    self.labelDisplayMoney.text = @"0.00";
//    self.intMoneyCalculating = nil;
}
- (IBAction) toAlipay:(UIButton*)sender {
    [PublicInformation makeCentreToast:@"敬请期待，即将开通!"];
}

/* 刷卡前检查输入 */
- (BOOL) checkInputsBeforeSwipe {
    BOOL inputsValid = YES;
    NameWeakSelf(wself);
    if ([MLoginSavedResource sharedLoginResource].checkedState != BusinessCheckedStateChecked) {
        [PublicInformation makeCentreToast:@"商户正在审核中，不允许交易"];
        inputsValid = NO;
    }
    if (inputsValid && [self.labelDisplayMoney.text floatValue] < 0.0001) {
        [PublicInformation makeToast:@"请输入金额!"];
        inputsValid = NO;
    }
    if (inputsValid && !blueToothPowerOn) {
        [PublicInformation makeToast:@"手机蓝牙未打开,请打开蓝牙!"];
        inputsValid = NO;
    }
    if (inputsValid && ![ModelDeviceBindedInformation hasBindedDevice]) {
        [JCAlertView showTwoButtonsWithTitle:@"未绑定设备" Message:@"是否跳转'绑定设备'界面去绑定设备?" ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"取消" Click:nil
                                  ButtonType:JCAlertViewButtonTypeWarn ButtonTitle:@"去绑定" Click:^{
                                      [wself.navigationController pushViewController:[[DeviceSignInViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
        }];
        inputsValid = NO;
    }
    
    if (inputsValid) {
        SETTLEMENTTYPE settlementType = [[ModelSettlementInformation sharedInstance] curSettlementType];
        switch (settlementType) {
            case SETTLEMENTTYPE_T_1:
            {
                if ([MLoginSavedResource sharedLoginResource].N_business_enable && [ModelBusinessInfoSaved beenSaved]) {
                    NSString* alert = [NSString stringWithFormat:@"已设置指定商户:\n[%@][%@]\n是否继续刷卡?", [ModelBusinessInfoSaved businessName],[ModelBusinessInfoSaved rateTypeSelected]];
                    [JCAlertView showTwoButtonsWithTitle:@"温馨提示" Message:alert ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"取消" Click:^{
                    } ButtonType:JCAlertViewButtonTypeDefault ButtonTitle:@"继续" Click:^{
                        [wself pushSwipeOrOtherDisplayVC];
                    }];
                    inputsValid = NO;
                }
                else if ([MLoginSavedResource sharedLoginResource].N_fee_enable && [ModelRateInfoSaved beenSaved]) {
                    NSString* alert = [NSString stringWithFormat:@"已设置指定费率:\n[%@][%@]\n是否继续刷卡?", [ModelRateInfoSaved rateTypeSelected],[ModelRateInfoSaved cityName]];
                    [JCAlertView showTwoButtonsWithTitle:@"温馨提示" Message:alert ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"取消" Click:^{
                    } ButtonType:JCAlertViewButtonTypeDefault ButtonTitle:@"继续" Click:^{
                        [wself pushSwipeOrOtherDisplayVC];
                    }];
                    inputsValid = NO;
                }
            }
                break;
            case SETTLEMENTTYPE_T_0:
            {
                // 检查当前输入金额是否超限,超限的话要重置为T+1
                CGFloat curInputedMoney = self.labelDisplayMoney.text.floatValue;
                CGFloat T_0MinLimitMoney = [[VMT_0InfoRequester sharedInstance] amountMinCust].floatValue;
                CGFloat T_0AvilabelMoney = [[VMT_0InfoRequester sharedInstance] amountAvilable].floatValue;
                JLPrint(@"输入金额[%lf],最小限额[%lf],可刷额度[%lf]",curInputedMoney,T_0MinLimitMoney,T_0AvilabelMoney);
                
                if (curInputedMoney < T_0MinLimitMoney) {
                    // 不允许交易
                    inputsValid = NO;
                    NSString* message = [NSString stringWithFormat:@"交易金额必须大于T+0最小刷卡额度:￥%.02lf", T_0MinLimitMoney];
                    [JCAlertView showOneButtonWithTitle:@"拒绝交易" Message:message ButtonType:JCAlertViewButtonTypeDefault ButtonTitle:@"确定" Click:^{
                    }];
                }
                else if (curInputedMoney > T_0AvilabelMoney) {
                    [[ModelSettlementInformation sharedInstance] setCurSettlementType:SETTLEMENTTYPE_T_1];
                }
                else {
                    // 提示T+0结算信息
                    inputsValid = NO;
                    CGFloat T_0LimitMoney = [[VMT_0InfoRequester sharedInstance] amountLimit].floatValue;
                    CGFloat T_0MoreFee = [[VMT_0InfoRequester sharedInstance] T_0ExtraFee].floatValue;
                    NSString* message = [NSString stringWithFormat:@"单日限额:￥%.02lf\n单笔最小限额:￥%.02lf\n单日可刷额度:￥%.02lf\n转账手续费:￥%.02lf",T_0LimitMoney,T_0MinLimitMoney,T_0AvilabelMoney,T_0MoreFee];
                    [JCAlertView showTwoButtonsWithTitle:@"T+0温馨提示" Message:message ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"取消" Click:^{
                    } ButtonType:JCAlertViewButtonTypeDefault ButtonTitle:@"继续" Click:^{
                        [wself pushSwipeOrOtherDisplayVC];
                    }];
                }
            }
                break;
            case SETTLEMENTTYPE_T_6:
            case SETTLEMENTTYPE_T_15:
            case SETTLEMENTTYPE_T_30:
            {
                // do nothing
            }
                break;
            default:
                break;
        }
    }
    return inputsValid;
}

/* 跳转界面: 根据t+0条件切换不同界面 */
- (void) pushSwipeOrOtherDisplayVC {
    UIViewController* viewController = nil;
    // 跳转刷卡界面
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    viewController = [storyboard instantiateViewControllerWithIdentifier:@"brush"];
    BrushViewController* viewcon = (BrushViewController*)viewController;
    [viewcon setStringOfTranType:TranType_Consume];
    [viewcon setSFloatMoney:self.labelDisplayMoney.text];
    [viewcon setSIntMoney:[PublicInformation intMoneyFromDotMoney:self.labelDisplayMoney.text]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:viewController animated:YES];
    });
    
    // 重置金额
    self.labelDisplayMoney.text = @"0.00";
    self.intMoneyCalculating = nil;
}

/*************************************
 * 功  能 : 重新计算数字按钮组的文本的高度跟button高度的比例;
 *          - 新的比例用 2/3 来计算
 * 参  数 :
 * 返  回 :
 *************************************/
- (CGFloat)resizeFontWithButton: (UIButton*)button inFrame: (CGRect) frame {
    CGFloat resize = 0.0;
    NSDictionary* textAttri = [NSDictionary dictionaryWithObject:button.titleLabel.font forKey:NSFontAttributeName];
    CGSize size = [button.titleLabel.text sizeWithAttributes:textAttri];
    // 重置:设置字体的高度占 label 的高度的 2/3
    resize = 2.0 * frame.size.height / (3.0 * size.height);
    return resize;
}

/* 金额清零 */
- (NSString* ) moneyClearZero {
    NSString* money = nil;
    while (YES) {
        money = [self.intMoneyCalculating dotMoneyByRevoked];
        if (money.floatValue == 0.0) {
            break;
        }
    }
    return money;
}


/*************************************
 * 功  能 : CustPayViewController 的子控件加载;
 *          - 图标          UIImageView + UILabel
 *          - 金额显示框     UILabel
 *          - 数字按键组     UIButtons
 *          - 其他支付按钮   UIButtons
 *          - 刷卡按钮       UIButton
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) addSubViews {
    /* status bar height */
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    // 有效高度: 视图的
    CGFloat visibleHeight = self.view.bounds.size.height - self.tabBarController.tabBar.bounds.size.height - statusBarHeight;
    // 间隔值
    CGFloat inset = 5.0;
    // 宽度: 数字按钮
    NSInteger numberOfLinesNumberButton = 4;
    CGFloat numBtnWidth = self.view.bounds.size.width/numberOfLinesNumberButton;
    // logo imageView高度
    CGSize  logoImgSize = [PublicInformation logoImageOfApp].size;
    CGFloat logoImgWidth = self.view.bounds.size.width / 2.0;
    CGFloat logoImgHeight = logoImgWidth * logoImgSize.height/logoImgSize.width;
    /* ---------
     1.计算好logo的最小高度
     2.计算数字按钮最大高度
     3.计算金额显示框最大高度
     4.计算金额显示框最小高度
     --------- */
    CGFloat minHeightLogoImageView = logoImgHeight + inset*2;
    CGFloat maxHeightNumButton = numBtnWidth;
    CGFloat minHeightMoneyDisplay = minHeightLogoImageView;
    
    // 初始高度值: 图标、金额框、数字按钮
    CGFloat heightLogoImageView = minHeightLogoImageView;
    CGFloat heightMoneyDisplay = minHeightMoneyDisplay;
    CGFloat heightNumButton = (visibleHeight - minHeightLogoImageView - minHeightMoneyDisplay)/numberOfLinesNumberButton;
    // 如果数字按钮高度大于最大值:置为最大值,金额框、logo视图各分多出来的高度的一半
    if (heightNumButton > maxHeightNumButton) {
        CGFloat difference = (heightNumButton - maxHeightNumButton) * numberOfLinesNumberButton;
        heightNumButton = maxHeightNumButton;
        heightLogoImageView += difference/2.0;
        heightMoneyDisplay += difference/2.0;
    }
    CGFloat yCenterPre = 0 + statusBarHeight;
    //////////////////////

    
    // 图标
    CGRect  frame                       = CGRectMake(0, 0, logoImgWidth, logoImgHeight);
    UIImageView *imageView              = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = [PublicInformation logoImageOfApp];
    imageView.center = CGPointMake(self.view.frame.size.width/2.0, yCenterPre + heightLogoImageView/2.0);
    yCenterPre += heightLogoImageView;
    [self.view addSubview:imageView];
    
    // 金额背景框
    frame.origin.x = 0;
    frame.origin.y = yCenterPre;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = heightMoneyDisplay;
    [self.backViewOfMoney setFrame:frame];
    [self.view addSubview:self.backViewOfMoney];

    // moneyLabel
    CGRect innerFrame = CGRectZero;
    innerFrame.origin.x = 0;
    innerFrame.origin.y = 0;
    innerFrame.size.width = frame.size.width - 45;
    innerFrame.size.height = frame.size.height;
    self.labelDisplayMoney.frame = innerFrame;
    self.labelDisplayMoney.font = [UIFont boldSystemFontOfSize:[PublicInformation resizeFontInSize:innerFrame.size andScale:6.0/12.0]];
    [self.backViewOfMoney addSubview:self.labelDisplayMoney];
    
    
    // moneyImageView 金额符号Label : 字体大小为金额字体大小的 3/4, 因为字体为汉字，显示要比英文字母高一点，所以将y降低一个 inset，高度也减少一个 inset
    innerFrame.origin.x                 = frame.size.width - 45;
    innerFrame.origin.y                 = 0 + inset;
    innerFrame.size.width               = frame.size.width - innerFrame.origin.x;
    innerFrame.size.height              = frame.size.height;
    UILabel *moneySymbolLabel           = [[UILabel alloc] initWithFrame:innerFrame];
    moneySymbolLabel.text               = @"￥";
    moneySymbolLabel.textAlignment      = NSTextAlignmentLeft;
    moneySymbolLabel.font               = [UIFont boldSystemFontOfSize:[PublicInformation resizeFontInSize:frame.size andScale:7.0/12.0 * 2.0/3.0]];
    [self.backViewOfMoney addSubview:moneySymbolLabel];
    yCenterPre += heightMoneyDisplay;
    
    // 数字按键组
    NSArray * numbers                   = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"C",@"0",@"delete"];
    frame.size.width                    = numBtnWidth;
    frame.size.height                   = heightNumButton;
    CGRect numbersFrame                 = CGRectMake(0, yCenterPre, self.view.bounds.size.width, heightNumButton*4);
    
    for (int i = 0; i < numbers.count; i++) {
        NSString* titleButton = [numbers objectAtIndex:i];
        CGPoint curCenterPoint = CGPointMake(0 + numBtnWidth * (i % 3) + numBtnWidth/2.0,
                                             yCenterPre + heightNumButton * (i / 3) + heightNumButton/2.0);
        // 数字按钮+小数点按钮
        if (titleButton.length == 1) {
            UIButton* numberButton = [[UIButton alloc] initWithFrame:frame];
            numberButton.center = curCenterPoint;
            [numberButton setTitle:titleButton forState:UIControlStateNormal];
            [numberButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            numberButton.titleLabel.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:frame.size andScale:0.5]];
            [numberButton  addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
            [numberButton  addTarget:self action:@selector(clickNumerButton:) forControlEvents:UIControlEventTouchUpInside];
            [numberButton  addTarget:self action:@selector(touchUpOut:) forControlEvents:UIControlEventTouchUpOutside];
            [self.view addSubview:numberButton];
        }
        // 删除按钮
        else {
            UIButton* deleteBtn = [[UIButton alloc] initWithFrame:frame];
            deleteBtn.center = curCenterPoint;
            [deleteBtn setTitle:[NSString stringWithIconFontType:IconFontType_backspace] forState:UIControlStateNormal];
            [deleteBtn setTitleColor:[UIColor colorWithHex:HexColorTypeThemeRed alpha:1] forState:UIControlStateNormal];
            deleteBtn.titleLabel.font = [UIFont iconFontWithSize:[PublicInformation resizeFontInSize:frame.size andScale:0.5]];
            [deleteBtn  addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
            [deleteBtn  addTarget:self action:@selector(touchUpDelete:) forControlEvents:UIControlEventTouchUpInside];
            [deleteBtn  addTarget:self action:@selector(touchUpOut:) forControlEvents:UIControlEventTouchUpOutside];
            // 给撤销按钮添加一个长按事件:将金额清零,金额栈也清0
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressButtonOfDelete:)];
            longPress.minimumPressDuration = 0.8;
            [deleteBtn addGestureRecognizer:longPress];
            [self.view addSubview:deleteBtn];

        }
    }
    // 分割线
    [self drawLineInRect:numbersFrame];
    
    NameWeakSelf(wself);
    CGFloat heightImageButton = heightNumButton;
    // 支付宝支付
    [self.view addSubview:self.alipayButton];
    [self.alipayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left).offset(numBtnWidth * 3);
        make.right.equalTo(wself.view.mas_right);
        make.top.equalTo(wself.view.mas_top).offset(yCenterPre);
        make.height.mas_equalTo(heightImageButton);
    }];
    
    // 微信支付
    [self.view addSubview:self.wechatPayButton];
    [self.wechatPayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.alipayButton.mas_left).offset(0);
        make.right.equalTo(wself.alipayButton.mas_right);
        make.top.equalTo(wself.alipayButton.mas_bottom).offset(0);
        make.height.equalTo(wself.alipayButton.mas_height);
    }];
    
    // 刷卡按钮
    heightImageButton *= 2;
    [self.view addSubview:self.swipeButton];
    [self.swipeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.wechatPayButton.mas_centerX);
        make.width.equalTo(wself.wechatPayButton.mas_width);
        make.height.mas_equalTo(heightImageButton);
        make.top.equalTo(wself.wechatPayButton.mas_bottom);
    }];
}

#pragma mask --- setter & getter
- (IntMoneyCalculating *)intMoneyCalculating {
    if (_intMoneyCalculating == nil) {
        _intMoneyCalculating = [[IntMoneyCalculating alloc] init];
    }
    return _intMoneyCalculating;
}
- (UILabel *)labelDisplayMoney {
    if (_labelDisplayMoney == nil) {
        _labelDisplayMoney = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelDisplayMoney.text = @"0.00";
        _labelDisplayMoney.textColor = [UIColor blackColor];
        _labelDisplayMoney.textAlignment = NSTextAlignmentRight;
    }
    return _labelDisplayMoney;
}
- (UIView *)backViewOfMoney {
    if (_backViewOfMoney == nil) {
        _backViewOfMoney = [[UIView alloc] initWithFrame:CGRectZero];
        _backViewOfMoney.backgroundColor = [UIColor colorWithRed:180.0/255.0 green:188.0/255.0 blue:194.0/255.0 alpha:1.0]; // 灰色
    }
    return _backViewOfMoney;
}
- (ImageTitleButton *)swipeButton {
    if (!_swipeButton) {
        _swipeButton = [[ImageTitleButton alloc] init];
        _swipeButton.bImgLabel.text = [NSString stringWithIconFontType:IconFontType_card];
        _swipeButton.bImgLabel.textColor = [PublicInformation returnCommonAppColor:@"blueBlack"];
        _swipeButton.bTitleLabel.text = @"刷卡";
        _swipeButton.bTitleLabel.textColor = [PublicInformation returnCommonAppColor:@"blueBlack"];
        _swipeButton.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.4];
        [_swipeButton addTarget:self action:@selector(toBrushClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _swipeButton;
}
- (ImageTitleButton *)wechatPayButton {
    if (!_wechatPayButton) {
        _wechatPayButton = [[ImageTitleButton alloc] init];
        _wechatPayButton.bImgLabel.text = [NSString stringWithIconFontType:IconFontType_wechatPay];
        _wechatPayButton.bImgLabel.textColor = [UIColor whiteColor];
        _wechatPayButton.bTitleLabel.text = @"微信收款";
        _wechatPayButton.bTitleLabel.textColor = [UIColor whiteColor];
        _wechatPayButton.backgroundColor = [PublicInformation returnCommonAppColor:@"green"];
        [_wechatPayButton addTarget:self action:@selector(toWechatPay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _wechatPayButton;
}
- (ImageTitleButton *)alipayButton {
    if (!_alipayButton) {
        _alipayButton = [[ImageTitleButton alloc] init];
        _alipayButton.bImgLabel.text = [NSString stringWithIconFontType:IconFontType_alipay];
        _alipayButton.bImgLabel.textColor = [UIColor whiteColor];
        _alipayButton.bTitleLabel.text = @"支付宝收款";
        _alipayButton.bTitleLabel.textColor = [UIColor whiteColor];
        _alipayButton.backgroundColor = [PublicInformation returnCommonAppColor:@"lightBlue"];
        [_alipayButton addTarget:self action:@selector(toAlipay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _alipayButton;
}

@end
