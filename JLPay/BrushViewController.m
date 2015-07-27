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



@interface BrushViewController()<CustomIOSAlertViewDelegate,wallDelegate,managerToCard,UIAlertViewDelegate,DeviceManagerDelegate>
@property (nonatomic, strong) UIActivityIndicatorView* activity;            // 刷卡状态的转轮
@property (nonatomic, strong) CustomIOSAlertView* passwordAlertView;        // 自定义alert:密码输入弹窗
@property (nonatomic, strong) UILabel* waitingLabel;                        // 动态文本框
@property (nonatomic, assign) CGFloat leftInset;                            // 动态文本区域的左边静态文本区域的右边界长度
@property (nonatomic, assign) int timeOut;                                  // 交易超时时间
@property (nonatomic, strong) NSTimer* waitingTimer;                        // 控制定时器
@property (nonatomic, strong) NSTimer* timeCountingTimer;                   // 计时器的定时器
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
    // 加载子视图
    [self addSubViews];
    // 交易超时时间为60秒,后面可以重置
    self.timeOut = TIMEOUT;
}

#pragma mask ::: 子视图的属性设置
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = YES;
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
    NSString* identifier = [[NSUserDefaults standardUserDefaults] valueForKey:DeviceIDOfBinded];
    // 先检查是否绑定设备
    if (identifier == nil) {
        [self alertForFailedMessage:@"未绑定设备,请先绑定设备!"];
        return;
    }
    // 先在主线程打开activitor 和 提示信息
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setWaitingLabelText:@"设备识别中..."];
        [self.activity startAnimating];
        self.timeOut = 20; // 扫描设备的超时时间为20
        self.waitingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(openDeviceInTimer) userInfo:nil repeats:YES];
    });
    
    // 再在后台线程扫描并打开设备 - 在回调中进行定时器的取消，并刷卡；并注册新的定时器
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        DeviceManager* device = [DeviceManager sharedInstance];
        [device setDelegate:self];
        [device setOpenAutomaticaly:YES];   // 设置自动打开设备标记
        [device startScanningDevices];
    });
}

// 界面消失的资源回收
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 移除定时器
    if (self.waitingTimer.valid) {
        [self.waitingTimer invalidate];
    }
    self.waitingTimer = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[DeviceManager sharedInstance] setDelegate:nil];
        [[DeviceManager sharedInstance] setOpenAutomaticaly:NO];     // 关闭自动打开标记
        [[DeviceManager sharedInstance] stopScanningDevices];
        [[DeviceManager sharedInstance] closeAllDevices];
    });
}
// 隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}


#pragma mask ----------------------- 刷卡结果的回调
- (void)deviceManager:(DeviceManager *)deviceManager didSwipeSuccessOrNot:(BOOL)yesOrNot withMessage:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 先停止计时器
        if (self.waitingTimer.valid) {
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
        // 读磁道信息或芯片信息
        long money = [self themoney] ;
        // 这里的密码 password 用 alertView.password
        long timeout = self.timeOut * 1000;
        [[DeviceManager sharedInstance] TRANS_Sale:timeout // 60s
                                           nAmount:money
                                      nPasswordlen:(int)self.passwordAlertView.password.length
                                          bPassKey:self.passwordAlertView.password];
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
    self.timeOut = TIMEOUT; // 超时时间改为 60
    dispatch_async(dispatch_get_main_queue(), ^{
        // 加载定时器
        if (![self.activity isAnimating]) {
            [self.activity startAnimating];
        }
        [self setWaitingLabelText:@"刷卡中..."];
        // 注册定时器:刷卡的超时等待定时器
        self.waitingTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeOut target:self selector:@selector(swipeTimingOut) userInfo:nil repeats:NO];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // 刷卡:刷卡回调中要注销定时器
        NSLog(@";;;';';;';开始刷卡");
        NSString* SNVersion = [[NSUserDefaults standardUserDefaults] valueForKey:SelectedSNVersionNum];
        NSString* money = [PublicInformation returnMoney];
        CGFloat moneyFloat = [money floatValue]* 100.0;
        NSString* cstringMoney = [NSString stringWithFormat:@"%012d",(int)moneyFloat];
        [[DeviceManager sharedInstance] cardSwipeWithMoney:cstringMoney yesOrNot:NO onSNVersion:SNVersion];
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
        [self setWaitingLabelText:@"交易处理中..."];
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
    
    // -- 注意::::::要区分IC卡和磁条卡交易
    if ([self.stringOfTranType isEqualToString:TranType_Consume]) {                 // 消费
        // 磁条
        if ([PublicInformation returnCardType_Track]) {
            orderMethod = [GroupPackage8583 consume:[[NSUserDefaults standardUserDefaults] valueForKey:Sign_in_PinKey]];
        }
        // 芯片
        else {
            orderMethod = [IC_GroupPackage8583 blue_consumer_IC:[[NSUserDefaults standardUserDefaults] valueForKey:Sign_in_PinKey]];
        }
        methodStr = @"cousume";
    } else if ([self.stringOfTranType isEqualToString:TranType_ConsumeRepeal]) {    // 消费撤销
        orderMethod = [GroupPackage8583 consumeRepeal:[[NSUserDefaults standardUserDefaults] valueForKey:Sign_in_PinKey] // 密文密码
                                              liushui:[PublicInformation returnConsumerSort]  // 原系统流水号  Consumer_Get_Sort  returnConsumerSort  returnLiushuiHao
                                                money:[PublicInformation returnConsumerMoney]]; // 原消费金额

        methodStr = @"consumeRepeal";
    }
    // 异步发送消费报文 -- 报文发送需要放在主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        [[TcpClientService getInstance] sendOrderMethod:orderMethod
                                                     IP:Current_IP
                                                   PORT:Current_Port
                                               Delegate:self
                                                 method:methodStr];
    });
}

