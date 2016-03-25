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
#import "ModelUserLoginInformation.h"
#import "IntMoneyCalculating.h"

#import "ModelRateInfoSaved.h"
#import "ModelBusinessInfoSaved.h"
#import "JCAlertView.h"
#import "PullListSegView.h"
#import "VMT_0InfoRequester.h"

#import <objc/runtime.h>



@interface CustPayViewController ()
<CBCentralManagerDelegate,
UITableViewDataSource,UITableViewDelegate>
{
    BOOL blueToothPowerOn;              // 蓝牙打开状态标记
    CBCentralManager* blueManager;      // 蓝牙设备操作入口
}
@property (nonatomic, strong) UILabel *labelDisplayMoney;                   // 金额显示标签栏
@property (nonatomic, strong) UIView* backViewOfMoney;                      // 用来优化结算方式视图的点击体验

@property (nonatomic, strong) IntMoneyCalculating* intMoneyCalculating;

@property (nonatomic, strong) UILabel* settlementPreLabel;                  // 显示结算方式
@property (nonatomic, strong) UIButton* settlementSwitchBtn;                // 切换结算方式
@property (nonatomic, strong) PullListSegView* pullListView;

@property (nonatomic, strong) NSMutableArray* displaySettlementTypes;
@property (nonatomic, assign) NSInteger selectedSettlementIndex;

@end

@implementation CustPayViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubViews];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
    
    blueToothPowerOn = NO;
    blueManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [self addKVOs];
    self.selectedSettlementIndex = -1;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    // 申请结算信息
    if ([ModelUserLoginInformation allowedT_0] && BranchAppName != 3) {
        [self startHTTPRequestForSettlementInfo];
    }
    // 重置当前的结算方式
    [ModelSettlementInformation sharedInstance].curSettlementType = SETTLEMENTTYPE_T_1;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void) addKVOs {
    [[ModelSettlementInformation sharedInstance] addObserver:self forKeyPath:@"curSettlementType" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"curSettlementType"]) {
        SETTLEMENTTYPE curSettllementType = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        self.settlementPreLabel.text = [NSString stringWithFormat:@"结算方式:%@", [ModelSettlementInformation nameOfSettlementType:curSettllementType]];
        if (curSettllementType == SETTLEMENTTYPE_T_0) {
            [self alertInformationForT_0];
        }
    }
}

/* 重载点击事件: 优化点击的体验 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint curPoint = [touch locationInView:self.view];
    /* 判断是否在T+0切换视图中 */
    if (curPoint.x >= self.backViewOfMoney.frame.origin.x &&
        curPoint.x <= self.backViewOfMoney.frame.origin.x + self.backViewOfMoney.frame.size.width &&
        curPoint.y >= self.backViewOfMoney.frame.origin.y &&
        curPoint.y <= self.backViewOfMoney.frame.origin.y + self.backViewOfMoney.frame.size.height
        )
    {
        if (BranchAppName != 3) {
            [self clickToSwitchSettlement:self.settlementSwitchBtn];
        }
    }
}

