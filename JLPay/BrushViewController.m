//
//  BrushViewController.m
//  JLPay
//
//  Created by jielian on 15/4/14.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "BrushViewController.h"
#import "CommunicationManager.h"
#import "Toast+UIView.h"
#import "ProgressHUD/ProgressHUD.h"
#import "AppDelegate.h"
#import "Define_Header.h"
#import "CustomIOSAlertView.h"
#import "CustPayViewController.h"
#import "TcpClientService.h"
#import "Unpacking8583.h"
#import "QianPiViewController.h"
#import "DeviceManager.h"
#import <CoreBluetooth/CoreBluetooth.h>


#import "TCP/Packing8583.h"
#import "EncodeString.h"



@interface BrushViewController()
<
    CustomIOSAlertViewDelegate,
    wallDelegate,
    Unpacking8583Delegate,
    UIAlertViewDelegate,
    DeviceManagerDelegate,
    CBCentralManagerDelegate
>
{
    BOOL blueToothPowerOn;
    CBCentralManager* blueManager;
}
@property (nonatomic, strong) UIActivityIndicatorView* activity;            // 刷卡状态的转轮
@property (nonatomic, strong) CustomIOSAlertView* passwordAlertView;        // 自定义alert:密码输入弹窗
@property (nonatomic, strong) UILabel* waitingLabel;                        // 动态文本框
@property (nonatomic, strong) UILabel* moneyLabel;                          // 金额显示框
@property (nonatomic, assign) CGFloat leftInset;                            // 动态文本区域的左边静态文本区域的右边界长度
@property (nonatomic, assign) int timeOut;                                  // 交易超时时间
@property (nonatomic, strong) NSTimer* waitingTimer;                        // 控制定时器
@property (nonatomic, strong) NSTimer* timeCountingTimer;                   // 计时器的定时器
@property (nonatomic, retain) TcpClientService* tcpHander;                  // Socket

@property (nonatomic, retain) NSMutableDictionary* cardInfoOfReading;       // 读到得卡数据
@property (nonatomic, strong) NSDictionary* responseOriginInfo;             // 8583原始交易信息

@end

/*************************************
 * ---- 功能
 *      1.刷卡
 *      2.输入密码
 *      3.发送消费/撤销/退货报文
 *      4.接收返回报文
*************************************/


#define TIMEOUT 60                      // 超时时间:统一60s

 
@implementation BrushViewController
@synthesize activity = _activity;
@synthesize passwordAlertView = _passwordAlertView;
@synthesize waitingLabel = _waitingLabel;
@synthesize leftInset;
@synthesize timeOut;
@synthesize waitingTimer = _waitingTimer;
@synthesize stringOfTranType = _stringOfTranType;
@synthesize moneyLabel = _moneyLabel;
@synthesize tcpHander = _tcpHander;
@synthesize cardInfoOfReading = _cardInfoOfReading;
@synthesize responseOriginInfo;

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
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor redColor]];
    // 加载子视图
    [self setTitle:@"刷卡"];
    [self addSubViews];
    // 交易超时时间为60秒,后面可以重置
    [self setTimeOut:TIMEOUT];
    
    blueToothPowerOn = NO;
    blueManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

#pragma mask ::: 子视图的属性设置
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.activity startAnimating];
    
    [[DeviceManager sharedInstance] setDelegate:self];

    
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
    }
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
    NSDictionary* infoBinded = [[NSUserDefaults standardUserDefaults] objectForKey:KeyInfoDictOfBinded];
    if (infoBinded == nil) {
        [self alertForFailedMessage:@"未绑定设备,请先绑定设备!"];
        return;
    }
    // 2.检查蓝牙是否开启
    if (!blueToothPowerOn) {
        [self alertForFailedMessage:@"手机蓝牙未打开,请打开蓝牙"];
        return;
    }
    // 3.扫描设备
    [[DeviceManager sharedInstance] startScanningDevices];
    
    // 4.先在主线程打开activitor 和 提示信息
    [self.activity startAnimating];
    self.timeOut = 30; // 扫描设备的超时时间为30
    [self startTimerWithSelector:@selector(waitingForDeviceOpenning)];
}
#pragma mask ::: 释放资源
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 移除定时器
    [self stopTimer];
    // 取消 TCP 响应的协议
    [self.tcpHander clearDelegateAndClose];
    // 断开设备
    [[DeviceManager sharedInstance] clearAndCloseAllDevices];
}



