//
//  UserRegisterViewController.m
//  JLPay
//
//  Created by jielian on 15/8/6.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "UserRegisterViewController.h"
#import "ASIFormDataRequest.h"
#import "JLActivity.h"
#import "PublicInformation.h"


@interface UserRegisterViewController()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) UIScrollView* scrollView;             // 滚动视图
@property (nonatomic, strong) UITextField* userMchntField;          // 商户名称
@property (nonatomic, strong) UITextField* userNameField;           // 用户登陆名
@property (nonatomic, strong) UITextField* userPwdField;            // 用户登陆密码
@property (nonatomic, strong) UITextField* userIDField;             // 身份证号
@property (nonatomic, strong) UITextField* userPhoneField;          // 手机号
@property (nonatomic, strong) UITextField* userSpeSettleDsField;    // 开户银行
@property (nonatomic, strong) UITextField* userSettleAcctField;     // 结算账号
@property (nonatomic, strong) UITextField* userSettleNameField;     // 结算账户名
@property (nonatomic, strong) UITextField* userMailField;           // 邮箱
@property (nonatomic, strong) UITextField* userAgeName;             // 所属代理商名称(可为空)
@property (nonatomic, strong) UITextView* userAddrTextView;           // 通信地址

@property (nonatomic, strong) UIButton* btnIDForce;                 // 身份证正面照片选择按钮
@property (nonatomic, strong) UIButton* btnIDBackground;            // 身份证背面照片选择按钮
@property (nonatomic, strong) UIButton* btnIDHanding;               // 身份证手持照片选择按钮
@property (nonatomic, strong) UIButton* btnCardForce;               // 银行卡正面照选择按钮
@property (nonatomic, strong) UIButton* btnUserRegistering;         // 注册按钮

@property (nonatomic, strong) UIImageView* imgViewIDForce;          // 身份证正面照片
@property (nonatomic, strong) UIImageView* imgViewIDBackground;     // 身份证背面照
@property (nonatomic, strong) UIImageView* imgViewIDHanding;        // 手持身份证照
@property (nonatomic, strong) UIImageView* imgViewCardForce;        // 银行卡正面照

@property (nonatomic, retain) ASIFormDataRequest* httpRequest;      // HTTP访问入口
@property (nonatomic, strong) JLActivity* activitor;

@property (nonatomic, strong) UIImageView* neededLoadImageView;       // 当前需要被加载的图片视图

@property (nonatomic, assign) CGFloat offsetHeightWithKeyboardHiddenView; // 用来计算键盘遮蔽视图的差距的
@end



@implementation UserRegisterViewController
@synthesize scrollView = _scrollView;
@synthesize userMchntField = _userMchntField;
@synthesize userNameField = _userNameField;
@synthesize userPwdField = _userPwdField;
@synthesize userIDField = _userIDField;
@synthesize userPhoneField = _userPhoneField;
@synthesize userSpeSettleDsField = _userSpeSettleDsField;
@synthesize userSettleAcctField = _userSettleAcctField;
@synthesize userSettleNameField = _userSettleNameField;
@synthesize userMailField = _userMailField;
@synthesize btnIDForce = _btnIDForce;
@synthesize btnIDBackground = _btnIDBackground;
@synthesize btnIDHanding = _btnIDHanding;
@synthesize btnCardForce = _btnCardForce;
@synthesize btnUserRegistering = _btnUserRegistering;
@synthesize imgViewIDForce = _imgViewIDForce;
@synthesize imgViewIDBackground = _imgViewIDBackground;
@synthesize imgViewIDHanding = _imgViewIDHanding;
@synthesize imgViewCardForce = _imgViewCardForce;
@synthesize userAddrTextView = _userAddrTextView;
@synthesize userAgeName = _userAgeName;
@synthesize httpRequest = _httpRequest;
@synthesize activitor = _activitor;


#pragma mask ------ 按钮的点击事件
/*****************************
 * 功能: 加载图片的按钮
 *          根据按钮的名称区分不同的图片;
 *****************************/
