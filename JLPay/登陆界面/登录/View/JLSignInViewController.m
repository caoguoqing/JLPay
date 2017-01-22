//
//  JLSignInViewController.m
//  CustomViewMaker
//
//  Created by 冯金龙 on 16/5/31.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "JLSignInViewController.h"
#import "JLSignUpViewController.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"
#import "Define_Header.h"
#import "DelegateForTextFieldControl.h"
#import "VMHttpSignIn.h"
#import "MBProgressHUD+CustomSate.h"
#import "ChangePinViewController.h"
#import "ForgetPinViewConroller.h"
#import "ModelAppInformation.h"
#import "SignUpBtn.h"
#import "VMSignInInfoCache.h"
#import "MPasswordEncrytor.h"
#import "JLSigninInputView.h"


@interface JLSignInViewController()

@property (nonatomic, strong) UIImageView* logoImgView;         // logo
@property (nonatomic, strong) UIImageView* logoTitleImgView;    // logo名


@property (nonatomic, strong) JLSigninInputView* userNameInputView;
@property (nonatomic, strong) JLSigninInputView* userPasswordInputView;


@property (nonatomic, strong) UIButton* pwdForgottenBtn;        // 忘记密码
@property (nonatomic, strong) UIButton* pwdSavingBtn;           // 保存密码-按钮
@property (nonatomic, strong) UILabel* pwdSavingLabel;          // 保存密码-标签

@property (nonatomic, strong) UIButton* signInBtn;              // 登录
@property (nonatomic, strong) SignUpBtn* signUpBtn;             // 注册

@property (nonatomic, strong) VMHttpSignIn* signinHttp;         // 登录http请求

@property (nonatomic, strong) VMSignInInfoCache* moreCaches;    // 各种本地缓存(登录数据、设备、多商户)

/* 控制密码输入和键盘遮挡处理 */
@property (nonatomic, strong) DelegateForTextFieldControl* delegateForTfield;

/* 登陆成功回调 */
@property (nonatomic, copy) void (^ loginFinished) (void);

/* 登陆取消回调 */
@property (nonatomic, copy) void (^ loginCanceled) (void);

/* 取消按钮 */
@property (nonatomic, strong) UIButton* loginCancelBtn;

/* 背景图层 */
@property (nonatomic, strong) CAGradientLayer* backGradientLayer;

@end


@implementation JLSignInViewController


- (instancetype) initWithLoginFinished:(void (^) (void))finishedBlock onCanceled:(void (^) (void))cancelBlock {
    self = [super init];
    if (self) {
        self.loginFinished = finishedBlock;
        self.loginCanceled = cancelBlock;
    }
    return self;
}




