//
//  CustPayViewController.m
//  JLPay
//
//  Created by jielian on 15/5/15.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "CustPayViewController.h"
#import "Define_Header.h"
#import "MoneyCalculated.h"
#import "BrushViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "DeleteButton.h"
#import "Packing8583.h"
#import "SettlementSwitchView.h"
#import "SettlementInfoViewController.h"
#import "HTTPRequestSettlementInfo.h"
#import "ModelDeviceBindedInformation.h"


#define ImageForBrand   @"logo"                                             // 商标图片


@interface CustPayViewController ()
<UIAlertViewDelegate, CBCentralManagerDelegate, HTTPRequestSettlementInfoDelegate, SettlementSwitchViewDelegate>
{
    BOOL blueToothPowerOn;  // 蓝牙打开状态标记
    CBCentralManager* blueManager; // 蓝牙设备操作入口
    BOOL isSettlementT_0;
}
@property (nonatomic, strong) UILabel           *labelDisplayMoney;         // 金额显示标签栏
@property (nonatomic)         NSString*         money;                      // 金额
@property (nonatomic, strong) MoneyCalculated*  moneyCalculated;            // 更新的金额计算类

@property (nonatomic, strong) SettlementSwitchView* settlementView;         // 结算方式切换视图
@property (nonatomic, retain) HTTPRequestSettlementInfo* settlementHTTP;    // 商户结算信息的http
@property (nonatomic, strong) NSDictionary* settlementInformation;          // 商户的结算信息
@end