#pragma mask -----------------------------------------  DeviceManagerDelegate

#pragma mask : 刷卡结果的回调
- (void)deviceManager:(DeviceManager *)deviceManager
 didSwipeSuccessOrNot:(BOOL)yesOrNot
          withMessage:(NSString *)msg
          andCardInfo:(NSDictionary *)cardInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 先停止计时器
        if ([self.waitingTimer isValid]) {
            [self.waitingTimer invalidate];
            self.waitingTimer = nil;
        }
        // 失败就退出
        if (!yesOrNot) {
            [self alertForFailedMessage:msg];
            return;
        }
        
        if (self.cardInfoOfReading.count > 0) {
            [self.cardInfoOfReading removeAllObjects];
            self.cardInfoOfReading = nil;
        }
        [self.cardInfoOfReading addEntriesFromDictionary:cardInfo];
        // 成功就继续,输入密码或直接发起交易
        NSString* deviceType = [[NSUserDefaults standardUserDefaults] valueForKey:DeviceType];
        if ([deviceType isEqualToString:DeviceType_JHL_M60]) {
            [self sendTranPackage:[self packingOnTranType:self.stringOfTranType] onTranType:self.stringOfTranType];
        }
        else if ([deviceType isEqualToString:DeviceType_JLpay_TY01]) {
            [self sendTranPackage:[self packingOnTranType:self.stringOfTranType] onTranType:self.stringOfTranType];
        }
        else if ([deviceType isEqualToString:DeviceType_RF_BB01]) {
            [self makePasswordAlertView];
        }
        else if ([deviceType isEqualToString:DeviceType_JHL_A60]) {
            [self makePasswordAlertView];
        }

    });
}

#pragma mask : 识别设备回调
- (void)didDiscoverDeviceOnID:(NSString *)identifier {
    NSDictionary* dictDeviceInfo = [[NSUserDefaults standardUserDefaults] objectForKey:KeyInfoDictOfBinded];
    if ([identifier isEqualToString:[dictDeviceInfo valueForKey:KeyInfoDictOfBindedDeviceIdentifier]]) {
        // 连接设备
        [[DeviceManager sharedInstance] stopScanningDevices];
        [[DeviceManager sharedInstance] openDeviceWithIdentifier:identifier];
    }
}

#pragma mask : SN号读取回调:SN号在设备连接后自动被读取
- (void)didReadSNVersion:(NSString *)SNVersion sucOrFail:(BOOL)yesOrNo withError:(NSString *)error {
    [self stopTimer];
    if (!yesOrNo) {
        // 提示并退出
        [self.activity stopAnimating];
        [self alertForFailedMessage:@"连接设备失败"];
    } else {
        // 继续刷卡:读磁道等信息
        [self beginToSwipe];
    }
}

#pragma mask : PIN加密密文获取
- (void)didEncryptPinSucOrFail:(BOOL)yesOrNo pin:(NSString *)pin withError:(NSString *)error {
    if (yesOrNo) {
        if (pin && pin.length > 0) {
            NSMutableString* f22 = [NSMutableString stringWithString:[self.cardInfoOfReading valueForKey:@"22"]];
            [f22 replaceCharactersInRange:NSMakeRange(2, 1) withString:@"1"];
            [self.cardInfoOfReading setValue:f22 forKey:@"22"];
            [self.cardInfoOfReading setValue:pin forKey:@"52"];
            [self.cardInfoOfReading setValue:@"2600000000000000" forKey:@"53"];
        } else {
            [self.cardInfoOfReading setValue:@"0600000000000000" forKey:@"53"];
        }
        [self sendTranPackage:[self packingOnTranType:self.stringOfTranType] onTranType:self.stringOfTranType];
    } else {
        [self alertForFailedMessage:error];
    }
}


