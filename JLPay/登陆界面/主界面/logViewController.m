//
//  ViewController.m
//  JLPay
//
//  Created by jielian on 15/3/30.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "logViewController.h"
#import "Define_Header.h"
#import "TcpClientService.h"
#import "Unpacking8583.h"
#import "Toast+UIView.h"
#import "OtherSignButton.h"
#import "EncodeString.h"
#import "DesUtil.h"
#import "ThreeDesUtil.h"
#import "AppDelegate.h"
#import "UserRegisterViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ModelUserLoginInformation.h"
#import "ModelDeviceBindedInformation.h"
#import "ModelHTTPRequestLogin.h"
#import "ModelFeeBusinessInformation.h"
#import "ChangePinViewController.h"


#pragma mask    ---- 常量设置区 ----
#define ViewCornerRadius 6.0                                        // 各个 view 的圆角半径值
#define leftLeave        30.0                                       // view 的左边距
#define ImageForBrand   @"logo"                                     // 商标图片


// 枚举: 弹窗标记
typedef enum : NSUInteger {
    TagAlertVersionLow = 701,
    TagAlertRegisterRefuse = 802,
    TagAlertOther = 999
} TagAlert;



static NSString* const KeyEncryptLoading = @"123456789012345678901234567890123456789012345678";

@interface logViewController ()<UITextFieldDelegate, ModelHTTPRequestLoginDelegate, UIAlertViewDelegate>
{
    NSInteger tagFieldUserName;
    NSInteger tagFieldUserPwd;
    
}
@property (nonatomic, strong) UITextField *userNumberTextField;     // 用户账号的文本输入框
@property (nonatomic, strong) UITextField *userPasswordTextField;   // 用户密码的文本输入框
@property (nonatomic, strong) UIButton    *loadButton;              // 登陆按钮

@property (nonatomic, strong) UIButton    *signInButton;          // 注册按钮
@property (nonatomic, strong) UIButton    *pinChangeButton;       // 密码修改按钮
@property (nonatomic, strong) UISwitch*    switchSavePin;
@property (nonatomic, strong) UISwitch*    switchSecurity;

@property (nonatomic, assign) CGFloat     moveHeightByWindow;       // 界面需要移动的高度
@property (nonatomic, retain) NSDictionary* dictLastRegisterInfo;   // 审核未通过的注册信息
@end



@implementation logViewController

@synthesize userNumberTextField     = _userNumberTextField;
@synthesize userPasswordTextField   = _userPasswordTextField;
@synthesize loadButton              = _loadButton;
@synthesize signInButton            = _signInButton;
@synthesize pinChangeButton         = _pinChangeButton;
@synthesize moveHeightByWindow      = _moveHeightByWindow;
@synthesize switchSavePin = _switchSavePin;
@synthesize switchSecurity = _switchSecurity;
@synthesize dictLastRegisterInfo ;

/*****************************/
- (void)viewDidLoad {
    [super viewDidLoad];
    tagFieldUserName = 2323;
    tagFieldUserPwd = 2321;

    
    UIImageView *bgImageView        = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.image               = [UIImage imageNamed:@"bg"];
    [self.view addSubview:bgImageView];
    _moveHeightByWindow             = 0.0;
    // 加载子视图
    [self addSubViews];
    [self EndEdit];
    
    // 设置标题栏 title 的字体颜色
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
    // 回退场景按钮标题: 设置为空标题
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    // 注册信息字典:
    self.dictLastRegisterInfo = nil;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    // 加载用户名和密码
    [self loadUserNameField];
    if (self.switchSavePin.isOn) {
        [self loadUserPasswordField];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 注册键盘的弹出跟隐藏事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[ModelHTTPRequestLogin sharedInstance] terminateLogin];
    [self.loadButton setEnabled:YES];
}


// 加载用户名
- (void) loadUserNameField {
    NSString* userName = [ModelUserLoginInformation userID];
    if (userName) {
        [self.userNumberTextField setText:userName];
    }
}
// 加载密码
- (void) loadUserPasswordField {
    NSString* userPwdPin = [ModelUserLoginInformation userPWD];
    if (userPwdPin && userPwdPin.length > 0) {
        [self.userPasswordTextField setText:[self pswDecryptByPin:userPwdPin]];
    }
}