@implementation CustPayViewController
@synthesize labelDisplayMoney               = _labelDisplayMoney;
@synthesize money                       = _money;
@synthesize moneyCalculated             = _moneyCalculated;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubViews];
    UIBarButtonItem* backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(backToLastViewController)];
    [self.navigationItem setBackBarButtonItem:backBarButton];
    
    isSettlementT_0 = NO;
    blueToothPowerOn = NO;
    blueManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    // 申请结算信息
    [self startHTTPRequestForSettlementInfo];
}
- (void) backToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    // 修改标题栏的字体颜色
    UIColor* color = [UIColor redColor];
    NSDictionary* textAttri = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = textAttri;
    self.navigationController.navigationBar.tintColor = color;

    
    // 更新结算方式的标记
    if (self.settlementInformation) {
        [self.settlementView setEnableSwitching:[[self.settlementInformation objectForKey:kSettleInfoNameT_0_Enable] boolValue]];
        [self.settlementView switchNormal];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mask ---- HTTP && HTTPRequestSettlementInfoDelegate
/* 请求数据 */
- (void) startHTTPRequestForSettlementInfo {
    if ([ModelDeviceBindedInformation hasBindedDevice]) {
        [self.settlementHTTP requestSettlementInfoWithBusinessNumber:[ModelDeviceBindedInformation businessNoBinded]
                                                      terminalNumber:[ModelDeviceBindedInformation terminalNoBinded]
                                                            delegate:self];
    }
}
/* 回调 */
- (void) didRequestedResult:(BOOL)result settlementInfo:(NSDictionary *)settlementInfo orErrorMessage:(NSString *)errorMessage
{
    if (result) {
        self.settlementInformation = [NSDictionary dictionaryWithDictionary:[settlementInfo copy]];
    } else {
        NSString* alert = [NSString stringWithFormat:@"结算信息查询失败[%@]", errorMessage];
        [self alertShow:alert];
    }
}

#pragma mask ---- SettlementSwitchViewDelegate
- (void)didSwitchedSettlementType:(SETTLEMENTTYPE)settlementType {
    switch (settlementType) {
        case SETTLEMENTTYPE_T_0:
        {
            isSettlementT_0 = YES;
            // 提示T+0信息
            [self alertInformationForT_0];
        }
            break;
        case SETTLEMENTTYPE_T_1:
        {
            isSettlementT_0 = NO;
        }
            break;
        default:
            isSettlementT_0 = YES;
            break;
    }
}
- (void) alertInformationForT_0 {
    if (self.settlementInformation) {
        NSMutableString* alert = [[NSMutableString alloc] init];
        
        [alert appendFormat:@"T+0单日限额: %@\n",[self.settlementInformation objectForKey:kSettleInfoNameAmountLimit]];
        [alert appendFormat:@"T+0当日可刷额度: %@\n",[self.settlementInformation objectForKey:kSettleInfoNameAmountAvilable]];
        [alert appendFormat:@"T+0最小刷卡限额: %@\n",[self.settlementInformation objectForKey:kSettleInfoNameMinCustAmount]];
        [alert appendFormat:@"T+0增加费率: +%@%%",[self.settlementInformation objectForKey:kSettleInfoNameT_0_Fee]];
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:alert delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
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
    CGFloat horizontalWidth = rect.size.width;  // 水平
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
    for (int j = 0; j < 4; j++) {
        UIView* line = [[UIView alloc] initWithFrame:frame];
        line.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
        frame.origin.x += rect.size.width/3.0;
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
- (IBAction) touchUp:(UIButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
    sender.backgroundColor              = [UIColor clearColor];
    // 向金额对象压入输入的数字
    self.money = [self.moneyCalculated moneyByAddedNumber:sender.titleLabel.text];
}


#pragma mask  ---- 撤销按钮的点击事件
- (IBAction) touchUpDelete:(DeleteButton*)sender {
    sender.transform                    = CGAffineTransformIdentity;
    sender.backgroundColor              = [UIColor clearColor];
    // 获取撤销后的上一次输入的金额
    self.money = [self.moneyCalculated moneyByRevoked];
}

/*************************************
 * 功  能 : 撤销按钮的长按事件;清除所有金额；
 * 参  数 :
 * 返  回 :
 *************************************/
- (IBAction)longPressButtonOfDelete:(UILongPressGestureRecognizer*)sender {
    while (YES) {
        self.money = [self.moneyCalculated moneyByRevoked];
        if ([self.money isEqualToString:@"0.00"]) {
            break;
        }
    }
    
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
    if ([self.money floatValue] < 0.0001) {
        [self alertShow:@"请输入金额!"];
        return;
    }
    
    if (!blueToothPowerOn) {
        [self alertShow:@"手机蓝牙未打开,请打开蓝牙"];
        return;
    }
    
//    if (self.settlementInformation && [[self.settlementInformation objectForKey:kSettleInfoNameT_0_Enable] boolValue]) {
    if (isSettlementT_0) {
        SettlementInfoViewController* settlementVC = [[SettlementInfoViewController alloc] initWithStyle:UITableViewStylePlain];
        settlementVC.settlementInformation = [NSDictionary dictionaryWithDictionary:[self.settlementInformation copy]];
        settlementVC.sFloatMoney = self.money;
        [self.navigationController pushViewController:settlementVC animated:YES];
    } else {
        // 跳转刷卡界面
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        BrushViewController *viewcon = [storyboard instantiateViewControllerWithIdentifier:@"brush"];
        [viewcon setStringOfTranType:TranType_Consume];
        [viewcon setSFloatMoney:self.money];
        [viewcon setSIntMoney:[self sIntMoneyOfFloatMoney:self.money]];
        [self.navigationController pushViewController:viewcon animated:YES];
    }
    
    // 重置金额
    self.money = @"0.00";
    self.moneyCalculated = nil;
}



#pragma mask ::: 自定义返回上层界面按钮的功能
- (IBAction) backToPreVC :(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    // 字体大小: 数字按钮组的
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    // 有效高度: 视图的
    CGFloat visibleHeight = self.view.bounds.size.height - self.tabBarController.tabBar.bounds.size.height - statusBarHeight;
    // 宽度: 分割线
    CGFloat  bornerWith = 1;
    // 间隔值
    CGFloat inset = 5.0;
    // 宽度: 数字按钮
    CGFloat numBtnWidth = self.view.bounds.size.width/3.0;
    // logo imageView高度
    CGSize  logoImgSize = [UIImage imageNamed:ImageForBrand].size;
    CGFloat logoImgWidth = self.view.bounds.size.width / 2.0;
    CGFloat logoImgHeight = logoImgWidth * logoImgSize.height/logoImgSize.width;
    /* ---------
     1.计算好logo的最小高度
     2.计算数字按钮最大高度
     3.计算金额显示框最大高度
     4.计算金额显示框最小高度
     --------- */
    CGFloat minHeightLogoImageView = logoImgHeight + inset*2;
    CGFloat maxHeightNumButton = numBtnWidth * 3.0/4.0 * 4.0/5.0;
//    CGFloat maxHeightMoneyDisplay = maxHeightNumButton * 1.5;
    CGFloat minHeightMoneyDisplay = minHeightLogoImageView;
    
    // 初始高度值: 图标、金额框、数字按钮
    CGFloat heightLogoImageView = minHeightLogoImageView;
    CGFloat heightMoneyDisplay = minHeightMoneyDisplay;
    CGFloat heightNumButton = (visibleHeight - minHeightLogoImageView - minHeightMoneyDisplay)/5.0;
    // 如果数字按钮高度大于最大值:置为最大值,金额框、logo视图各分多出来的高度的一半
    if (heightNumButton > maxHeightNumButton) {
        CGFloat difference = (heightNumButton - maxHeightNumButton)*5;
        heightNumButton = maxHeightNumButton;
        heightLogoImageView += difference/2.0;
        heightMoneyDisplay += difference/2.0;
    }
    CGFloat yCenterPre = 0 + statusBarHeight;
    //////////////////////

    
    // 图标
    CGRect  frame                       = CGRectMake(0, 0, logoImgWidth, logoImgHeight);
    UIImageView *imageView              = [[UIImageView alloc] initWithFrame:frame];
    imageView.image                     = [UIImage imageNamed:ImageForBrand];
    imageView.center = CGPointMake(self.view.frame.size.width/2.0, yCenterPre + heightLogoImageView/2.0);
    yCenterPre += heightLogoImageView;
    [self.view addSubview:imageView];
    
    // 金额背景框
    frame.size.width = self.view.bounds.size.width - bornerWith*2;
    frame.size.height                   = heightMoneyDisplay - bornerWith*2;
    UIView  *moneyView                  = [[UIView alloc] initWithFrame:frame];
    moneyView.backgroundColor           = [UIColor colorWithRed:180.0/255.0 green:188.0/255.0 blue:194.0/255.0 alpha:1.0]; // 灰色
    moneyView.center = CGPointMake(self.view.frame.size.width/2.0, yCenterPre + heightMoneyDisplay/2.0);
    [self.view addSubview:moneyView];
    
    // moneyLabel
    CGRect innerFrame = CGRectMake(0, 0, frame.size.width - 45, frame.size.height);
    self.labelDisplayMoney.frame = innerFrame;
    self.labelDisplayMoney.font = [UIFont boldSystemFontOfSize:[PublicInformation resizeFontInSize:innerFrame.size andScale:6.0/12.0]];
    [moneyView addSubview:self.labelDisplayMoney];
    
    // 结算方式切换视图
    innerFrame.origin.x += inset;
    innerFrame.origin.y += inset;
    innerFrame.size.height = 20;
    [self.settlementView setFrame:innerFrame];
    [moneyView addSubview:self.settlementView];
    
    // moneyImageView 金额符号Label : 字体大小为金额字体大小的 3/4, 因为字体为汉字，显示要比英文字母高一点，所以将y降低一个 inset，高度也减少一个 inset
    innerFrame.origin.x                 = 0 + innerFrame.size.width + inset;
    innerFrame.origin.y                 = 0 + inset;
    innerFrame.size.width               = frame.size.width - innerFrame.origin.x;
    innerFrame.size.height              = frame.size.height;
    UILabel *moneySymbolLabel           = [[UILabel alloc] initWithFrame:innerFrame];
    moneySymbolLabel.text               = @"￥";
    moneySymbolLabel.textAlignment      = NSTextAlignmentLeft;
    moneySymbolLabel.font               = [UIFont boldSystemFontOfSize:[PublicInformation resizeFontInSize:frame.size andScale:7.0/12.0 * 2.0/3.0]];
    [moneyView addSubview:moneySymbolLabel];
    yCenterPre += heightMoneyDisplay;
    
    // 数字按键组
    NSArray * numbers                   = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@".",@"0",@"delete"];
    frame.size.width                    = numBtnWidth;
    frame.size.height                   = heightNumButton;
    CGRect numbersFrame                 = CGRectMake(0, yCenterPre, self.view.bounds.size.width, heightNumButton*4);
    for (int i = 0; i < numbers.count; i++) {
        NSString* titleButton = [numbers objectAtIndex:i];
        CGPoint curCenterPoint = CGPointMake(0 + numBtnWidth * (i % 3) + numBtnWidth/2.0, yCenterPre + heightNumButton * (i / 3) + heightNumButton/2.0);
        // 数字按钮+小数点按钮
        if (titleButton.length == 1) {
            UIButton* numberButton = [[UIButton alloc] initWithFrame:frame];
            numberButton.center = curCenterPoint;
            [numberButton setTitle:titleButton forState:UIControlStateNormal];
            [numberButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            numberButton.titleLabel.font = [UIFont boldSystemFontOfSize:[PublicInformation resizeFontInSize:frame.size andScale:2.0/3.0]];
            [numberButton  addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
            [numberButton  addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
            [numberButton  addTarget:self action:@selector(touchUpOut:) forControlEvents:UIControlEventTouchUpOutside];
            [self.view addSubview:numberButton];
        }
        // 删除按钮
        else {
            DeleteButton* deleteButton = [[DeleteButton alloc] initWithFrame:frame];
            deleteButton.center = curCenterPoint;
            [deleteButton  addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
            [deleteButton  addTarget:self action:@selector(touchUpDelete:) forControlEvents:UIControlEventTouchUpInside];
            [deleteButton  addTarget:self action:@selector(touchUpOut:) forControlEvents:UIControlEventTouchUpOutside];
            // 给撤销按钮添加一个长按事件:将金额清零,金额栈也清0
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressButtonOfDelete:)];
            longPress.minimumPressDuration = 0.8;
            [deleteButton addGestureRecognizer:longPress];
            [self.view addSubview:deleteButton];
        }
    }
    // 分割线
    [self drawLineInRect:numbersFrame];
    yCenterPre += heightNumButton*4;
    
    // 刷卡按钮
    frame.size.width                    = self.view.bounds.size.width - inset*2;
    frame.size.height                   = heightNumButton - inset*2;
    UIButton *brushButton               = [[UIButton alloc] initWithFrame:frame];
    brushButton.center = CGPointMake(self.view.frame.size.width/2.0, yCenterPre + heightNumButton/2.0);
    brushButton.layer.cornerRadius      = 8.0;
    brushButton.backgroundColor         = [PublicInformation returnCommonAppColor:@"red"];
    [brushButton setTitle:@"开始刷卡" forState:UIControlStateNormal];
    [brushButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [brushButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [brushButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    brushButton.titleLabel.font = [UIFont boldSystemFontOfSize:[PublicInformation resizeFontInSize:frame.size andScale:0.7]];
    [brushButton addTarget:self action:@selector(beginBrush:) forControlEvents:UIControlEventTouchDown];
    [brushButton addTarget:self action:@selector(toBrushClick:) forControlEvents:UIControlEventTouchUpInside];
    [brushButton addTarget:self action:@selector(outBrush:) forControlEvents:UIControlEventTouchUpOutside];
    [brushButton setSelected:YES];
    [self.view addSubview:brushButton];
}


// 简化代码:简单的弹窗提示
- (void) alertShow: (NSString*) msg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// 小数点型金额转换为整型金额
- (NSString*) sIntMoneyOfFloatMoney:(NSString*)floatMoney {
    NSString* sIntMoney = nil;
    NSString* sInt = [floatMoney substringToIndex:[floatMoney rangeOfString:@"."].location];
    NSString* sFloat = [floatMoney substringFromIndex:[floatMoney rangeOfString:@"."].location + 1];
    sIntMoney = [NSString stringWithFormat:@"%012d",sInt.intValue * 100 + sFloat.intValue];
    return sIntMoney;
}



#pragma mask --- setter & getter
- (MoneyCalculated *)moneyCalculated {
    if (_moneyCalculated == nil) {
        _moneyCalculated = [[MoneyCalculated alloc] initWithLimit:6];   // 金额限制在6位
    }
    return _moneyCalculated;
}
/* 金额值的 setter 方法 */
- (void)setMoney:(NSString*)money {
    if (![_money isEqualToString: money]) {
        _money                          = money;
        _labelDisplayMoney.text             = _money;
    }
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
- (SettlementSwitchView *)settlementView {
    if (_settlementView == nil) {
        _settlementView = [[SettlementSwitchView alloc] initWithFrame:CGRectZero];
        [_settlementView setDelegate:self];
//        _settlementView.enableSwitching = NO;
    }
    return _settlementView;
}
- (HTTPRequestSettlementInfo *)settlementHTTP {
    if (_settlementHTTP == nil) {
        _settlementHTTP = [[HTTPRequestSettlementInfo alloc] init];
    }
    return _settlementHTTP;
}

@end