- (void) manageOnKVOs {
    
    @weakify(self);
    /* 监控: 保存密码的标志颜色 */
    [[RACObserve(self.moreCaches, needPasswordSaving) deliverOnMainThread] subscribeNext:^(NSNumber* enable) {
        @strongify(self);
        if (enable.boolValue) {
            [self.pwdSavingBtn setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
        } else {
            [self.pwdSavingBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.3] forState:UIControlStateNormal];
        }
    }];
    
    [[RACObserve(self.moreCaches, seenPasswordAvilable) deliverOnMainThread] subscribeNext:^(NSNumber* visible) {
        @strongify(self);
        if (visible.boolValue) {
            [self.userPasswordInputView.rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.userPasswordInputView.rightBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAEye] forState:UIControlStateNormal];
        } else {
            [self.userPasswordInputView.rightBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.3] forState:UIControlStateNormal];
            [self.userPasswordInputView.rightBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAEyeSlash] forState:UIControlStateNormal];
        }
    }];
    
    
    /* binding: secureTextEntry to seenVisible */
    RAC(self.userPasswordInputView.textField, secureTextEntry) = [RACObserve(self.moreCaches, seenPasswordAvilable) map:^NSNumber*(NSNumber* visible) {
        return @(!visible.boolValue);
    }];
    

    /* binding: 用户名+密码 */
    RAC(self.moreCaches, userName) = [[RACObserve(self.userNameInputView.textField, text) skip:1] map:^id(NSString* userName) {
        return [userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }];
    RAC(self.moreCaches, userPasswordPin) = [[[RACObserve(self.userPasswordInputView.textField, text) skip:1] filter:^BOOL(NSString* password) {
        return password && password.length > 0;
    }] map:^id(NSString* password) {
        return [MPasswordEncrytor pinEncryptedBySource:password];
    }];
    
    RAC(self.signinHttp, userNameStr) = RACObserve(self.moreCaches, userName);
    RAC(self.signinHttp, userPwdStr) = RACObserve(self.moreCaches, userPasswordPin);

    
    /* observing: 跟踪登录过程 */
    [self.signinHttp.signInCommand.executionSignals subscribeNext:^(RACSignal* sig) {
        [[[sig dematerialize] deliverOnMainThread] subscribeNext:^(id x) {
            [MBProgressHUD showNormalWithText:@"正在登录..." andDetailText:nil];
        } error:^(NSError *error) {
            NSInteger errorCode = [error code];
            if (errorCode == VMSigninSpecialErrorTypeLowVersion) {
                [MBProgressHUD hideCurNormalHud];
                [UIAlertController showAlertWithTitle:@"App版本过低,请下载更新版本" message:nil target:nil clickedHandle:^(UIAlertAction *action) {
                    if ([action.title isEqualToString:@"去下载"]) {
                        NSURL* url = [NSURL URLWithString:[ModelAppInformation URLStringInAppStore]];
                        [[UIApplication sharedApplication] openURL:url];
                    }
                } buttons:@{@(UIAlertActionStyleDefault):@"取消"}, @{@(UIAlertActionStyleCancel):@"去下载"}, nil];
            }
            else {
                [MBProgressHUD showFailWithText:@"登录失败" andDetailText:[error localizedDescription] onCompletion:nil];
            }
        } completed:^{
            @strongify(self);
            [MBProgressHUD hideCurNormalHud];
            /* 先缓存 */
            [self.moreCaches reWriteLocalConfig];
            /* 初始密码为8个0的: 强制修改密码 */
            if ([self.userPasswordInputView.textField.text isEqualToString:@"00000000"]) {
                [self switchToChangePinInterface];
            } else {
                /* 退出登录界面 */
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    @strongify(self);
                    if (self.loginFinished) {
                        self.loginFinished();
                    }
                }];
            }
        }];
    }];
    
}



# pragma mask 2 IBAction

- (IBAction) clickedSavingPwdBtn:(id)sender {
    self.moreCaches.needPasswordSaving = !self.moreCaches.needPasswordSaving;
}

- (IBAction) clickedPwdSeenBtn:(id)sender {
    self.moreCaches.seenPasswordAvilable = !self.moreCaches.seenPasswordAvilable;
}

- (IBAction) clickedForgotPwdBtn:(id)sender {
    ForgetPinViewConroller* forgotPwdVC = [[ForgetPinViewConroller alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:forgotPwdVC animated:YES];
}

- (IBAction) clickedSignUpBtn:(id)sender {
    JLSignUpViewController* userSignUpVC = [[JLSignUpViewController alloc] initWithNibName:nil bundle:nil];
    [userSignUpVC setFirstStep];
    userSignUpVC.seperatedIndex = 0;
    [self.navigationController pushViewController:userSignUpVC animated:YES];
}

/* 点击空白隐藏键盘 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NameWeakSelf(wself);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.view.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
    }];

    for (UIView* subView in self.view.subviews) {
        if ([subView class] == [JLSigninInputView class]) {
            JLSigninInputView* inputView = (JLSigninInputView*)subView;
            [inputView.textField resignFirstResponder];
        }
    }
}

/* 点击了取消登录按钮 */
- (IBAction) clickedLoginCancelBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


/* 切换到修改密码界面 */
- (void) switchToChangePinInterface {
    ChangePinViewController* changePinVC = [[ChangePinViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:changePinVC animated:YES];
}





# pragma mask 4 布局

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    
    [self loadSubviews];
    [self layoutSubviews];
    [self manageOnKVOs];
    [self initialDatas];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden:YES];
    
}