- (IBAction) touchToLoadImageByButton:(UIButton*)sender {
    // 打开图片库，加载图片到指定的 imageView
    NSString* buttonTitle = sender.titleLabel.text;
    NSLog(@"点击了按钮:[%@]",buttonTitle);
    if ([buttonTitle isEqualToString:@"点击上传身份证正面照"]) {
        self.neededLoadImageView = self.imgViewIDForce;
    } else if ([buttonTitle isEqualToString:@"点击上传身份证背面照"]) {
        self.neededLoadImageView = self.imgViewIDBackground;

    }else if ([buttonTitle isEqualToString:@"点击上传手持身份证照"]) {
        self.neededLoadImageView = self.imgViewIDHanding;

    }else if ([buttonTitle isEqualToString:@"点击上传银行卡正面照"]) {
        self.neededLoadImageView = self.imgViewCardForce;

    }
    
    UIActionSheet* imageSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imageSheet addButtonWithTitle:@"拍照"];
        [imageSheet addButtonWithTitle:@"从相册选择"];
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        [imageSheet addButtonWithTitle:@"从相册选择"];
    }
    
    [imageSheet showInView:self.view];
}
- (IBAction) touchToRegister:(UIButton*)sender {
    // 发送http请求
}

#pragma mask ------ UIActionSheetDelegate: 点击事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    }
    
    NSUInteger imgPickerSourceType ;
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"拍照"]) {
        imgPickerSourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imgPickerSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        } else {
        }
        imgPickerSourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    
    UIImagePickerController* imgPickerController = [[UIImagePickerController alloc] init];
    [imgPickerController setDelegate:self];
    [imgPickerController setAllowsEditing:YES];
    [imgPickerController setSourceType:imgPickerSourceType];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activitor startAnimating];
    });
    [self presentViewController:imgPickerController animated:YES completion:^{
        [self.activitor stopAnimating];
    }];
}

#pragma mask ------ UIImagePickerControllerDelegate : 相册选择协议
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage* selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    if (self.neededLoadImageView != nil) {
        self.neededLoadImageView.image = selectedImage;
    }
    
}


#pragma mask ------ 键盘的处理事件:如果遮蔽就移动view
- (void) keyboardWillApear:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    CGFloat keyboardHeight = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    UIView* firstResView = nil;
    for (UIView* view in self.scrollView.subviews) {
        if ([view isFirstResponder] && ([view class] == [UITextField class] || [view class] == [UITextView class])) {
            firstResView = view;
        }
    }
    if (firstResView) {
        NSLog(@"触发键盘的view:[%@]",firstResView);
        CGFloat factOriginYInRootView = self.view.bounds.size.height - (self.scrollView.frame.origin.y + (firstResView.frame.origin.y - self.scrollView.contentOffset.y) + firstResView.frame.size.height);
        if (factOriginYInRootView - keyboardHeight < 0) {
            self.offsetHeightWithKeyboardHiddenView += keyboardHeight - factOriginYInRootView;
            CGRect frame = self.view.frame;
            frame.origin.y -= self.offsetHeightWithKeyboardHiddenView;
            self.view.frame = frame;
        }
    }
    
}
- (void) keyboardWillHidden:(NSNotification*)notification {
    if (self.offsetHeightWithKeyboardHiddenView > 0.000001) {
        CGRect frame = self.view.frame;
        frame.origin.y += self.offsetHeightWithKeyboardHiddenView;
        self.view.frame = frame;
        self.offsetHeightWithKeyboardHiddenView = 0.0;
    }
}

