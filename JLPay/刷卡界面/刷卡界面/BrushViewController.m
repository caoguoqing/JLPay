//
//  BrushViewController.m
//  JLPay
//
//  Created by jielian on 15/4/14.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "BrushViewController.h"
#import "Define_Header.h"
#import "CustomIOSAlertView.h"
#import "CustPayViewController.h"
#import "QianPiViewController.h"
#import "DeviceManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "Packing8583.h"
#import "ViewModelTCPPosTrans.h"
#import "BalanceEnquiryViewController.h"
#import "ModelDeviceBindedInformation.h"
#import "ModelSettlementInformation.h"
#import "ModelTCPTransPacking.h"

@interface BrushViewController()
<
    CustomIOSAlertViewDelegate,
    ViewModelTCPPosTransDelegate,
    UIAlertViewDelegate,
    DeviceManagerDelegate,
    CBCentralManagerDelegate
>
{
    BOOL blueToothPowerOn;
    CBCentralManager* blueManager; // 用来检测手机蓝牙是否开启
    NSString* curTransType;
}

@property (nonatomic, strong) ViewModelTCPPosTrans* tcpViewModel;           // TCP交易中转

@property (nonatomic, retain) NSMutableDictionary* cardInfoOfReading;       // 读到得卡数据
@property (nonatomic, copy) NSDictionary* transResponseInfo;                // 交易响应信息

@property (nonatomic, strong) UIActivityIndicatorView* activity;            // 刷卡状态的指示器
@property (nonatomic, strong) CustomIOSAlertView* passwordAlertView;        // 自定义alert:密码输入弹窗

@property (nonatomic, strong) UILabel* waitingLabel;                        // 动态文本框
@property (nonatomic, strong) UILabel* moneyLabel;                          // 金额显示框
@property (nonatomic, assign) CGFloat leftInset;                            // 动态文本区域的左边静态文本区域的右边界长度

@property (nonatomic, assign) int timeOut;                                  // 交易超时时间
@property (nonatomic, strong) NSTimer* waitingTimer;                        // 控制定时器


@end

/*************************************
 * ---- 功能
 *      1.刷卡
 *      2.输入密码
 *      3.发送交易报文(消费、查询、批上传)
 *      4.接收返回报文
*************************************/



 
@implementation BrushViewController
@synthesize activity = _activity;
@synthesize passwordAlertView = _passwordAlertView;
@synthesize waitingLabel = _waitingLabel;
@synthesize leftInset;
@synthesize timeOut;
@synthesize waitingTimer = _waitingTimer;
@synthesize stringOfTranType = _stringOfTranType;
@synthesize moneyLabel = _moneyLabel;
@synthesize cardInfoOfReading = _cardInfoOfReading;

/*************************************
 * 功  能 : 界面的初始化;
 *          - 金额标签              UILabel + UIImageView
 *          - 刷卡动态提示           UILabel + UIActiveView
 *          - 刷卡说明图片           UIImageView
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    
    // 加载子视图
    [self setTitle:@"刷卡"];
    [self addSubViews];
    // 交易超时时间为60秒,后面可以重置
    [self setTimeOut:60];
    
    blueToothPowerOn = NO;
    blueManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [[DeviceManager sharedInstance] setDelegate:self];
}



#pragma mask ::: 子视图的属性设置
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.activity startAnimating];
    
    self.navigationController.navigationBarHidden = NO;
}


#pragma mask ::: 界面显示后的事件注册及处理
/*************************************
 * 功  能 : 进入界面后，各个轮询事件就开始了;
 *          - 在副线程中扫描并打开设备
 *          - 在主线程中加载识别设备的定时器，并显示
 *          - 在主线程中加载刷卡的定时器，并显示
 *          - 在主线程中加载交易的定时器，并显示
 * 参  数 :
 *          (NSString*) message
 * 返  回 : 无
 *************************************/
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 1.先检查是否绑定设备
    if (![ModelDeviceBindedInformation hasBindedDevice]) {
        [self alertForFailedMessage:@"未绑定设备,请先绑定设备!"];
        return;
    }

    // 2.检查蓝牙是否开启
    if (!blueToothPowerOn) {
        [self alertForFailedMessage:@"手机蓝牙未打开,请打开蓝牙"];
        return;
    }

    // 3.扫描设备
    [[DeviceManager sharedInstance] makeDeviceEntryOnDeviceType:[ModelDeviceBindedInformation deviceTypeBinded]];
    [[DeviceManager sharedInstance] openDeviceWithIdentifier:[ModelDeviceBindedInformation deviceIDBinded]];

    // 4.先在主线程打开activitor 和 提示信息
    [self.activity startAnimating];
    self.timeOut = 20; // 扫描设备的超时时间为30
    [self startTimerWithSelector:@selector(waitingForDeviceOpenning)];

}
#pragma mask ::: 释放资源
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 移除定时器
    [self stopTimer];
    // 取消 TCP 响应的协议
    [self.tcpViewModel terminateTransWithTransType:self.stringOfTranType];
    // 断开设备
    [[DeviceManager sharedInstance] clearAndCloseAllDevices];
    [blueManager setDelegate:nil];
}