- (void) initialDatas {
    [self.moreCaches reReadLocalConfig];
    if (self.moreCaches.userName && self.moreCaches.userName.length > 0) {
        self.userNameInputView.textField.text = self.moreCaches.userName;
    }
    if (self.moreCaches.userPasswordPin && self.moreCaches.userPasswordPin.length > 0) {
        self.userPasswordInputView.textField.text = [MPasswordEncrytor pinSourceDecryptedOnPin:self.moreCaches.userPasswordPin];
    }
}


- (void) loadSubviews {
    [self.view.layer addSublayer:self.backGradientLayer];
    
    [self.view addSubview:self.logoImgView];
    [self.view addSubview:self.logoTitleImgView];
    
    [self.view addSubview:self.userNameInputView];
    [self.view addSubview:self.userPasswordInputView];
    
    [self.view addSubview:self.pwdSavingBtn];
    [self.view addSubview:self.pwdSavingLabel];
    [self.view addSubview:self.pwdForgottenBtn];
    
    [self.view addSubview:self.signUpBtn];
    [self.view addSubview:self.signInBtn];
    
    [self.view addSubview:self.loginCancelBtn];
}

- (void) layoutSubviews {
    NameWeakSelf(wself);
    CGFloat inset = 15;
    
    CGFloat txtFieldHRate = 1/12.5f;
    CGFloat btnHRate = 1/12.5f;
    CGFloat heightTxtField = self.view.frame.size.height * txtFieldHRate;
    CGFloat heightBtn = self.view.frame.size.height * btnHRate;
    CGFloat widthPwdForgotBtn =  [UIScreen mainScreen].bounds.size.width * 100/320.f;
    CGFloat widthLoginCancelBtn = [UIScreen mainScreen].bounds.size.width * 33/320.f;
    
    CGFloat heightLogoTitleImg = ScreenWidth * 18/320.f;
    CGFloat widthLogoTitleImg = self.logoTitleImgView.image.size.width / self.logoTitleImgView.image.size.height * heightLogoTitleImg;
    
    self.userNameInputView.layer.cornerRadius = heightTxtField * 0.5;
    self.userPasswordInputView.layer.cornerRadius = heightTxtField * 0.5;
    self.signInBtn.layer.cornerRadius = heightBtn * 0.5;
    
    
    self.signInBtn.titleLabel.font = [UIFont systemFontOfSize:[@"xx" resizeFontAtHeight:heightBtn scale:0.38]];
    self.signUpBtn.titleLabel.font = [UIFont systemFontOfSize:[@"xx" resizeFontAtHeight:heightBtn scale:0.38]];
    self.pwdSavingLabel.font = [UIFont systemFontOfSize:[@"xx" resizeFontAtHeight:heightTxtField scale:0.38]];
    self.pwdForgottenBtn.titleLabel.font = [UIFont systemFontOfSize:[@"xx" resizeFontAtHeight:heightTxtField scale:0.38]];
    self.pwdSavingBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[@"xx" resizeFontAtHeight:heightTxtField scale:0.5]];
    self.loginCancelBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:widthLoginCancelBtn scale:1]];
    
    self.backGradientLayer.frame = self.view.bounds;
    
    [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.view.mas_centerX);
        make.bottom.equalTo(wself.view.mas_top).offset(wself.view.frame.size.height * 0.25);
        make.width.height.equalTo(wself.view.mas_width).multipliedBy(0.18);
    }];
    [self.logoTitleImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.view.mas_centerX);
        make.top.mas_equalTo(wself.logoImgView.mas_bottom).offset(inset);
        make.width.mas_equalTo(widthLogoTitleImg);
        make.height.mas_equalTo(heightLogoTitleImg);
    }];
    
    [self.userNameInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(wself.view.mas_centerY).offset(- 3);
        make.left.equalTo(wself.view.mas_left).offset(inset);
        make.right.equalTo(wself.view.mas_right).offset(-inset);
        make.height.equalTo(wself.view.mas_height).multipliedBy(txtFieldHRate);
    }];

    [self.userPasswordInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.userNameInputView.mas_bottom).offset(6);
        make.left.equalTo(wself.view.mas_left).offset(inset);
        make.right.equalTo(wself.view.mas_right).offset(-inset);
        make.height.equalTo(wself.view.mas_height).multipliedBy(txtFieldHRate);
    }];
    

    [self.pwdSavingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.userPasswordInputView.mas_bottom).offset(0);
        make.left.equalTo(wself.userPasswordInputView.mas_left).offset(0);
        make.height.equalTo(wself.view.mas_height).multipliedBy(txtFieldHRate);
        make.width.equalTo(wself.pwdSavingBtn.mas_height);

    }];

    [self.pwdSavingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.userPasswordInputView.mas_bottom).offset(0);
        make.left.equalTo(wself.pwdSavingBtn.mas_right).offset(0);
        make.right.equalTo(wself.view.mas_centerX);
        make.height.equalTo(wself.view.mas_height).multipliedBy(txtFieldHRate);
    }];

    [self.pwdForgottenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.pwdSavingLabel.mas_top);
        make.right.equalTo(wself.userPasswordInputView.mas_right);
        make.width.mas_equalTo(widthPwdForgotBtn);
        make.height.equalTo(wself.view.mas_height).multipliedBy(txtFieldHRate);

    }];

    [self.signUpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(wself.view.mas_bottom).offset(-15);
        make.left.equalTo(wself.view.mas_left).offset(inset);
        make.right.equalTo(wself.view.mas_right).offset(-inset);
        make.height.equalTo(wself.view.mas_height).multipliedBy(btnHRate);

    }];

    [self.signInBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(wself.signUpBtn.mas_top).offset(-10);
        make.left.equalTo(wself.view.mas_left).offset(inset);
        make.right.equalTo(wself.view.mas_right).offset(-inset);
        make.height.equalTo(wself.view.mas_height).multipliedBy(btnHRate);
    }];

    [self.loginCancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20 + inset);
        make.right.mas_equalTo(- inset);
        make.width.height.mas_equalTo(widthLoginCancelBtn);
    }];
    
}