#pragma mask ::: ------ 消费报文上送的接收协议 walldelegate
- (void)receiveGetData:(NSString *)data method:(NSString *)str {
    if ([data length] > 0) {
        if ([str isEqualToString:@"cousume"]) {
            NSLog(@"消费响应数据:[%@]", data);
        } else if ([str isEqualToString:@"consumeRepeal"]) {
            NSLog(@"消费撤销响应数据:[%@]", data);
        } else if ([str isEqualToString:@"batchUpload"]) {
            NSLog(@"披上送响应数据:[%@]",data);
        }
        // 拆包
        [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
    } else {
        [self alertForFailedMessage:@"网络异常，请检查网络"];
    }

}
- (void)falseReceiveGetDataMethod:(NSString *)str {
    // 批上送交易失败不做任何操作
    if ([str isEqualToString:@"batchUpload"]) {
        // 交易成功，跳转到签名界面
        if ([self.activity isAnimating]) {
            [self.activity stopAnimating];
        }
        QianPiViewController  *qianpi=[[QianPiViewController alloc] init];
        [qianpi qianpiType:1];
//        [qianpi getCurretnLiushui:[PublicInformation returnLiushuiHao]];
        [qianpi getCurretnLiushui:[[NSUserDefaults standardUserDefaults] valueForKey:Current_Liushui_Number]];
        [qianpi leftTitle:[PublicInformation returnMoney]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:qianpi animated:YES];
        });
        return;
    }
    [self alertForFailedMessage:@"网络异常，请检查网络"];
}