#pragma mask ----  显示密码switch的切换
- (IBAction) clickSwitchSecurity:(UISwitch*)sender {
    if (sender.isOn) {
        self.userPasswordTextField.secureTextEntry = NO;
        [self.userPasswordTextField setNeedsDisplay];
    } else {
        self.userPasswordTextField.secureTextEntry = YES;
        [self.userPasswordTextField setNeedsDisplay];
    }
}


#pragma mask ---- UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL enable = YES;
    // 回车直接取消输入
    if ([string isEqualToString:@"\n"]) {
        enable = NO;
        [textField resignFirstResponder];
    } else {
        // 密码才限制位数,用户名不用限制
        if (textField.tag == tagFieldUserPwd && textField.text.length + string.length > 8) {
            enable = NO;
        }
    }
    return enable;
}

/*************************************
 * 功  能 : 键盘弹出来时判断是否要上移界面：因遮蔽了控件;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) keyboardWillShow: (NSNotification*)notification {
    // get keyboard frame.Height
    NSDictionary* userInfo          = [notification userInfo];
    NSValue* value                  = [userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyboardHeight          = [value CGRectValue].size.height;

    UITextField* textField = nil;
    if ([self.userNumberTextField isFirstResponder]) {
        textField = self.userNumberTextField;
    } else if ([self.userPasswordTextField isFirstResponder]) {
        textField = self.userPasswordTextField;
    }
    if (textField != nil) {
        UIView* superView = [textField superview];
        CGFloat insetOfViewAndKeyboard = keyboardHeight - (self.view.frame.size.height - (superView.frame.origin.y + self.view.frame.origin.y + superView.frame.size.height));
        if (insetOfViewAndKeyboard > 0) {
            self.moveHeightByWindow += insetOfViewAndKeyboard;
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame        = self.view.frame;
                frame.origin.y      -= self.moveHeightByWindow;
                self.view.frame     = frame;
            }];
        }
    }
}
- (void) keyboardWillHide: (NSNotification*)notification {
    if (self.moveHeightByWindow > 0) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame            = self.view.frame;
            frame.origin.y          += self.moveHeightByWindow;
            self.view.frame         = frame;
        }];
        self.moveHeightByWindow     = 0;
    }
}

#pragma mark =======点击空白区域取消键盘
-(void)EndEdit {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(End)];
    [self.view addGestureRecognizer:tap];
}
-(void)End {
    [self.view endEditing:YES];
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
    
    CGFloat      inset                  = 10.0; // 间隔
    /* 商标：图片 */
    UIImage*     iconImage              = [UIImage imageNamed:ImageForBrand];
    CGSize       iconSize               = [iconImage size];
    CGFloat      iconViewWidth          = self.view.bounds.size.width / 2.0;
    CGFloat      iconViewHeight         = iconViewWidth * iconSize.height/iconSize.width;
    CGFloat      x                      = 0 + (self.view.bounds.size.width - iconViewWidth)/2.0;
    CGFloat      y                      = (self.view.bounds.size.height - iconViewHeight*5 - inset*3 - inset - self.switchSecurity.frame.size.height)/2.0;
    CGRect       frame                  = CGRectMake(x, y, iconViewWidth, iconViewHeight);
    iconImageView                       = [[UIImageView alloc] initWithFrame:frame];
    iconImageView.image                 = iconImage;
    [self.view addSubview:iconImageView];
    
    /* 账号：textField ; width=view.bounds.width - 50*2 ; height = iconViewHeight; */
    frame.origin.x                      = leftLeave;
    frame.origin.y                      += iconViewHeight * (1 + 0.8);
    frame.size.width                    = self.view.bounds.size.width - leftLeave*2.0;
    userNumberView                      = [self userInputViewForName:@"账号" inRect:frame];
    [self.view addSubview:userNumberView];
    
    /* 密码：textField; bounds跟账号的一致; y = number.y + number.height + 10; */
    frame.origin.y                      += frame.size.height + inset;
    userPasswordView                    = [self userInputViewForName:@"密码" inRect:frame];
    [self.view addSubview:userPasswordView];
    
    /* 是否保存密码 */
    frame.origin.y += frame.size.height + inset;
    frame.size.width = (frame.size.width - self.switchSecurity.frame.size.width*2 - inset)/2.0;
    frame.size.height = self.switchSecurity.frame.size.height;
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.text = @"保存密码";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:label];
    
    /* switch */
    frame.origin.x += frame.size.width;
    self.switchSavePin.frame = frame;
    [self.view addSubview:self.switchSavePin];
    
    /* 是否显示密码 */
    frame.origin.x += self.switchSavePin.frame.size.width + inset;
    label = [[UILabel alloc] initWithFrame:frame];
    label.text = @"显示密码";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:label];
    
    /* switch */
    frame.origin.x += frame.size.width ;
    self.switchSecurity.frame = frame;
    [self.view addSubview:self.switchSecurity];
    
    /* 登陆按钮：UIButton */
    frame.origin.x                      = leftLeave;
    frame.origin.y                      += frame.size.height*2 + inset * 2.0;
    frame.size.width                    = self.view.bounds.size.width - leftLeave*2.0;
    frame.size.height                   = iconViewHeight;
    self.loadButton.frame               = frame;
    [self.view addSubview:self.loadButton];
    frame.origin.y += frame.size.height;
    
    
    /* 注册按钮：UIButton */
    y = frame.origin.y + inset*2;
    CGFloat signInViewHeight            = iconViewHeight / 5.0 * 2.0;
    CGFloat signInViewWidth             = signInViewHeight * 137.0/42.0;
    CGFloat pinChangeViewWidth          = signInViewHeight * 154.0/42.0;
    CGFloat midViewLeave                = signInViewHeight * 15.0/51.0;
    CGFloat midInset                    = signInViewWidth/2.0;
    CGRect signInFrame                  = CGRectMake((self.view.bounds.size.width - signInViewWidth - pinChangeViewWidth - midInset*2 - midViewLeave)/2.0,
                                                     y,
                                                     signInViewWidth,
                                                     signInViewHeight);
    self.signInButton.frame             = signInFrame;
    [self.view addSubview:self.signInButton];
    
    // 间隔图标
    signInFrame.origin.x                += signInViewWidth + midInset;
    signInFrame.size.width              = midViewLeave;
    UIImageView* midLeaveView           = [[UIImageView alloc] initWithFrame:signInFrame];
    midLeaveView.image                  = [UIImage imageNamed:@"fgx"];
    [self.view addSubview:midLeaveView];
    
    // 修改密码按钮：UIButton
    signInFrame.origin.x                += midViewLeave + midInset;
    signInFrame.size.width              = pinChangeViewWidth;
    self.pinChangeButton.frame          = signInFrame;
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
    CGFloat x                           = 0 + frame.size.width/4;
    CGRect  textFieldFrame              = CGRectMake(x, 0, frame.size.width - x, frame.size.height);
    
    UITextField* textField = nil;
    UIImage* image = nil;
    CGFloat imageViewHeight = 0;
    CGFloat imageViewY = 0;
    CGFloat imageViewWidth = 0;
    CGFloat imageViewX = 0;
    
    CGFloat cent = 9.0/24.0;
    if ([viewName isEqualToString:@"账号"]) {
        textField = self.userNumberTextField;
        image = [UIImage imageNamed:@"zhm"];
        CGSize imageSize = image.size;
        // 109*90  h:37, w:38
        
        imageViewHeight = frame.size.height * cent * 90.0/37.0;
        imageViewY = frame.size.height * (1 - cent)/2.0;
        imageViewWidth = imageViewHeight * imageSize.width/imageSize.height;
        imageViewX = x - frame.size.height * 2.0/3.0;
    } else if ([viewName isEqualToString:@"密码" ]) {
        textField = self.userPasswordTextField;
        image = [UIImage imageNamed:@"mm"];
        CGSize imageSize = image.size;

        // 102*89 h:43, w:34
        imageViewWidth = frame.size.height * cent * 38.0/37.0 * 0.9 * 102.0/34.0;
        imageViewHeight = imageViewWidth * imageSize.height/imageSize.width;
        imageViewY = (frame.size.height - imageViewHeight * 43.0/89.0)/2.0;
        imageViewX = x - frame.size.height * 2.0/3.0 + 1.5;
    }
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewX, imageViewY, imageViewWidth, imageViewHeight)];
    imageView.image = image;
    [view addSubview:imageView];
    
    textField.frame = textFieldFrame;
    [view addSubview:textField];
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
    [UIView animateWithDuration:0.3 animations:^{
        sender.transform                      = CGAffineTransformMakeScale(0.95, 0.95);
    }];
    [sender setEnabled:NO];
}
- (IBAction)touchOutLoad: (UIButton*)sender {
    // 添加动画效果: 恢复原大小
    sender.transform                      = CGAffineTransformIdentity;
    [sender setEnabled:YES];
}
/*************************************
 * 功  能 : 登陆按钮的登陆功能实现;
 * 参  数 :
 *          (UIButton*) sender
 * 返  回 : 无
 *************************************/
