//
//  BrushViewController.m
//  JLPay
//
//  Created by jielian on 15/4/14.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "BrushViewController.h"
#import "CommunicationCallBack.h"
#import "CommunicationManager.h"
#import "Toast+UIView.h"
#import "ProgressHUD/ProgressHUD.h"
#import "AppDelegate.h"
#import "PasswordViewController.h"
#import "Define_Header.h"
#import "CustomIOSAlertView.h"
#import "CustPayViewController.h"
#import "WaitViewController.h"
#import "TcpClientService.h"
#import "Unpacking8583.h"
#import "QianPiViewController.h"
#import "GroupPackage8583.h"



@interface BrushViewController()<CustomIOSAlertViewDelegate,wallDelegate,managerToCard,UIAlertViewDelegate>
@property (nonatomic, strong) UIActivityIndicatorView* activity;            // 刷卡状态的转轮
@property (nonatomic, strong) CustomIOSAlertView* passwordAlertView;        // 自定义alert:密码输入弹窗
@property (nonatomic, strong) UILabel* waitingLabel;                        // 动态文本框
@property (nonatomic, assign) CGFloat leftInset;                            // 动态文本区域的左边静态文本区域的右边界长度
@property (nonatomic, assign) int timeOut;                                  // 交易超时时间
@property (nonatomic, strong) NSTimer* consumeWaitingTimer;                 // 交易超时控制定时器
@property (nonatomic, strong) NSTimer* swipeWaitingTimer;                   // 刷卡超时控制定时器
@end

/*************************************
 * ---- 功能
 *      1.刷卡
 *      2.输入密码
 *      3.发送消费/撤销/退货报文
 *      4.接收返回报文
*************************************/


#define TIMEOUT 20              // 超时时间
 
 
@implementation BrushViewController
@synthesize activity                    = _activity;
@synthesize passwordAlertView           = _passwordAlertView;
@synthesize waitingLabel                = _waitingLabel;
@synthesize leftInset;
@synthesize timeOut;
@synthesize consumeWaitingTimer         = _consumeWaitingTimer;
@synthesize swipeWaitingTimer           = _swipeWaitingTimer;
@synthesize stringOfTranType;

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
    
    // 注册刷卡成功的通知处理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardSwipeSuccess:) name:Noti_CardSwiped_Success object:nil];
    
    // 注册刷卡失败的通知处理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardSwipeFail:) name:Noti_CardSwiped_Fail object:nil];
    
    // 注册刷磁消费的通知处理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toCust:) name:Noti_TransSale_Success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToCust:) name:Noti_TransSale_Fail object:nil];
    
    // 交易超时时间为20秒
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
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AppDelegate* delegate               = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([delegate.device isConnected]) {
        // 刷卡
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // 启动刷卡超时定时器
            if (!self.swipeWaitingTimer.valid) {
                self.swipeWaitingTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(swipeWaitingTimer) userInfo:nil repeats:YES];
            }
            [[NSRunLoop mainRunLoop] addTimer:self.swipeWaitingTimer forMode:@"NSDefaultRunLoopMode"];
            // 刷卡
            [delegate.device cardSwipe];
        });
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未检测到设备,请插入设备" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        // 连接设备....循环中.......还要优化定时器
        [delegate.device open];
        // 重新打开后要能继续刷卡............
    }
}
// 界面消失的资源回收
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 移除定时器
    if (self.consumeWaitingTimer.valid) {
        [self.consumeWaitingTimer invalidate];
    }
    if (self.swipeWaitingTimer.valid) {
        [self.swipeWaitingTimer invalidate];
    }
    self.consumeWaitingTimer = nil;
    self.swipeWaitingTimer = nil;
}