#pragma mask ::: 进行刷卡
/*************************************
 * 功  能 : 进行刷卡;
 *          - 在副线程中扫描并打开设备
 *          - 在主线程中加载刷卡的定时器，并显示
 *          - 在主线程中加载交易的定时器，并显示
 * 参  数 :
 *          (NSString*) message
 * 返  回 : 无
 *************************************/
- (void) beginToSwipe {
    self.timeOut = 0; // 超时从0开始计数
    [self.activity startAnimating];
    // 启动定时器:刷卡计时
    [self startTimerWithSelector:@selector(waitingForDeviceSwiping)];
    
    // 刷卡:刷卡回调中要注销定时器
    NSString* SNVersion = [[[NSUserDefaults standardUserDefaults] objectForKey:KeyInfoDictOfBinded] valueForKey:KeyInfoDictOfBindedDeviceSNVersion];
    [[DeviceManager sharedInstance] cardSwipeWithMoney:self.sIntMoney yesOrNot:NO onSNVersion:SNVersion];
}


#pragma mask ::: 进行加密
- (void) encryptPinWithSource:(NSString*)source {
    NSString* deviceType = [[NSUserDefaults standardUserDefaults] valueForKey:DeviceType];
    if ([deviceType isEqualToString:DeviceType_RF_BB01]) {
        NSString* SNVersion = [[[NSUserDefaults standardUserDefaults] objectForKey:KeyInfoDictOfBinded] valueForKey:KeyInfoDictOfBindedDeviceSNVersion];
        [[DeviceManager sharedInstance] pinEncryptBySource:source withPan:[self.cardInfoOfReading valueForKey:@"2"] onSNVersion:SNVersion];
    }
    else if ([deviceType isEqualToString:DeviceType_JHL_A60]) {
        
    }
}




#pragma mask ::: 初始化并加载密码输入提示框
- (void) makePasswordAlertView {
    // innerView 放在 alertView 中创建
    self.passwordAlertView.delegate = self;
    [self.passwordAlertView setUseMotionEffects:YES];
    [self.passwordAlertView setButtonTitles:[NSArray arrayWithObjects:@"取消", @"确定", nil]];
    [self.passwordAlertView show];
    [self.view addSubview:self.passwordAlertView];
}



#pragma mask ::: 密码输入提示框的按钮点击事件
- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    CustomIOSAlertView* alertV = (CustomIOSAlertView*)alertView;
    [alertV close];

    if (buttonIndex == 0) { // 取消
        // 弹出刷卡界面,回到上层界面
        [self.navigationController popViewControllerAnimated:YES];
    } else {                // 确定-开始设备加密
        // 进行加密
        [self encryptPinWithSource:self.passwordAlertView.password];
    }
}


/* 上送交易报文 */
- (void) sendTranPackage:(NSString*)package onTranType:(NSString*)tranType {
    self.timeOut = 0;
    // 调起交易超时计时器
    [self startTimerWithSelector:@selector(waitingForDeviceCusting)];
    
    // Socket 异步发送消费报文 -- 报文发送需要放在主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tcpHander sendOrderMethod:package
                                     IP:Current_IP
                                   PORT:Current_Port
                               Delegate:self
                                 method:tranType];
        
    });
}

