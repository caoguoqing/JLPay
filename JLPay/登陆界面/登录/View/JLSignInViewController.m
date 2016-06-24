//
//  JLSignInViewController.m
//  CustomViewMaker
//
//  Created by 冯金龙 on 16/5/31.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "JLSignInViewController.h"

@implementation JLSignInViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    
    self.seenVisible = NO;
    
    [self loadSubviews];
    [self layoutSubviews];
    [self manageOnKVOs];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    /* 加载历史登陆信息 */
    [self loadSignInInfoLastSaved];
}


- (void) manageOnKVOs {
    
    @weakify(self);
    [[RACObserve(self, savedEnable) deliverOnMainThread] subscribeNext:^(NSNumber* enable) {
        @strongify(self);
        if (enable.boolValue) {
            [self.pwdSavingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            [self.pwdSavingBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }];
    
    [[RACObserve(self, seenVisible) deliverOnMainThread] subscribeNext:^(NSNumber* visible) {
        @strongify(self);
        if (visible.boolValue) {
            [self.visiblePwdSeenBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.visiblePwdSeenBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAEye] forState:UIControlStateNormal];
        } else {
            [self.visiblePwdSeenBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [self.visiblePwdSeenBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAEyeSlash] forState:UIControlStateNormal];
        }
    }];
    
    /* binding: secureTextEntry to seenVisible */
    RAC(self.pwdTextField, secureTextEntry) = [[RACObserve(self, seenVisible) deliverOnMainThread] map:^NSNumber*(NSNumber* visible) {
        return @(!visible.boolValue);
    }];
    
    /* binding: sign in inputed info to VMSigninCache */
    RAC(self.signInCache.loginSavedResource, userName) = [self.userTextField.rac_textSignal skip:1];
    RAC(self.signInCache.loginSavedResource, userPwdPan) = [RACObserve(self.signinHttp, userPwdPinStr) skip:1]; /* 保存密文 */
    RAC(self.signInCache.loginSavedResource, needSaving) = [RACObserve(self, savedEnable) skip:1];



    /* binding: inputs value to http */
    RAC(self.signinHttp, userNameStr) = RACObserve(self.userTextField, text);
    RAC(self.signinHttp, userPwdStr) = RACObserve(self.pwdTextField, text);

    
    /* observing: 跟踪登录过程 */
    [self.signinHttp.signInCommand.executionSignals subscribeNext:^(RACSignal* sig) {
        [[[sig dematerialize] deliverOnMainThread] subscribeNext:^(id x) {
            @strongify(self);
            [self.progressHud showNormalWithText:@"正在登录..." andDetailText:nil];
        } error:^(NSError *error) {
            NSInteger errorCode = [error code];
            @strongify(self);
            if (errorCode == VMSigninSpecialErrorTypeLowVersion) {
                [self.progressHud hide:YES];
                [PublicInformation alertCancleAndOther:@"去下载" title:@"App版本过低,请下载更新版本" message:nil tag:SignInVCAlertTagLowAppVersion delegate:self];
            }
            else {
                [self.progressHud showFailWithText:@"登录失败" andDetailText:[error localizedDescription] onCompletion:^{}];
            }
        } completed:^{
            @strongify(self);
            [self.progressHud showSuccessWithText:@"登录成功" andDetailText:nil onCompletion:^{
                @strongify(self);
                /* 初始密码为8个0的: 强制修改密码 */
                if ([self.pwdTextField.text isEqualToString:@"00000000"]) {
                    [self switchToChangePinInterface];
                } else {
                    /* 重置登陆信息的保存 */
                    [self resetAndSavingSignInResponse];
                    /* 检查是否切换了账号 */
                    [self clearDeviceInfoIfSwitchUser];
                    /* 跳转到主界面 */
                    [self switchToMainInterface];
                }
            }];
        }];
    }];
    
}

# pragma mask 2 UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == SignInVCAlertTagLowAppVersion) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[ModelAppInformation URLStringInAppStore]]];
        }
    }
}


# pragma mask 2 IBAction