- (IBAction)loadToMainView: (UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    
    if ([self.userNumberTextField.text length] == 0) {
        [PublicInformation makeCentreToast:@"请输入账号"];
        [sender setEnabled:YES];
        return;
    }
    if ([self.userPasswordTextField.text length] == 0) {
        [PublicInformation makeCentreToast:@"请输入密码"];
        [sender setEnabled:YES];
        return;
    }
    // 登陆
    [self startLogin];

}

/*************************************
 * 功  能 : 注册按钮的用户注册功能实现;
 * 参  数 :
 *          (id) sender
 * 返  回 : 无
 *************************************/
- (IBAction)signIn: (id)sender {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserRegisterViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"userRegisterVC"];
    [self.navigationController pushViewController:viewController animated:YES];
}

/*************************************
 * 功  能 : 改密按钮的用户修改密码功能实现;
 * 参  数 :
 *          (id) sender
 * 返  回 : 无
 *************************************/
- (IBAction)changePin: (id)sender {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"forgetPinVC"];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mask ::: ModelHTTPRequestLoginDelegate
- (void) startLogin {
    [[ModelHTTPRequestLogin sharedInstance] loginWithUserID:self.userNumberTextField.text
                                                 andUserPWD:[self pinEncryptBySource:self.userPasswordTextField.text]
                                                   delegate:self];
}
/* 登陆成功 */
- (void)didLoginSuccessWithLoginInfo:(NSDictionary *)loginInfo {
    [self.loadButton setEnabled:YES];
    // 校验是否切换了账号
    [self checkoutLoadingSwitch];
    
    if ([self.userPasswordTextField.text isEqualToString:@"00000000"]) {
        [self gotoModifyPin]; // 8位0强制修改密码
    } else {
        // 保存当前登陆信息
        [self savingLoadingInfo];
        // 保存响应的商户信息
        [self savingBussinessInfo:loginInfo];
        [PublicInformation makeToast:@"登录成功"];
        
        
        UITabBarController* mainTabBar = [APPMainDelegate mainTabBarControllerOfApp];
        if ([ModelDeviceBindedInformation hasBindedDevice]) {
            [mainTabBar setSelectedIndex:0]; // 切换到金额输入界面
        } else {
            [mainTabBar setSelectedIndex:1]; // 切换到商户管理界面
        }
        [self presentViewController:mainTabBar animated:YES completion:nil];
    }
}

