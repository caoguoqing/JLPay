//
//  BrushViewController.m
//  JLPay
//
//  Created by jielian on 15/4/14.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "BrushViewController.h"
#import "JLPasswordView.h"

@interface BrushViewController()


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
    
    [RACObserve(self.deviceManager, deviceState) subscribeNext:^(NSNumber* state) {
        switch (state.integerValue) {
            case VMDeviceStateDisconnected:
                JLPrint(@"-->当前设备状态:[已断开连接]");
                break;
            case VMDeviceStateDisconnecting:
                JLPrint(@"-->当前设备状态:[正在断开连接...]");
                break;
            case VMDeviceStateConnected:
                JLPrint(@"-->当前设备状态:[已连接设备]");
                break;
            case VMDeviceStateConnecting:
                JLPrint(@"-->当前设备状态:[正在连接设备...]");
                break;
            case VMDeviceStateScanning:
                JLPrint(@"-->当前设备状态:[正在扫描设备...]");
                break;
            case VMDeviceStateScanned:
                JLPrint(@"-->当前设备状态:[已扫描到设备]");
                break;
            default:
                break;
        }
    }];
    
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
    AppDelegate* appDelegate = APPMainDelegate;
    if (appDelegate.CBManager.state != CBCentralManagerStatePoweredOn) {
        [self alertForFailedMessage:@"手机蓝牙未打开,请打开蓝牙"];
        return;
    }

    // 3.先在主线程打开activitor 和 提示信息
    self.timeOut = 20;
    [self startActivity];
    [self startTimerWithSelector:@selector(waitingForDeviceOpenning)];
    
    // 4.开始 连接设备-刷卡-加密
    NameWeakSelf(wself);
    [self.deviceManager connectDeviceOnFinished:^{
        wself.timeOut = 0;
        [wself stopTimer];
        [wself startActivity];
        [wself startTimerWithSelector:@selector(waitingForDeviceSwiping)];
        // 刷卡
        [wself.deviceManager swipeCardWithMoney:wself.sIntMoney onCardInfoReaded:^(NSDictionary *cardInfo) {
            [wself stopTimer];
            [wself stopActivity];
            [wself.cardInfoOfReading addEntriesFromDictionary:cardInfo];
            [wself.cardInfoOfReading setValue:wself.sIntMoney forKey:@"4"];
            if ([wself.deviceManager hasNumbersButton]) {
                [wself startTransPackingOnTransType:self.stringOfTranType];
            } else {
                [wself makePasswordAlertView];
            }
        } onError:^(NSError *error) {
            [wself stopTimer];
            [wself stopActivity];
            [wself alertForFailedMessage:[NSString stringWithFormat:@"刷卡失败:%@",[error localizedDescription]]];
        }];
    } onError:^(NSError *error) {
        [wself stopTimer];
        [wself stopActivity];
        [wself alertForFailedMessage:[NSString stringWithFormat:@"连接设备失败:%@",[error localizedDescription]]];
    }];

}
#pragma mask ::: 释放资源
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 移除定时器
    [self stopTimer];
    // 取消 TCP 响应的协议
    [self.tcpViewModel terminateTransWithTransType:self.stringOfTranType];
    
    [self.deviceManager disconnectOnFinished:nil];
    self.deviceManager = nil;
}



#pragma mask ::: 初始化并加载密码输入提示框
- (void) makePasswordAlertView {
    // innerView 放在 alertView 中创建
    NameWeakSelf(wself);
    [JLPasswordView showAfterClickedSure:^(NSString *password) {
        // 输了密码则加密
        if (password && password.length > 0) {
            [wself.deviceManager encryptPinSource:password onEncryptedPIN:^(NSString *pin) {
                if (pin && pin.length > 0) {
                    NSMutableString* f22 = [NSMutableString stringWithString:[wself.cardInfoOfReading valueForKey:@"22"]];
                    [f22 replaceCharactersInRange:NSMakeRange(2, 1) withString:@"1"];
                    [wself.cardInfoOfReading setValue:f22 forKey:@"22"];
                    [wself.cardInfoOfReading setValue:pin forKey:@"52"];
                    [wself.cardInfoOfReading setValue:@"2600000000000000" forKey:@"53"];
                } else {
                    [wself.cardInfoOfReading setValue:@"0600000000000000" forKey:@"53"];
                }
                // 发起交易
                [wself startTransPackingOnTransType:wself.stringOfTranType];
            } onError:^(NSError *error) {
                [wself alertForFailedMessage:[error localizedDescription]];
            }];
        }
        // 未输直接交易
        else {
            [wself.cardInfoOfReading setObject:@"0600000000000000" forKey:@"53"];
            [wself startTransPackingOnTransType:wself.stringOfTranType];
        }
    } orCancel:^{
        [wself.navigationController popToRootViewControllerAnimated:YES];
    }];
}





#pragma mask ---- ViewModelTCPPosTransDelegate 
- (void)didTransSuccessWithResponseInfo:(NSDictionary *)responseInfo onTransType:(NSString *)transType {
    [self stopTimer];
    [self stopActivity];
    NSMutableDictionary* updateF55dic = [NSMutableDictionary dictionaryWithDictionary:responseInfo];
    if ([[self.cardInfoOfReading objectForKey:@"22"] hasPrefix:@"05"]) {
        [updateF55dic setObject:[self.cardInfoOfReading objectForKey:@"55"] forKey:@"55"];
        [updateF55dic setObject:[self.cardInfoOfReading objectForKey:@"23"] forKey:@"23"];
        NSString* f14 = [self.cardInfoOfReading objectForKey:@"14"];
        [updateF55dic setObject:((f14 && f14.length > 0)?(f14):(@"")) forKey:@"14"];
    }
    self.transResponseInfo = updateF55dic;
    
    
    [self handleWithTransSuccessOnTransType:transType]; // 直接成功处理

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
    
    __block ModelTCPTransPacking* tcpHandle = [ModelTCPTransPacking sharedModel];
    [tcpHandle packingFieldsInfo:self.cardInfoOfReading forTransType:transType];
    
    [self.deviceManager encryptMacSource:[tcpHandle getMacStringAfterPacking] onEncryptedMac:^(NSString *macPin) {
        [tcpHandle repackingWithMacPin:macPin];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tcpViewModel startTransWithTransType:curTransType
                                      andPackingString:[tcpHandle packageFinalyPacking]
                                            onDelegate:self];
        });
    } onError:^(NSError *error) {
        [self alertForFailedMessage:[error localizedDescription]];
    }];
    
}




#pragma mask ---- PRIVATE INTERFACE

// 跳转界面: 跳转到签名界面
- (void) pushToSignVCWithInfo:(NSDictionary*)transInfo {
    PosInformationViewController  *posInforVC=[[PosInformationViewController alloc] initWithNibName:nil bundle:nil];
    [posInforVC setUserFor:PosNoteUseForUpload];
    [posInforVC setTransInformation:transInfo];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:posInforVC animated:YES];
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

// -- alert and alertDelegate
- (void) alertForFailedMessage: (NSString*) messageStr {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"交易失败" message:messageStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 要么是交易失败，要么设备未连接，都要弹出界面
    [self.navigationController popToRootViewControllerAnimated:YES];
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
//        _stringOfTranType = [[NSUserDefaults standardUserDefaults] valueForKey:TranType];
        _stringOfTranType = TranType_Consume;
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
- (VMDeviceHandle *)deviceManager {
    if (!_deviceManager) {
        _deviceManager = [[VMDeviceHandle alloc] init];
    }
    return _deviceManager;
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
