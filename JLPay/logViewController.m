//
//  ViewController.m
//  JLPay
//
//  Created by jielian on 15/3/30.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "logViewController.h"
#import "Define_Header.h"
#import "TCP/TcpClientService.h"
#import "GroupPackage8583.h"
#import "Unpacking8583.h"
#import "Toast+UIView.h"
#import "CommunicationCallBack.h"
#import "CommunicationManager.h"



//  ---- 常量设置区
#define ViewCornerRadius 6.0                                        // 各个 view 的圆角半径值
#define leftLeave        30.0                                       // view 的左边距
#define ImageForBrand   @"01icon"                                   // 商标图片


@interface logViewController ()<wallDelegate,managerToCard,CommunicationCallBack>
@property (nonatomic, strong) CommunicationManager* osmanager;      // JHL的协议接口指针
@property (nonatomic, strong) UITextField *userNumberTextField;     // 用户账号的文本输入框
@property (nonatomic, strong) UITextField *userPasswordTextField;   // 用户密码的文本输入框
@property (nonatomic, strong) UIButton    *loadButton;              // 登陆按钮
@property (nonatomic, strong) UIButton    *signInButton;            // 注册按钮
@property (nonatomic, strong) UIButton    *pinChangeButton;         // 密码修改按钮

@end



@implementation logViewController
@synthesize osmanager;
static FieldTrackData TransData;

@synthesize userNumberTextField     = _userNumberTextField;
@synthesize userPasswordTextField   = _userPasswordTextField;
@synthesize loadButton              = _loadButton;
@synthesize signInButton            = _signInButton;
@synthesize pinChangeButton         = _pinChangeButton;

/*****************************/
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *bgImageView        = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.image               = [UIImage imageNamed:@"bg"];
    [self.view addSubview:bgImageView];

    _loadButton                     = [[UIButton alloc] initWithFrame:CGRectZero];
    _pinChangeButton                = [[UIButton alloc] initWithFrame:CGRectZero];
    _signInButton                   = [[UIButton alloc] initWithFrame:CGRectZero];
    _userNumberTextField            = [[UITextField alloc] initWithFrame:CGRectZero];
    _userPasswordTextField          = [[UITextField alloc] initWithFrame:CGRectZero];
    
    [self addSubViews];
    
    [self openDevice];
    [self EndEdit];
    
    self.view.backgroundColor       = [UIColor colorWithWhite:1 alpha:0.9];
    
}


#pragma mark =======点击取消键盘

-(void)EndEdit
{
    UITapGestureRecognizer *tap     = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(End) ];
    [self.view addGestureRecognizer:tap];
}

-(void)End
{
    [self.view endEditing:YES];
}

/*
 *登陆点击按钮
 */
- (IBAction)loginClick:(UIButton *)sender {


    [[TcpClientService getInstance] sendOrderMethod:[GroupPackage8583 signIn] IP:Current_IP PORT:Current_Port Delegate:self method:@"tcpsignin"];


}

#pragma mark==========================================wallDelegate