#pragma mask ------ 界面声明周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.userMchntField];
    [self.scrollView addSubview:self.userNameField];
    [self.scrollView addSubview:self.userPwdField];
    [self.scrollView addSubview:self.userIDField];
    [self.scrollView addSubview:self.userPhoneField];
    [self.scrollView addSubview:self.userSpeSettleDsField];
    [self.scrollView addSubview:self.userSettleAcctField];
    [self.scrollView addSubview:self.userSettleNameField];
    [self.scrollView addSubview:self.userMailField];
    [self.scrollView addSubview:self.userAddrTextView];
    [self.scrollView addSubview:self.userAgeName];
    [self.scrollView addSubview:self.btnIDForce];
    [self.scrollView addSubview:self.btnIDBackground];
    [self.scrollView addSubview:self.btnIDHanding];
    [self.scrollView addSubview:self.btnCardForce];
    [self.scrollView addSubview:self.imgViewIDForce];
    [self.scrollView addSubview:self.imgViewIDBackground];
    [self.scrollView addSubview:self.imgViewIDHanding];
    [self.scrollView addSubview:self.imgViewCardForce];
    [self.view addSubview:self.btnUserRegistering];
    
    [self.view addSubview:self.activitor];
    // 注册隐藏键盘的手势事件
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditingWithTextField)];
    [self.view addGestureRecognizer:gesture];

    self.offsetHeightWithKeyboardHiddenView = 0.0;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
    }
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    self.automaticallyAdjustsScrollViewInsets = NO;

    CGFloat inset = 10;
    CGFloat bottomInset = 30;
    CGFloat buttonHeight = 50;
    CGFloat naviAndStatusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.bounds.size.height;
    CGRect scrollFrame = CGRectMake(0,
                                    naviAndStatusHeight,
                                    self.view.bounds.size.width,
                                    self.view.bounds.size.height - naviAndStatusHeight - buttonHeight - inset - bottomInset);
    self.scrollView.frame = scrollFrame;
    // 重新布局滚动视图的子视图
    [self layoutSubviewsInScrollView];
    
    scrollFrame.origin.x += inset;
    scrollFrame.origin.y += scrollFrame.size.height + inset;
    scrollFrame.size.width -= inset*2;
    scrollFrame.size.height = buttonHeight;
    self.btnUserRegistering.frame = scrollFrame;
    
    
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 注册键盘的出现、消失事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillApear:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
// 给 scrollView 加载子视图
- (void) layoutSubviewsInScrollView {
    CGFloat verticalInset = 10.0;
    CGFloat horizontalInset = 15.0;
    CGFloat flagLabelWidth = 10;
    
    
    CGRect frame = CGRectMake(horizontalInset, verticalInset, flagLabelWidth, 30);
    
    frame = [self newFrameAfterAddTextFiled:self.userMchntField withFrame:frame andTitle:@"商户名称"];
    frame.origin.y += verticalInset;
    frame = [self newFrameAfterAddTextFiled:self.userNameField withFrame:frame andTitle:@"账号名称"];
    frame.origin.y += verticalInset;
    frame = [self newFrameAfterAddTextFiled:self.userPwdField withFrame:frame andTitle:@"登陆密码"];
    frame.origin.y += verticalInset;
    frame = [self newFrameAfterAddTextFiled:self.userIDField withFrame:frame andTitle:@"身份证号码"];
    frame.origin.y += verticalInset;
    frame = [self newFrameAfterAddTextFiled:self.userPhoneField withFrame:frame andTitle:@"手机号码"];
    frame.origin.y += verticalInset;
    frame = [self newFrameAfterAddTextFiled:self.userSpeSettleDsField withFrame:frame andTitle:@"开户银行名称"];
    frame.origin.y += verticalInset;
    frame = [self newFrameAfterAddTextFiled:self.userSettleAcctField withFrame:frame andTitle:@"结算账户号"];
    frame.origin.y += verticalInset;
    frame = [self newFrameAfterAddTextFiled:self.userSettleNameField withFrame:frame andTitle:@"结算账户名称"];
    frame.origin.y += verticalInset;
    frame = [self newFrameAfterAddTextFiled:self.userMailField withFrame:frame andTitle:@"邮箱"];
    frame.origin.y += verticalInset;
    frame = [self newFrameAfterAddTextFiled:self.userAgeName withFrame:frame andTitle:@"所属代理商用户名"];
    frame.origin.y += verticalInset;
    frame = [self newFrameAfterAddTextFiled:self.userAddrTextView withFrame:frame andTitle:@"商户通信地址"];

    frame.origin.y += verticalInset*2;
    frame = [self newFrameAfterAddButton:self.btnIDForce andImageView:self.imgViewIDForce inFrame:frame];
    frame.origin.y += verticalInset;
    frame = [self newFrameAfterAddButton:self.btnIDBackground andImageView:self.imgViewIDBackground inFrame:frame];
    frame.origin.y += verticalInset;
    frame = [self newFrameAfterAddButton:self.btnIDHanding andImageView:self.imgViewIDHanding inFrame:frame];
    frame.origin.y += verticalInset;
    frame = [self newFrameAfterAddButton:self.btnCardForce andImageView:self.imgViewCardForce inFrame:frame];

    
    CGFloat contentHeight = frame.origin.y + 10.0;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, contentHeight);
}
// 简化代码: 组合 textFiled + * + title
- (CGRect) newFrameAfterAddTextFiled:(UIView*)textField
                           withFrame:(CGRect)frame
                            andTitle:(NSString*)title
{
    CGFloat horizontalInset = 15.0;
    CGFloat flagLabelWidth = 10;
    CGFloat savedHeight = frame.size.height;
    CGFloat savedWidth = frame.size.width;

    NSString* flagText = @"*";
    UIFont* titleFont = [UIFont systemFontOfSize:15];
    CGSize fontSize = [flagText sizeWithAttributes:[NSDictionary dictionaryWithObject:titleFont forKey:NSFontAttributeName]];
    frame.size.height = fontSize.height + 4*2;
    
    // 星号
    UILabel* flagLabel = [[UILabel alloc] initWithFrame:frame];
    if (![title isEqualToString:@"所属代理商用户名"]) {
        flagLabel.text = @"*";
    }
    flagLabel.textColor = [UIColor redColor];
    [self.scrollView addSubview:flagLabel];
    // 标题
    frame.origin.x += frame.size.width;
    frame.size.width = self.scrollView.bounds.size.width - horizontalInset*2 - flagLabelWidth;
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:15];
    [self.scrollView addSubview:titleLabel];
    // 文本输入框
    frame.origin.x -= flagLabelWidth;
    frame.origin.y += frame.size.height;
    frame.size.width = self.scrollView.bounds.size.width - horizontalInset*2;
    if ([title isEqualToString:@"商户通信地址"]) {
        frame.size.height = savedHeight * 3;
    } else {
        frame.size.height = savedHeight;
    }
    textField.frame = frame;
    
    frame.origin.y += frame.size.height;
    frame.size.width = savedWidth;
    frame.size.height = savedHeight;
    return frame;
}
// 简化代码: 组合 * + 按钮 + imageView
- (CGRect) newFrameAfterAddButton:(UIButton*)button
                     andImageView:(UIImageView*)imageView
                          inFrame:(CGRect)frame
{
    CGFloat horizontalInset = 15.0;
    CGFloat verticalInset = 5.0;
    CGFloat savedHeight = frame.size.height;
    CGFloat savedWidth = frame.size.width;
    
    // 输入强制标记
    NSString* flagText = @"*";
    UIFont* titleFont = [UIFont systemFontOfSize:15];
    CGSize fontSize = [flagText sizeWithAttributes:[NSDictionary dictionaryWithObject:titleFont forKey:NSFontAttributeName]];
    frame.size.height = fontSize.height + 4*2;
    UILabel* flagLabel = [[UILabel alloc] initWithFrame:frame];
    flagLabel.text = flagText;
    flagLabel.textColor = [UIColor redColor];
    [self.scrollView addSubview:flagLabel];


    // 按钮
    frame.origin.x += frame.size.width;
    CGSize btnSize = [button.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:button.titleLabel.font forKey:NSFontAttributeName]];
    frame.size.width = btnSize.width + 5*2;
    button.frame = frame;
    
    // 图片视图
