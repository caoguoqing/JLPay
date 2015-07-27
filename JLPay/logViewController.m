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
#import "OtherSignButton.h"
#import "EncodeString.h"
#import "DesUtil.h"
#import "ThreeDesUtil.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"



#pragma mask    ---- 常量设置区 ----
#define ViewCornerRadius 6.0                                        // 各个 view 的圆角半径值
#define leftLeave        30.0                                       // view 的左边距
#define ImageForBrand   @"logo"                                   // 商标图片


@interface logViewController ()<UITextFieldDelegate, ASIHTTPRequestDelegate, UIAlertViewDelegate>


@property (nonatomic, strong) UITextField *userNumberTextField;     // 用户账号的文本输入框
@property (nonatomic, strong) UITextField *userPasswordTextField;   // 用户密码的文本输入框
@property (nonatomic, strong) UIButton    *loadButton;              // 登陆按钮

//@property (nonatomic, strong) UIButton    *signInButton;            // 注册按钮
//@property (nonatomic, strong) UIButton    *pinChangeButton;         // 密码修改按钮

@property (nonatomic, assign) CGFloat     moveHeightByWindow;       // 界面需要移动的高度

@end



@implementation logViewController

@synthesize userNumberTextField     = _userNumberTextField;
@synthesize userPasswordTextField   = _userPasswordTextField;
@synthesize loadButton              = _loadButton;
//@synthesize signInButton            = _signInButton;
//@synthesize pinChangeButton         = _pinChangeButton;
@synthesize moveHeightByWindow      = _moveHeightByWindow;

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
    
    // 如果有登陆过，就显示账号
    NSString* userID = [[NSUserDefaults standardUserDefaults] objectForKey:UserID];
    if ([userID length] > 0) {
        self.userNumberTextField.text = userID;
    }
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
    CGFloat      y                      = (self.view.bounds.size.height - iconViewHeight*5 - inset*3)/2.0;
    CGRect       frame                  = CGRectMake(x, y, iconViewWidth, iconViewHeight);
    iconImageView                       = [[UIImageView alloc] initWithFrame:frame];
    iconImageView.image                 = iconImage;
    [self.view addSubview:iconImageView];
    
    
    
    /* 账号：textField ; width=view.bounds.width - 50*2 ; height = iconViewHeight; */
    frame.origin.x                      = leftLeave;
    frame.origin.y                      += iconViewHeight * 2;
    frame.size.width                    = self.view.bounds.size.width - leftLeave*2.0;
    userNumberView                      = [self userInputViewForName:@"账号" inRect:frame];
    [self.view addSubview:userNumberView];
    
    /* 密码：textField; bounds跟账号的一致; y = number.y + number.height + 10; */
    frame.origin.y                      += frame.size.height + inset;
    userPasswordView                    = [self userInputViewForName:@"密码" inRect:frame];
    [self.view addSubview:userPasswordView];
    
    
    /* 登陆按钮：UIButton */
    frame.origin.y                      += frame.size.height + inset * 2.0;
    self.loadButton.frame               = frame;
    [self.view addSubview:self.loadButton];
    /* 给“登陆”按钮绑定一个登陆的 action */
    [self.loadButton addTarget:self action:@selector(touchDownLoad:) forControlEvents:UIControlEventTouchDown];
    [self.loadButton addTarget:self action:@selector(loadToMainView:) forControlEvents:UIControlEventTouchUpInside];
    [self.loadButton addTarget:self action:@selector(touchOutLoad:) forControlEvents:UIControlEventTouchUpOutside];
    
    
    
    /* 注册按钮：UIButton */
//    y += (iconViewHeight + 30);
//    CGFloat midViewLeave                = 6.0;
//    CGFloat signInViewHeight            = iconViewHeight / 5.0 * 2.0;
//    CGFloat signInViewWidth             = signInViewHeight * 4.0;
//    
//    CGFloat midInset                    = (self.view.bounds.size.width - leftLeave * 2 - midViewLeave - signInViewWidth * 2)/4.0;
//    CGRect signInFrame                  = CGRectMake(leftLeave + midInset + signInViewWidth * 0.1, y, signInViewWidth * 0.9, signInViewHeight);
    /*
     *   注册按钮修改:
     *      1.新建一个自定义 OtherSignButton : UIButton
     */
//    self.signInButton.frame             = signInFrame;
//    [self.signInButton setImage:[UIImage imageNamed:@"zc"] forState:UIControlStateNormal];
    /* 给注册按钮添加 action */
//    [self.signInButton addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.signInButton];
    
    /* 间隔图标 */