-(void)receiveGetData:(NSString *)data method:(NSString *)str
{
        NSLog(@"app---------------------------------%@",str);
        //签到成功
        if ([str  isEqualToString:@"tcpsignin"]) {
            //        [app_delegate dismissWaitingView];
            if ([data length] > 0) {
                
#pragma mark------------------界面跳转
                
                [app_delegate signInSuccessToLogin:1];
                
                [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
            }else{
                [self.view makeToast:@"签到失败，请重新签到"];
            }
        }
}
-(void)falseReceiveGetDataMethod:(NSString *)str
{
    if ([str  isEqualToString:@"tcpsignin"]) {
        [self.view makeToast:@"连接超时，请重新签到"];
    }

}

-(void)managerToCardState:(NSString *)type isSuccess:(BOOL)state method:(NSString *)metStr
{
    if ([metStr isEqualToString:@"tcpsignin"]) {
        if (state) {

            [[app_delegate window] makeToast:type];

        }else{
            [self.view makeToast:type];
        }
    }
}


-(void)openDevice{
    
    
    NSThread* DeviceThread          = [[NSThread alloc] initWithTarget:self selector:@selector(CheckDevceThread1)
                                                      object:nil];
    [DeviceThread start];
}

-(void)CheckDevceThread1
{
    while (true) {
//        NSLog(@"- - - - - - - - - -\n - - - - -- - - - 轮询检测 设备是否开启\n - - - - - - ");
        int result                  =[self openJhlDevice];
        [self StatusChange:result];
        if (result ==0)
        {
            break;
        }
        [NSThread sleepForTimeInterval:0.5];
        
    }
}
-(int)openJhlDevice
{
    memset(&TransData, 0x00, sizeof(FieldTrackData));
    if (osmanager ==NULL)
        osmanager                   = [CommunicationManager sharedInstance];
    
    NSString *astring               =[CommunicationManager getLibVersion];
    
    
    // --- 打印设备的版本
    NSLog(@"%@",astring);
    int result                      = [osmanager openDevice];
    // --- 打印打开设备的结果: result
    NSLog(@"%s,result:%d",__func__,result);
    return result;
    
    
}
-(void )StatusChange:(int )Nstate
{
    NSLog(@"%s,result:%d",__func__,Nstate);
    switch (Nstate) {
        case KNOWED_DEVICE_ING://刷卡器已识别
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self GetSnVersion];
            });
        }
            break;
        case UNKNOW_DEVICE_ING://设备接入但不能识别为刷卡器
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        }
            break;
        case NO_DEVICE_INSERT://没有设备介入 （设备拔出）
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        }
            break;
        case KNOWING_DEVICE_ING://设备正在识别
        {
            dispatch_async(dispatch_get_main_queue(), ^{

            });
        }
            break;
        case DEVICE_NEED_UPDATE_ING://刷卡器已识别，但需要升级
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                

            });
        }
            break;
        default:
            break;
    }
}
-(int)GetSnVersion
{
    if (osmanager ==NULL)
        osmanager = [CommunicationManager sharedInstance];
    int result = [osmanager isConnected];
    if (!result)
        return  result;
    
    NSMutableData* data = [[NSMutableData alloc] init];
    Byte array[1] = {GETSNVERSION};
    [data appendBytes:array length:1];
    result =[osmanager exchangeData:data timeout:WAIT_TIMEOUT cb:self];
    return result;
    
}
-(NSString *)stringFromHexString:(NSString *)hexString { //
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
    
    
}
-(int)ReadTernumber
{
    if (osmanager ==NULL)
        osmanager = [CommunicationManager sharedInstance];
    int result = [osmanager isConnected];
    if (!result)
        return  result;
    
    NSMutableData* data = [[NSMutableData alloc] init];
    Byte array[1] = {GETTERNUMBER};
    [data appendBytes:array length:1];
    result =[osmanager exchangeData:data timeout:WAIT_TIMEOUT cb:self];
    return result;
}


#pragma mark       --------------------------------CommunicationCallBack

-(void)onReceive:(NSData*)data{
    
    NSLog(@"%s %@",__func__,data);
    Byte * ByteDate = (Byte *)[data bytes];
    switch (ByteDate[0]) {
        case MAINKEY_CMD:
            if (!ByteDate[1])   // 主密钥设置成功
            {
                NSLog(@"%s,result:%@",__func__,@"主密钥设置成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                  
                });
                
            }
            
            
            break;
        case WORKKEY_CMD:
            if (!ByteDate[1])   // 工作密钥设置成功
            {
                NSLog(@"%s,result:%@",__func__,@"工作密钥设置成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
               
                });
                
            }
            break;
        case GETSNVERSION:
            if (!ByteDate[1])   // SN号获取成功
            {
                NSString * strSN =@"";
                for (int i=3; i <19; i++) {
                    NSString *newHexStr = [NSString stringWithFormat:@"%x",ByteDate[i]&0xff];///16进制数
                    strSN = [strSN stringByAppendingString:newHexStr];
                    
                }
                strSN =[self stringFromHexString:strSN];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                 self.LabSn.text = strSN;
                    NSLog(@"SN获取成功  %@",strSN);
                    NSString * SN =@"SN:";
                    SN = [SN stringByAppendingString:strSN];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:SN delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
                
            }
            break;
        case GETMAC_CMD:
            if (!ByteDate[1])   // MAC
            {
                NSLog(@"%s,result:%@",__func__,@"MAC 获取成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString * strMAC =@"";
                    strMAC = [NSString stringWithFormat:@"%@",data];
                    strMAC = [strMAC stringByReplacingOccurrencesOfString:@" " withString:@""];
                    strMAC =[strMAC substringFromIndex:5];
                    strMAC = [strMAC substringToIndex:16];
                    
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                });
                
            }
            break;
        case WRITETERNUMBER:
            if (!ByteDate[1])   // 工作密钥设置成功
            {
                NSLog(@"%s,result:%@",__func__,@"终端号商户号设置成功");
                dispatch_async(dispatch_get_main_queue(), ^{

                    [self ReadTernumber];  //读取终端号
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
         
                });
                
            }
            
            break;
        case GETTERNUMBER:
            if (!ByteDate[1])   // 终端号
            {
                
                NSString * strTerNumber =@"";
                strTerNumber = [NSString stringWithFormat:@"%@",data];
                
                strTerNumber = [strTerNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                strTerNumber =[strTerNumber substringFromIndex:5];
                strTerNumber = [strTerNumber substringToIndex:23];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                    self.LabTerid.text = strTerNumber;
                    NSString * strTer =@"";
                    strTer = [@"终端商户号:" stringByAppendingString:strTerNumber];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:strTer delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                });
                
            }
            
            break;
        default:
            break;
    }
    
    
}
-(void)onSendOK{
    NSLog(@"%s",__func__);
}
-(void)onTimeout{
    NSLog(@"%s",__func__);
}
-(void)onError:(NSInteger)code message:(NSString*)msg{
    NSLog(@"%s",__func__);
}
-(void)onProgress:(NSData*)data{
    NSLog(@"%s %@",__func__,data);
}