#pragma mask ::: ------ 拆包结果的处理协议    managerToCard
- (void)managerToCardState:(NSString *)type isSuccess:(BOOL)state method:(NSString *)metStr {
    if (state) {
        // 需要判断是否芯片交易
        if (![PublicInformation returnCardType_Track]) {     // 芯片卡交易
            if ([metStr isEqualToString:@"cousume"] ||          // 消费、消费撤销要继续批上送
                [metStr isEqualToString:@"consumeRepeal"]) {
                // 继续发起批上送........
                [[TcpClientService getInstance] sendOrderMethod:[IC_GroupPackage8583 uploadBatchTransOfICC] IP:Current_IP PORT:Current_Port Delegate:self method:@"batchUpload"];
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
        [self alertForFailedMessage:type];
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
    CGFloat rightInset          = 15;                // 右边界
    CGFloat inset               = 60;                // 上部分视图跟下部分视图的间隔
    CGFloat uifont              = 20.0;              // 字体大小
    
    CGFloat xFrame              = 0 + fleftInset;
    CGFloat yFrame              = [[UIApplication sharedApplication] statusBarFrame].size.height + topInset;
    CGFloat width               = 40;
    CGFloat height              = 30;
    CGRect  frame               = CGRectMake(xFrame, yFrame, width, height);
    
    // 背景
    UIImageView* backImage      = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backImage.image             = [UIImage imageNamed:@"bg"];
    [self.view addSubview:backImage];
    // 金额
    UILabel* jine               = [[UILabel alloc] initWithFrame:frame];
    jine.text                   = @"金额";
    jine.font                   = [UIFont boldSystemFontOfSize:uifont];
    jine.textAlignment          = NSTextAlignmentCenter;
    [self.view addSubview:jine];
    self.leftInset              = frame.origin.x + frame.size.width;
    // 符号图片
    frame.origin.x              += width;
    frame.size.width            = frame.size.height;
    UIImageView* jineImage      = [[UIImageView alloc] initWithFrame:frame];
    jineImage.image             = [UIImage imageNamed:@"jine"];
    [self.view addSubview:jineImage];
    self.leftInset              += frame.size.width;
    // 金额数值
    frame.origin.x              += frame.size.width;
    frame.size.width            = width * 3.0;
    UILabel* money              = [[UILabel alloc] initWithFrame:frame];
    money.font                   = [UIFont boldSystemFontOfSize:uifont];
    money.textAlignment         = NSTextAlignmentLeft;
    money.text                  = [[[NSUserDefaults standardUserDefaults] valueForKey:Consumer_Money] stringByAppendingString:@"元"];
    [self.view addSubview:money];
    self.leftInset              += frame.size.width;
    // 请刷卡...
    frame.size.width            = 80.0;
    frame.origin.x              = self.view.bounds.size.width - rightInset - frame.size.width;
    self.waitingLabel.frame     = frame;
    self.waitingLabel.textAlignment        = NSTextAlignmentLeft;
    self.waitingLabel.font                   = [UIFont boldSystemFontOfSize:uifont];
    self.waitingLabel.text                 = @"请刷卡...";
    [self.view addSubview:self.waitingLabel];
    // 动态滚动图
    frame.origin.x              -= frame.size.height;
    frame.size.width            = frame.size.height;
    self.activity.frame         = frame;
    [self.activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.activity];
    if (![self.activity isAnimating]) {
        [self.activity startAnimating];
    }
    // 图片1
    frame.origin.y              += frame.size.height + inset;
    fleftInset                   = self.view.bounds.size.width / 6.0;
    rightInset                  *= 2;
    frame.origin.x              = fleftInset;
    frame.size.width            = self.view.bounds.size.width - fleftInset - rightInset;
    frame.size.height           = frame.size.width * 0.8;
    UIImageView* shuakaImage    = [[UIImageView alloc] initWithFrame:frame];
    shuakaImage.image           = [UIImage imageNamed:@"shuaka"];
    [self.view addSubview:shuakaImage];
    
    // 图片2
    frame.origin.x              = 0 + rightInset;
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
    [self setWaitingLabelText:[NSString stringWithFormat:@"请刷卡:%02d秒",timeOut]];
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
    NSString* SNVersion = [[NSUserDefaults standardUserDefaults] valueForKey:SelectedSNVersionNum];
    int connected = [device isConnectedOnSNVersionNum:SNVersion];
    if (self.timeOut < 0) { // 超时了
        [self.waitingTimer invalidate];
        self.waitingTimer = nil;
        [self alertForFailedMessage:@"连接设备超时!"]; // 点击确定就会退出场景
        // 就可以退出了
        return;
    }
    if (connected == 1) { // 已连接
        // 注销定时器
        [self.waitingTimer invalidate];
        self.waitingTimer = nil;
        // 继续刷卡
        [self beginToSwipe];
        return;
    }
    self.timeOut--;
}

/*************************************
 * 功  能 : 刷卡超时的处理;
 *          - 注销定时器
 *          - 停止转轮
 *          - 弹错误框
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) swipeTimingOut {
    [self.waitingTimer invalidate];
    self.waitingTimer = nil;
    [self alertForFailedMessage:@"设备刷卡超时!"];
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
// 刷卡超时定时器
- (NSTimer *)waitingTimer {
    if (_waitingTimer == nil) {
    }
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


@end