/* 登陆失败 */
- (void)didLoginFailWithErrorMessage:(NSString *)errorMessage andErrorType:(LoginErrorCodeType)errorType {
    [self.loadButton setEnabled:YES];

    TagAlert tagalert = TagAlertOther;
    NSString* retMessage = [NSString stringWithString:errorMessage];
    // 部分提示信息成拉丝效果，部分为弹窗效果
    switch (errorType) {
        case LoginErrorCodeTypeDefault:
            [PublicInformation makeToast:retMessage];
            break;
        case LoginErrorCodeTypeLowVersion:
            retMessage = [retMessage stringByAppendingString:@",请点击\"确定\"按钮下载最新版本."];
            tagalert = TagAlertVersionLow;
            [PublicInformation alertCancleAndSureWithTitle:@"提示" message:retMessage tag:tagalert delegate:self];
            break;
        case LoginErrorCodeTypeRegistRefuse:
            self.dictLastRegisterInfo = [ModelHTTPRequestLogin sharedInstance].lastRegisterInfo;
            tagalert = TagAlertRegisterRefuse;
            [PublicInformation alertCancleAndOther:@"修改" title:@"提示" message:retMessage tag:tagalert delegate:self];
            break;
        default:
            [PublicInformation makeToast:@"登录失败"];
            break;
    }
}