#pragma mark ======================================= 添加子控件

/*************************************
 * 功  能 : 给当前 viewController 添加子视图控件;
 *         -商标图片
 *         -产品名标签
 *         -账号view
 *         -密码view
 *         -登陆按钮
 *         -注册按钮
 *         -密码修改按钮
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) addSubViews {
    UIImageView *iconImageView;     // 商标
    UIView      *userNumberView;    // 账号视图控件
    UIView      *userPasswordView;  // 密码视图控件
    
    /* 商标：图片 */
    CGFloat      iconViewHeight         = self.view.bounds.size.height/12;      // 商标图片的：高
    CGFloat      appNameLable_width     = 2 * iconViewHeight;
    
    CGFloat      x                      = 0 + (self.view.bounds.size.width - iconViewHeight - appNameLable_width)/2;
    CGFloat      y                      = 2 * iconViewHeight + iconViewHeight;

    iconImageView                       = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, iconViewHeight + appNameLable_width, iconViewHeight)];
    iconImageView.image                 = [UIImage imageNamed:@"logo"];
    [self.view addSubview:iconImageView];

    
    
    /* 账号：textField ; width=view.bounds.width - 50*2 ; height = iconViewHeight; */
    y += (iconViewHeight + iconViewHeight);
    CGRect      numberViewFrame         = CGRectMake(0 + leftLeave, y, self.view.bounds.size.width - leftLeave * 2, iconViewHeight);
    userNumberView                      = [self userInputViewForName:@"账号" inRect:numberViewFrame];
    [self.view addSubview:userNumberView];
    
    /* 密码：textField; bounds跟账号的一致; y = number.y + number.height + 10; */
    y += (iconViewHeight + 10);
    CGRect      passwordViewFrame       = CGRectMake(0 + leftLeave, y, self.view.bounds.size.width - leftLeave * 2, iconViewHeight);
    userPasswordView                    = [self userInputViewForName:@"密码" inRect:passwordViewFrame];
    [self.view addSubview:userPasswordView];
    
    
    /* 登陆按钮：UIButton */
    y += (iconViewHeight + 20);
    self.loadButton.frame               = CGRectMake(0 + leftLeave, y, self.view.bounds.size.width - leftLeave * 2, iconViewHeight);
    self.loadButton.backgroundColor     = [UIColor colorWithRed:1 green:0.1 blue:0 alpha:1];
    self.loadButton.layer.cornerRadius  = ViewCornerRadius;
    self.loadButton.titleLabel.font     = [UIFont fontWithName:@"Helvetica-Bold" size:22];// 设置字体大小
    [self.loadButton setTitle:@"登陆" forState:UIControlStateNormal];
    [self.view addSubview:self.loadButton];
    /* 给“登陆”按钮绑定一个登陆的 action */
    [self.loadButton addTarget:self action:@selector(touchDownLoad:) forControlEvents:UIControlEventTouchDown];
    [self.loadButton addTarget:self action:@selector(loadToMainView:) forControlEvents:UIControlEventTouchUpInside];
    [self.loadButton addTarget:self action:@selector(touchOutLoad:) forControlEvents:UIControlEventTouchUpOutside];

    
    
    /* 注册按钮：UIButton */
    y += (iconViewHeight + 30);
    CGFloat midViewLeave                = 6.0;
    CGFloat signInViewWidth             = (self.view.bounds.size.width - leftLeave * 2)/2 - midViewLeave;
    CGFloat signInViewHeight            = iconViewHeight/2;
    CGRect signInFrame                  = CGRectMake(leftLeave, y, signInViewWidth, signInViewHeight);
    self.signInButton.frame             = signInFrame;
    [self.signInButton setTitle:@"立即注册" forState:UIControlStateNormal];
    /* 给注册按钮添加 action */
    [self.signInButton addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.signInButton];
    
    /* 间隔图标 */
    UIImageView *midLeaveView           = [[UIImageView alloc] initWithFrame:CGRectMake(leftLeave + signInViewWidth, y, midViewLeave, signInViewHeight)];
    midLeaveView.image                  = [UIImage imageNamed:@"fgx"];
    [self.view addSubview:midLeaveView];
    
    /* 修改密码按钮：UIButton */
    self.pinChangeButton.frame          = CGRectMake(leftLeave + midViewLeave + signInViewWidth, y, signInViewWidth, signInViewHeight);
    [self.pinChangeButton setTitle:@"忘记密码?" forState:UIControlStateNormal];
    [self.view addSubview:self.pinChangeButton];


    
}


