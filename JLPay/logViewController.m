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



#pragma mask    ---- 常量设置区 ----
#define ViewCornerRadius 6.0                                        // 各个 view 的圆角半径值
#define leftLeave        30.0                                       // view 的左边距
#define ImageForBrand   @"01icon"                                   // 商标图片


@interface logViewController ()<wallDelegate,managerToCard, UITextFieldDelegate, ASIHTTPRequestDelegate>


@property (nonatomic, strong) UITextField *userNumberTextField;     // 用户账号的文本输入框
@property (nonatomic, strong) UITextField *userPasswordTextField;   // 用户密码的文本输入框
@property (nonatomic, strong) UIButton    *loadButton;              // 登陆按钮

@property (nonatomic, strong) UIButton    *signInButton;            // 注册按钮
@property (nonatomic, strong) UIButton    *pinChangeButton;         // 密码修改按钮

@property (nonatomic, assign) CGFloat     moveHeightByWindow;       // 界面需要移动的高度

@end



@implementation logViewController

@synthesize userNumberTextField     = _userNumberTextField;
@synthesize userPasswordTextField   = _userPasswordTextField;
@synthesize loadButton              = _loadButton;
@synthesize signInButton            = _signInButton;
@synthesize pinChangeButton         = _pinChangeButton;
@synthesize moveHeightByWindow      = _moveHeightByWindow;

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
    _moveHeightByWindow             = 0.0;
    
    _userPasswordTextField.delegate = self;
    
    // 登陆按钮
    [self addSubViews];
    [self EndEdit];
    
    // 如果有登陆过，就显示账号
    NSString* userID = [[NSUserDefaults standardUserDefaults] objectForKey:UserID];
    if ([userID length] > 0) {
        self.userNumberTextField.text = userID;
    }
    
    // 打开设备..循环中。。这里需要读取设备么????????????????????????