/* 打包8583报文包:根据交易类型 */
- (NSString*) packingOnTranType:(NSString*)tranType {
    NSString* packing = nil;
    // 消费
    if ([tranType isEqualToString:TranType_Consume]) {
        packing = [self packingConsume];
    }
    // 撤销
    else if ([tranType isEqualToString:TranType_ConsumeRepeal]) {
        
    }
    return packing;
}
// 消费
- (NSString*) packingConsume {
    NSString* packing = nil;
    Packing8583* packingHolder = [Packing8583 sharedInstance];
    [packingHolder setFieldAtIndex:2 withValue:[self.cardInfoOfReading valueForKey:@"2"]];
    [packingHolder setFieldAtIndex:3 withValue:TranType_Consume];
    [packingHolder setFieldAtIndex:4 withValue:self.sIntMoney];
    [packingHolder setFieldAtIndex:11 withValue:[PublicInformation exchangeNumber]];
    [packingHolder setFieldAtIndex:14 withValue:[self.cardInfoOfReading valueForKey:@"14"]];
    [packingHolder setFieldAtIndex:22 withValue:[self.cardInfoOfReading valueForKey:@"22"]];
    [packingHolder setFieldAtIndex:23 withValue:[self.cardInfoOfReading valueForKey:@"23"]];
    [packingHolder setFieldAtIndex:25 withValue:@"82"];
    [packingHolder setFieldAtIndex:26 withValue:@"12"];
    [packingHolder setFieldAtIndex:35 withValue:[self.cardInfoOfReading valueForKey:@"35"]];
    [packingHolder setFieldAtIndex:36 withValue:[self.cardInfoOfReading valueForKey:@"36"]];
    [packingHolder setFieldAtIndex:41 withValue:[EncodeString encodeASC:[PublicInformation returnTerminal]]];
    [packingHolder setFieldAtIndex:42 withValue:[EncodeString encodeASC:[PublicInformation returnBusiness]]];
    [packingHolder setFieldAtIndex:49 withValue:[EncodeString encodeASC:@"156"]];
    [packingHolder setFieldAtIndex:52 withValue:[self.cardInfoOfReading valueForKey:@"52"]];
    [packingHolder setFieldAtIndex:53 withValue:[self.cardInfoOfReading valueForKey:@"53"]];
    [packingHolder setFieldAtIndex:55 withValue:[self.cardInfoOfReading valueForKey:@"55"]];
    [packingHolder setFieldAtIndex:60 withValue:[Packing8583 makeF60OnTrantype:TranType_Consume]];
    [packingHolder setFieldAtIndex:64 withValue:@"0000000000000000"];


    packing = [packingHolder stringPackingWithType:@"0200"];
    return packing;
}
// 批上送
- (NSString*) packingBatchUpLoadWithLastInfo:(NSDictionary*)lastInfo {
    NSString* packing = nil;
    Packing8583* packingHolder = [Packing8583 sharedInstance];
    [packingHolder setFieldAtIndex:2 withValue:[lastInfo valueForKey:@"2"]];
    [packingHolder setFieldAtIndex:3 withValue:[lastInfo valueForKey:@"3"]];
    [packingHolder setFieldAtIndex:4 withValue:[lastInfo valueForKey:@"4"]];
    [packingHolder setFieldAtIndex:11 withValue:[lastInfo valueForKey:@"11"]];
    [packingHolder setFieldAtIndex:25 withValue:@"82"];
    [packingHolder setFieldAtIndex:26 withValue:@"12"];
    [packingHolder setFieldAtIndex:41 withValue:[lastInfo valueForKey:@"41"]];
    [packingHolder setFieldAtIndex:42 withValue:[lastInfo valueForKey:@"42"]];
    [packingHolder setFieldAtIndex:49 withValue:[lastInfo valueForKey:@"49"]];
    [packingHolder setFieldAtIndex:60 withValue:[Packing8583 makeF60ByLast60:[lastInfo valueForKey:@"60"]]];

    [packingHolder setFieldAtIndex:22 withValue:[self.cardInfoOfReading valueForKey:@"22"]];
    [packingHolder setFieldAtIndex:23 withValue:[self.cardInfoOfReading valueForKey:@"23"]];
    [packingHolder setFieldAtIndex:55 withValue:[self.cardInfoOfReading valueForKey:@"55"]];
    [packingHolder setFieldAtIndex:64 withValue:@"0000000000000000"];
    
    packing = [packingHolder stringPackingWithType:@"0320"];
    return packing;
}


#pragma mask ::: ------ 消费报文上送的接收协议 walldelegate
// 接收响应报文成功
- (void)receiveGetData:(NSString *)data method:(NSString *)str {
    if ([self.waitingTimer isValid]) {
        [self.waitingTimer invalidate];
        self.waitingTimer = nil;
    }
    if ([data length] > 0) {
        [[Unpacking8583 getInstance] unpacking8583:data withDelegate:self];
    } else {
        [self alertForFailedMessage:@"网络异常，请检查网络"];
    }

}
// 接收响应报文失败
- (void)falseReceiveGetDataMethod:(NSString *)str {
    if ([self.waitingTimer isValid]) {
        [self.waitingTimer invalidate];
        self.waitingTimer = nil;
    }
    // 批上送交易失败不做任何操作
    if ([str isEqualToString:TranType_BatchUpload]) { // batchUpload
        // 交易成功，跳转到签名界面
        if ([self.activity isAnimating]) {
            [self.activity stopAnimating];
        }
        // 跳转签名界面
        [self pushToSignVCWithInfo:self.cardInfoOfReading];
        return;
    }
    [self alertForFailedMessage:[NSString stringWithFormat:@"交易失败:%@",str]];
}