#pragma mask : SN号读取回调:SN号在设备连接后自动被读取
- (void)didConnectedDeviceResult:(BOOL)result onSucSN:(NSString *)SNVersion onErrMsg:(NSString *)errMsg
{
    [self stopTimer];
    if (!result) {
        // 提示并退出
        [self.activity stopAnimating];
        [self alertForFailedMessage:@"连接设备失败"];
    } else {
        // 继续刷卡:读磁道等信息
        [self beginToSwipe];
    }
}

#pragma mask ::: 进行刷卡
- (void) beginToSwipe {
    self.timeOut = 0; // 超时从0开始计数
    [self.activity startAnimating];
    // 启动定时器:刷卡计时
    [self startTimerWithSelector:@selector(waitingForDeviceSwiping)];
    [[DeviceManager sharedInstance] cardSwipeWithMoney:self.sIntMoney yesOrNot:NO onSNVersion:[ModelDeviceBindedInformation deviceSNBinded]];
}


#pragma mask : DeviceManagerDelegate 刷卡结果的回调
- (void)didCardSwipedResult:(BOOL)result onSucCardInfo:(NSDictionary *)cardInfo onErrMsg:(NSString *)errMsg
{
    [self stopTimer];
    [self stopActivity];
    if (!result) {
        [self alertForFailedMessage:errMsg];
        return;
    }
    if (self.cardInfoOfReading.count > 0) {
        [self.cardInfoOfReading removeAllObjects];
        self.cardInfoOfReading = nil;
    }
    // 添加读取到得卡数据
    [self.cardInfoOfReading addEntriesFromDictionary:cardInfo];
    // 添加金额
    [self.cardInfoOfReading setValue:self.sIntMoney forKey:@"4"];

    
    // 成功就继续,输入密码或直接发起交易
    NSString* deviceType = [ModelDeviceBindedInformation deviceTypeBinded];
    if ([deviceType isEqualToString:DeviceType_DL01])
    {
        [self makePasswordAlertView];
    }
    else if ([deviceType isEqualToString:DeviceType_LD_M18])
    {
        [self makePasswordAlertView];
    }
    else if ([deviceType isEqualToString:DeviceType_JLpay_TY01]) {
        curTransType = self.stringOfTranType;
        [self startTransPackingOnTransType:curTransType];
    }
}

#pragma mask ::: 初始化并加载密码输入提示框
- (void) makePasswordAlertView {
    // innerView 放在 alertView 中创建
    self.passwordAlertView.delegate = self;
    [self.passwordAlertView setUseMotionEffects:YES];
    [self.passwordAlertView setButtonTitles:[NSArray arrayWithObjects:@"取消", @"确定", nil]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:self.passwordAlertView];
        [self.passwordAlertView show];
    });
}

