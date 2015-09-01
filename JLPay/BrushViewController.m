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
#import "GroupPackage8583.h"
#import "IC_GroupPackage8583.h"
#import "DeviceManager.h"



@interface BrushViewController()
<
//    CustomIOSAlertViewDelegate,
    wallDelegate,
    Unpacking8583Delegate,
    managerToCard,
    UIAlertViewDelegate,
    DeviceManagerDelegate
>
@property (nonatomic, strong) UIActivityIndicatorView* activity;            // 刷卡状态的转轮
@property (nonatomic, strong) CustomIOSAlertView* passwordAlertView;        // 自定义alert:密码输入弹窗
@property (nonatomic, strong) UILabel* waitingLabel;                        // 动态文本框
@property (nonatomic, strong) UILabel* moneyLabel;                          // 金额显示框
@property (nonatomic, assign) CGFloat leftInset;                            // 动态文本区域的左边静态文本区域的右边界长度
@property (nonatomic, assign) int timeOut;                                  // 交易超时时间
@property (nonatomic, strong) NSTimer* waitingTimer;                        // 控制定时器
@property (nonatomic, strong) NSTimer* timeCountingTimer;                   // 计时器的定时器
@property (nonatomic, retain) TcpClientService* tcpHander;                  // Socket
@end

/*************************************
 * ---- 功能
 *      1.刷卡
 *      2.输入密码
 *      3.发送消费/撤销/退货报文
 *      4.接收返回报文
*************************************/


#define TIMEOUT 60                      // 超时时间:统一60s
#define INTERFACE8583   0               // 8583打包解包接口类型:  0:旧接口, 1:新接口
 
 
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
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar.backItem setTitle:@"返回"];
    [self.navigationController.navigationBar setTintColor:[UIColor redColor]];
    // 加载子视图
    self.title = @"刷卡";
    [self addSubViews];
    // 交易超时时间为60秒,后面可以重置
    self.timeOut = TIMEOUT;
}

#pragma mask ::: 子视图的属性设置
-(void)viewWillAppear:(BOOL)animated
{
    [self.activity startAnimating];
    [super viewWillAppear:animated];
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
    }
}
#pragma mask ::: 释放资源
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tcpHander clearDelegateAndClose];
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
    NSDictionary* infoBinded = [[NSUserDefaults standardUserDefaults] objectForKey:KeyInfoDictOfBinded];
    // 先检查是否绑定设备
    if (infoBinded == nil) {
        [self alertForFailedMessage:@"未绑定设备,请先绑定设备!"];
        return;
    }
    // 先在主线程打开activitor 和 提示信息
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activity startAnimating];
        self.timeOut = 30; // 扫描设备的超时时间为30
        self.waitingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(openDeviceInTimer) userInfo:nil repeats:YES];
    });
    
    // 再在后台线程扫描并打开设备 - 在回调中进行定时器的取消，并刷卡；并注册新的定时器
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DeviceManager sharedInstance] setDelegate:self];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        [[DeviceManager sharedInstance] startScanningDevices];
    });
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        sleep(2);
//        [[DeviceManager sharedInstance] openDeviceWithIdentifier:[infoBinded valueForKey:KeyInfoDictOfBindedDeviceIdentifier]];
//    });
}

// 界面消失的资源回收
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 移除定时器
    if (self.waitingTimer.valid) {
        [self.waitingTimer invalidate];
        self.waitingTimer = nil;
    }
    self.waitingTimer = nil;
    // 取消对 TCP 响应的协议
    [self.tcpHander setDelegate:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DeviceManager sharedInstance] clearAndCloseAllDevices];
    });
}



#pragma mask ----------------------- 刷卡结果的回调
- (void)deviceManager:(DeviceManager *)deviceManager didSwipeSuccessOrNot:(BOOL)yesOrNot withMessage:(NSString *)msg {
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
        
        // 成功就继续发起交易
        NSString* deviceType = [[NSUserDefaults standardUserDefaults] valueForKey:DeviceType];
        if ([deviceType isEqualToString:DeviceType_JHL_M60]) {
            // 直接发起消费交易
            [self toCust:nil];
        } else if ([deviceType isEqualToString:DeviceType_JHL_A60]) {
            // 打开密码输入提示框
            [self makePasswordAlertView];
        }
    });
}


#pragma mask ::: 初始化并加载密码输入提示框
- (void) makePasswordAlertView {
    // innerView 放在 alertView 中创建
//    self.passwordAlertView.delegate = self;
    [self.passwordAlertView setUseMotionEffects:YES];
    [self.passwordAlertView setButtonTitles:[NSArray arrayWithObjects:@"取消", @"确定", nil]];
    [self.passwordAlertView show];
    [self.view addSubview:self.passwordAlertView];
}