#pragma mask ::: ------ 拆包结果的处理协议
- (void)didUnpackDatas:(NSDictionary *)dataDict onState:(BOOL)state withErrorMsg:(NSString *)message {
    NSString* cardType = [self.cardInfoOfReading valueForKey:@"22"];
    NSString* msgType = [dataDict valueForKey:@"msgType"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activity stopAnimating];
    });
    
    if ([msgType isEqualToString:@"0330"]) {
        [self pushToSignVCWithInfo:self.responseOriginInfo];
    } else {
        // 交易成功
        if (state) {
            // 批上送:IC卡消费、撤销、退货
            [self setResponseOriginInfo:dataDict];
            if ([cardType hasPrefix:@"05"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activity startAnimating];
                });
                NSString* batchPackage = [self packingBatchUpLoadWithLastInfo:dataDict];
                [self sendTranPackage:batchPackage onTranType:TranType_BatchUpload];
            }
            // 跳转签名:磁条卡
            else {
                [self pushToSignVCWithInfo:dataDict];
            }
        }
        // 交易失败
        else {
            [self alertForFailedMessage:message];
        }
    }
    
}


#pragma mask ------------------ CBCentrolManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        blueToothPowerOn = YES;
    } else {
        blueToothPowerOn = NO;
    }
}


// 跳转界面: 跳转到签名界面
- (void) pushToSignVCWithInfo:(NSDictionary*)transInfo {
    QianPiViewController  *qianpi=[[QianPiViewController alloc] init];
    [qianpi qianpiType:1];
    [qianpi getCurretnLiushui:[[NSUserDefaults standardUserDefaults] valueForKey:Current_Liushui_Number]];
    [qianpi leftTitle:self.sFloatMoney];
    [qianpi setTransInformation:transInfo];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:qianpi animated:YES];
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
        [self.waitingLabel setText:[NSString stringWithFormat:@"设备已连接,请刷卡...%02d秒",self.timeOut++]];
    }
}
/*************************************
 * 功  能 : 等待交易返回的计数器;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) waitingForDeviceCusting {
    [self.waitingLabel setText:[NSString stringWithFormat:@"交易处理中...%02d秒",self.timeOut++]];
}


// -- 启动定时器:指定selector
- (void) startTimerWithSelector:(SEL)aselector {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.waitingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:aselector userInfo:nil repeats:YES];
    });
}
// -- 停止定时器
- (void) stopTimer {
    if ([self.waitingTimer isValid]) {
        [self.waitingTimer invalidate];
        self.waitingTimer = nil;
    }
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
    [self.view addSubview:imageView];
    // 刷卡金额: 0.00 元
    frame.origin.x += frame.size.width + 4;
    frame.size.width =  self.view.frame.size.width - fleftInset*2 - frame.size.width - 4;
    self.moneyLabel.frame = frame;
    self.moneyLabel.font = [UIFont boldSystemFontOfSize:uifont];
    [self.view addSubview:self.moneyLabel];
    
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
        if ([self.activity isAnimating]) {
            [self.activity stopAnimating];
        }
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
    [self.navigationController popViewControllerAnimated:YES];
}





#pragma mask ------------------------ getter

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
        _moneyLabel.text = [NSString stringWithFormat:@"金额: %@ 元",self.sFloatMoney];
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
// TCP Socket入口
- (TcpClientService *)tcpHander {
    if (_tcpHander == nil) {
        _tcpHander = [TcpClientService getInstance];
    }
    return _tcpHander;
}
// 读卡数据字典
- (NSMutableDictionary *)cardInfoOfReading {
    if (_cardInfoOfReading == nil) {
        _cardInfoOfReading = [NSMutableDictionary dictionary];
    }
    return _cardInfoOfReading;
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