//    frame.origin.x -= savedWidth;
    frame.origin.y += frame.size.height + verticalInset;
    frame.size.width = (self.scrollView.bounds.size.width - frame.origin.x * 2)/2.0;
    frame.size.height = frame.size.width;
    imageView.frame = frame;
    
    frame.origin.x = horizontalInset;
    frame.origin.y += frame.size.height;
    frame.size.width = savedWidth;
    frame.size.height = savedHeight;
    
    return frame;
}



// 隐藏键盘的引发事件
- (void) endEditingWithTextField {
    [self.view endEditing:YES];
}

#pragma mask ------ 私有接口:

// 创建一个 UITextField
- (UITextField*) newTextFieldWithPlaceHolder:(NSString*)placeHolder {
    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.placeholder = placeHolder;
    textField.layer.cornerRadius = 5.0;
    textField.layer.masksToBounds = YES;
    textField.backgroundColor = [UIColor whiteColor];
    textField.textColor = [UIColor blueColor];
    [self setLeftViewInTextField:textField];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    return textField;
}
// 创建一个 textField 的左空白视图
- (void) setLeftViewInTextField:(UITextField*)textField {
    // 宽度为输入框预留的文本空白
    CGRect leftFrame = CGRectMake(0, 0, 5, textField.frame.size.height);
    UIView* view = [[UIView alloc] initWithFrame:leftFrame];
    view.backgroundColor = [UIColor clearColor];
    [textField setLeftView:view];
    [textField setLeftViewMode:UITextFieldViewModeAlways];
}
// 创建button:上传图片系列按钮
- (UIButton*) newButtonWithTitle:(NSString*)title {
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    button.layer.cornerRadius = 5.0;
    button.layer.masksToBounds = YES;
    [button setBackgroundColor:[UIColor colorWithRed:38.0/255.0 green:124.0/255.0 blue:231.0/255.0 alpha:1]];
    button.layer.shadowOffset = CGSizeMake(3, 3);
    
    [button addTarget:self action:@selector(touchToLoadImageByButton:) forControlEvents:UIControlEventTouchUpInside];

    return button;
}
// 先创建一个空的 UIImageView ,图片在后面加载


