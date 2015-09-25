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
#import "Unpacking8583.h"
#import "Toast+UIView.h"
#import "OtherSignButton.h"
#import "EncodeString.h"
#import "DesUtil.h"
#import "ThreeDesUtil.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"
#import "RegisterViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>



#pragma mask    ---- 常量设置区 ----
#define ViewCornerRadius 6.0                                        // 各个 view 的圆角半径值
#define leftLeave        30.0                                       // view 的左边距
#define ImageForBrand   @"logo"                                     // 商标图片


@interface logViewController ()<UITextFieldDelegate, ASIHTTPRequestDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITextField *userNumberTextField;     // 用户账号的文本输入框
@property (nonatomic, strong) UITextField *userPasswordTextField;   // 用户密码的文本输入框
@property (nonatomic, strong) UIButton    *loadButton;              // 登陆按钮

@property (nonatomic, strong) UIButton    *signInButton;          // 注册按钮
@property (nonatomic, strong) UIButton    *pinChangeButton;       // 密码修改按钮
@property (nonatomic, strong) UISwitch*    switchSavePin;
@property (nonatomic, strong) UISwitch*    switchSecurity;

@property (nonatomic, assign) CGFloat     moveHeightByWindow;       // 界面需要移动的高度
@property (nonatomic, retain) ASIFormDataRequest* httpRequest;      // http请求
@property (nonatomic, retain) NSDictionary* dictLastRegisterInfo;   // 审核未通过的注册信息
@end



@implementation logViewController

@synthesize userNumberTextField     = _userNumberTextField;
@synthesize userPasswordTextField   = _userPasswordTextField;
@synthesize loadButton              = _loadButton;
@synthesize signInButton            = _signInButton;
@synthesize pinChangeButton         = _pinChangeButton;
@synthesize moveHeightByWindow      = _moveHeightByWindow;
@synthesize httpRequest = _httpRequest;
@synthesize switchSavePin = _switchSavePin;
@synthesize switchSecurity = _switchSecurity;
@synthesize dictLastRegisterInfo ;

/*****************************/
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *bgImageView        = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.image               = [UIImage imageNamed:@"bg"];
    [self.view addSubview:bgImageView];
    _moveHeightByWindow             = 0.0;
    // 登陆按钮
    [self addSubViews];
    [self EndEdit];
    // 设置版本号
    NSString* appVersion            = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    
    
    // 设置 title 的字体颜色
    UIColor *color                  = [UIColor redColor];
    NSDictionary *dict              = [NSDictionary dictionaryWithObject:color  forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    self.navigationController.navigationBar.tintColor = color;
    UIBarButtonItem* backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(backToLastViewController)];
    [self.navigationItem setBackBarButtonItem:backBarButton];
    
    self.dictLastRegisterInfo = nil;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = YES;
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
    [self.httpRequest clearDelegatesAndCancel];
    self.httpRequest = nil;
    [self.loadButton setEnabled:YES];
}
- (void) backToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mask ---- 密码文本框的编辑事件
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.userPasswordTextField) {
        if ([self.switchSecurity isOn]) {
            [textField setSecureTextEntry:NO];
        } else {
            [textField setSecureTextEntry:YES];
        }
    }
    
    return YES;
}


#pragma mask ---- UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length > 8) {
        textField.text = [newString substringToIndex:8];
        return NO;
    }
    return YES;
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

-(void)EndEdit
{
    UITapGestureRecognizer *tap     = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(End) ];
    [self.view addGestureRecognizer:tap];
}