#pragma mask ::: 密码输入提示框的按钮点击事件
- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    CustomIOSAlertView* alertV = (CustomIOSAlertView*)alertView;
    [alertV close];
    if (buttonIndex == 0) { // 取消
        // 弹出刷卡界面,回到上层界面
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {                // 确定-开始设备加密
        // 进行加密
        [self encryptPinWithSource:self.passwordAlertView.password];
    }
}

#pragma mask ::: 进行加密
- (void) encryptPinWithSource:(NSString*)source {
    curTransType = self.stringOfTranType;
    // pin encrypt. if source != null
    if (source && source.length > 0) {
        [[DeviceManager sharedInstance] pinEncryptBySource:source withPan:[self.cardInfoOfReading valueForKey:@"2"] onSNVersion:[ModelDeviceBindedInformation deviceSNBinded]];
    }
    // start trans. if source == null
    else {
        [self.cardInfoOfReading setObject:@"0600000000000000" forKey:@"53"];
        [self startTransPackingOnTransType:curTransType];
    }
}


#pragma mask : PIN加密密文获取
- (void)didPinEncryptResult:(BOOL)result onSucPin:(NSString *)pin onErrMsg:(NSString *)errMsg
{
    if (result) {
        if (pin && pin.length > 0) {
            NSMutableString* f22 = [NSMutableString stringWithString:[self.cardInfoOfReading valueForKey:@"22"]];
            [f22 replaceCharactersInRange:NSMakeRange(2, 1) withString:@"1"];
            [self.cardInfoOfReading setValue:f22 forKey:@"22"];
            [self.cardInfoOfReading setValue:pin forKey:@"52"];
            [self.cardInfoOfReading setValue:@"2600000000000000" forKey:@"53"];
        } else {
            [self.cardInfoOfReading setValue:@"0600000000000000" forKey:@"53"];
        }
        // 发起交易
        [self startTransPackingOnTransType:curTransType];
    } else {
        [self alertForFailedMessage:errMsg];
    }
}


#pragma mask ---- ViewModelTCPPosTransDelegate 
- (void)didTransSuccessWithResponseInfo:(NSDictionary *)responseInfo onTransType:(NSString *)transType {
    [self stopTimer];
    [self stopActivity];
    self.transResponseInfo = responseInfo;
    
    [self handleWithTransSuccessOnTransType:transType]; // 直接成功处理

    // --- modify: IC卡交易不送披上送交易了
//    if ([transType isEqualToString:TranType_BatchUpload]) {
//        [self handleWithTransSuccessOnTransType:transType];
//    } else {
//        if ([self.cardInfoOfReading[@"22"] hasPrefix:@"05"]) {
//            curTransType = TranType_BatchUpload;
//            // 将响应信息的域追加到卡信息域里
//            [self repackingCardInfoWithTransResponseInfo];
//            // 发起批上送交易
//            [self startTransPackingOnTransType:curTransType];
//        } else {
//            [self handleWithTransSuccessOnTransType:transType];
//        }
//    }
}
- (void)didTransFailWithErrMsg:(NSString *)errMsg onTransType:(NSString *)transType {
    [self stopTimer];
    [self stopActivity];
    if (![transType isEqualToString:TranType_BatchUpload]) {
        [self alertForFailedMessage:[NSString stringWithFormat:@"交易失败:%@",errMsg]];
    } else {
        [self handleWithTransSuccessOnTransType:self.stringOfTranType];
    }
}
- (void) handleWithTransSuccessOnTransType:(NSString*)transType {
    self.waitingLabel.text = @"交易成功";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.stringOfTranType isEqualToString:TranType_YuE]) {
            [self pushToYuEVCWithInfo:self.transResponseInfo];
        } else {
            [self pushToSignVCWithInfo:self.transResponseInfo];
        }
    });
}
- (void) repackingCardInfoWithTransResponseInfo {
    for (NSString* key in self.transResponseInfo.allKeys) {
        NSString* cardFieldValue = [self.cardInfoOfReading objectForKey:key];
        if (!cardFieldValue || cardFieldValue.length == 0) {
            [self.cardInfoOfReading setObject:[self.transResponseInfo objectForKey:key] forKey:key];
        }
    }
}