#pragma mask ::: 密码输入提示框的按钮点击事件
//- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    CustomIOSAlertView* alertV = (CustomIOSAlertView*)alertView;
//    [alertV close];
//
//    if (buttonIndex == 0) { // 取消
//        // 弹出刷卡界面,回到上层界面
//        [self.navigationController popViewControllerAnimated:YES];
//    } else {                // 确定-开始设备加密
//        // 读磁道信息或芯片信息
//        long money = [self themoney] ;
//        // 这里的密码 password 用 alertView.password
//        long timeout = self.timeOut * 1000;
////        [[DeviceManager sharedInstance] TRANS_Sale:timeout // 60s
////                                           nAmount:money
////                                      nPasswordlen:(int)self.passwordAlertView.password.length
////                                          bPassKey:self.passwordAlertView.password];
//    }
//}

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
    dispatch_async(dispatch_get_main_queue(), ^{
        // 加载定时器
        if (![self.activity isAnimating]) {
            [self.activity startAnimating];
        }
        // 注册定时器:刷卡的超时等待定时器
        self.waitingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(swipeTimingOut) userInfo:nil repeats:YES];

    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 刷卡:刷卡回调中要注销定时器
        NSString* SNVersion = [[[NSUserDefaults standardUserDefaults] objectForKey:KeyInfoDictOfBinded] valueForKey:KeyInfoDictOfBindedDeviceSNVersion];
        NSString* money = [PublicInformation returnMoney];
        NSString* newMoney = [PublicInformation moneyStringWithCString:(char*)[money cStringUsingEncoding:NSUTF8StringEncoding]];
        [[DeviceManager sharedInstance] cardSwipeWithMoney:newMoney yesOrNot:NO onSNVersion:SNVersion];
    });
}


#pragma mask ::: 跳转到消费的联机阶段-上送报文
/*
 * 这里要添加分支:消费、撤销、退货 都要支持
 *  -- 由原来的通知处理函数修改而来:参数noti已经无用了
 */
- (void) toCust: (NSNotification*)notification {
    // 密码
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self.activity isAnimating]) {
            [self.activity startAnimating];
        }
    });
    
    // 设置流水号 - 除了冲正是用原交易的流水号，其他交易都是新生成
    NSString *liushui=[PublicInformation exchangeNumber];
    [[NSUserDefaults standardUserDefaults] setValue:liushui forKey:Current_Liushui_Number];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 只有打包格式、交易名称需要定制
    NSString* orderMethod;
    NSString* methodStr;
    
    // 金融交易8583报文打包
    //    注意::::::要区分IC卡和磁条卡交易
    
    /*--------------- NEW interface -----------------*/
    if (INTERFACE8583 == 1) {
        orderMethod = [GroupPackage8583 stringPacking8583];
    }
    /*--------------- OLD interface -----------------*/
    else if (INTERFACE8583 == 0) {
        if ([self.stringOfTranType isEqualToString:TranType_Consume]) {                 // 消费
            // 磁条
            if ([PublicInformation returnCardType_Track]) {
                orderMethod = [GroupPackage8583 consume:[[NSUserDefaults standardUserDefaults] valueForKey:Sign_in_PinKey]];
            }
            // 芯片
            else {
                orderMethod = [IC_GroupPackage8583 blue_consumer_IC:[[NSUserDefaults standardUserDefaults] valueForKey:Sign_in_PinKey]];
            }
//            methodStr = @"cousume";
            methodStr = self.stringOfTranType;
        } else if ([self.stringOfTranType isEqualToString:TranType_ConsumeRepeal]) {    // 消费撤销
            orderMethod = [GroupPackage8583 consumeRepeal:[[NSUserDefaults standardUserDefaults] valueForKey:Sign_in_PinKey] // 密文密码
                                                  liushui:[PublicInformation returnConsumerSort]  // 原系统流水号
                                                    money:[PublicInformation returnConsumerMoney]]; // 原消费金额
//            methodStr = @"consumeRepeal";
            methodStr = self.stringOfTranType;
        }
    }
    

    
    self.timeOut = 0;
    // 调起交易超时计时器
    self.waitingTimer = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.waitingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(custInTiming) userInfo:nil repeats:YES];
    });
    // Socket 异步发送消费报文 -- 报文发送需要放在主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tcpHander sendOrderMethod:orderMethod
                                     IP:Current_IP
                                   PORT:Current_Port
                               Delegate:self
                                 method:methodStr];
        
    });
}