/*************************************
 * 功  能 : 创建输入视图控件;
 * 参  数 :
 *          (NSString *) viewName   控件类型名
 *          (CGRect)     rect       控件的frame
 * 返  回 : 将创建的自定义视图返回
 *************************************/
- (UIView *) userInputViewForName : (NSString *)viewName inRect: (CGRect)frame {
    
    UIView *view                        = [[UIView alloc] initWithFrame:frame];
    view.layer.cornerRadius             = ViewCornerRadius;      // 圆角半径;
    
    CGFloat x                           = 0 + frame.size.width/3;
    CGRect  textFieldFrame              = CGRectMake(x, 0, frame.size.width - x, frame.size.height);

    UIImageView *imageView              = [[UIImageView alloc] initWithFrame:CGRectMake(x/2.0, frame.size.height * 1.0 / 4.0, x/2.0, frame.size.height * 3.0 / 4.0)];
    
    if ([viewName isEqualToString:@"账号"]) {
        /* 先设置 textField，并添加到自定义 view 上 */
        
        self.userNumberTextField.frame          = textFieldFrame;
        self.userNumberTextField.placeholder    = @"请输入您的账号";
        self.userNumberTextField.textColor      = [UIColor whiteColor];

        [view addSubview:self.userNumberTextField];

        /* 然后设置该 view 的标签图片...... */
        imageView.image                         = [UIImage imageNamed:@"zhm"];
        /*/..............................*/
        
    } else if ([viewName isEqualToString:@"密码" ]) {
        self.userPasswordTextField.frame        = textFieldFrame;
        self.userPasswordTextField.placeholder  = @"请输入您的密码";
        self.userPasswordTextField.textColor    = [UIColor whiteColor];

        [view addSubview:self.userPasswordTextField];
        
        /* 然后设置该 view 的标签图片...... */
        imageView.image                         = [UIImage imageNamed:@"mm"];
        /*/..............................*/

    }
    [view addSubview:imageView];

    view.backgroundColor                        = [UIColor colorWithWhite:0.9 alpha:0.5];
    
    return view;
}



/*************************************
 * 功  能 : 登陆按钮的登陆功能实现;
 * 参  数 :
 *          (UIButton*) sender
 * 返  回 : 无
 *************************************/
- (IBAction)touchDownLoad: (UIButton*)sender {
    // 添加动画效果: 缩小
    sender.transform                      = CGAffineTransformMakeScale(0.98, 0.98);
}
- (IBAction)touchOutLoad: (UIButton*)sender {
    // 添加动画效果: 恢复原大小
    sender.transform                      = CGAffineTransformIdentity;
}
/*************************************
 * 功  能 : 登陆按钮的登陆功能实现;
 * 参  数 :
 *          (UIButton*) sender
 * 返  回 : 无
 *************************************/
- (IBAction)loadToMainView: (UIButton*)sender {
    NSLog(@"登陆按钮的功能实现。。。。。。。");
    // 添加动画效果
    sender.transform                      = CGAffineTransformIdentity;
    [[TcpClientService getInstance] sendOrderMethod:[GroupPackage8583 signIn] IP:Current_IP PORT:Current_Port Delegate:self method:@"tcpsignin"];
}

/*************************************
 * 功  能 : 注册按钮的用户注册功能实现;
 * 参  数 :
 *          (id) sender
 * 返  回 : 无
 *************************************/
- (IBAction)signIn: (id)sender {
    NSLog(@"注册按钮的功能实现。。。。。。。");
}

/*************************************
 * 功  能 : 改密按钮的用户修改密码功能实现;
 * 参  数 :
 *          (id) sender
 * 返  回 : 无
 *************************************/
- (IBAction)changePin: (id)sender {
    NSLog(@"修改密码的功能实现。。。。。。。");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
