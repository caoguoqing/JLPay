//
//  JLSignInViewController.h
//  CustomViewMaker
//
//  Created by 冯金龙 on 16/5/31.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa.h>
#import "Masonry.h"
#import "Define_Header.h"
#import "DelegateForTextFieldControl.h"
#import "VMHttpSignIn.h"
#import "MBProgressHUD+CustomSate.h"
#import "ModelDeviceBindedInformation.h"
#import "ChangePinViewController.h"
#import "VMSignInInfoCache.h"
#import "ForgetPinViewConroller.h"
#import "ModelAppInformation.h"
#import "UserRegisterViewController.h"
#import "SignUpBtn.h"


typedef enum {
    SignInVCAlertTagLowAppVersion = 9
}SignInVCAlertTag;


@interface JLSignInViewController : UIViewController
<UIAlertViewDelegate>

@property (nonatomic, assign) BOOL seenVisible;
@property (nonatomic, assign) BOOL savedEnable;


@property (nonatomic, strong) UIImageView* backgroundImgView;   // 背景

@property (nonatomic, strong) UIImageView* logoImgView;         // logo

@property (nonatomic, strong) UILabel* headLabel;               // 头像
@property (nonatomic, strong) UILabel* lockLabel;               // 密码锁
@property (nonatomic, strong) UITextField* userTextField;       // 用户名
@property (nonatomic, strong) UITextField* pwdTextField;        // 密码

@property (nonatomic, strong) UIButton* pwdForgottenBtn;        // 忘记密码
@property (nonatomic, strong) UIButton* pwdSavingBtn;           // 保存密码-按钮
@property (nonatomic, strong) UILabel* pwdSavingLabel;          // 保存密码-标签

@property (nonatomic, strong) UIButton* visiblePwdSeenBtn;      // 密码可见

@property (nonatomic, strong) UIButton* signInBtn;              // 登录
@property (nonatomic, strong) SignUpBtn* signUpBtn;              // 注册

@property (nonatomic, strong) UIView* separateViewLeft;         // 分割线-left
@property (nonatomic, strong) UIView* separateViewRight;        // 分割线-right

@property (nonatomic, strong) MBProgressHUD* progressHud;       // 指示器

@property (nonatomic, strong) VMHttpSignIn* signinHttp;         // 登录http请求
@property (nonatomic, strong) VMSignInInfoCache* signInCache;   // 登陆保存信息的缓存

/* 控制密码输入和键盘遮挡处理 */
@property (nonatomic, strong) DelegateForTextFieldControl* delegateForTfield;

@end
