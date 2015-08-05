//
//  ChangePinViewController.m
//  JLPay
//
//  Created by jielian on 15/8/5.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "ChangePinViewController.h"
#import "PublicInformation.h"

@interface ChangePinViewController()
@property (nonatomic, strong) UITextField* userNumberField;
@property (nonatomic, strong) UITextField* userOldPwdField;
@property (nonatomic, strong) UITextField* userNewPwdField;
@property (nonatomic, strong) UIButton* sureButton;
@end


@implementation ChangePinViewController
@synthesize userNumberField = _userNumberField;
@synthesize userOldPwdField = _userOldPwdField;
@synthesize userNewPwdField = _userNewPwdField;
@synthesize sureButton = _sureButton;




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
}

#pragma mask ---- 界面声明周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // 背景图
    UIImageView* bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.image = [UIImage imageNamed:@"bg"];
    [self.view addSubview:bgImageView];

    [self.view addSubview:self.userNumberField];
    [self.view addSubview:self.userOldPwdField];
    [self.view addSubview:self.userNewPwdField];
    [self.view addSubview:self.sureButton];
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
    self.userNumberField.frame = frame;
    [self.userNumberField setLeftView:[self newLabelWithText:@"账    号:" andFrame:frame]];
    [self.userNumberField setLeftViewMode:UITextFieldViewModeAlways];
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
}

// 给textField生成的左边的描述label
- (UILabel*)newLabelWithText:(NSString*)text andFrame:(CGRect)frame {
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/4.0, frame.size.height)];
    label.text = text;
    label.textAlignment = NSTextAlignmentRight;
    label.backgroundColor = [UIColor clearColor];
    return label;
}


#pragma mask ---- 隐藏键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
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
        _userNumberField.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        _userNumberField.textColor = [UIColor whiteColor];

    }
    return _userNumberField;
}
- (UITextField *)userOldPwdField {
    if (_userOldPwdField == nil) {
        _userOldPwdField = [[UITextField alloc] initWithFrame:CGRectZero];
        _userOldPwdField.layer.cornerRadius = 8.0;
        _userOldPwdField.layer.masksToBounds = YES;
        _userOldPwdField.placeholder = @"请输入旧密码";
        _userOldPwdField.layer.borderWidth = 0.5;
        _userOldPwdField.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _userOldPwdField.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
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
        _userNewPwdField.placeholder = @"请输入新密码";
        _userNewPwdField.layer.borderWidth = 0.5;
        _userNewPwdField.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _userNewPwdField.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.7];
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
@end