- (IBAction) clickedSavingPwdBtn:(id)sender {
    self.savedEnable = !self.savedEnable;
}

- (IBAction) clickedPwdSeenBtn:(id)sender {
    self.seenVisible = !self.seenVisible;
}

- (IBAction) clickedForgotPwdBtn:(id)sender {
    ForgetPinViewConroller* forgotPwdVC = [[ForgetPinViewConroller alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:forgotPwdVC animated:YES];
}

- (IBAction) clickedSignUpBtn:(id)sender {
    UserRegisterViewController* userRegisterVC = [[UserRegisterViewController alloc] initWithNibName:nil bundle:nil];
    userRegisterVC.registerType = RegisterTypeNew;
    [self.navigationController pushViewController:userRegisterVC animated:YES];
}

/* 点击空白隐藏键盘 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NameWeakSelf(wself);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.view.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
    }];

    for (UIView* subView in self.view.subviews) {
        if ([subView class] == [UITextField class]) {
            [subView resignFirstResponder];
        }
    }
}

/* 切换到主界面 */
- (void) switchToMainInterface {
    UITabBarController* mainTabBar = [APPMainDelegate mainTabBarControllerOfApp];
    
    if ([ModelDeviceBindedInformation hasBindedDevice]) {
        [mainTabBar setSelectedIndex:0]; // 切换到金额输入界面
    } else {
        [mainTabBar setSelectedIndex:1]; // 切换到商户管理界面
    }
    [self presentViewController:mainTabBar animated:YES completion:nil];
}

/* 切换到修改密码界面 */
- (void) switchToChangePinInterface {
    ChangePinViewController* changePinVC = [[ChangePinViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:changePinVC animated:YES];
}

/* 重置并保存登陆信息 */
- (void) resetAndSavingSignInResponse {
    [self.signInCache resetPropertiesBySignInResponseData:self.signinHttp.responseData];
    [self.signInCache doLoginResourceSaving];
}

/* 加载已保存的登陆信息 */
- (void) loadSignInInfoLastSaved {
    self.savedEnable = self.signInCache.loginSavedResource.needSaving;
    self.userTextField.text = self.signInCache.loginSavedResource.userName;
    self.pwdTextField.text = (self.savedEnable && self.signInCache.loginSavedResource.userPwdPan && self.signInCache.loginSavedResource.userPwdPan.length > 0) ?
    ([self.signinHttp sourceByUnEncryptPin:self.signInCache.loginSavedResource.userPwdPan]):
    (nil);
}

/* 检查是否切换了账号: 是，则清空设备绑定信息 */
- (void) clearDeviceInfoIfSwitchUser {
    if (![[ModelDeviceBindedInformation businessNoBinded] isEqualToString:[MLoginSavedResource sharedLoginResource].businessNumber]) {
        [ModelDeviceBindedInformation cleanDeviceBindedInfo];
    }
}


# pragma mask 4 布局

- (void) loadSubviews {
    
    [self.view addSubview:self.backgroundImgView];
    
    [self.view addSubview:self.logoImgView];
    
    [self.view addSubview:self.userTextField];
    [self.view addSubview:self.pwdTextField];
    [self.view addSubview:self.headLabel];
    [self.view addSubview:self.lockLabel];
    
    [self.view addSubview:self.visiblePwdSeenBtn];
    [self.view addSubview:self.pwdSavingBtn];
    [self.view addSubview:self.pwdSavingLabel];
    [self.view addSubview:self.pwdForgottenBtn];
    
    [self.view addSubview:self.signUpBtn];
    [self.view addSubview:self.signInBtn];
    
    [self.view addSubview:self.progressHud];
    
}

- (void) layoutSubviews {
    NameWeakSelf(wself);
    CGFloat inset = 15;
    
    CGFloat txtFieldHRate = 1/13.f;
    CGFloat btnHRate = 1/13.f;
    CGFloat heightTxtField = self.view.frame.size.height * txtFieldHRate;
    CGFloat heightBtn = self.view.frame.size.height * btnHRate;
    CGFloat widthPwdForgotBtn = 100;
    
    self.userTextField.layer.cornerRadius = heightTxtField * 0.5;
    self.pwdTextField.layer.cornerRadius = heightTxtField * 0.5;
    self.signInBtn.layer.cornerRadius = heightBtn * 0.5;
    
    self.userTextField.font = [UIFont systemFontOfSize:[@"xx" resizeFontAtHeight:heightTxtField scale:0.4]];
    self.pwdTextField.font = [UIFont systemFontOfSize:[@"xx" resizeFontAtHeight:heightTxtField scale:0.4]];
    self.signInBtn.titleLabel.font = [UIFont systemFontOfSize:[@"xx" resizeFontAtHeight:heightBtn scale:0.38]];
    self.signUpBtn.titleLabel.font = [UIFont systemFontOfSize:[@"xx" resizeFontAtHeight:heightBtn scale:0.38]];
    self.pwdSavingLabel.font = [UIFont systemFontOfSize:[@"xx" resizeFontAtHeight:heightTxtField scale:0.38]];
    self.pwdForgottenBtn.titleLabel.font = [UIFont systemFontOfSize:[@"xx" resizeFontAtHeight:heightTxtField scale:0.38]];
    self.pwdSavingBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[@"xx" resizeFontAtHeight:heightTxtField scale:0.5]];
    self.headLabel.font = [UIFont iconFontWithSize:[@"xx" resizeFontAtHeight:heightTxtField scale:0.5]];
    self.lockLabel.font = [UIFont iconFontWithSize:[@"xx" resizeFontAtHeight:heightTxtField scale:0.45]];
    self.visiblePwdSeenBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[@"xx" resizeFontAtHeight:heightTxtField scale:0.5]];
    
    [self.backgroundImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.top.equalTo(wself.view.mas_top);
        make.bottom.equalTo(wself.view.mas_bottom);
    }];
    
    [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.centerX.equalTo(wself.view.mas_centerX);
        make.bottom.equalTo(wself.view.mas_top).offset(wself.view.frame.size.height * 0.25);
        make.width.equalTo(wself.view.mas_width).multipliedBy(0.5);
        make.height.equalTo(wself.logoImgView.mas_width).multipliedBy(wself.logoImgView.image.size.height / wself.logoImgView.image.size.width);
    }];
    
    [self.userTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(wself.view.mas_centerY).offset(- 3);
        make.left.equalTo(wself.view.mas_left).offset(inset);
        make.right.equalTo(wself.view.mas_right).offset(-inset);
        make.height.equalTo(wself.view.mas_height).multipliedBy(txtFieldHRate);
    }];

    [self.pwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.userTextField.mas_bottom).offset(6);
        make.left.equalTo(wself.view.mas_left).offset(inset);
        make.right.equalTo(wself.view.mas_right).offset(-inset);
        make.height.equalTo(wself.view.mas_height).multipliedBy(txtFieldHRate);
    }];

    [self.headLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.userTextField.mas_left).offset(heightTxtField * 0);
        make.top.equalTo(wself.userTextField.mas_top);
        make.bottom.equalTo(wself.userTextField.mas_bottom);
        make.width.equalTo(wself.view.mas_height).multipliedBy(txtFieldHRate * 1.5);

    }];

    [self.lockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.pwdTextField.mas_left).offset(heightTxtField * 0);
        make.top.equalTo(wself.pwdTextField.mas_top);
        make.bottom.equalTo(wself.pwdTextField.mas_bottom);
        make.width.equalTo(wself.view.mas_height).multipliedBy(txtFieldHRate * 1.5);
    }];

    [self.visiblePwdSeenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wself.pwdTextField.mas_right).offset(- heightTxtField * 0.5);
        make.centerY.equalTo(wself.pwdTextField.mas_centerY);
        make.height.equalTo(wself.view.mas_height).multipliedBy(txtFieldHRate);
        make.width.equalTo(wself.visiblePwdSeenBtn.mas_height);
    }];

    [self.pwdSavingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.pwdTextField.mas_bottom).offset(0);
        make.left.equalTo(wself.pwdTextField.mas_left).offset(0);
        make.height.equalTo(wself.view.mas_height).multipliedBy(txtFieldHRate);
        make.width.equalTo(wself.pwdSavingBtn.mas_height);

    }];

    [self.pwdSavingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.pwdTextField.mas_bottom).offset(0);
        make.left.equalTo(wself.pwdSavingBtn.mas_right).offset(0);
        make.right.equalTo(wself.view.mas_centerX);
        make.height.equalTo(wself.view.mas_height).multipliedBy(txtFieldHRate);
    }];

    [self.pwdForgottenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.pwdSavingLabel.mas_top);
        make.right.equalTo(wself.pwdTextField.mas_right);
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

}






