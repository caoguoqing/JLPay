//
//  ForgetPinViewConroller.m
//  JLPay
//
//  Created by jielian on 15/8/6.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "ForgetPinViewConroller.h"
#import "PublicInformation.h"
#import "asi-http/ASIFormDataRequest.h"
#import "JLActivity.h"
#import "EncodeString.h"
#import "ThreeDesUtil.h"

@interface ForgetPinViewConroller()<ASIHTTPRequestDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) UITextField* userNumberField;
@property (nonatomic, strong) UITextField* userIDField;
@property (nonatomic, strong) UITextField* userNewPwdField;
@property (nonatomic, strong) UIButton* sureButton;
@property (nonatomic, strong) JLActivity* activitor;
@property (nonatomic, strong) ASIFormDataRequest* httpRequest;

@end

@implementation ForgetPinViewConroller
@synthesize userNumberField = _userNumberField;
@synthesize userIDField = _userIDField;
@synthesize userNewPwdField = _userNewPwdField;
@synthesize sureButton = _sureButton;
@synthesize activitor = _activitor;
@synthesize httpRequest = _httpRequest;

/******************************
 * 函  数: requestForChangingPin
 * 功  能: 发送修改密码请求
 *         1.HTTP协议
 * 返  回:
 ******************************/
- (void) requestForChangingPin {
    [self.httpRequest addPostValue:self.userNumberField.text forKey:@"userName"];
    [self.httpRequest addPostValue:self.userIDField.text forKey:@"identityNo"];
    [self.httpRequest addPostValue:[self encryptBy3DESForPin:self.userNewPwdField.text] forKey:@"newPassword"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.httpRequest startAsynchronous];
        [self.activitor startAnimating];
    });
}

- (NSString*) encryptBy3DESForPin:(NSString*)pin {
    NSString* keyStr    = @"123456789012345678901234567890123456789012345678";
    NSString* sourceStr = [EncodeString encodeASC:pin] ;
    // 开始加密
    NSString* newPin = [ThreeDesUtil encryptUse3DES:sourceStr key:keyStr];
    return newPin;
}
#pragma mask --- ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activitor stopAnimating];
    });
    NSData* data = [self.httpRequest responseData];
    [self.httpRequest clearDelegatesAndCancel];
    NSDictionary* dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([[dataDict valueForKey:@"code"] intValue] == 0) {
        [self alertViewWithMessage:@"修改密码成功!"];
    } else {
        [self alertViewWithMessage:[NSString stringWithFormat:@"修改密码失败:%@",[dataDict valueForKey:@"message"]]];
    }
    self.httpRequest = nil;
}
- (void)requestFailed:(ASIHTTPRequest *)request {
    [self.httpRequest clearDelegatesAndCancel];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activitor stopAnimating];
        [self alertViewWithMessage:@"网络异常,请检查网络"];
    });
    self.httpRequest = nil;
}



#pragma mask ---- “修改”按钮的点击事件
- (IBAction) touchDown:(UIButton*)sender {
    [UIView animateWithDuration:0.2 animations:^{
        sender.transform = CGAffineTransformMakeScale(0.95, 0.95);
    }];
}
- (IBAction) touchUpOutSide:(UIButton*)sender {
    [UIView animateWithDuration:0.2 animations:^{
        sender.transform = CGAffineTransformIdentity;
    }];
    
}
- (IBAction) touchToChangePin:(UIButton*)sender {
    [UIView animateWithDuration:0.2 animations:^{
        sender.transform = CGAffineTransformIdentity;
    }];
    
    // 上送修改密码请求
    if ([self checkInPut]) {
        [self requestForChangingPin];
    }
}

#pragma mask ---- 界面声明周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // 背景图
    UIImageView* bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.image = [UIImage imageNamed:@"bg"];
//    [self.view addSubview:bgImageView];
    
    [self.view addSubview:self.userNumberField];
    [self.view addSubview:self.userIDField];
    [self.view addSubview:self.userNewPwdField];
    [self.view addSubview:self.sureButton];
    [self.view addSubview:self.activitor];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
    }
    
    CGFloat naviAndStatusHeight = self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.bounds.size.height;
    CGFloat verticalInset = 15;
    CGFloat horizontalInset = 20;
    CGFloat viewHeight = 50;
    
    CGRect frame = CGRectMake(horizontalInset,
                              naviAndStatusHeight + viewHeight*2,
                              self.view.bounds.size.width - horizontalInset*2.0,
                              viewHeight);
    // 账号
    self.userNumberField.frame = frame;
    [self.userNumberField setLeftView:[self newLabelWithText:@"账   号:" andFrame:frame]];
    [self.userNumberField setLeftViewMode:UITextFieldViewModeAlways];
    // 旧密码
    frame.origin.y += frame.size.height + verticalInset;
    self.userIDField.frame = frame;
    [self.userIDField setLeftView:[self newLabelWithText:@"身份证:" andFrame:frame]];
    [self.userIDField setLeftViewMode:UITextFieldViewModeAlways];
    // 新密码
    frame.origin.y += frame.size.height + verticalInset;
    self.userNewPwdField.frame = frame;
    [self.userNewPwdField setLeftView:[self newLabelWithText:@"新密码:" andFrame:frame]];
    [self.userNewPwdField setLeftViewMode:UITextFieldViewModeAlways];
    // 修改按钮
    frame.origin.y = self.view.bounds.size.height - tabBarHeight - viewHeight*2.0;
    self.sureButton.frame = frame;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.httpRequest clearDelegatesAndCancel];
}