#pragma mask ---- PACKING & TCP
- (void) startTransPackingOnTransType:(NSString*)transType {
    self.timeOut = 0;
    [self startTimerWithSelector:@selector(waitingForDeviceCusting)];
    [self startActivity];
    [[ModelTCPTransPacking sharedModel] packingFieldsInfo:self.cardInfoOfReading forTransType:transType];
    [[DeviceManager sharedInstance] macEncryptBySource:[[ModelTCPTransPacking sharedModel] getMacStringAfterPacking]
                                               onSNVersion:[ModelDeviceBindedInformation deviceSNBinded]];
}

#pragma mask ---- 设备MAC加密结果
- (void)didMacEncryptResult:(BOOL)result onSucMacPin:(NSString *)macPin onErrMsg:(NSString *)errMsg
{
    if (result) {
        [[ModelTCPTransPacking sharedModel] repackingWithMacPin:macPin];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tcpViewModel startTransWithTransType:curTransType
                                      andPackingString:[[ModelTCPTransPacking sharedModel] packageFinalyPacking]
                                            onDelegate:self];
        });
    } else {
        [self alertForFailedMessage:errMsg];
    }
}

- (void)didDisconnectDeviceOnSN:(NSString *)SNVersion {
    if (![SNVersion isEqualToString:[ModelDeviceBindedInformation deviceSNBinded]]) {
        return;
    }
    [self stopTimer];
    [self stopActivity];
    [self alertForFailedMessage:[NSString stringWithFormat:@"交易失败:设备[%@]丢失",SNVersion]];
}
- (void)deviceManagerTimeOut {
    [self stopActivity];
    [self stopTimer];
    [self alertForFailedMessage:@"交易失败:设备操作超时!"];
}

#pragma mask ---- CBCentrolManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        blueToothPowerOn = YES;
    } else {
        blueToothPowerOn = NO;
    }
}


#pragma mask ---- PRIVATE INTERFACE

// 跳转界面: 跳转到签名界面
- (void) pushToSignVCWithInfo:(NSDictionary*)transInfo {
    QianPiViewController  *qianpi=[[QianPiViewController alloc] init];
    [qianpi qianpiType:1];
    [qianpi leftTitle:self.sFloatMoney];
    [qianpi setTransInformation:transInfo];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:qianpi animated:YES];
    });
}

// 跳转界面: 跳转余额显示界面
- (void) pushToYuEVCWithInfo:(NSDictionary*)transInfo {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BalanceEnquiryViewController* balanceEnquiryVC = [storyBoard instantiateViewControllerWithIdentifier:@"balanceEquiryVC"];
    balanceEnquiryVC.transInfo = [transInfo copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:balanceEnquiryVC animated:YES];
    });
}