#pragma mask ---- HTTP
/* 请求数据 */
- (void) startHTTPRequestForSettlementInfo {
    if ([ModelDeviceBindedInformation hasBindedDevice]) {
        NameWeakSelf(wself);
        [[VMT_0InfoRequester sharedInstance] requestT_0InformationWithBusinessNumbser:[ModelDeviceBindedInformation businessNoBinded] onSucBlocK:^{
            VMT_0InfoRequester* vmT0Requester = [VMT_0InfoRequester sharedInstance];
            if ([vmT0Requester enableT_0]) {
                wself.settlementSwitchBtn.hidden = NO;
                if (![wself.displaySettlementTypes containsObject:@(SETTLEMENTTYPE_T_0)]) {
                    [wself.displaySettlementTypes insertObject:@(SETTLEMENTTYPE_T_0) atIndex:1];
                }
            } else {
                if ([wself.displaySettlementTypes containsObject:@(SETTLEMENTTYPE_T_0)]) {
                    [wself.displaySettlementTypes removeObjectAtIndex:1];
                }
            }
        } onErrorBlock:^(NSError *error) {
            
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

// -- 点击切换结算方式
- (IBAction) clickToSwitchSettlement:(UIButton*)sender {
    CGRect frame = sender.frame;
    CGFloat widthPullList = 160;
    frame.origin.x = frame.origin.x + frame.size.width/2.f - widthPullList/2.f;
    frame.origin.y += frame.size.height + 4;
    frame.size.width = widthPullList;
    [self.pullListView setFrame:frame];
    [self.pullListView showWithCompletion:^{}];
}
#pragma mark 2  UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellIdentifier = @"cellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.textLabel.text = [ModelSettlementInformation nameOfSettlementType:[[self.displaySettlementTypes objectAtIndex:indexPath.row] intValue]];
    if (indexPath.row == self.selectedSettlementIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.displaySettlementTypes.count;
}
#pragma mark 2  UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedSettlementIndex = indexPath.row;
    SETTLEMENTTYPE selectedSettlementType = [[self.displaySettlementTypes objectAtIndex:indexPath.row] intValue];
    [self.pullListView hideWithCompletion:^{
        [ModelSettlementInformation sharedInstance].curSettlementType = selectedSettlementType;
    }];
}

- (void) alertInformationForT_0 {
    NSMutableString* alert = [[NSMutableString alloc] init];
    [alert appendFormat:@"单日限额:      ￥%@\n",[[VMT_0InfoRequester sharedInstance] amountLimit]];
    [alert appendFormat:@"单笔最小限额:   ￥%@\n",[[VMT_0InfoRequester sharedInstance] amountMinCust]];
    [alert appendFormat:@"单日可刷额度:   ￥%@\n",[[VMT_0InfoRequester sharedInstance] amountAvilable]];
    [alert appendFormat:@"手续费率:      +%@%%\n",[[VMT_0InfoRequester sharedInstance] T_0MoreRate]];
    [alert appendFormat:@"转账手续费:    ￥%@", [[VMT_0InfoRequester sharedInstance] T_0ExtraFee]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [JCAlertView showOneButtonWithTitle:@"T+0温馨提示" Message:alert ButtonType:JCAlertViewButtonTypeDefault ButtonTitle:@"确定" Click:^{
        }];
    });
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

/* 刷卡前检查输入 */
- (BOOL) checkInputsBeforeSwipe {
    BOOL inputsValid = YES;
    NameWeakSelf(wself);

    if ([self.labelDisplayMoney.text floatValue] < 0.0001) {
        [PublicInformation makeToast:@"请输入金额!"];
        inputsValid = NO;
    }
    else if (!blueToothPowerOn) {
        [PublicInformation makeToast:@"手机蓝牙未打开,请打开蓝牙!"];
        inputsValid = NO;
    }
    else if (![ModelDeviceBindedInformation hasBindedDevice]) {
        [PublicInformation makeToast:@"设备未绑定,请先绑定设备!"];
        inputsValid = NO;
    }
    else if ([[ModelSettlementInformation sharedInstance] curSettlementType] == SETTLEMENTTYPE_T_0) {
        if (self.labelDisplayMoney.text.floatValue < [[VMT_0InfoRequester sharedInstance] amountMinCust].floatValue) {
            NSString* log = [NSString stringWithFormat:@"T+0最小刷卡额度:%@￥",[[VMT_0InfoRequester sharedInstance] amountMinCust]];
            [PublicInformation makeToast:log];
            inputsValid = NO;
        }
        else if (self.labelDisplayMoney.text.floatValue > [[VMT_0InfoRequester sharedInstance] amountAvilable].floatValue) {
            NSString* log = [NSString stringWithFormat:@"金额超限:T+0当日可刷卡额度:%@￥",[[VMT_0InfoRequester sharedInstance] amountAvilable]];
            [PublicInformation makeToast:log];
            inputsValid = NO;
        }
    }
    else if ([ModelUserLoginInformation allowedMoreBusiness] && [ModelBusinessInfoSaved beenSaved]) {
        NSString* alert = [NSString stringWithFormat:@"已设置指定商户:\n[%@][%@]\n是否继续刷卡?", [ModelBusinessInfoSaved businessName],[ModelBusinessInfoSaved rateTypeSelected]];
        [JCAlertView showTwoButtonsWithTitle:@"温馨提示" Message:alert ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"取消" Click:^{
        } ButtonType:JCAlertViewButtonTypeDefault ButtonTitle:@"继续" Click:^{
            [wself pushSwipeOrOtherDisplayVC];
        }];
        inputsValid = NO;
    }
    else if ([ModelUserLoginInformation allowedMoreRate] && [ModelRateInfoSaved beenSaved]) {
        NSString* alert = [NSString stringWithFormat:@"已设置指定费率:\n[%@][%@]\n是否继续刷卡?", [ModelRateInfoSaved rateTypeSelected],[ModelRateInfoSaved cityName]];
        [JCAlertView showTwoButtonsWithTitle:@"温馨提示" Message:alert ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"取消" Click:^{
        } ButtonType:JCAlertViewButtonTypeDefault ButtonTitle:@"继续" Click:^{
            [wself pushSwipeOrOtherDisplayVC];
        }];
        inputsValid = NO;
    }
    return inputsValid;
}

/* 跳转界面: 根据t+0条件切换不同界面 */
- (void) pushSwipeOrOtherDisplayVC {
    UIViewController* viewController = nil;
    if ([[ModelSettlementInformation sharedInstance] curSettlementType] == SETTLEMENTTYPE_T_0) {
        viewController = [[SettlementInfoViewController alloc] initWithNibName:nil bundle:nil];
        SettlementInfoViewController* settlementVC = (SettlementInfoViewController*)viewController;
        [settlementVC setSFloatMoney:[NSString stringWithString:self.labelDisplayMoney.text]];
    } else {
        // 跳转刷卡界面
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        viewController = [storyboard instantiateViewControllerWithIdentifier:@"brush"];
        BrushViewController* viewcon = (BrushViewController*)viewController;
        [viewcon setStringOfTranType:TranType_Consume];
        [viewcon setSFloatMoney:self.labelDisplayMoney.text];
        [viewcon setSIntMoney:[PublicInformation intMoneyFromDotMoney:self.labelDisplayMoney.text]];
    }
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
    CGFloat maxHeightNumButton = numBtnWidth * 3.0/4.0 * 4.0/5.0;
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
    imageView.image = [PublicInformation logoImageOfApp];
    imageView.center = CGPointMake(self.view.frame.size.width/2.0, yCenterPre + heightLogoImageView/2.0);
    yCenterPre += heightLogoImageView;
    [self.view addSubview:imageView];
    
    // 金额背景框
    frame.origin.x = bornerWith;
    frame.origin.y = yCenterPre;
    frame.size.width = self.view.bounds.size.width - bornerWith*2;
    frame.size.height = heightMoneyDisplay - bornerWith*2;
    [self.backViewOfMoney setFrame:frame];
    [self.view addSubview:self.backViewOfMoney];
    
    // 结算方式切换视图
    CGRect innerFrame = CGRectMake(frame.origin.x + inset, frame.origin.y + inset, 0, 20);
    UIFont* littleFont = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:innerFrame.size andScale:1.f]];
    self.settlementPreLabel.font = littleFont;
    innerFrame.size.width = [self.settlementPreLabel.text sizeWithAttributes:@{NSFontAttributeName:littleFont}].width + 15;
    [self.settlementPreLabel setFrame:innerFrame];
    [self.view addSubview:self.settlementPreLabel];
    
    innerFrame.origin.x += innerFrame.size.width;
    innerFrame.size.width = [[self.settlementSwitchBtn titleForState:UIControlStateNormal] sizeWithAttributes:@{NSFontAttributeName:littleFont}].width + 4;
    [self.settlementSwitchBtn setFrame:innerFrame];
    self.settlementSwitchBtn.titleLabel.font = littleFont;
    [self.view addSubview:self.settlementSwitchBtn];

    // moneyLabel
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
    
    // 下拉展示
    [self.view addSubview:self.pullListView];
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
- (UILabel *)settlementPreLabel {
    if (!_settlementPreLabel) {
        _settlementPreLabel = [UILabel new];
        _settlementPreLabel.text = [NSString stringWithFormat:@"结算方式:%@" ,[ModelSettlementInformation nameOfSettlementType:SETTLEMENTTYPE_T_1]];
        _settlementPreLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
    }
    return _settlementPreLabel;
}
- (UIButton *)settlementSwitchBtn {
    if (!_settlementSwitchBtn) {
        _settlementSwitchBtn = [UIButton new];
        [_settlementSwitchBtn setTitle:@"切换" forState:UIControlStateNormal];
        [_settlementSwitchBtn setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
        [_settlementSwitchBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_settlementSwitchBtn addTarget:self action:@selector(clickToSwitchSettlement:) forControlEvents:UIControlEventTouchUpInside];
        _settlementSwitchBtn.hidden = YES;
    }
    return _settlementSwitchBtn;
}
- (NSMutableArray *)displaySettlementTypes {
    if (!_displaySettlementTypes) {
        _displaySettlementTypes = [NSMutableArray array];
        [_displaySettlementTypes addObject:@(SETTLEMENTTYPE_T_1)];
        if ([ModelUserLoginInformation allowedT_N] && BranchAppName != 3) {
            self.settlementSwitchBtn.hidden = NO;
            [_displaySettlementTypes addObject:@(SETTLEMENTTYPE_T_6)];
            [_displaySettlementTypes addObject:@(SETTLEMENTTYPE_T_15)];
            [_displaySettlementTypes addObject:@(SETTLEMENTTYPE_T_30)];
        }
    }
    return _displaySettlementTypes;
}
- (PullListSegView *)pullListView {
    if (!_pullListView) {
        _pullListView = [[PullListSegView alloc] init];
        _pullListView.tableView.dataSource = self;
        _pullListView.tableView.delegate = self;
    }
    return _pullListView;
}

@end
