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



@interface BrushViewController()<CustomIOSAlertViewDelegate>


@property (nonatomic, strong) UIActivityIndicatorView* activity;            // 刷卡状态的转轮
@property (nonatomic, strong) CustomIOSAlertView* passwordAlertView;

@end

@implementation BrushViewController
@synthesize activity                    = _activity;
@synthesize passwordAlertView           = _passwordAlertView;

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
}

#pragma mask ::: 子视图的属性设置
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

#pragma mask ::: 界面显示后的事件注册及处理
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AppDelegate* delegate               = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([delegate.device isConnected]) {
        // 刷卡
        [[delegate window] makeToast:@"请刷卡..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // 刷卡
            [delegate.device cardSwipe];
        });
    } else {
        [[delegate window] makeToast:@"请插入设备"];
        // 连接设备....循环中
        [delegate.device open];
    }


}


#pragma mask ::: 刷卡成功
- (void) cardSwipeSuccess : (NSNotification*)notification {
    if ([self.activity isAnimating]) {
        [self.activity stopAnimating];
    }
    
    // 打开密码输入提示框
    [self makePasswordAlertView];
    
}
#pragma mask ::: 刷卡失败
- (void) cardSwipeFail : (NSNotification*)notification {
    if ([self.activity isAnimating]) {
        [self.activity stopAnimating];
    }
    // 弹出刷卡界面,回到金额输入界面
    [self.navigationController popViewControllerAnimated:YES];

}


#pragma mask ::: 初始化并加载密码输入提示框
- (void) makePasswordAlertView {
    // innerView 放在 alertView 中创建
    
    self.passwordAlertView.delegate = self;
    [self.passwordAlertView setUseMotionEffects:YES];
    
    [self.passwordAlertView setButtonTitles:[NSArray arrayWithObjects:@"取消", @"确定", nil]];
        
    [self.passwordAlertView show];
}



#pragma mask ::: 密码输入提示框的按钮点击事件
- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    CustomIOSAlertView* alertV = (CustomIOSAlertView*)alertView;
    [alertV close];

    if (buttonIndex == 0) { // 取消
        // 弹出刷卡界面,回到金额输入界面
        [self.navigationController popViewControllerAnimated:YES];
    } else {                // 确定
        long money = [self themoney] ;
        AppDelegate* delegate_  = (AppDelegate*)[UIApplication sharedApplication].delegate;
        // 这里的密码 password 用 alertView.password
        [delegate_.device TRANS_Sale:20000
                             nAmount:money
                        nPasswordlen:(int)self.passwordAlertView.password.length
                            bPassKey:self.passwordAlertView.password];
    }
}


#pragma mask ::: 跳转到消费的联机阶段
- (void) toCust: (NSNotification*)notification {
    // 密码
    AppDelegate* delegate_  = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate_.window makeToast:@"刷磁成功,交易处理中..."];
    
    NSString *liushui=[PublicInformation exchangeNumber];
    [[NSUserDefaults standardUserDefaults] setValue:liushui forKey:Current_Liushui_Number];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    WaitViewController *viewcon = [[WaitViewController alloc]init];
    viewcon.pinstr  = [[NSUserDefaults standardUserDefaults] valueForKey:Sign_in_PinKey];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:viewcon animated:YES];
    });
}

#pragma mask ::: 跳转回金额输入界面
- (void) backToCust: (NSNotification*)notification {
    AppDelegate* delegate_  = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate_.window makeToast:@"交易失败!"];
    
    UIStoryboard* storyBoard    = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CustPayViewController* viewController   = [storyBoard instantiateViewControllerWithIdentifier:@"CustPayViewController"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popToViewController:viewController animated:YES];
    });
}



#pragma mask ::: 从本地配置获取金额
-(NSString *)returnMoney{
    NSString *moneyStr=[[NSUserDefaults standardUserDefaults] valueForKey:Consumer_Money];
    if (moneyStr && ![moneyStr isEqualToString:@"0.00"] && ![moneyStr isEqualToString:@"(null)"]) {
        moneyStr=[[NSUserDefaults standardUserDefaults] valueForKey:Consumer_Money];
    }else{
        moneyStr=@"1";
    }
    return moneyStr;
}

#pragma mask ::: 将小数点金额转换为报文需要的无小数点格式
-(int)themoney{
    int money=[[self returnMoney] floatValue]*100;
    return money;
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
    CGFloat leftInset           = 15;                // 左边界
    CGFloat rightInset          = 15;                // 右边界
    CGFloat inset               = 60;                // 上部分视图跟下部分视图的间隔
    CGFloat uifont              = 20.0;              // 字体大小
    
    CGFloat xFrame              = 0 + leftInset;
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
    // 符号图片
    frame.origin.x              += width;
    frame.size.width            = frame.size.height;
    UIImageView* jineImage      = [[UIImageView alloc] initWithFrame:frame];
    jineImage.image             = [UIImage imageNamed:@"jine"];
    [self.view addSubview:jineImage];
    // 金额数值
    frame.origin.x              += frame.size.width;
    frame.size.width            = width * 3.0;
    UILabel* money              = [[UILabel alloc] initWithFrame:frame];
    money.font                   = [UIFont boldSystemFontOfSize:uifont];
    money.textAlignment         = NSTextAlignmentLeft;
    money.text                  = [[[NSUserDefaults standardUserDefaults] valueForKey:Consumer_Money] stringByAppendingString:@"元"];
    [self.view addSubview:money];
    // 请刷卡...
    frame.size.width            = 80.0;
    frame.origin.x              = self.view.bounds.size.width - rightInset - frame.size.width;
    UILabel* shuaka             = [[UILabel alloc] initWithFrame:frame];
    shuaka.textAlignment        = NSTextAlignmentLeft;
    shuaka.font                   = [UIFont boldSystemFontOfSize:uifont];
    shuaka.text                 = @"请刷卡...";
    [self.view addSubview:shuaka];
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
    leftInset                   = self.view.bounds.size.width / 6.0;
    rightInset                  *= 2;
    frame.origin.x              = leftInset;
    frame.size.width            = self.view.bounds.size.width - leftInset - rightInset;
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



@end
