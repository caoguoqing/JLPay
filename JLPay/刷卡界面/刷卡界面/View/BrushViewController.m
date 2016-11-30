//
//  BrushViewController.m
//  JLPay
//
//  Created by jielian on 15/4/14.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "BrushViewController.h"
#import "JLPasswordView.h"
#import "MTransMoneyCache.h"
#import "JLElecSignController.h"

#import "MBProgressHUD+CustomSate.h"
#import "BVC_vmTransController.h"
#import "BVC_vmDeviceController.h"
#import "BVC_vmPackageTransformer.h"
#import "BVC_vmPasswordController.h"
#import "ImageHelper.h"

#import "Define_Header.h"
#import "PosInformationViewController.h"
#import "DeviceManager.h"
#import "Packing8583.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>

#import "BVC_vmTimer.h"

@interface BrushViewController()

/* 控制定时器 */
//@property (nonatomic, strong) NSTimer* waitingTimer;

@property (nonatomic, strong) BVC_vmTimer* timerCtrl;

/* 设备管理器 */
@property (nonatomic, strong) BVC_vmDeviceController* deviceCtrl;

/* 交易管理器 */
@property (nonatomic, strong) BVC_vmTransController* transCtrl;

/* 打包管理器 */
@property (nonatomic, strong) BVC_vmPackageTransformer* packageCtrl;

/* 密码输入管理器 */
@property (nonatomic, strong) BVC_vmPasswordController* passwordCtrl;



/* 状态文本框 */
@property (nonatomic, strong) UILabel* stateLabel;

/* 读秒文本框 */
@property (nonatomic, strong) UILabel* secondsLabel;

/* 金额标签 */
@property (nonatomic, strong) UILabel* moneyIconImg;

/* 金额显示框 */
@property (nonatomic, strong) UILabel* moneyLabel;

/* 刷卡演示图片 */
@property (nonatomic, strong) UIImageView* swipeDemoImg;

@end






/*************************************
 * ---- 功能
 *      1.刷卡
 *      2.输入密码
 *      3.发送交易报文(消费、查询、批上传)
 *      4.接收返回报文
*************************************/

 
@implementation BrushViewController


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
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    
    // 加载子视图
    [self setTitle:@"刷卡"];
    [self loadSubviews];
    [self layoutSubviews];
    [self newControl];

}



#pragma mask ::: 子视图的属性设置
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    
    // 连接设备
    [self.deviceCtrl.cmd_deviceConnecting execute:nil];
    // 启动定时器
    [self makeTimeoutForDeviceConnecting];
}



#pragma mask ::: 释放资源
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 断开设备、清空金额缓存、停止定时器、取消密码输入、取消签名
    [[MTransMoneyCache sharedMoney] resetMoneyToZero];
    [self.deviceCtrl.cmd_deviceDisconnecting execute:nil];
    [self stopTimer];
    [JLPasswordView hidden];
    [[JLElecSignController sharedElecSign] hiddenAnimationOnFinished:nil];
}