#pragma mask ------ setter && getter
- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        [_scrollView setCanCancelContentTouches:NO];
    }
    return _scrollView;
}
- (UITextField *) userMchntField {
    if (_userMchntField == nil) {
        _userMchntField = [self newTextFieldWithPlaceHolder:@"不超过40位字符"];
    }
    return _userMchntField;
}
- (UITextField *)userNameField {
    if (_userNameField == nil) {
        _userNameField = [self newTextFieldWithPlaceHolder:@"不超过40位字母或数字字符"];
    }
    return _userNameField;
}
- (UITextField *)userPwdField {
    if (_userPwdField == nil) {
        _userPwdField = [self newTextFieldWithPlaceHolder:@"请输入8位字母或数字密码"];
        _userPwdField.secureTextEntry = YES;
    }
    return _userPwdField;
}
- (UITextField *)userIDField {
    if (_userIDField == nil) {
        _userIDField = [self newTextFieldWithPlaceHolder:@"请输入15位或18位身份证号"];
    }
    return _userIDField;
}
- (UITextField *)userPhoneField {
    if (_userPhoneField == nil) {
        _userPhoneField = [self newTextFieldWithPlaceHolder:@"请输入手机号码"];
    }
    return _userPhoneField;
}
- (UITextField *)userSpeSettleDsField {
    if (_userSpeSettleDsField == nil) {
        _userSpeSettleDsField = [self newTextFieldWithPlaceHolder:@"请输入开户银行名称(不超过40位)"];
    }
    return _userSpeSettleDsField;
}
- (UITextField *)userSettleAcctField {
    if (_userSettleAcctField == nil) {
        _userSettleAcctField = [self newTextFieldWithPlaceHolder:@"请输入您的结算账户号码"];
    }
    return _userSettleAcctField;
}
- (UITextField *)userSettleNameField {
    if (_userSettleNameField == nil) {
        _userSettleNameField = [self newTextFieldWithPlaceHolder:@"请输入您的结算账户名称(不超过40位)"];
    }
    return _userSettleNameField;
}
- (UITextField *)userMailField {
    if (_userMailField == nil) {
        _userMailField = [self newTextFieldWithPlaceHolder:@"请输入您的邮箱"];
    }
    return _userMailField;
}
- (UITextView *)userAddrTextView {
    if (_userAddrTextView == nil) {
        _userAddrTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        _userAddrTextView.font = [UIFont systemFontOfSize:15];
        _userAddrTextView.layer.cornerRadius = 5.0;
        _userAddrTextView.layer.masksToBounds = YES;
        
    }
    return _userAddrTextView;
}
- (UITextField *)userAgeName {
    if (_userAgeName == nil) {
        _userAgeName = [self newTextFieldWithPlaceHolder:@"不超过20位\"用户名\"(可为空)"];
    }
    return _userAgeName;
}