#pragma mask ::: 刷卡成功
- (void) cardSwipeSuccess : (NSNotification*)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.swipeWaitingTimer.valid) {
            [self.swipeWaitingTimer invalidate];
        }
        if ([self.activity isAnimating]) {
            [self.activity stopAnimating];
        }
        // 打开密码输入提示框
        [self makePasswordAlertView];
    });
    
}
#pragma mask ::: 通知事件 ->刷卡失败
- (void) cardSwipeFail : (NSNotification*)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.swipeWaitingTimer.valid) {
            [self.swipeWaitingTimer invalidate];
        }
        if ([self.activity isAnimating]) {
            [self.activity stopAnimating];
        }
        [[app_delegate window] makeToast:@"刷卡失败"];
        // 弹出刷卡界面,回到金额输入界面
        [self.navigationController popViewControllerAnimated:YES];
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
    } else {                // 确定
        
        ///   读磁道信息或芯片信息
        long money = [self themoney] ;
        AppDelegate* delegate_  = (AppDelegate*)[UIApplication sharedApplication].delegate;
        // 这里的密码 password 用 alertView.password
        [delegate_.device TRANS_Sale:20000
                             nAmount:money
                        nPasswordlen:(int)self.passwordAlertView.password.length
                            bPassKey:self.passwordAlertView.password];
    }
}


#pragma mask ::: 跳转到消费的联机阶段-上送报文
/*
 * 这里要添加分支:消费、撤销、退货 都要支持
 */
- (void) toCust: (NSNotification*)notification {
    // 密码
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setWaitingLabelText:@"交易处理中..."];
        if (![self.activity isAnimating]) {
            [self.activity startAnimating];
        }
    });
    
    // 设置流水号
    NSString *liushui=[PublicInformation exchangeNumber];
    [[NSUserDefaults standardUserDefaults] setValue:liushui forKey:Current_Liushui_Number];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 只有打包格式、交易名称需要定制
    NSString* orderMethod;
    NSString* methodStr;
    if ([self.stringOfTranType isEqualToString:TranType_Consume]) {                 // 消费
        orderMethod = [GroupPackage8583 consume:[[NSUserDefaults standardUserDefaults] valueForKey:Sign_in_PinKey]];
        methodStr = @"cousume";
    } else if ([self.stringOfTranType isEqualToString:TranType_ConsumeRepeal]) {    // 消费撤销
        orderMethod = [GroupPackage8583 consumeRepeal:[[NSUserDefaults standardUserDefaults] valueForKey:Sign_in_PinKey]
                                              liushui:[PublicInformation returnConsumerSort]
                                                money:[[NSUserDefaults standardUserDefaults] valueForKey:Last_Exchange_Number]];
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
    
    // 启动超时定时器
    self.timeOut = TIMEOUT;
    [[NSRunLoop mainRunLoop] addTimer:self.consumeWaitingTimer forMode:@"NSDefaultRunLoopMode"];
}

#pragma mask ::: 跳转回金额输入界面
- (void) backToCust: (NSNotification*)notification {
    [self alertForFailedMessage:@"读卡失败"];
}