# pragma mask 5 getter

- (UIImageView *)logoImgView {
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc] initWithImage:[PublicInformation logoImageOfApp]];
    }
    return _logoImgView;
}
- (UIImageView *)logoTitleImgView {
    if (!_logoTitleImgView) {
        _logoTitleImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_title_gray"]];
    }
    return _logoTitleImgView;
}


- (UIButton *)signInBtn {
    if (!_signInBtn) {
        _signInBtn = [UIButton new];
        _signInBtn.backgroundColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        [_signInBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_signInBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_signInBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
        [_signInBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
        
        _signInBtn.rac_command = self.signinHttp.signInCommand;
    }
    return _signInBtn;
}
- (SignUpBtn *)signUpBtn {
    if (!_signUpBtn) {
        _signUpBtn = [[SignUpBtn alloc] init];
        [_signUpBtn setTitle:@"新用户注册" forState:UIControlStateNormal];
        [_signUpBtn setTitleColor:[UIColor colorWithHex:HexColorTypeBlackGray alpha:0.7] forState:UIControlStateNormal];
        [_signUpBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateHighlighted];
        [_signUpBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateDisabled];
        [_signUpBtn addTarget:self action:@selector(clickedSignUpBtn:) forControlEvents:UIControlEventTouchUpInside];
        _signUpBtn.directionLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackGray alpha:0.7];
        
    }
    return _signUpBtn;
}

- (UIButton *)pwdForgottenBtn {
    if (!_pwdForgottenBtn) {
        _pwdForgottenBtn = [UIButton new];
        [_pwdForgottenBtn setTitle:@"忘记密码?" forState:UIControlStateNormal];
        [_pwdForgottenBtn setTitleColor:[UIColor colorWithWhite:0.9 alpha:1] forState:UIControlStateNormal];
        [_pwdForgottenBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateHighlighted];
        [_pwdForgottenBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateDisabled];
        [_pwdForgottenBtn addTarget:self action:@selector(clickedForgotPwdBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pwdForgottenBtn;
}

- (UIButton *)pwdSavingBtn {
    if (!_pwdSavingBtn) {
        _pwdSavingBtn = [UIButton new];
        [_pwdSavingBtn setTitle:[NSString fontAwesomeIconStringForEnum:FACheckCircle] forState:UIControlStateNormal];
        [_pwdSavingBtn setTitleColor:[UIColor colorWithWhite:0.9 alpha:1] forState:UIControlStateNormal];
        [_pwdSavingBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateHighlighted];
        [_pwdSavingBtn addTarget:self action:@selector(clickedSavingPwdBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pwdSavingBtn;
}

- (UILabel *)pwdSavingLabel {
    if (!_pwdSavingLabel) {
        _pwdSavingLabel = [UILabel new];
        _pwdSavingLabel.text = @"保存密码";
        _pwdSavingLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];
        _pwdSavingLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _pwdSavingLabel;
}


- (DelegateForTextFieldControl *)delegateForTfield {
    if (!_delegateForTfield) {
        _delegateForTfield = [[DelegateForTextFieldControl alloc] init];
        NameWeakSelf(wself);
        _delegateForTfield.pullViewUpFrontKeyBordByOffset = ^(CGFloat offset){
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                wself.view.transform = CGAffineTransformMakeTranslation(0, - offset);
            } completion:^(BOOL finished) {}];
        };
    }
    return _delegateForTfield;
}


- (VMHttpSignIn *)signinHttp {
    if (!_signinHttp) {
        _signinHttp = [[VMHttpSignIn alloc] init];
    }
    return _signinHttp;
}

- (VMSignInInfoCache *)moreCaches {
    if (!_moreCaches) {
        _moreCaches = [[VMSignInInfoCache alloc] init];
    }
    return _moreCaches;
}

- (UIButton *)loginCancelBtn {
    if (!_loginCancelBtn) {
        _loginCancelBtn = [UIButton new];
        [_loginCancelBtn setTitle:[NSString fontAwesomeIconStringForEnum:FATimesCircle] forState:UIControlStateNormal];
        [_loginCancelBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.618] forState:UIControlStateNormal];
        [_loginCancelBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
        [_loginCancelBtn addTarget:self action:@selector(clickedLoginCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginCancelBtn;
}

- (CAGradientLayer *)backGradientLayer {
    if (!_backGradientLayer) {
        _backGradientLayer = [CAGradientLayer layer];
        _backGradientLayer.colors = @[(__bridge id)[UIColor colorWithHex:0x99cccc alpha:1].CGColor,
                                      (__bridge id)[UIColor colorWithHex:0x27384b alpha:0.618].CGColor,
                                      (__bridge id)[UIColor colorWithHex:0x99cccc alpha:1].CGColor];
        _backGradientLayer.locations = @[@0, @0.7, @1];
        _backGradientLayer.startPoint = CGPointMake(0.5, 0);
        _backGradientLayer.endPoint = CGPointMake(0.5, 1);
    }
    return _backGradientLayer;
}

- (JLSigninInputView *)userNameInputView {
    if (!_userNameInputView) {
        _userNameInputView = [[JLSigninInputView alloc] init];
        _userNameInputView.iconLabel.text = [NSString fontAwesomeIconStringForEnum:FAUser];
        _userNameInputView.iconLabel.textColor = [UIColor whiteColor];
        _userNameInputView.textField.placeholder = @"请输入用户名";
        _userNameInputView.textField.textColor = [UIColor whiteColor];
        _userNameInputView.textField.delegate = self.delegateForTfield;
        _userNameInputView.rightBtn.hidden = YES;
        _userNameInputView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    }
    return _userNameInputView;
}

- (JLSigninInputView *)userPasswordInputView {
    if (!_userPasswordInputView) {
        _userPasswordInputView = [[JLSigninInputView alloc] init];
        _userPasswordInputView.iconLabel.text = [NSString fontAwesomeIconStringForEnum:FALock];
        _userPasswordInputView.iconLabel.textColor = [UIColor whiteColor];
        _userPasswordInputView.textField.placeholder = @"请输入密码";
        _userPasswordInputView.textField.textColor = [UIColor whiteColor];
        _userPasswordInputView.textField.delegate = self.delegateForTfield;
        _userPasswordInputView.textField.tag = SignInTxtTaguserPwd;
        _userPasswordInputView.textField.keyboardType = UIKeyboardTypeAlphabet;
        [_userPasswordInputView.rightBtn addTarget:self action:@selector(clickedPwdSeenBtn:) forControlEvents:UIControlEventTouchUpInside];
        _userPasswordInputView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    }
    return _userPasswordInputView;
}



@end