- (UIButton *)btnIDForce {
    if (_btnIDForce == nil) {
        _btnIDForce = [self newButtonWithTitle:@"点击上传身份证正面照"];
    }
    return _btnIDForce;
}
- (UIButton *)btnIDBackground {
    if (_btnIDBackground == nil) {
        _btnIDBackground = [self newButtonWithTitle:@"点击上传身份证背面照"];
    }
    return _btnIDBackground;
}
- (UIButton *)btnIDHanding {
    if (_btnIDHanding == nil) {
        _btnIDHanding = [self newButtonWithTitle:@"点击上传手持身份证照"];
    }
    return _btnIDHanding;
}
- (UIButton *)btnCardForce {
    if (_btnCardForce == nil) {
        _btnCardForce = [self newButtonWithTitle:@"点击上传银行卡正面照"];
    }
    return _btnCardForce;
}
- (UIButton *)btnUserRegistering {
    if (_btnUserRegistering == nil) {
        _btnUserRegistering = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnUserRegistering setTitle:@"开始注册" forState:UIControlStateNormal];
        [_btnUserRegistering setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnUserRegistering setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        _btnUserRegistering.layer.cornerRadius = 8.0;
        _btnUserRegistering.layer.masksToBounds = YES;
        [_btnUserRegistering setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        _btnUserRegistering.layer.shadowOffset = CGSizeMake(-3, -3);
        _btnUserRegistering.layer.shadowColor = [UIColor grayColor].CGColor;
        [_btnUserRegistering addTarget:self action:@selector(touchToRegister:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnUserRegistering;
}
- (UIImageView *)imgViewIDForce {
    if (_imgViewIDForce == nil) {
        _imgViewIDForce = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imgViewIDForce.backgroundColor = [UIColor whiteColor];
    }
    return _imgViewIDForce;
}
- (UIImageView *)imgViewIDBackground {
    if (_imgViewIDBackground == nil) {
        _imgViewIDBackground = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imgViewIDBackground.backgroundColor = [UIColor whiteColor];

    }
    return _imgViewIDBackground;
}
- (UIImageView *)imgViewIDHanding {
    if (_imgViewIDHanding == nil) {
        _imgViewIDHanding = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imgViewIDHanding.backgroundColor = [UIColor whiteColor];

    }
    return _imgViewIDHanding;
}
- (UIImageView *)imgViewCardForce {
    if (_imgViewCardForce == nil) {
        _imgViewCardForce = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imgViewCardForce.backgroundColor = [UIColor whiteColor];

    }
    return _imgViewCardForce;
}
- (ASIFormDataRequest *)httpRequest {
    if (_httpRequest == nil) {
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/jlagent/MchntRegister", [PublicInformation getDataSourceIP],[PublicInformation getDataSourcePort]]];
        _httpRequest = [ASIFormDataRequest requestWithURL:url];
        [_httpRequest setDelegate:self];
    }
    return _httpRequest;
}
- (JLActivity *)activitor {
    if (_activitor == nil) {
        _activitor = [[JLActivity alloc] init];
    }
    return _activitor;
}

@end