#pragma mask ::: 校验是否切换了账号:如果切换,清空配置
- (void) checkoutLoadingSwitch {
    NSString* lastUserID = [ModelUserLoginInformation userID];
    if (!lastUserID || ![lastUserID isEqualToString:self.userNumberTextField.text]) {
        // 清空登陆信息
        [ModelUserLoginInformation deleteLoginUpInformation];
        [ModelUserLoginInformation deleteLoginDownInformation];
        // 清空设备绑定信息
        [ModelDeviceBindedInformation cleanDeviceBindedInfo];
        // 清空设置的指定费率商户信息
        [ModelFeeBusinessInformation clearFeeBusinessInfoSaved];
    }
}

#pragma mask ::: 保存登陆信息
- (void) savingLoadingInfo {
    NSString* pin = nil;
    if (self.switchSavePin.isOn) {
        pin = [self pinEncryptBySource:self.userPasswordTextField.text];
    }
    [ModelUserLoginInformation newLoginUpInfoWithUserID:self.userNumberTextField.text
                                                userPWD:pin
                                        needSaveUserPWD:self.switchSavePin.isOn
                                     needDisplayUserPWD:self.switchSecurity.isOn];
}

#pragma mask ::: 保存商户信息
- (void) savingBussinessInfo:(NSDictionary*)loginInfo {
    NSArray* terminals = nil;
    NSString* termCount = [loginInfo objectForKey:kFieldNameLoginDownTerminalCount];
    if (termCount.intValue > 0) {
        terminals = [self arraySeparatedByTerminalListString:[loginInfo objectForKey:kFieldNameLoginDownTerminalList]];
    }
    [ModelUserLoginInformation newLoginDownInfoWithBusinessName:[loginInfo objectForKey:kFieldNameLoginDownBusinessName]
                                                 businessNumber:[loginInfo objectForKey:kFieldNameLoginDownBusinessNum]
                                                  businessEmail:[loginInfo objectForKey:kFieldNameLoginDownBusinessEmail]
                                                  terminalCount:termCount
                                                terminalNumbers:terminals];

}
#pragma mask ::: 分隔终端号字符串
- (NSArray*) arraySeparatedByTerminalListString:(NSString*) terminalsString {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    // 按逗号拆分到数组
    if (terminalsString && terminalsString.length > 0) {
        NSArray* separatedArray = [terminalsString componentsSeparatedByString:@","];
        [array addObjectsFromArray:separatedArray];
        for (int i = 0; i < array.count; i++) {
            NSString* sourceString = [array objectAtIndex:i];
            // 去掉首尾的多余空白字符
            NSString* stringTrimmed = [sourceString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (![stringTrimmed isEqualToString:sourceString]) {
                [array replaceObjectAtIndex:i withObject:stringTrimmed];
            }
        }
    }
    return array;
}


#pragma mask ------ UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.loadButton setEnabled:YES];
    NSString* buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    switch (alertView.tag) {
        case TagAlertVersionLow:
            if ([buttonTitle isEqualToString:@"确定"] && TAG_OF_BRANCH_EDITION != 0) { // app store分支不能跳转去下载
                [self gotoDownloadApp];
            }
            break;
        case TagAlertRegisterRefuse:
        {
            if (self.dictLastRegisterInfo == nil) {
                return;
            }
            if ([buttonTitle isEqualToString:@"修改"]) {
                [self gotoSignUp];
            }
        }
            break;
        default:
            break;
    }
}

// -- 强制修改密码
- (void) gotoModifyPin {
    // 保存当前登陆账号
    self.switchSavePin.on = NO;
    self.userPasswordTextField.text = nil;
    [self savingLoadingInfo];
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChangePinViewController* modifyPinVC = [storyBoard instantiateViewControllerWithIdentifier:@"changePinVC"];
    [self.navigationController pushViewController:modifyPinVC animated:YES];
}

// 下载app
- (void) gotoDownloadApp {
    NSString* urlString = @"http://www.cccpay.cn/center.html";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}