//    AppDelegate* delegate_          = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    
//    [delegate_.device open];

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

    
    // checkout textField, and push up Window
    if ([self.userNumberTextField isFirstResponder] || [self.userPasswordTextField isFirstResponder]) {
        UIView* view                = [self.userPasswordTextField superview];
        
        // 高度差 = 键盘高度 - (屏幕高度 - (密码输入框.superview.y坐标 + view.高度))
        //    大于0 : 表示键盘遮盖了输入框
        CGFloat insetOfViewAndKeyboard = keyboardHeight - (self.view.bounds.size.height - (view.frame.origin.y + view.frame.size.height));

        // 遮盖时才将 window 向上移动
        if (insetOfViewAndKeyboard > 0) {
            self.moveHeightByWindow = insetOfViewAndKeyboard;
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



#pragma mark==========================================wallDelegate

// 成功接收响应数据的回调 - TcpClientServer
-(void)receiveGetData:(NSString *)data method:(NSString *)str
{
    if ([data length] > 0) {
        [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
    } else {
        [self.view makeToast:@"网络超时,请重新登陆"];
    }
    
}
// 失败接收响应数据的回调
-(void)falseReceiveGetDataMethod:(NSString *)str
{
    if ([str  isEqualToString:@"tcpsignin"]) {
        [self.view makeToast:@"网络超时,请检查网络"];
    }
}

// 响应数据拆包后的结果处理回调
-(void)managerToCardState:(NSString *)type isSuccess:(BOOL)state method:(NSString *)metStr
{
        if (state) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[app_delegate window] makeToast:@"登陆成功"];
            });
            [app_delegate signInSuccessToLogin:1];  // 成功了才切换到主场景
        }else{
            [self.view makeToast:type];
        }
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
    self.loadButton.backgroundColor     = [UIColor colorWithRed:234.0/255.0 green:58.0/255.0 blue:66.0/255.0 alpha:1];
    
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
    CGFloat signInViewHeight            = iconViewHeight / 5.0 * 2.0;
    CGFloat signInViewWidth             = signInViewHeight * 4.0;
    
    CGFloat midInset                    = (self.view.bounds.size.width - leftLeave * 2 - midViewLeave - signInViewWidth * 2)/4.0;
    CGRect signInFrame                  = CGRectMake(leftLeave + midInset + signInViewWidth * 0.1, y, signInViewWidth * 0.9, signInViewHeight);
    /*
     *   注册按钮修改:
     *      1.新建一个自定义 OtherSignButton : UIButton
     *      2.
     */
    self.signInButton.frame             = signInFrame;
    [self.signInButton setImage:[UIImage imageNamed:@"zc"] forState:UIControlStateNormal];
    /* 给注册按钮添加 action */
    [self.signInButton addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.signInButton];
    
    /* 间隔图标 */
    signInFrame.origin.x                       += signInViewWidth * 0.9 + midInset;
    signInFrame.size.width              = midViewLeave;
    UIImageView* midLeaveView           = [[UIImageView alloc] initWithFrame:signInFrame];
    midLeaveView.image                  = [UIImage imageNamed:@"fgx"];
    [self.view addSubview:midLeaveView];
    
    /* 修改密码按钮：UIButton */
    signInFrame.origin.x                += midViewLeave + midInset;
    signInFrame.size.width              = signInViewWidth;
    self.pinChangeButton.frame          = signInFrame;
    [self.pinChangeButton setImage:[UIImage imageNamed:@"wmm"] forState:UIControlStateNormal];
    
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
    
    UIImageView *imageView              = [[UIImageView alloc] initWithFrame:CGRectMake(x/2.0, frame.size.height * 1.0 / 4.0, x / 5.0 * 4.0, frame.size.height )];
    
    if ([viewName isEqualToString:@"账号"]) {
        /* 先设置 textField，并添加到自定义 view 上 */
        self.userNumberTextField.frame          = textFieldFrame;
        self.userNumberTextField.placeholder    = @"请输入您的账号";
        self.userNumberTextField.textColor      = [UIColor whiteColor];
        [self.userNumberTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        
        [view addSubview:self.userNumberTextField];
        
        /* 然后设置该 view 的标签图片 */
        imageView.image                         = [UIImage imageNamed:@"zhm"];
        
    } else if ([viewName isEqualToString:@"密码" ]) {
        self.userPasswordTextField.frame        = textFieldFrame;
        self.userPasswordTextField.placeholder  = @"请输入您的密码";
        self.userPasswordTextField.textColor    = [UIColor whiteColor];
        self.userPasswordTextField.secureTextEntry = YES;
        [self.userPasswordTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        
        [view addSubview:self.userPasswordTextField];
        
        /* 然后设置该 view 的标签图片 */
        imageView.image                         = [UIImage imageNamed:@"mm"];
        
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
    
    // 发送签到报文  -- 改到管理界面去签到、或刷卡界面
//    [[TcpClientService getInstance] sendOrderMethod:[GroupPackage8583 signIn] IP:Current_IP PORT:Current_Port Delegate:self method:@"tcpsignin"];
    
    // 不是发签到了，而是登陆: 登陆要上送账号跟密码，明文用 3des 加密成密文
    [[NSUserDefaults standardUserDefaults] setValue:self.userNumberTextField.text forKey:UserID];
    // 3des 加密
    // 原始 key
    NSString* keyStr    = @"123456789012345678901234567890123456789012345678";
    NSString* sourceStr = [EncodeString encodeASC:self.userPasswordTextField.text] ;
    
    // 开始加密
    NSString* pin = [ThreeDesUtil encryptUse3DES:sourceStr key:keyStr];
    
    // 输出信息
    NSLog(@"\n-----------\nsrc=[%@]\n------------------\npin=[%@]\n------------------", keyStr,pin);

    // 准备上送加密数据
//    [[NSUserDefaults standardUserDefaults] setValue:pin forKey:@"userPW"];
//    [[TcpClientService getInstance] sendOrderMethod:[GroupPackage8583 loadIn] IP:Current_IP PORT:Current_Port Delegate:self method:@"loadIn"];
    
    
    // 修改::: 不要送 8583 报文，改送 HTTP
    [self logInWithPin:pin];
    
    // testing ...
//    [];
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
    NSLog(@"ip:[%@], port:[%@], urlString=[%@]", [PublicInformation getDataSourceIP], [PublicInformation getDataSourcePort], urlString);
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
//    NSLog(@"retcode = [%@], retMsg = [%@]", retcode, retMsg);
    if ([retcode intValue] != 0) {      // 登陆失败
        [self alertShow:retMsg];
    } else {                            // 登陆成功
        // 解析响应数据
        [[NSUserDefaults standardUserDefaults] setObject:self.userNumberTextField.text forKey:UserID];                  // 账号
        [[NSUserDefaults standardUserDefaults] setObject:[dataDic objectForKey:@"mchtNo"] forKey:Business_Number];      // 商户编号
        [[NSUserDefaults standardUserDefaults] setObject:[dataDic objectForKey:@"mchtNm"] forKey:Business_Name];        // 商户名称
        [[NSUserDefaults standardUserDefaults] setObject:[dataDic objectForKey:@"commEmail"] forKey:Business_Email];    // 邮箱
        [[NSUserDefaults standardUserDefaults] setObject:[dataDic objectForKey:@"termCount"] forKey:Terminal_Count];    // 终端个数
        /**************** test for null of email ************/
//        NSString* test = [dataDic objectForKey:@"commEmail"];
//        if (test == nil || test.length == 0) {
//            [[NSUserDefaults standardUserDefaults] setValue:@"89sdsdf2adfadfadfadfadfadsfa83972@qq.com" forKey:Business_Email];
//        }
        /****************test************/

        
        int termCount = [[dataDic objectForKey:@"termCount"] intValue];
        if (termCount == 0) {
            
        }
        else if (termCount == 1) {    // 一个终端的编号
            [[NSUserDefaults standardUserDefaults] setObject:[dataDic objectForKey:@"TermNoList"] forKey:Terminal_Number];
        }
        else {                        // 终端编号组的编号
            NSLog(@"\n--------------TermNoList[%@]",[dataDic objectForKey:@"TermNoList"]);
//            NSArray* array = [dataDic objectForKey:@"TermNoList"];
            NSString* terminalNumbersString = [dataDic objectForKey:@"TermNoList"];
            NSArray* array = [self terminalArrayBySeparateWithString: terminalNumbersString inPart:termCount];
            
            
            [[NSUserDefaults standardUserDefaults] setObject:array forKey:Terminal_Numbers];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[app_delegate window] makeToast:@"登陆成功"];
        });
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DeviceBeingSignedIn]; // 切换设备的签到标记
        [[NSUserDefaults standardUserDefaults] synchronize];
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
        NSLog(@"range:%d",[tempString rangeOfString:@","].length);
        NSInteger index;
        NSString* terminalNum;
        if ([tempString rangeOfString:@","].length == 0) {
//            index = [tempString length];
            index = 0;
            terminalNum = tempString;
        } else {
            index = [tempString rangeOfString:@","].location;
            terminalNum = [tempString substringToIndex:index];
        }
        NSLog(@"\n<<<<<<<<<<<<<index=[%d],",index);
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
        NSLog(@"tempString = [%@]", tempString);
    }
    if (array.count == 0) {
        return nil;
    }
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:Terminal_Count] intValue] != array.count) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lu", (unsigned long)array.count] forKey:Terminal_Count];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSLog(@"\n-------------array=[%@]", array);
    return array;
}

#pragma mask ::: 弹出提示框
- (void) alertShow: (NSString*) message {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