//    signInFrame.origin.x   += signInViewWidth * 0.9 + midInset;
//    signInFrame.size.width              = midViewLeave;
//    UIImageView* midLeaveView           = [[UIImageView alloc] initWithFrame:signInFrame];
//    midLeaveView.image                  = [UIImage imageNamed:@"fgx"];
//    [self.view addSubview:midLeaveView];
    
    /* 修改密码按钮：UIButton */
//    signInFrame.origin.x                += midViewLeave + midInset;
//    signInFrame.size.width              = signInViewWidth;
//    self.pinChangeButton.frame          = signInFrame;
//    [self.pinChangeButton setImage:[UIImage imageNamed:@"wmm"] forState:UIControlStateNormal];
//    
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
    view.backgroundColor                        = [UIColor colorWithWhite:0.8 alpha:0.5];
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
    [sender setEnabled:NO];
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
    // 不是发签到了，而是登陆: 登陆要上送账号跟密码，明文用 3des 加密成密文
    [[NSUserDefaults standardUserDefaults] setValue:self.userNumberTextField.text forKey:UserID];
    // 3des 加密
    // 原始 key
    NSString* keyStr    = @"123456789012345678901234567890123456789012345678";
    NSString* sourceStr = [EncodeString encodeASC:self.userPasswordTextField.text] ;
    NSLog(@"明文准备加密:%@", sourceStr);
    // 开始加密
    NSString* pin = [ThreeDesUtil encryptUse3DES:sourceStr key:keyStr];
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

#pragma mask ::: 上送登陆报文
- (void)logInWithPin: (NSString*)pin {
    NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/LoginService", [PublicInformation getDataSourceIP], [PublicInformation getDataSourcePort] ];
    ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.delegate = self;
    [request addPostValue:self.userNumberTextField.text forKey:@"userName"];
    [request addPostValue:pin forKey:@"passWord"];
    [request startAsynchronous];
}

#pragma mask ::: HTTP响应协议
-(void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"登陆响应数据[%@]", [request responseString]);
    NSData* data = [request responseData];
    NSError* error;
    NSDictionary* dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSString* retcode = [dataDic objectForKey:@"code"];
    NSString* retMsg = [dataDic objectForKey:@"message"];
    if ([retcode intValue] != 0) {      // 登陆失败
        [self alertShow:retMsg];
    } else {                            // 登陆成功
        // 解析响应数据
        [[NSUserDefaults standardUserDefaults] setObject:self.userNumberTextField.text forKey:UserID];                  // 账号
        [[NSUserDefaults standardUserDefaults] setObject:[dataDic objectForKey:@"mchtNo"] forKey:Business_Number];      // 商户编号
        [[NSUserDefaults standardUserDefaults] setObject:[dataDic objectForKey:@"mchtNm"] forKey:Business_Name];        // 商户名称
        [[NSUserDefaults standardUserDefaults] setObject:[dataDic objectForKey:@"commEmail"] forKey:Business_Email];    // 邮箱
        [[NSUserDefaults standardUserDefaults] setObject:[dataDic objectForKey:@"termCount"] forKey:Terminal_Count];    // 终端个数

        
        int termCount = [[dataDic objectForKey:@"termCount"] intValue];
        if (termCount == 0) {
            // 没有终端号
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:Terminal_Numbers];
        }
        else {                        // 终端编号组的编号
            NSString* terminalNumbersString = [dataDic objectForKey:@"TermNoList"];
            // 将终端号列表字符串拆成数组保存到 Terminal_Numbers
            NSArray* array = [self terminalArrayBySeparateWithString: terminalNumbersString inPart:termCount];
            [[NSUserDefaults standardUserDefaults] setObject:array forKey:Terminal_Numbers];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[app_delegate window] makeToast:@"登陆成功"];
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [DeviceManager sharedInstance];
        });
        [app_delegate signInSuccessToLogin:1];  // 切换到主场景
    }
    
}
-(void)requestFailed:(ASIHTTPRequest *)request {
    [self alertShow:@"网络异常，请检查网络"];
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
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.loadButton setEnabled:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mask ::: getter & setter 
// 账号输入框
- (UITextField *)userNumberTextField {
    if (_userNumberTextField == nil) {
        _userNumberTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _userNumberTextField.placeholder    = @"请输入您的账号";
        _userNumberTextField.textColor      = [UIColor whiteColor];

    }
    return _userNumberTextField;
}
// 密码输入框
- (UITextField *)userPasswordTextField {
    if (_userPasswordTextField == nil) {
        _userPasswordTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _userPasswordTextField.placeholder  = @"请输入您的密码";
        _userPasswordTextField.textColor    = [UIColor whiteColor];
        _userPasswordTextField.secureTextEntry = YES;
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

    }
    return _loadButton;
}
@end