// 跳转注册页面
- (void) gotoSignUp {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserRegisterViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"userRegisterVC"];
    [viewController setRegisterType:RegisterTypeRefused];
    [viewController loadLastRegisterInfo:self.dictLastRegisterInfo];
    [self.navigationController pushViewController:viewController animated:YES];
}

// 加密登陆密码
- (NSString*) pinEncryptBySource:(NSString*)source {
    NSString* formationSource = [EncodeString encodeASC:source];
    NSString* pin = [ThreeDesUtil encryptUse3DES:formationSource key:KeyEncryptLoading];
    return pin;
}
// 解密登陆密码
- (NSString*) pswDecryptByPin:(NSString*)pin {
    NSString* password = [ThreeDesUtil decryptUse3DES:pin key:KeyEncryptLoading];
    password = [PublicInformation stringFromHexString:password];
    return password;
}


#pragma mask ::: getter & setter 
// 账号输入框
- (UITextField *)userNumberTextField {
    if (_userNumberTextField == nil) {
        _userNumberTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _userNumberTextField.placeholder    = @"请输入登录账号";
        _userNumberTextField.textColor      = [UIColor whiteColor];
        _userNumberTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_userNumberTextField setDelegate:self];
        [_userNumberTextField setTag:tagFieldUserName];
    }
    return _userNumberTextField;
}
// 密码输入框
- (UITextField *)userPasswordTextField {
    if (_userPasswordTextField == nil) {
        _userPasswordTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _userPasswordTextField.placeholder  = @"请输入登录密码";
        _userPasswordTextField.textColor    = [UIColor whiteColor];
        if ([self.switchSecurity isOn]) {
            _userPasswordTextField.secureTextEntry = NO;
        } else {
            _userPasswordTextField.secureTextEntry = YES;
        }
        _userPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_userPasswordTextField setDelegate:self];
        [_userPasswordTextField setDelegate:self];
        [_userPasswordTextField setTag:tagFieldUserPwd];

    }
    return _userPasswordTextField;
}
// 登陆按钮
- (UIButton *)loadButton {
    if (_loadButton == nil) {
        _loadButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _loadButton.backgroundColor     = [UIColor colorWithRed:234.0/255.0 green:58.0/255.0 blue:66.0/255.0 alpha:1];
        _loadButton.layer.cornerRadius  = ViewCornerRadius;
        _loadButton.titleLabel.font = [UIFont boldSystemFontOfSize:22];
        [_loadButton setTitle:@"登    录" forState:UIControlStateNormal];
        [_loadButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_loadButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];

        /* 给“登陆”按钮绑定一个登陆的 action */
        [_loadButton addTarget:self action:@selector(touchDownLoad:) forControlEvents:UIControlEventTouchDown];
        [_loadButton addTarget:self action:@selector(loadToMainView:) forControlEvents:UIControlEventTouchUpInside];
        [_loadButton addTarget:self action:@selector(touchOutLoad:) forControlEvents:UIControlEventTouchUpOutside];

    }
    return _loadButton;
}
- (UIButton *)signInButton {
    if (_signInButton == nil) {
        _signInButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_signInButton setImage:[UIImage imageNamed:@"zc"] forState:UIControlStateNormal];
        // 给注册按钮添加 action
        [_signInButton addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _signInButton;
}
- (UIButton *)pinChangeButton {
    if (_pinChangeButton == nil) {
        _pinChangeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_pinChangeButton setImage:[UIImage imageNamed:@"wmm"] forState:UIControlStateNormal];
        [_pinChangeButton addTarget:self action:@selector(changePin:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _pinChangeButton;
}
- (UISwitch *)switchSavePin {
    if (_switchSavePin == nil) {
        _switchSavePin = [[UISwitch alloc] initWithFrame:CGRectZero];
        [_switchSavePin setOn:[ModelUserLoginInformation needSaveUserPWD]];
    }
    return _switchSavePin;
}
- (UISwitch *)switchSecurity {
    if (_switchSecurity == nil) {
        _switchSecurity = [[UISwitch alloc] initWithFrame:CGRectZero];
        [_switchSecurity setOn:[ModelUserLoginInformation needDisplayUserPWD]];
        [_switchSecurity addTarget:self action:@selector(clickSwitchSecurity:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchSecurity;
}
@end