# pragma mask 5 getter

- (UIImageView *)backgroundImgView {
    if (!_backgroundImgView) {
        _backgroundImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    }
    return _backgroundImgView;
}
- (UIImageView *)logoImgView {
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc] initWithImage:[PublicInformation logoImageOfApp]];
    }
    return _logoImgView;
}

- (UILabel *)headLabel {
    if (!_headLabel) {
        _headLabel = [UILabel new];
        _headLabel.text = [NSString stringWithIconFontType:IconFontType_user];

        JLPrint(@"headLabel.text = [%@]", _headLabel.text);
        _headLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
        _headLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _headLabel;
}
- (UILabel *)lockLabel {
    if (!_lockLabel) {
        _lockLabel = [UILabel new];
        _lockLabel.text = [NSString stringWithIconFontType:IconFontType_lock];
        _lockLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
        _lockLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _lockLabel;
}

- (UITextField *)userTextField {
    if (!_userTextField) {
        _userTextField = [UITextField new];
        _userTextField.placeholder = @"请输入用户名";
        _userTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _userTextField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.7].CGColor;
        _userTextField.layer.borderWidth = 1.f;
        _userTextField.textAlignment = NSTextAlignmentCenter;
        _userTextField.textColor = [UIColor whiteColor];
        _userTextField.delegate = self.delegateForTfield;
    }
    return _userTextField;
}
- (UITextField *)pwdTextField {
    if (!_pwdTextField) {
        _pwdTextField = [UITextField new];
        _pwdTextField.placeholder = @"请输入8位密码";
        _pwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _pwdTextField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.7].CGColor;
        _pwdTextField.layer.borderWidth = 1.f;
        _pwdTextField.textAlignment = NSTextAlignmentCenter;
        _pwdTextField.textColor = [UIColor whiteColor];
        _pwdTextField.keyboardType = UIKeyboardTypeAlphabet;
        _pwdTextField.delegate = self.delegateForTfield;
        _pwdTextField.tag = SignInTxtTaguserPwd;
    }
    return _pwdTextField;
}

- (UIButton *)signInBtn {
    if (!_signInBtn) {
        _signInBtn = [UIButton new];
        _signInBtn.backgroundColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        [_signInBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_signInBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_signInBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateHighlighted];
        [_signInBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateDisabled];
        
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

- (UIButton *)visiblePwdSeenBtn {
    if (!_visiblePwdSeenBtn) {
        _visiblePwdSeenBtn = [UIButton new];
        [_visiblePwdSeenBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAEye] forState:UIControlStateNormal];
        [_visiblePwdSeenBtn setTitleColor:[UIColor colorWithWhite:0.9 alpha:1] forState:UIControlStateNormal];
        [_visiblePwdSeenBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateHighlighted];
        [_visiblePwdSeenBtn addTarget:self action:@selector(clickedPwdSeenBtn:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _visiblePwdSeenBtn;
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

- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _progressHud;
}

- (VMHttpSignIn *)signinHttp {
    if (!_signinHttp) {
        _signinHttp = [[VMHttpSignIn alloc] init];
    }
    return _signinHttp;
}

- (VMSignInInfoCache *)signInCache {
    if (!_signInCache) {
        _signInCache = [[VMSignInInfoCache alloc] init];
    }
    return _signInCache;
}

@end