#pragma mask ::: ------ 消费报文上送的接收协议 walldelegate
- (void)receiveGetData:(NSString *)data method:(NSString *)str {
    if ([self.waitingTimer isValid]) {
        [self.waitingTimer invalidate];
        self.waitingTimer = nil;
    }
    if ([data length] > 0) {
        if ([str isEqualToString:TranType_Consume]) { // cousume
            NSLog(@"消费响应数据:[%@]", data);
        } else if ([str isEqualToString:TranType_ConsumeRepeal]) { //consumeRepeal
            NSLog(@"消费撤销响应数据:[%@]", data);
        } else if ([str isEqualToString:TranType_BatchUpload]) { // batchUpload
            NSLog(@"披上送响应数据:[%@]",data);
        }
        // 拆包
        /*--------------- NEW interface -----------------*/
        if (INTERFACE8583 == 1) {
            [[Unpacking8583 getInstance] unpacking8583:data withDelegate:self];
        }
        /*--------------- OLD interface -----------------*/
        else if (INTERFACE8583 == 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
        }
    } else {
        [self alertForFailedMessage:@"网络异常，请检查网络"];
    }

}
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
        QianPiViewController  *qianpi=[[QianPiViewController alloc] init];
        [qianpi qianpiType:1];
        [qianpi getCurretnLiushui:[[NSUserDefaults standardUserDefaults] valueForKey:Current_Liushui_Number]];
        [qianpi leftTitle:[PublicInformation returnMoney]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:qianpi animated:YES];
        });
        return;
    }
    [self alertForFailedMessage:[NSString stringWithFormat:@"交易失败:%@",str]];
//    [self alertForFailedMessage:@"网络异常，请检查网络"];
}


#pragma mask ::: ------ 拆包结果的处理协议
/*--------------- NEW interface -----------------*/
- (void)didUnpackDatas:(NSDictionary *)dataDict onState:(BOOL)state withErrorMsg:(NSString *)message {
    NSLog(@"拆包结果:[%@]",message);
    [self alertForFailedMessage:message];
}
/*--------------- NEW interface -----------------*/

