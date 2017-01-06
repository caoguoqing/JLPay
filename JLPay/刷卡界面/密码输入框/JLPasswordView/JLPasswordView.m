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
#import "Define_Header.h"


@interface JLPasswordView ()

@property (nonatomic, strong) JLPWDInputsView* inputsView;

@property (nonatomic, strong) JLPWDKeyBoardView* keyboardView;

@property (nonatomic, strong) UIView* bgView;
@property (nonatomic, strong) UIView* bearView;

@property (nonatomic, copy) void (^ sureBlock) (NSString* password);

@property (nonatomic, copy) void (^ cancelBlock) (void);

@end



@implementation JLPasswordView

+ (void)showWithDoneClicked:(void (^)(NSString *))doneBlock orCancelClicked:(void (^)(void))cancelBlock {
    JLPasswordView* pwdView = [JLPasswordView sharedPWDView];
    pwdView.sureBlock = doneBlock;
    pwdView.cancelBlock = cancelBlock;
    pwdView.keyboardView.numbersInputed = nil;
    
    [pwdView showAnimation];

}


+ (void)hidden {
    
    [[JLPasswordView sharedPWDView] hideAnimation];
    
}


- (void) loadAllViews {
    UIWindow* curKeyWindow = [UIApplication sharedApplication].keyWindow;
    [curKeyWindow addSubview:self.bgView];
    [curKeyWindow addSubview:self.bearView];
    [self.bearView addSubview:self.inputsView];
    [self.bearView addSubview:self.keyboardView];
}

- (void) removeAllViews {
    [self.keyboardView removeFromSuperview];
    [self.inputsView removeFromSuperview];
    [self.bearView removeFromSuperview];
    [self.bgView removeFromSuperview];
}

- (void) showAnimation {
    NameWeakSelf(wself);
    [self loadAllViews];
    [self initialFrames];
    
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.bgView.alpha = 0.3;
        
        CGRect frame = wself.keyboardView.frame;
        CGFloat height = wself.frame.size.height;
        CGFloat heightKeyboard = frame.size.height;
        CGFloat heightInputsView = wself.inputsView.frame.size.height;
        
        frame.origin.y = height - frame.size.height;
        wself.keyboardView.frame = frame;
        
        frame = wself.inputsView.frame;
        frame.origin.y = (height - heightKeyboard - heightInputsView)/2.f;
        wself.inputsView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void) hideAnimation {
    NameWeakSelf(wself);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.bgView.alpha = 0;
        
        CGRect frame = wself.keyboardView.frame;
        frame.origin.y = wself.frame.size.height;
        wself.keyboardView.frame = frame;
        
        frame = wself.inputsView.frame;
        frame.origin.y = - frame.size.height;
        wself.inputsView.frame = frame;
    } completion:^(BOOL finished) {
        [wself removeAllViews];
    }];
}
+ (void) hiddenOnFinished:(void (^) (void))finishedBlock {
    JLPasswordView* pwdView = [JLPasswordView sharedPWDView];
    
    [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        pwdView.inputsView.center = CGPointMake(pwdView.center.x, 0 - pwdView.inputsView.frame.size.height * 0.5);
        
        CGRect frame = pwdView.keyboardView.frame;
        frame.origin.y += frame.size.height;
        pwdView.keyboardView.frame = frame;
        
        pwdView.bgView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [pwdView removeFromSuperview];
        finishedBlock();
    }];
}



- (void) initialFrames {
    CGFloat inset = 30;
    CGFloat heightKeyboard = 216;
    CGFloat heightInputsView = [UIScreen mainScreen].bounds.size.height * 180.f/667.f;
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    self.bgView.frame = frame;
    self.bearView.frame = frame;
    
    frame.origin.y = frame.size.height;
    frame.size.height = heightKeyboard;
    self.keyboardView.frame = frame;
    
    frame.origin.x = inset;
    frame.size.width -= inset * 2;
    frame.origin.y = - heightInputsView;
    frame.size.height = heightInputsView;
    self.inputsView.frame = frame;
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
//    [JLPasswordView hidden];
    NameWeakSelf(wself);
    [JLPasswordView hiddenOnFinished:^{
        if (wself.sureBlock) {
            wself.sureBlock(wself.keyboardView.numbersInputed);
        }
    }];
}

- (IBAction) clickedCancelBtn:(id)sender {
//    [JLPasswordView hidden];
    NameWeakSelf(wself);

    [JLPasswordView hiddenOnFinished:^{
        if (wself.cancelBlock) {
            wself.cancelBlock();
        }
    }];
}

# pragma mask 3 界面布局
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addKVOs];
        
    }
    return self;
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
- (UIView *)bearView {
    if (!_bearView) {
        _bearView = [[UIView alloc] init];
    }
    return _bearView;
}


@end