#pragma mask ::: ------ 消费报文上送的接收协议 walldelegate
- (void)receiveGetData:(NSString *)data method:(NSString *)str {
    if ([data length] > 0) {
        if ([str isEqualToString:@"cousume"]) {
            NSLog(@"消费响应数据:[%@]", data);
        } else if ([str isEqualToString:@"撤销......"]) {
            
        }
        [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
    } else {
        [self alertForFailedMessage:@"网络异常，请检查网络"];
        [self.consumeWaitingTimer invalidate]; // 注销定时器
        self.consumeWaitingTimer = nil;
    }

}
- (void)falseReceiveGetDataMethod:(NSString *)str {
    if ([str isEqualToString:@"cousume"]) {
        [self alertForFailedMessage:@"网络异常，请检查网络"];
        [self.consumeWaitingTimer invalidate]; // 注销定时器
        self.consumeWaitingTimer = nil;
    }
}

#pragma mask ::: ------ 拆包结果的处理协议    managerToCard
- (void)managerToCardState:(NSString *)type isSuccess:(BOOL)state method:(NSString *)metStr {
    if (state) {
        // 可以不校验交易名称,因为后续流程都一样
        if ([metStr isEqualToString:@"cousume"]) {
            if (self.consumeWaitingTimer.valid) {
                [self.consumeWaitingTimer invalidate]; // 注销定时器
                self.consumeWaitingTimer = nil;
            }
            if ([self.activity isAnimating]) {
                [self.activity stopAnimating];
            }
            QianPiViewController  *qianpi=[[QianPiViewController alloc] init];
            [qianpi qianpiType:1];
            [qianpi getCurretnLiushui:[PublicInformation returnLiushuiHao]];
            [qianpi leftTitle:[PublicInformation returnMoney]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:qianpi animated:YES];
            });
        }
    } else {
        [self alertForFailedMessage:type];
        [self.consumeWaitingTimer invalidate]; // 注销定时器
        self.consumeWaitingTimer = nil;
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
    CGFloat fleftInset           = 15;                // 左边界
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




#pragma mask ::: 从本地配置获取金额
-(NSString *)returnMoney{
    NSString *moneyStr;
    if ([self.stringOfTranType isEqualToString:TranType_Consume]) { // 消费
        moneyStr = [[NSUserDefaults standardUserDefaults] valueForKey:Consumer_Money];
    } else if ([self.stringOfTranType isEqualToString:TranType_ConsumeRepeal]) { // 消费撤销
        moneyStr = [[NSUserDefaults standardUserDefaults] valueForKey:Last_Exchange_Number];
    }
    if (moneyStr == nil || [moneyStr isEqualToString:@""]) {
        moneyStr = @"0.00";
    }
    
//    NSString *moneyStr=[[NSUserDefaults standardUserDefaults] valueForKey:Consumer_Money];
//    if (moneyStr && ![moneyStr isEqualToString:@"0.00"] && ![moneyStr isEqualToString:@"(null)"]) {
//        moneyStr=[[NSUserDefaults standardUserDefaults] valueForKey:Consumer_Money];
//    }else{
//        moneyStr=@"1";
//    }
    return moneyStr;
}

#pragma mask ::: 将小数点金额转换为报文需要的无小数点格式
-(int)themoney{
    int money=[[self returnMoney] floatValue]*100;
    return money;
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
    if ([alertView.title isEqualToString:@"交易失败"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/*************************************
 * 功  能 : 交易发送后的计时器方法，超时了要弹窗并推出当前场景;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) waitingForConsume {
    [self setWaitingLabelText:[NSString stringWithFormat:@"处理中:%02d秒",timeOut]];
    NSLog(@"定时器:[%d]", self.timeOut);
    if (self.timeOut == 0) {
        // 超时了
        if (self.consumeWaitingTimer.valid) {
            [self.consumeWaitingTimer invalidate]; // 停止计时
            self.consumeWaitingTimer = nil;
        }
        [self alertForFailedMessage:@"交易超时,请检查网络"];
    }
    self.timeOut--;
}
/*************************************
 * 功  能 : 等待刷卡的定时器任务;超时就退出当前场景;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) waitingForSwipe {
    [self setWaitingLabelText:[NSString stringWithFormat:@"请刷卡:%02d秒",timeOut]];
    NSLog(@"定时器:[%d]", self.timeOut);
    if (self.timeOut == 0) {
        // 超时了
        if (self.swipeWaitingTimer.valid) {
            [self.swipeWaitingTimer invalidate]; // 停止计时
            self.swipeWaitingTimer = nil;
        }
        [[app_delegate window] makeToast:@"未刷卡"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    self.timeOut--;
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
// 消费超时定时器
- (NSTimer *)consumeWaitingTimer {
    if (_consumeWaitingTimer == nil) {
        _consumeWaitingTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(waitingForConsume) userInfo:nil repeats:YES];
    }
    return _consumeWaitingTimer;
}
// 刷卡超时定时器
- (NSTimer *)swipeWaitingTimer {
    if (_swipeWaitingTimer == nil) {
        _swipeWaitingTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(waitingForSwipe) userInfo:nil repeats:YES];
    }
    return _swipeWaitingTimer;
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
    CGSize oldTextSize = [self.waitingLabel.text sizeWithFont:self.waitingLabel.font];
    self.waitingLabel.text = text;
    CGSize newTextSize = [self.waitingLabel.text sizeWithFont:self.waitingLabel.font];
    // 新的文本长度如果长于旧的文本长度时就改变label的frame
    CGFloat addLength = newTextSize.width - oldTextSize.width;
    if (addLength > 0) {
        CGRect frame = self.waitingLabel.frame;
        frame.origin.x -= addLength;
        frame.size.width += addLength;
        self.waitingLabel.frame = frame;
        
        // 同时改变 activity 的frame;
        frame = self.activity.frame;
        frame.origin.x -= addLength;
        self.activity.frame = frame;
    }
}

@end