/*************************************
 * 功  能 : 本模块注册在定时器中,1s扫描一次;
 *          - 检测设备是否连接
 *          - 如果已经连接了，就注销定时器，并继续刷卡
 *          - 如果到了超时时间还未连接，注销定时器，报错退出
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) waitingForDeviceOpenning {
    if (self.timeOut < 0) { // 超时了
        [self stopTimer];
        [self stopActivity];
        [self alertForFailedMessage:@"连接设备超时!"]; // 点击确定就会退出场景
        return;
    }
    [self.waitingLabel setText:[NSString stringWithFormat:@"设备识别中... %02d秒",self.timeOut--]];
}

/*************************************
 * 功  能 : 等待刷卡计时器;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) waitingForDeviceSwiping {
    if (self.timeOut > 30) {
        [self stopTimer];
        [self alertForFailedMessage:@"设备刷卡超时"]; // 点击确定就会退出场景
    } else {
        [self.waitingLabel setText:[NSString stringWithFormat:@"刷卡中,IC卡请勿拔卡...%02d秒",self.timeOut++]];

    }
}
/*************************************
 * 功  能 : 等待交易返回的计数器;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) waitingForDeviceCusting {
    [self.waitingLabel setText:[NSString stringWithFormat:@"交易处理中,请收好卡片...%02d秒",self.timeOut++]];
}


// -- 启动定时器:指定selector
- (void) startTimerWithSelector:(SEL)aselector {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.waitingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:aselector userInfo:nil repeats:YES];
    });
}
// -- 停止定时器
- (void) stopTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.waitingTimer isValid]) {
            [self.waitingTimer invalidate];
            self.waitingTimer = nil;
        }
    });
}
// -- 启动指示器
- (void) startActivity {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activity startAnimating];
    });
}
// -- 停止指示器
- (void) stopActivity {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.activity isAnimating]) {
            [self.activity stopAnimating];
        }
    });
}



/*************************************
 * 功  能 : 界面的subviews的加载;
 *          - 金额标签              UILabel + UIImageView
 *          - 刷卡动态提示           UILabel + UIActiveView
 *          - 刷卡说明图片           UIImageView
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) addSubViews {
    CGFloat topInset            = 15;                // 子视图公用变量: 上边界
    CGFloat fleftInset          = 15;                // 左边界
    CGFloat inset               = 30;                // 上部分视图跟下部分视图的间隔
    CGFloat uifont              = 20.0;              // 字体大小
    CGSize fontSize             = [@"刷卡" sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont boldSystemFontOfSize:uifont] forKey:NSFontAttributeName]];
    
    // 背景
    UIImageView* backImage      = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backImage.image             = [UIImage imageNamed:@"bg"];
    [self.view addSubview:backImage];
    
    CGFloat xFrame              = 0 + fleftInset;
    CGFloat navigationHeight    = self.navigationController.navigationBar.frame.size.height;
    CGFloat yFrame              = [PublicInformation returnStatusHeight] + navigationHeight + topInset;
    CGFloat width               = fontSize.height;
    CGFloat height              = fontSize.height;
    CGRect  frame               = CGRectMake(xFrame, yFrame, width, height);
    
    // 金额图片
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = [UIImage imageNamed:@"jine"];
    if (![self.stringOfTranType isEqualToString:TranType_YuE]) {
        [self.view addSubview:imageView];
    }
    // 刷卡金额: 0.00 元
    frame.origin.x += frame.size.width + 4;
    frame.size.width =  self.view.frame.size.width - fleftInset*2 - frame.size.width - 4;
    self.moneyLabel.frame = frame;
    self.moneyLabel.font = [UIFont boldSystemFontOfSize:uifont];
    if (![self.stringOfTranType isEqualToString:TranType_YuE]) {
        [self.view addSubview:self.moneyLabel];
    }
    
    // 动态滚轮
    frame.origin.x = fleftInset;
    frame.origin.y += frame.size.height + 4;
    frame.size.width = frame.size.height;
    self.activity.frame         = frame;
    [self.activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.activity];

    // 提示信息标签 Label
    frame.origin.x += frame.size.width + 4;
    frame.size.width = self.view.frame.size.width - leftInset*2 - frame.size.width - 4;
    self.waitingLabel.frame = frame;
    self.waitingLabel.textAlignment = NSTextAlignmentLeft;
    self.waitingLabel.font = [UIFont boldSystemFontOfSize:uifont];
    self.waitingLabel.text = @"请刷卡...";
    [self.view addSubview:self.waitingLabel];
    
    // 刷卡背景图
    UIImage* image = [UIImage imageNamed:@"swipeBlack"];
    CGSize imageSize = [image size];
    frame.origin.y              += frame.size.height + inset;
    frame.size.height           = self.view.frame.size.height - frame.origin.y - inset*2;
    frame.size.width            = frame.size.height * imageSize.width/imageSize.height;
    frame.origin.x = (self.view.bounds.size.width - frame.size.width)/2.0;
    
    
    
    UIImageView* shuakaImage    = [[UIImageView alloc] initWithFrame:frame];
    shuakaImage.image           = image;
    [self.view addSubview:shuakaImage];
}



/*************************************
 * 功  能 : 交易失败的alert显示;
 *          在主线程中显示;
 * 参  数 : 
 *          (NSString*) message
 * 返  回 : 无
 *************************************/
