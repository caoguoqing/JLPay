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

@property (nonatomic, strong) JLPWDKeyBoardView* keyboardView;

@property (nonatomic, strong) UIView* bgView;

@property (nonatomic, copy) void (^ sureBlock) (NSString* password);

@property (nonatomic, copy) void (^ cancelBlock) (void);

@end

@implementation JLPasswordView

+ (void)showWithDoneClicked:(void (^)(NSString *))doneBlock orCancelClicked:(void (^)(void))cancelBlock {
    JLPasswordView* pwdView = [JLPasswordView sharedPWDView];
    pwdView.sureBlock = doneBlock;
    pwdView.cancelBlock = cancelBlock;
    pwdView.keyboardView.numbersInputed = nil;
    
    UIWindow* curKeyWindow = [UIApplication sharedApplication].keyWindow;
    [curKeyWindow addSubview:pwdView];
    [curKeyWindow bringSubviewToFront:pwdView];
    
    [pwdView setNeedsUpdateConstraints];
    [pwdView updateConstraintsIfNeeded];
    [pwdView layoutIfNeeded];
    
    [pwdView.keyboardView setNeedsUpdateConstraints];
    [pwdView.keyboardView updateConstraintsIfNeeded];
    [pwdView.keyboardView layoutIfNeeded];
    
    [pwdView.inputsView setNeedsUpdateConstraints];
    [pwdView.inputsView updateConstraintsIfNeeded];
    [pwdView.inputsView layoutIfNeeded];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        pwdView.bgView.alpha = 0.3;
        
        CGRect frame = pwdView.keyboardView.frame;
        frame.origin.y -= frame.size.height;
        pwdView.keyboardView.frame = frame;
        
        pwdView.inputsView.center = CGPointMake(pwdView.center.x, pwdView.center.y - pwdView.inputsView.frame.size.height * 0.5);
        
    } completion:^(BOOL finished) {
    }];

}


+ (void)hidden {
    JLPasswordView* pwdView = [JLPasswordView sharedPWDView];
    
    [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        pwdView.inputsView.center = CGPointMake(pwdView.center.x, 0 - pwdView.inputsView.frame.size.height * 0.5);

        CGRect frame = pwdView.keyboardView.frame;
        frame.origin.y += frame.size.height;
        pwdView.keyboardView.frame = frame;

        pwdView.bgView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [pwdView removeFromSuperview];
    }];
    
}




+ (instancetype) sharedPWDView {
    static JLPasswordView* shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[JLPasswordView alloc] initWithFrame:[UIScreen mainScreen].bounds];
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
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubviews];
        [self addKVOs];
        
    }
    return self;
}


- (void) loadSubviews {
    [self addSubview:self.bgView];
    [self addSubview:self.inputsView];
    [self addSubview:self.keyboardView];
}


- (void)updateConstraints {
    
    CGFloat inset = 30;
    CGFloat heightKeyboard = 216;
    CGFloat heightInputsView = [UIScreen mainScreen].bounds.size.height * 180.f/667.f;

    __weak typeof(self) wself = self;
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self.inputsView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wself.mas_left).offset(inset);
        make.right.mas_equalTo(wself.mas_right).offset(-inset);
        make.bottom.mas_equalTo(wself.mas_top).offset(- heightInputsView);
        make.height.mas_equalTo(heightInputsView);
    }];
    
    [self.keyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(wself.mas_bottom);
        make.height.mas_equalTo(heightKeyboard);
    }];
    
    [super updateConstraints];
}




# pragma mask 4 getter

- (JLPWDInputsView *)inputsView {
    if (!_inputsView) {
        _inputsView = [[JLPWDInputsView alloc] initWithFrame:CGRectZero];
        _inputsView.layer.cornerRadius = 10;
        [_inputsView.sureBtn addTarget:self action:@selector(clickedSureBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_inputsView.cancelBtn addTarget:self action:@selector(clickedCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
        _inputsView.titleLabel.text = @"请输入支付密码";
        
    }
    return _inputsView;
}

- (JLPWDKeyBoardView *)keyboardView {
    if (!_keyboardView) {
        _keyboardView = [[JLPWDKeyBoardView alloc] initWithFrame:CGRectZero];
    }
    return _keyboardView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0;
    }
    return _bgView;
}


@end