- (void) newControl {
    @weakify(self);
    // 状态
    RAC(self.stateLabel, text) = [RACSignal merge:@[RACObserve(self.deviceCtrl, stateMessage),
                                                    RACObserve(self.transCtrl, stateMessage)]];
    
    // 签名特征码
    RAC([JLElecSignController sharedElecSign], characteristicCode) = RACObserve(self.packageCtrl, characteristicCode);
    
    // 读秒
    RAC(self.secondsLabel, text) = [RACObserve(self.timerCtrl, timeCount) map:^id(id value) {
        return [NSString stringWithFormat:@"%02ds", [value integerValue]];
    }];
    
    // 连接设备
    [self.deviceCtrl.cmd_deviceConnecting.executionSignals subscribeNext:^(RACSignal* sig) {
        [[[sig dematerialize] deliverOnMainThread] subscribeNext:^(id x) {
            [MBProgressHUD showNormalWithText:@"正在连接设备..." andDetailText:nil];
        } error:^(NSError *error) {
            [MBProgressHUD showFailWithText:@"连接设备失败!" andDetailText:[error localizedDescription] onCompletion:^{
                @strongify(self);
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } completed:^{
            // 读卡
            [MBProgressHUD hideCurNormalHud];
            @strongify(self);
            [self makeTimeoutForDeviceSwiping];
            [self.deviceCtrl.cmd_cardReading execute:nil];
        }];
    }];
    
    // 读卡
    [self.deviceCtrl.cmd_cardReading.executionSignals subscribeNext:^(RACSignal* sig) {
        [[[sig dematerialize] deliverOnMainThread] subscribeNext:^(id x) {
            [MBProgressHUD showNormalWithText:@"正在读取卡数据..." andDetailText:nil];
        } error:^(NSError *error) {
            [MBProgressHUD showFailWithText:@"读取卡数据失败!" andDetailText:[error localizedDescription] onCompletion:^{
                @strongify(self);
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } completed:^{
            [MBProgressHUD hideCurNormalHud];
            @strongify(self);
            self.packageCtrl.cardInfo = self.deviceCtrl.cardInfo;
            if (self.deviceCtrl.mposHasKeyboard) {
                // 签名
                [self doElecSigning];
            } else {
                // 输入密码
                [self makeTimeoutForPinEncrypt];
                [self.passwordCtrl.cmd_passwordInputting execute:nil];
            }
        }];
    }];
    
    // 密码输入
    [self.passwordCtrl.cmd_passwordInputting.executionSignals subscribeNext:^(RACSignal* sig) {
        [[[sig dematerialize] deliverOnMainThread] subscribeError:^(NSError *error) {
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        } completed:^{
            @strongify(self);
            if (self.passwordCtrl.passwordPin && self.passwordCtrl.passwordPin.length > 0) {
                // 加密密码
                self.deviceCtrl.pinSource = self.passwordCtrl.passwordPin;
                [self.deviceCtrl.cmd_pinEncrypting execute:nil];
            } else {
                // 签名
                [self doElecSigning];
            }
        }];
    }];
    
    // 密码加密
    [self.deviceCtrl.cmd_pinEncrypting.executionSignals subscribeNext:^(RACSignal* sig) {
        [[[sig dematerialize] deliverOnMainThread] subscribeNext:^(id x) {
            [MBProgressHUD showNormalWithText:@"设备正在加密密码..." andDetailText:nil];
        } error:^(NSError *error) {
            [MBProgressHUD showFailWithText:@"加密密码失败!" andDetailText:[error localizedDescription] onCompletion:^{
                @strongify(self);
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } completed:^{
            [MBProgressHUD hideCurNormalHud];
            @strongify(self);
            self.packageCtrl.pinEncrypted = self.deviceCtrl.pinEncrypted;
            // 签名
            [self doElecSigning];
        }];
    }];
    
    
    // mac计算
    [self.deviceCtrl.cmd_macCalculating.executionSignals subscribeNext:^(RACSignal* sig) {
        [[[sig dematerialize] deliverOnMainThread] subscribeNext:^(id x) {
            [MBProgressHUD showNormalWithText:@"正在计算MAC..." andDetailText:nil];
        } error:^(NSError *error) {
            [MBProgressHUD showFailWithText:@"计算MAC失败!" andDetailText:[error localizedDescription] onCompletion:^{
                @strongify(self);
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } completed:^{
            @strongify(self);
            [MBProgressHUD hideCurNormalHud];
            // 执行消费上送
            self.packageCtrl.macCalculated = self.deviceCtrl.macCalculated;
            self.transCtrl.transMessage = [self.packageCtrl consumeMessageMaking];
            self.transCtrl.transType = TranType_Consume;
            [self.transCtrl.cmd_transSending execute:nil];
        }];
    }];
    
    // 消费解析
    [self.transCtrl.cmd_transSending.executionSignals subscribeNext:^(RACSignal* sig) {
        [[[sig dematerialize] deliverOnMainThread] subscribeNext:^(id x) {
            [MBProgressHUD showNormalWithText:@"正在发送交易请求..." andDetailText:nil];
        } error:^(NSError *error) {
            [MBProgressHUD showFailWithText:@"消费失败!" andDetailText:[error localizedDescription] onCompletion:^{
                @strongify(self);
                // #: 回退界面
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } completed:^{
            @strongify(self);
            [MBProgressHUD hideCurNormalHud];
            // 上送签名
            [self makeTimeoutForElecSignUploading];
            self.packageCtrl.consumeResponseInfo = self.transCtrl.responseInfo;
            self.transCtrl.transType = TranType_ElecSignPicUpload;
            self.transCtrl.transMessage = [self.packageCtrl elecSignMessageMaking];
            [self.transCtrl.cmd_elecSignSending execute:nil];
        }];
    }];
    
    // 上送签名解析
    [self.transCtrl.cmd_elecSignSending.executionSignals subscribeNext:^(RACSignal* sig) {
        [[[sig dematerialize] deliverOnMainThread] subscribeNext:^(id x) {
            [MBProgressHUD showNormalWithText:@"正在上送签名..." andDetailText:nil];
        } error:^(NSError *error) {
            [MBProgressHUD showFailWithText:@"上送签名失败!" andDetailText:[error localizedDescription] onCompletion:^{
                @strongify(self);
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } completed:^{
            @strongify(self);
            [MBProgressHUD hideCurNormalHud];
            [self stopTimer];
            // 跳转小票
            [MBProgressHUD showSuccessWithText:@"交易成功!" andDetailText:nil onCompletion:^{
                @strongify(self);
                PosInformationViewController  *posInforVC=[[PosInformationViewController alloc] initWithNibName:nil bundle:nil];
                [posInforVC setTransInformation:self.packageCtrl.consumeResponseInfo];
                posInforVC.elecSignImage = [ImageHelper elecSignImgWithView:[JLElecSignController sharedElecSign].elecSignView];
                [self.navigationController pushViewController:posInforVC animated:YES];
            }];
        }];
    }];

}


// 执行签名
- (void) doElecSigning {
    [self makeTimeoutForElecSign];
    @weakify(self);
    [[JLElecSignController sharedElecSign] signWithCompletion:^{
        @strongify(self);
        /* mac加密 */
        [self makeTimeoutForTransConsume];
        self.deviceCtrl.macSource = [self.packageCtrl macSourceMaking];
        [self.deviceCtrl.cmd_macCalculating execute:nil];
    } orCancel:^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
}




# pragma mask 2 定时器任务

/* 定时器: 连接设备 */
- (void) makeTimeoutForDeviceConnecting {
    NameWeakSelf(wself);
    [self.timerCtrl startCircleTimerWithTimecount:20];
    [self.timerCtrl timerWaitingForInterval:20 handleWhenTimeOut:^{
        [MBProgressHUD showFailWithText:@"设备连接超时" andDetailText:nil onCompletion:^{
            [wself.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

/* 定时器: 刷卡 */
- (void) makeTimeoutForDeviceSwiping {
    NameWeakSelf(wself);
    [self.timerCtrl startCircleTimerWithTimecount:60];
    [self.timerCtrl timerWaitingForInterval:60 handleWhenTimeOut:^{
        [MBProgressHUD showFailWithText:@"刷卡超时" andDetailText:nil onCompletion:^{
            [wself.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

/* 定时器: 加密 */
- (void) makeTimeoutForPinEncrypt {
    NameWeakSelf(wself);
    [self.timerCtrl startCircleTimerWithTimecount:30];
    [self.timerCtrl timerWaitingForInterval:30 handleWhenTimeOut:^{
        [MBProgressHUD showFailWithText:@"输入密码超时" andDetailText:nil onCompletion:^{
            [wself.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

/* 定时器: 签名 */
- (void) makeTimeoutForElecSign {
    NameWeakSelf(wself);
    [self.timerCtrl startCircleTimerWithTimecount:60];
    [self.timerCtrl timerWaitingForInterval:60 handleWhenTimeOut:^{
        [MBProgressHUD showFailWithText:@"签名超时" andDetailText:nil onCompletion:^{
            [wself.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

/* 定时器: 消费超时 */
- (void) makeTimeoutForTransConsume {
    NameWeakSelf(wself);
    [self.timerCtrl startCircleTimerWithTimecount:60];
    [self.timerCtrl timerWaitingForInterval:60 handleWhenTimeOut:^{
        [wself.transCtrl.cmd_stopSending execute:nil];
        [MBProgressHUD showFailWithText:@"交易超时" andDetailText:nil onCompletion:^{
            [wself.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

/* 定时器: 电签上送 */
- (void) makeTimeoutForElecSignUploading {
    NameWeakSelf(wself);
    [self.timerCtrl startCircleTimerWithTimecount:60];
    [self.timerCtrl timerWaitingForInterval:60 handleWhenTimeOut:^{
        [wself.transCtrl.cmd_stopSending execute:nil];
        [MBProgressHUD showFailWithText:@"交易超时" andDetailText:nil onCompletion:^{
            [wself.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

/* 销毁定时器 */
- (void) stopTimer {
    [self.timerCtrl stopWaitingTimer];
    [self.timerCtrl stopCircleTimer];
}



# pragma mask 3 界面布局


- (void) loadSubviews {
    [self.view addSubview:self.moneyIconImg];
    [self.view addSubview:self.moneyLabel];
    [self.view addSubview:self.stateLabel];
    [self.view addSubview:self.secondsLabel];
    [self.view addSubview:self.swipeDemoImg];
}

- (void) layoutSubviews {
    NameWeakSelf(wself);
    
    CGFloat insetMax = ScreenWidth * 15 / 320.f;
    CGFloat insetMin = ScreenWidth * 5 / 320.f;
    
    CGFloat heightLabelMin = ScreenWidth * 20 / 320.f;
    
    CGFloat widthImg = ScreenWidth * 0.70;
    CGFloat heightImg = widthImg * self.swipeDemoImg.image.size.height / self.swipeDemoImg.image.size.width;
    
    self.moneyIconImg.layer.cornerRadius = heightLabelMin * 0.5;
    [self.moneyIconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(insetMax);
        make.top.mas_equalTo(64 + insetMax);
        make.height.width.mas_equalTo(heightLabelMin);
    }];
    [self.moneyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wself.moneyIconImg.mas_right).offset(insetMin);
        make.right.mas_equalTo(- insetMax);
        make.top.bottom.mas_equalTo(wself.moneyIconImg);
    }];
    
    [self.swipeDemoImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(- insetMax * 3);
        make.centerX.mas_equalTo(wself.view.mas_centerX);
        make.width.mas_equalTo(widthImg);
        make.height.mas_equalTo(heightImg);
    }];
    
    [self.stateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(wself.swipeDemoImg.mas_top).offset(- insetMax);
        make.left.mas_equalTo(insetMax);
        make.right.mas_equalTo(- insetMax);
        make.top.mas_equalTo(wself.secondsLabel.mas_bottom).offset(0);
        make.height.mas_equalTo(wself.secondsLabel.mas_height).multipliedBy(2.f);
    }];
    
    [self.secondsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(wself.stateLabel.mas_top).offset(- 0);
        make.left.mas_equalTo(insetMax);
        make.right.mas_equalTo(- insetMax);
        make.top.mas_equalTo(wself.moneyLabel.mas_bottom).offset(insetMax);
        make.height.mas_equalTo(wself.stateLabel.mas_height).multipliedBy(0.5f);
    }];
    
}



#pragma mask ------------------------ getter


- (BVC_vmTransController *)transCtrl {
    if (!_transCtrl) {
        _transCtrl = [[BVC_vmTransController alloc] init];
    }
    return _transCtrl;
}

- (BVC_vmDeviceController *)deviceCtrl {
    if (!_deviceCtrl) {
        _deviceCtrl = [[BVC_vmDeviceController alloc] init];
    }
    return _deviceCtrl;
}

- (BVC_vmPackageTransformer *)packageCtrl {
    if (!_packageCtrl) {
        _packageCtrl = [[BVC_vmPackageTransformer alloc] init];
    }
    return _packageCtrl;
}

- (BVC_vmPasswordController *)passwordCtrl {
    if (!_passwordCtrl) {
        _passwordCtrl = [[BVC_vmPasswordController alloc] init];
    }
    return _passwordCtrl;
}

- (BVC_vmTimer *)timerCtrl {
    if (!_timerCtrl) {
        _timerCtrl = [[BVC_vmTimer alloc] init];
    }
    return _timerCtrl;
}

- (UILabel *)stateLabel {
    if (_stateLabel == nil) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _stateLabel.font = [UIFont boldSystemFontOfSize:16];
        _stateLabel.textColor = [UIColor colorWithHex:0x27384b alpha:1];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.numberOfLines = 0;
    }
    return _stateLabel;
}

- (UILabel *)secondsLabel {
    if (!_secondsLabel) {
        _secondsLabel = [UILabel new];
        _secondsLabel.textAlignment = NSTextAlignmentCenter;
        _secondsLabel.textColor = [UIColor colorWithHex:0x27384b alpha:1];
        _secondsLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    return _secondsLabel;
}

- (UILabel *)moneyIconImg {
    if (!_moneyIconImg) {
        _moneyIconImg = [UILabel new];
        _moneyIconImg.backgroundColor = [UIColor colorWithHex:0x00bb9c alpha:1];
        _moneyIconImg.textColor = [UIColor whiteColor];
        _moneyIconImg.text = @"￥";
        _moneyIconImg.textAlignment = NSTextAlignmentCenter;
        _moneyIconImg.font = [UIFont boldSystemFontOfSize:15];
        _moneyIconImg.layer.masksToBounds = YES;
    }
    return _moneyIconImg;
}

- (UILabel *)moneyLabel {
    if (_moneyLabel == nil) {
        _moneyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _moneyLabel.text = [NSString stringWithFormat:@"金额: %.02lf",[MTransMoneyCache sharedMoney].curMoneyUniteYuan];
        _moneyLabel.font = [UIFont boldSystemFontOfSize:18];
        _moneyLabel.textColor = [UIColor colorWithHex:0x27384b alpha:1];
    }
    return _moneyLabel;
}

- (UIImageView *)swipeDemoImg {
    if (!_swipeDemoImg) {
        _swipeDemoImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipeBlack"]];
    }
    return _swipeDemoImg;
}
@end