- (void) alertForFailedMessage: (NSString*) messageStr {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"交易失败" message:messageStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}
/*************************************
 * 功  能 : 交易失败的alert按钮跳转界面事件协议;
 *          pop时要考虑资源释放;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 要么是交易失败，要么设备未连接，都要弹出界面
    [self.navigationController popToRootViewControllerAnimated:YES];
}





#pragma mask ------------------------ getter
- (ViewModelTCPPosTrans *)tcpViewModel {
    if (_tcpViewModel == nil) {
        _tcpViewModel = [[ViewModelTCPPosTrans alloc] init];
    }
    return _tcpViewModel;
}
- (UIActivityIndicatorView *)activity {
    if (_activity == nil) {
        _activity                   = [[UIActivityIndicatorView alloc] init];
    }
    return _activity;
}

- (CustomIOSAlertView *)passwordAlertView {
    if (_passwordAlertView == nil) {
        _passwordAlertView = [[CustomIOSAlertView alloc] init];
    }
    return _passwordAlertView;
}

- (UILabel *)waitingLabel {
    if (_waitingLabel == nil) {
        _waitingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _waitingLabel;
}
- (UILabel *)moneyLabel {
    if (_moneyLabel == nil) {
        _moneyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        NSString* settleType = [ModelSettlementInformation nameOfSettlementType:[[ModelSettlementInformation sharedInstance] curSettlementType]] ;
        
        _moneyLabel.text = [NSString stringWithFormat:@"金额: %@ 元,(%@)",self.sFloatMoney, settleType];
    }
    return _moneyLabel;
}
// 刷卡超时定时器
- (NSTimer *)waitingTimer {
    return _waitingTimer;
}
// 交易类型
- (NSString *)stringOfTranType {
    if (_stringOfTranType == nil) {
        _stringOfTranType = [[NSUserDefaults standardUserDefaults] valueForKey:TranType];
    }
    return _stringOfTranType;
}
// 读卡数据字典
- (NSMutableDictionary *)cardInfoOfReading {
    if (_cardInfoOfReading == nil) {
        _cardInfoOfReading = [NSMutableDictionary dictionary];
    }
    return _cardInfoOfReading;
}
- (NSString *)sIntMoney {
    if (_sIntMoney == nil) {
        _sIntMoney = [NSString stringWithFormat:@"%012d",0];
    }
    return _sIntMoney;
}
- (NSString *)sFloatMoney {
    if (_sFloatMoney == nil) {
        _sFloatMoney = [NSString stringWithFormat:@"%.02lf",0.0];
    }
    return _sFloatMoney ;
}



#pragma mask ----------------------------- setter
/*************************************
 * 功  能 : 设置 self.waitingLabel的文本;
 *          该label的frame要根据文本的长度进行适配;
 *          左边界的值是在装填金额等ui的时候计算出来的;
 *          要考虑预留一个activity的宽度;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) setWaitingLabelText : (NSString*)text {
    NSDictionary* oldAttri = [NSDictionary dictionaryWithObject:self.waitingLabel.font forKey:NSFontAttributeName];
    CGSize oldTextSize = [self.waitingLabel.text sizeWithAttributes:oldAttri];
    self.waitingLabel.text = text;
    NSDictionary* newAttri = [NSDictionary dictionaryWithObject:self.waitingLabel.font forKey:NSFontAttributeName];
    CGSize newTextSize = [self.waitingLabel.text sizeWithAttributes:newAttri];
    // 新的文本长度如果长于旧的文本长度时就改变label的frame
    CGFloat addLength = newTextSize.width - oldTextSize.width;
    CGRect frame = self.waitingLabel.frame;
    frame.origin.x -= addLength;
    frame.size.width += addLength;
    self.waitingLabel.frame = frame;
    
    // 同时改变 activity 的frame;
    frame = self.activity.frame;
    frame.origin.x -= addLength;
    self.activity.frame = frame;
}

@end