#pragma mask ::: ------ 拆包结果的处理协议    managerToCard
/*--------------- OLD interface -----------------*/
- (void)managerToCardState:(NSString *)type isSuccess:(BOOL)state method:(NSString *)metStr {
    
    if (state) {
        // 需要判断是否芯片交易
        if (![PublicInformation returnCardType_Track]) {     // 芯片卡交易
            if ([metStr isEqualToString:TranType_Consume] ||          // 消费、消费撤销要继续批上送
                [metStr isEqualToString:TranType_ConsumeRepeal]) {
                // 继续发起批上送........
                [self.tcpHander sendOrderMethod:[IC_GroupPackage8583 uploadBatchTransOfICC] IP:Current_IP PORT:Current_Port Delegate:self method:TranType_BatchUpload];
                return;
            }
            // 如果是披上送交易，也可以跳转到签名界面了
        }
        // 交易成功，跳转到签名界面
        if ([self.activity isAnimating]) {
            [self.activity stopAnimating];
        }
        QianPiViewController  *qianpi=[[QianPiViewController alloc] init];
        [qianpi qianpiType:1];
        [qianpi getCurretnLiushui:[[NSUserDefaults standardUserDefaults] valueForKey:Current_Liushui_Number]];
        [qianpi leftTitle:[PublicInformation returnMoney]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:qianpi animated:YES];
        });
    } else {
        if ([metStr isEqualToString:TranType_BatchUpload]) {
            if ([self.activity isAnimating]) {
                [self.activity stopAnimating];
            }
            QianPiViewController  *qianpi=[[QianPiViewController alloc] init];
            [qianpi qianpiType:1];
            [qianpi getCurretnLiushui:[[NSUserDefaults standardUserDefaults] valueForKey:Current_Liushui_Number]];
            [qianpi leftTitle:[PublicInformation returnMoney]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:qianpi animated:YES];
            });
            return;
        }
        [self alertForFailedMessage:type];
    }
}
/*--------------- OLD interface -----------------*/






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
    CGFloat inset               = 40;                // 上部分视图跟下部分视图的间隔
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
    
    // 图片1
    UIImage* image = [UIImage imageNamed:@"shuaka"];
    CGSize imageSize = [image size];
    frame.origin.y              += frame.size.height + inset/2.0;
    frame.size.height           = (self.view.frame.size.height - frame.origin.y - inset)/2.0;
    frame.size.width            = frame.size.height * imageSize.width/imageSize.height;
    if (frame.size.width > self.view.bounds.size.width - fleftInset) {
        frame.size.width = self.view.bounds.size.width - fleftInset;
        frame.size.height = frame.size.width * imageSize.height/imageSize.width;
    }
    frame.origin.x = self.view.bounds.size.width - fleftInset - frame.size.width;
    UIImageView* shuakaImage    = [[UIImageView alloc] initWithFrame:frame];
    shuakaImage.image           = image;
    [self.view addSubview:shuakaImage];
    
    // 图片2
    frame.origin.x              = 0 + fleftInset;
    frame.origin.y              += frame.size.height;
    UIImageView* shuakaImage1   = [[UIImageView alloc] initWithFrame:frame];
    shuakaImage1.image          = [UIImage imageNamed:@"shuaka1"];
    [self.view addSubview:shuakaImage1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mask ::: 将小数点金额转换为报文需要的 int 无小数点格式
-(int)themoney{
    NSString *moneyStr;
    if ([self.stringOfTranType isEqualToString:TranType_Consume]) { // 消费
        moneyStr = [[NSUserDefaults standardUserDefaults] valueForKey:Consumer_Money];
    } else if ([self.stringOfTranType isEqualToString:TranType_ConsumeRepeal]) { // 消费撤销
        moneyStr = [[NSUserDefaults standardUserDefaults] valueForKey:Last_Exchange_Number];
    }
    if (moneyStr == nil || [moneyStr isEqualToString:@""]) {
        moneyStr = @"0.00";
    }
    return [moneyStr floatValue]*100;
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

/*************************************
 * 功  能 : 等待刷卡的定时器任务;超时就退出当前场景;   --
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) waitingForSwipe {
    [self.waitingLabel setText:[NSString stringWithFormat:@"请刷卡:%02d秒",timeOut]];
    NSLog(@"定时器:[%d]", self.timeOut);
    if (self.timeOut == 0) {
        // 超时了
        if (self.waitingTimer.valid) {
            [self.waitingTimer invalidate]; // 停止计时
            self.waitingTimer = nil;
            // 还要终止设备............
        }
        [[app_delegate window] makeToast:@"未刷卡"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    self.timeOut--;
}

/*************************************
 * 功  能 : 本模块注册在定时器中,1s扫描一次;
 *          - 检测设备是否连接
 *          - 如果已经连接了，就注销定时器，并继续刷卡
 *          - 如果到了超时时间还未连接，注销定时器，报错退出
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) openDeviceInTimer {
    DeviceManager* device = [DeviceManager sharedInstance];
    NSString* SNVersion = [[[NSUserDefaults standardUserDefaults] objectForKey:KeyInfoDictOfBinded] valueForKey:KeyInfoDictOfBindedDeviceSNVersion];
    int connected = [device isConnectedOnSNVersionNum:SNVersion];
    if (self.timeOut < 0) { // 超时了
        [self.waitingTimer invalidate];
        self.waitingTimer = nil;
        [self alertForFailedMessage:@"连接设备超时!"]; // 点击确定就会退出场景
        // 就可以退出了
        return;
    }
    [self.waitingLabel setText:[NSString stringWithFormat:@"设备识别中... %02d秒",self.timeOut]];
    if (connected == 1) { // 已连接
        // 注销定时器
        [self.waitingTimer invalidate];
        self.waitingTimer = nil;
        // 继续刷卡
        [self beginToSwipe];
        return;
    } else if (connected == -1) {
        NSString* identifier = [[[NSUserDefaults standardUserDefaults] objectForKey:KeyInfoDictOfBinded] valueForKey:KeyInfoDictOfBindedDeviceIdentifier];
        [device openDeviceWithIdentifier:identifier];
    }
    self.timeOut--;
}

/*************************************
 * 功  能 : 刷卡超时的处理;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) swipeTimingOut {
    [self.waitingLabel setText:[NSString stringWithFormat:@"设备已连接,刷卡中...%02d秒",self.timeOut]];
    self.timeOut++;
}
/*************************************
 * 功  能 : 等待交易返回的计数器方法;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) custInTiming {
    [self.waitingLabel setText:[NSString stringWithFormat:@"交易处理中...%02d秒",self.timeOut]];
    self.timeOut++;

}


#pragma mask ::: getter
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
        NSString* money = [PublicInformation returnMoney];
        _moneyLabel.text = [NSString stringWithFormat:@"金额: %@ 元",money];
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

#pragma mask ::: setter
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
#pragma mask ::: getter
- (TcpClientService *)tcpHander {
    if (_tcpHander == nil) {
        _tcpHander = [TcpClientService getInstance];
    }
    return _tcpHander;
}

@end