// 给textField生成的左边的描述label
- (UILabel*)newLabelWithText:(NSString*)text andFrame:(CGRect)frame {
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/4.0, frame.size.height)];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    return label;
}


#pragma mask ---- 隐藏键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

/******************************
 * 函  数: checkInPut
 * 功  能: 检查输入是否有效
 *         1.是否输入为空
 *         2.新旧密码是否不一致
 * 返  回:
 *         (BOOL) 校验通过返回YES,否则返回NO;
 ******************************/
- (BOOL) checkInPut {
    BOOL valid = YES;
    if ([self.userNumberField.text length] == 0) {
        [self alertViewWithMessage:@"账号不能为空"];
        valid = NO;
    } else if ([self.userIDField.text length] == 0) {
        [self alertViewWithMessage:@"身份证号码不能为空"];
        valid = NO;
    } else if ([self.userNewPwdField.text length] == 0) {
        [self alertViewWithMessage:@"新密码不能为空"];
        valid = NO;
    } else if (self.userNewPwdField.text.length > 8) {
        [self alertViewWithMessage:@"密码长度不能大于8位"];
        valid = NO;
    }
    return valid;
}

- (void) alertViewWithMessage:(NSString*)msg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0 && [alertView.message isEqualToString:@"修改密码成功!"]) {
        // 密码修改成功:跳转出界面
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mask ---- getter & setter
- (UITextField *)userNumberField {
    if (_userNumberField == nil) {
        _userNumberField = [[UITextField alloc] initWithFrame:CGRectZero];
        _userNumberField.layer.cornerRadius = 8.0;
        _userNumberField.layer.masksToBounds = YES;
        _userNumberField.placeholder = @"请输入账号";
        _userNumberField.layer.borderWidth = 0.5;
        _userNumberField.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _userNumberField.backgroundColor = [UIColor colorWithRed:160.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1];
        _userNumberField.textColor = [UIColor whiteColor];
        _userNumberField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _userNumberField;
}
- (UITextField *)userIDField {
    if (_userIDField == nil) {
        _userIDField = [[UITextField alloc] initWithFrame:CGRectZero];
        _userIDField.layer.cornerRadius = 8.0;
        _userIDField.layer.masksToBounds = YES;
        _userIDField.placeholder = @"请输入身份证号码";
        _userIDField.layer.borderWidth = 0.5;
        _userIDField.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _userIDField.backgroundColor = [UIColor colorWithRed:160.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1];
        _userIDField.textColor = [UIColor whiteColor];
        _userIDField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _userIDField;
}
- (UITextField *)userNewPwdField {
    if (_userNewPwdField == nil) {
        _userNewPwdField = [[UITextField alloc] initWithFrame:CGRectZero];
        _userNewPwdField.layer.cornerRadius = 8.0;
        _userNewPwdField.layer.masksToBounds = YES;
        _userNewPwdField.placeholder = @"请输入8位新密码";
        _userNewPwdField.layer.borderWidth = 0.5;
        _userNewPwdField.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _userNewPwdField.backgroundColor = [UIColor colorWithRed:160.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1];
        _userNewPwdField.secureTextEntry = YES;
        _userNewPwdField.textColor = [UIColor whiteColor];
        _userNewPwdField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _userNewPwdField;
}
- (UIButton *)sureButton {
    if (_sureButton == nil) {
        _sureButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_sureButton setTitle:@"修改密码" forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        _sureButton.layer.cornerRadius = 8.0;
        _sureButton.layer.masksToBounds = YES;
        
        [_sureButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_sureButton addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_sureButton addTarget:self action:@selector(touchToChangePin:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}
- (JLActivity *)activitor {
    if (_activitor == nil) {
        _activitor = [[JLActivity alloc] init];
    }
    return _activitor;
}
- (ASIFormDataRequest *)httpRequest {
    if (_httpRequest == nil) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/ForgetPassword",[PublicInformation getDataSourceIP],[PublicInformation getDataSourcePort]];
        NSURL* url = [NSURL URLWithString:urlString];
        _httpRequest = [ASIFormDataRequest requestWithURL:url];
        [_httpRequest setDelegate:self];
    }
    return _httpRequest;
}

@end