-(void)End
{
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
//    [self.view addSubview:self.signInButton];
    
    // 间隔图标
    signInFrame.origin.x                += signInViewWidth + midInset;
    signInFrame.size.width              = midViewLeave;
    UIImageView* midLeaveView           = [[UIImageView alloc] initWithFrame:signInFrame];
    midLeaveView.image                  = [UIImage imageNamed:@"fgx"];
//    [self.view addSubview:midLeaveView];
    
    // 修改密码按钮：UIButton
    signInFrame.origin.x                += midViewLeave + midInset;
    signInFrame.size.width              = pinChangeViewWidth;
    self.pinChangeButton.frame          = signInFrame;
//    [self.view addSubview:self.pinChangeButton];
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
    // 添加动画效果
    sender.transform                      = CGAffineTransformIdentity;
    
    if ([self.userNumberTextField.text length] == 0) {
        [self alertShow:@"请输入账号"];
        return;
    }
    if ([self.userPasswordTextField.text length] == 0) {
        [self alertShow:@"请输入密码"];
        return;
    }

    // 保存历史信息
    [[NSUserDefaults standardUserDefaults] setBool:self.switchSavePin.on forKey:NeedSavingUserPW];
    [[NSUserDefaults standardUserDefaults] setBool:self.switchSecurity.on forKey:NeedDisplayUserPW];
    if ([self.switchSavePin isOn]) {
        [[NSUserDefaults standardUserDefaults] setValue:self.userPasswordTextField.text forKey:UserPW];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 登陆密码加密
    NSString* pin = [self pinEncryptBySource:self.userPasswordTextField.text];
    
    // 登陆
    [self logInWithPin:pin];
    
    //***************** test for 不登陆 ************
//    [app_delegate signInSuccessToLogin:1];  // 切换到主场景

}

/*************************************
 * 功  能 : 注册按钮的用户注册功能实现;
 * 参  数 :
 *          (id) sender
 * 返  回 : 无
 *************************************/
- (IBAction)signIn: (id)sender {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegisterViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"userRegisterVC"];
    [viewController setPackageType:0];// 注册
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

#pragma mask ::: 上送登陆报文
- (void)logInWithPin: (NSString*)pin {
    // 账号参数
    [self.httpRequest addPostValue:self.userNumberTextField.text forKey:@"userName"];
    // 密码参数
    [self.httpRequest addPostValue:pin forKey:@"passWord"];
    // 操作系统版本 0:IOS, 1:Android
    [self.httpRequest addPostValue:@"0" forKey:@"sysFlag"];
    // 版本号参数
    NSString* versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    NSString* versionNum = [NSString stringWithFormat:@"%@%@%@",[versionString substringToIndex:1],[versionString substringWithRange:NSMakeRange(2, 1)],[versionString substringFromIndex:versionString.length - 1]];
    // 发起HTTP请求
//    versionNum = @"99"; // test for 低版本登陆校验
    [self.httpRequest addPostValue:versionNum forKey:@"versionNum"];
    [self.httpRequest startAsynchronous];
}

#pragma mask ::: HTTP响应协议
-(void)requestFinished:(ASIHTTPRequest *)request {
    [self.loadButton setEnabled:YES];
    NSData* data = [request responseData];
    NSError* error;
    NSDictionary* dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    [request clearDelegatesAndCancel];
    self.httpRequest = nil;
    NSString* retcode = [dataDic objectForKey:@"code"];
    NSString* retMsg = [retcode stringByAppendingString:[dataDic objectForKey:@"message"]];
    if ([retcode intValue] != 0) {      // 登陆失败
        if ([retcode isEqualToString:@"701"]) { // 当前版本过低
            retMsg = [retMsg stringByAppendingString:@",请点击\"确定\"按钮下载最新版本."];
        } else if ([retcode isEqualToString:@"802"]) {
            self.dictLastRegisterInfo = [dataDic objectForKey:@"registerInfoList"];
        }
        [self alertShow:retMsg];
    } else {                            // 登陆成功
        // 校验是否切换了账号
        [self checkoutCustSwitch];

        // 保存商户信息: 解析响应数据
        [[NSUserDefaults standardUserDefaults] setObject:self.userNumberTextField.text forKey:UserID];                  // 账号
        [[NSUserDefaults standardUserDefaults] setObject:[dataDic objectForKey:@"mchtNo"] forKey:Business_Number];      // 商户编号
        [[NSUserDefaults standardUserDefaults] setObject:[dataDic objectForKey:@"mchtNm"] forKey:Business_Name];        // 商户名称
        [[NSUserDefaults standardUserDefaults] setObject:[dataDic objectForKey:@"commEmail"] forKey:Business_Email];    // 邮箱
        [[NSUserDefaults standardUserDefaults] setObject:[dataDic objectForKey:@"termCount"] forKey:Terminal_Count];    // 终端个数
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        int termCount = [[dataDic objectForKey:@"termCount"] intValue];
        if (termCount > 0) {
            // 终端编号组的编号
            NSString* terminalNumbersString = [dataDic objectForKey:@"TermNoList"];
            // 将终端号列表字符串拆成数组保存到 Terminal_Numbers
            NSArray* array = [self terminalArrayBySeparateWithString: terminalNumbersString inPart:termCount];
            [[NSUserDefaults standardUserDefaults] setObject:array forKey:Terminal_Numbers];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:Terminal_Numbers];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[app_delegate window] makeToast:@"登陆成功"];
        });
        // 切换到主场景
        [app_delegate signInSuccessToLogin:1];
    }
    
}
-(void)requestFailed:(ASIHTTPRequest *)request {
    [self.loadButton setEnabled:YES];
    [request clearDelegatesAndCancel];
    self.httpRequest = nil;
    [self alertShow:@"网络异常，请检查网络"];
}
// 校验是否切换了账号:如果切换,清空配置
- (void) checkoutCustSwitch {
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSString* lastUserID = [userDefault valueForKey:UserID];
    
    if (![lastUserID isEqualToString:self.userNumberTextField.text]) {
        [userDefault removeObjectForKey:KeyInfoDictOfBinded];
        [userDefault synchronize];
    }
}




