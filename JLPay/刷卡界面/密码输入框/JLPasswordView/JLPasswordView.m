//
//  JLPasswordView.m
//  TestForJLPasswordView
//
//  Created by jielian on 16/8/15.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "JLPasswordView.h"
#import "JLPWDInputsView.h"
#import "JLPWDKeyBoardView.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>


@interface JLPasswordView ()

@property (nonatomic, strong) JLPWDInputsView* inputsView;

@property (nonatomic, strong) UIWindow* superWindow;

@property (nonatomic, weak) UIWindow* lastKeyWindow;

@property (nonatomic, strong) JLPWDKeyBoardView* keyboardView;

@property (nonatomic, copy) void (^ sureBlock) (NSString* password);

@property (nonatomic, copy) void (^ cancelBlock) (void);

@end

@implementation JLPasswordView



+ (void)showAfterClickedSure:(void (^)(NSString *))sureBlock orCancel:(void (^)(void))cancelBlock {
    JLPasswordView* pwdView = [JLPasswordView sharedPWDView];
    pwdView.sureBlock = sureBlock;
    pwdView.cancelBlock = cancelBlock;
    
    pwdView.lastKeyWindow = [[[UIApplication sharedApplication] delegate] window];
    pwdView.superWindow.rootViewController = pwdView;
    
    [pwdView.superWindow makeKeyAndVisible];
    pwdView.superWindow.frame = [UIScreen mainScreen].bounds;
    
    pwdView.keyboardView.numbersInputed = nil;
    
    pwdView.view.transform = CGAffineTransformMakeScale(0, 0);
    [UIView animateWithDuration:0.2 animations:^{
        pwdView.view.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

+ (void)hidden {
    JLPasswordView* pwdView = [JLPasswordView sharedPWDView];
    
    pwdView.view.transform = CGAffineTransformMakeScale(1, 1);

    [UIView animateWithDuration:0.2 animations:^{
        pwdView.view.transform = CGAffineTransformMakeScale(0, 0);
        pwdView.superWindow.alpha = 0;
    } completion:^(BOOL finished) {
        pwdView.superWindow.rootViewController = nil;
        pwdView.superWindow = nil;
        pwdView.view.transform = CGAffineTransformMakeScale(1, 1);
    }];
}




+ (instancetype) sharedPWDView {
    static JLPasswordView* shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[JLPasswordView alloc] init];
    });
    return shared;
}


# pragma mask 1 KVO
- (void) addKVOs {
    RAC(self.inputsView, pinInputs) = RACObserve(self.keyboardView, numbersInputed);
}


# pragma mask 2 IBAction

- (IBAction) clickedSureBtn:(id)sender {
    [JLPasswordView hidden];
    if (self.sureBlock) {
        self.sureBlock(self.keyboardView.numbersInputed);
    }
}

- (IBAction) clickedCancelBtn:(id)sender {
    [JLPasswordView hidden];
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

# pragma mask 3 界面布局
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self loadSubviews];
    [self layoutSubviews];
    [self addKVOs];
}

- (void) loadSubviews {
    [self.view addSubview:self.inputsView];
    [self.view addSubview:self.keyboardView];
}

- (void) layoutSubviews {
    CGFloat inset = 30;
    CGFloat heightKeyboard = 216;
    
    __weak JLPasswordView* wself = self;
    [self.inputsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(wself.view.mas_centerY);
        make.left.equalTo(wself.view.mas_left).offset(inset);
        make.right.equalTo(wself.view.mas_right).offset(- inset);
        make.height.equalTo(wself.view.mas_height).multipliedBy(180.f/667.f);
    }];
    
    [self.keyboardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(wself.view.mas_bottom);
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.height.mas_equalTo(heightKeyboard);
    }];
    
}




# pragma mask 4 getter

- (JLPWDInputsView *)inputsView {
    if (!_inputsView) {
        _inputsView = [[JLPWDInputsView alloc] initWithFrame:CGRectZero];
        _inputsView.layer.cornerRadius = 10;
        [_inputsView.sureBtn addTarget:self action:@selector(clickedSureBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_inputsView.cancelBtn addTarget:self action:@selector(clickedCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
        _inputsView.titleLabel.text = @"请输入消费密码";
    }
    return _inputsView;
}

- (JLPWDKeyBoardView *)keyboardView {
    if (!_keyboardView) {
        _keyboardView = [[JLPWDKeyBoardView alloc] initWithFrame:CGRectZero];
    }
    return _keyboardView;
}

- (UIWindow *)superWindow {
    if (!_superWindow) {
        _superWindow = [[UIWindow alloc] init];
        _superWindow.windowLevel = UIWindowLevelAlert;
        _superWindow.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.3];
    }
    return _superWindow;
}

@end
