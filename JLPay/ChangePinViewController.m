//
//  ChangePinViewController.m
//  JLPay
//
//  Created by jielian on 15/8/5.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "ChangePinViewController.h"
#import "PublicInformation.h"
#import "asi-http/ASIFormDataRequest.h"
#import "JLActivity.h"
#import "EncodeString.h"
#import "ThreeDesUtil.h"
#import "Define_Header.h"

@interface ChangePinViewController()<ASIHTTPRequestDelegate>
@property (nonatomic, strong) UILabel* userNumberLabel;
@property (nonatomic, strong) UITextField* userOldPwdField;
@property (nonatomic, strong) UITextField* userNewPwdField;
@property (nonatomic, strong) UIButton* sureButton;
@property (nonatomic, strong) JLActivity* activitor;
@property (nonatomic, strong) ASIFormDataRequest* httpRequest;
@end


@implementation ChangePinViewController
@synthesize userOldPwdField = _userOldPwdField;
@synthesize userNewPwdField = _userNewPwdField;
@synthesize sureButton = _sureButton;
@synthesize activitor = _activitor;
@synthesize httpRequest = _httpRequest;
@synthesize userNumberLabel = _userNumberLabel;

/******************************
 * 函  数: requestForChangingPin
 * 功  能: 发送修改密码请求
 *         1.HTTP协议
 * 返  回:
 ******************************/
- (void) requestForChangingPin {
    [self.httpRequest addPostValue:[[NSUserDefaults standardUserDefaults] valueForKey:UserID] forKey:@"userName"];
    [self.httpRequest addPostValue:[self encryptBy3DESForPin:self.userOldPwdField.text] forKey:@"oldPassword"];
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

    [self.view addSubview:self.userNumberLabel];
    [self.view addSubview:self.userOldPwdField];
    [self.view addSubview:self.userNewPwdField];
    [self.view addSubview:self.sureButton];
    [self.view addSubview:self.activitor];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    [self.userNumberLabel setFrame:frame];
    // 旧密码
    frame.origin.y += frame.size.height + verticalInset;
    self.userOldPwdField.frame = frame;
    [self.userOldPwdField setLeftView:[self newLabelWithText:@"旧密码:" andFrame:frame]];
    [self.userOldPwdField setLeftViewMode:UITextFieldViewModeAlways];
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
    label.textColor = [UIColor whiteColor];
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
    if ([self.userOldPwdField.text length] == 0) {
        [self alertViewWithMessage:@"旧密码不能为空"];
        valid = NO;
    } else if ([self.userNewPwdField.text length] == 0) {
        [self alertViewWithMessage:@"新密码不能为空"];
        valid = NO;
    } else if ([self.userOldPwdField.text isEqualToString:self.userNewPwdField.text]) {
        [self alertViewWithMessage:@"新密码不能跟旧密码一样"];
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

#pragma mask ---- getter & setter
- (UILabel *)userNumberLabel {
    if (_userNumberLabel == nil) {
        _userNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _userNumberLabel.layer.cornerRadius = 8.0;
        _userNumberLabel.layer.masksToBounds = YES;

        _userNumberLabel.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1];
        _userNumberLabel.textColor = [UIColor whiteColor];
        
        _userNumberLabel.text = [NSString stringWithFormat:@"  账    号: %@",[[NSUserDefaults standardUserDefaults] valueForKey:UserID]];
        _userNumberLabel.textAlignment = NSTextAlignmentLeft;
        
    }
    return _userNumberLabel;
}
- (UITextField *)userOldPwdField {
    if (_userOldPwdField == nil) {
        _userOldPwdField = [[UITextField alloc] initWithFrame:CGRectZero];
        _userOldPwdField.layer.cornerRadius = 8.0;
        _userOldPwdField.layer.masksToBounds = YES;
        _userOldPwdField.placeholder = @"请输入8位旧密码";
        _userOldPwdField.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1];
        _userOldPwdField.secureTextEntry = YES;
        _userOldPwdField.textColor = [UIColor whiteColor];
    }
    return _userOldPwdField;
}
- (UITextField *)userNewPwdField {
    if (_userNewPwdField == nil) {
        _userNewPwdField = [[UITextField alloc] initWithFrame:CGRectZero];
        _userNewPwdField.layer.cornerRadius = 8.0;
        _userNewPwdField.layer.masksToBounds = YES;
        _userNewPwdField.placeholder = @"请输入8位新密码";
        _userNewPwdField.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1];
        _userNewPwdField.secureTextEntry = YES;
        _userNewPwdField.textColor = [UIColor whiteColor];

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
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/ModifyPassword",[PublicInformation getDataSourceIP],[PublicInformation getDataSourcePort]];
        NSURL* url = [NSURL URLWithString:urlString];
        _httpRequest = [ASIFormDataRequest requestWithURL:url];
        [_httpRequest setDelegate:self];
    }
    return _httpRequest;
}
@end