#pragma mask ::: 分隔终端号字符串
- (NSArray*) terminalArrayBySeparateWithString: (NSString*) termString inPart: (int)count {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    NSString* tempString = [termString copy];
    for (int i = 0; i < count; i++) {
        NSInteger index;
        NSString* terminalNum;
        if ([tempString rangeOfString:@","].length == 0) {
            index = 0;
            terminalNum = tempString;
        } else {
            index = [tempString rangeOfString:@","].location;
            terminalNum = [tempString substringToIndex:index];
        }
        if (terminalNum == nil) {
            break;
        }
        while ([terminalNum hasPrefix:@" "]) {
            terminalNum = [terminalNum substringFromIndex:[terminalNum rangeOfString:@" "].location + 1];
        }
        if ([terminalNum hasSuffix:@" "]) {
            terminalNum = [terminalNum substringToIndex:[terminalNum rangeOfString:@" "].location];
        }
        if (terminalNum != nil) {
            [array addObject:terminalNum];
        }
        if (index != 0) {
            tempString = [tempString substringFromIndex:index + 1];
        }
    }
    if (array.count == 0) {
        return nil;
    }
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:Terminal_Count] intValue] != array.count) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lu", (unsigned long)array.count] forKey:Terminal_Count];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return array;
}

#pragma mask ::: 弹出提示框
- (void) alertShow: (NSString*) message {
    UIAlertView* alert;
    if ([message hasPrefix:@"802"]) {
        alert = [[UIAlertView alloc] initWithTitle:@"登陆失败" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"修改注册", nil];
    } else {
        alert = [[UIAlertView alloc] initWithTitle:@"登陆失败" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    }
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.loadButton setEnabled:YES];
    if (buttonIndex == 0) {
        return;
    }
    
    // 如果是版本过低的提示，点击了确定要跳转到下载网址
    if ([alertView.message hasPrefix:@"701"]) {
        NSString* urlString = @"http://www.cccpay.cn/center.html";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
    // 注册审核不通过,需要修改信息
    else if ([alertView.message hasPrefix:@"802"]) {
        if (self.dictLastRegisterInfo == nil) {
            return;
        }
        UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RegisterViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"userRegisterVC"];
        [viewController setPackageType:1]; // 0:新增注册, 1:修改注册, 2:修改信息
        [[NSUserDefaults standardUserDefaults] setValue:[self.dictLastRegisterInfo valueForKey:@"mchntNm"] forKey:RESIGN_mchntNm];
        [[NSUserDefaults standardUserDefaults] setValue:[self.dictLastRegisterInfo valueForKey:@"userName"] forKey:RESIGN_userName];
        [[NSUserDefaults standardUserDefaults] setValue:[self.dictLastRegisterInfo valueForKey:@"passWord"] forKey:RESIGN_passWord];
        [[NSUserDefaults standardUserDefaults] setValue:[self.dictLastRegisterInfo valueForKey:@"identifyNo"] forKey:RESIGN_identifyNo];
        [[NSUserDefaults standardUserDefaults] setValue:[self.dictLastRegisterInfo valueForKey:@"telNo"] forKey:RESIGN_telNo];
        [[NSUserDefaults standardUserDefaults] setValue:[self.dictLastRegisterInfo valueForKey:@"speSettleDs"] forKey:RESIGN_speSettleDs];
        [[NSUserDefaults standardUserDefaults] setValue:[self.dictLastRegisterInfo valueForKey:@"settleAcct"] forKey:RESIGN_settleAcct];
        [[NSUserDefaults standardUserDefaults] setValue:[self.dictLastRegisterInfo valueForKey:@"settleAcctNm"] forKey:RESIGN_settleAcctNm];
        [[NSUserDefaults standardUserDefaults] setValue:[self.dictLastRegisterInfo valueForKey:@"mail"] forKey:RESIGN_mail];
        [[NSUserDefaults standardUserDefaults] setValue:[self.dictLastRegisterInfo valueForKey:@"ageUserName"] forKey:RESIGN_ageUserName];
        [[NSUserDefaults standardUserDefaults] setValue:[self.dictLastRegisterInfo valueForKey:@"addr"] forKey:RESIGN_addr];
        [[NSUserDefaults standardUserDefaults] setValue:[self.dictLastRegisterInfo valueForKey:@"areaNo"] forKey:RESIGN_areaNo];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

// 加密登陆密码
- (NSString*) pinEncryptBySource:(NSString*)source {
    NSString* formationSource = [EncodeString encodeASC:source];
    NSString* pin = [ThreeDesUtil encryptUse3DES:formationSource key:KeyEncryptLoading];
    return pin;
}


#pragma mask ::: getter & setter 
// 账号输入框
- (UITextField *)userNumberTextField {
    if (_userNumberTextField == nil) {
        _userNumberTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _userNumberTextField.placeholder    = @"请输入您的账号";
        _userNumberTextField.textColor      = [UIColor whiteColor];
        _userNumberTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        NSString* textPrepare = [[NSUserDefaults standardUserDefaults] valueForKey:UserID];
        if (textPrepare && textPrepare.length > 0) {
            _userNumberTextField.text = textPrepare;
        }
    }
    return _userNumberTextField;
}
// 密码输入框
- (UITextField *)userPasswordTextField {
    if (_userPasswordTextField == nil) {
        _userPasswordTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _userPasswordTextField.placeholder  = @"请输入您的密码";
        _userPasswordTextField.textColor    = [UIColor whiteColor];
        if ([self.switchSecurity isOn]) {
            _userPasswordTextField.secureTextEntry = NO;
        } else {
            _userPasswordTextField.secureTextEntry = YES;
        }
        _userPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_userPasswordTextField setDelegate:self];
        if ([self.switchSavePin isOn]) {
            NSString* textPrepare = [[NSUserDefaults standardUserDefaults] valueForKey:UserPW];
            if (textPrepare && textPrepare.length > 0) {
                _userPasswordTextField.text = textPrepare;
            }
        }
        [_userPasswordTextField setDelegate:self];
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
        [_loadButton setTitle:@"登陆" forState:UIControlStateNormal];
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
- (ASIFormDataRequest *)httpRequest {
    if (_httpRequest == nil) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/LoginService", [PublicInformation getDataSourceIP], [PublicInformation getDataSourcePort] ];
        _httpRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [_httpRequest setDelegate:self];
    }
    return _httpRequest;
}
- (UISwitch *)switchSavePin {
    if (_switchSavePin == nil) {
        _switchSavePin = [[UISwitch alloc] initWithFrame:CGRectZero];
        [_switchSavePin setOn:[[NSUserDefaults standardUserDefaults] boolForKey:NeedSavingUserPW]];
    }
    return _switchSavePin;
}
- (UISwitch *)switchSecurity {
    if (_switchSecurity == nil) {
        _switchSecurity = [[UISwitch alloc] initWithFrame:CGRectZero];
        [_switchSecurity setOn:[[NSUserDefaults standardUserDefaults] boolForKey:NeedDisplayUserPW]];
    }
    return _switchSecurity;
}
@end
