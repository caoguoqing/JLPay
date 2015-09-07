//
//  CustomIOSAlertView.m
//  CustomIOSAlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013-2015 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import "CustomIOSAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "Define_Header.h"
#import "LVKeyboardView.h"
#import "passwordView.h"

const static CGFloat kCustomIOSAlertViewDefaultButtonHeight       = 40;     // 按钮高度
const static CGFloat kCustomIOSAlertViewDefaultButtonSpacerHeight = 1;      // 分割线高度
const static CGFloat kCustomIOSAlertViewCornerRadius              = 7;      // 圆角半径
const static CGFloat kCustomIOS7MotionEffectExtent                = 10.0;   //
const static CGFloat kCustomIOSContentViewHorizontalInset         = 24.0;    // 内嵌视图跟 alertView 水平边界间隔值
const static CGFloat kCustomIOSContentViewInset                   = 10.0;    // 内嵌视图跟 alertView 水平边界间隔值


@interface CustomIOSAlertView()<LVKeyboardDelegate>
@property (nonatomic, strong) LVKeyboardView* keyboard;
@property (nonatomic, strong) NSMutableArray* mutableArrayButtons;
@property (nonatomic, retain) passwordView* passwordFieldView;
@end



@implementation CustomIOSAlertView

CGFloat buttonHeight = 0;
CGFloat buttonSpacerHeight = 0;

@synthesize parentView, containerView, dialogView, onButtonTouchUpInside;
@synthesize delegate;
@synthesize buttonTitles;
@synthesize useMotionEffects;
@synthesize keyboard;
@synthesize passwordFieldView = _passwordFieldView;
@synthesize mutableArrayButtons = _mutableArrayButtons;
@synthesize password = _password;


- (id)initWithParentView: (UIView *)_parentView
{
    self = [self init];
    if (_parentView) {
        self.frame = _parentView.frame;
        self.parentView = _parentView;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0,
                                0,
                                [UIScreen mainScreen].bounds.size.width,
                                [UIScreen mainScreen].bounds.size.height);

        delegate = self;
        useMotionEffects = false;
        buttonTitles = @[@"Close"];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

// Create the dialog view, and animate opening the dialog
- (void)show
{
    dialogView = [self createContainerView];
    
    // 创建自定义键盘
    [self createCustomKeyboard];
    [self addSubview:self.keyboard];
  
    dialogView.layer.shouldRasterize = YES;
    dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
  
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];

#if (defined(__IPHONE_7_0))
    if (useMotionEffects) {
        [self applyMotionEffects];
    }
#endif

//    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1];

    [self addSubview:dialogView];

    // Can be attached to a view or to the top most window
    // Attached to a view:
//    if (parentView != NULL) {
//        [parentView addSubview:self];
//
//    // Attached to the top most window
//    } else {
//
//        // On iOS7, calculate with orientation
//        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
//            
//            UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
//            switch (interfaceOrientation) {
//                case UIInterfaceOrientationLandscapeLeft:
//                    self.transform = CGAffineTransformMakeRotation(M_PI * 270.0 / 180.0);
//                    break;
//                    
//                case UIInterfaceOrientationLandscapeRight:
//                    self.transform = CGAffineTransformMakeRotation(M_PI * 90.0 / 180.0);
//                    break;
//                    
//                case UIInterfaceOrientationPortraitUpsideDown:
//                    self.transform = CGAffineTransformMakeRotation(M_PI * 180.0 / 180.0);
//                    break;
//                    
//                default:
//                    break;
//            }
//            
//            [self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//
//        // On iOS8, just place the dialog in the middle
//        } else {
//
//            CGSize screenSize = [self countScreenSize];
//            CGSize dialogSize = [self countDialogSize];
//            CGSize keyboardSize = CGSizeMake(0, 0);
//
//            dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
//
//        }
//
//        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
//    }

//    dialogView.layer.opacity = 0.5f;
//    dialogView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
//
//    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//					 animations:^{
//						 self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
//                         dialogView.layer.opacity = 1.0f;
//                         dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
//					 }
//					 completion:NULL
//     ];

}

// Button has been touched
- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender
{
    if (delegate != NULL) {
        [delegate customIOS7dialogButtonTouchUpInside:self clickedButtonAtIndex:[sender tag]];
    }

    if (onButtonTouchUpInside != NULL) {
        onButtonTouchUpInside(self, (int)[sender tag]);
    }
}

// Default button behaviour
//- (void)customIOS7dialogButtonTouchUpInside: (CustomIOSAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSLog(@"Button Clicked! %d, %d", (int)buttonIndex, (int)[alertView tag]);
//    if (delegate != NULL) {
//        [delegate customIOS7dialogButtonTouchUpInside:self clickedButtonAtIndex:buttonIndex];
//    }
//
//    [self close];
//}

// Dialog close animation then cleaning and removing the view from the parent
- (void)close
{
    CATransform3D currentTransform = dialogView.layer.transform;

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        CGFloat startRotation = [[dialogView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
        CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);

        dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    }

    dialogView.layer.opacity = 1.0f;

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
						 self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         dialogView.layer.opacity = 0.0f;
					 }
					 completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
                         // 清空按键组的 holder
                         [self.mutableArrayButtons removeAllObjects];
					 }
	 ];
}

- (void)setSubView: (UIView *)subView
{
    containerView = subView;
}

// Creates the container view here: create the dialog, then add the custom content and buttons
- (UIView *)createContainerView
{
    CGSize screenSize = [self countScreenSize];     // 屏幕 size
    // For the black background
    [self setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    
    if (containerView == NULL) {
        // 先设置密码输入框 textField 的frame
        self.passwordFieldView.frame = CGRectMake(kCustomIOSContentViewInset,
                                                  0,
                                                  screenSize.width - kCustomIOSContentViewInset*2 - kCustomIOSContentViewHorizontalInset*2,
                                                  screenSize.height/6.0);

        [self setSubView:self.passwordFieldView];
    }

    CGSize dialogSize = [self countDialogSize];     // alertView 的size
    NSLog(@"\n----------- \n screenSize=[%f,%f]\n dialogSize=[%f,%f] \n------------", screenSize.width, screenSize.height, dialogSize.width,dialogSize.height);
    

    // This is the dialog's container; we attach the custom content and the buttons to this one
    // 初始化弹窗视图:用frame
    UIView *dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width - dialogSize.width) / 2.0,
                                                                       // 这里的 y 点坐标: (screen.height - keyboard.h - self.h )/2
                                                                       (screenSize.height - dialogSize.height - CustomKeyboardHeight) / 2.0,
                                                                       dialogSize.width,
                                                                       dialogSize.height)];

    dialogContainer.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0f];

    dialogContainer.layer.cornerRadius = kCustomIOSAlertViewCornerRadius;


    // Add the custom container if there is any
    [dialogContainer addSubview:containerView];

    // Add the buttons too
    [self addButtonsToView:dialogContainer];
    
    return dialogContainer;
}


#pragma mask ::: 创建自定义键盘
- (void) createCustomKeyboard {
    CGFloat x = 0;
    CGFloat y = self.frame.size.height - CustomKeyboardHeight;
    CGFloat w = self.frame.size.width;
    CGFloat h = CustomKeyboardHeight;
    self.keyboard = [[LVKeyboardView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    self.keyboard.delegate = self;
}

// Helper function: add buttons to container
- (void)addButtonsToView: (UIView *)container
{
    if (buttonTitles==NULL) { return; }

    // 按钮组平分了自定义view.width
    CGFloat buttonWidth = (container.bounds.size.width - kCustomIOSContentViewInset*2.0 - ([buttonTitles count] - 1)*kCustomIOSContentViewInset) / [buttonTitles count];

    CGRect frame = CGRectMake(0 + kCustomIOSContentViewInset,
                              container.bounds.size.height - kCustomIOSContentViewInset - buttonHeight,
                              buttonWidth,
                              buttonHeight);
    for (int i=0; i<[buttonTitles count]; i++) {

        UIButton* closeButton = [[UIButton alloc] init];
        [closeButton setFrame:frame];

        [closeButton addTarget:self action:@selector(customIOS7dialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTag:i];

        [closeButton setTitle:[buttonTitles objectAtIndex:i] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [closeButton.layer setCornerRadius:kCustomIOSAlertViewCornerRadius - 2];
        [closeButton.layer setBorderWidth:0.3];
        [closeButton.layer setBorderColor:[UIColor colorWithWhite:0.5 alpha:0.5].CGColor];
        if (i != 0) {
            closeButton.backgroundColor = [UIColor colorWithRed:43.0/255.0 green:91.0/255.0 blue:236.0/255.0 alpha:1];
            [closeButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateNormal];
            [closeButton setEnabled:NO];
            [closeButton setHighlighted:NO];
        } else {
            closeButton.backgroundColor = [UIColor whiteColor];
        }
        
        ////////// 按钮组的保存
        [self.mutableArrayButtons addObject:closeButton];

        [container addSubview:closeButton];
        
        //
        frame.origin.x += buttonWidth + kCustomIOSContentViewInset;
    }
}

// Helper function: count and return the dialog's size
- (CGSize)countDialogSize
{
    // 密码框+按钮+按钮底间隙+3*公用间隙
    CGFloat dialogWidth = containerView.frame.size.width + kCustomIOSContentViewInset * 2.0;
    CGFloat dialogHeight = containerView.frame.size.height + buttonHeight + buttonSpacerHeight + kCustomIOSContentViewHorizontalInset;

    
    return CGSizeMake(dialogWidth, dialogHeight);
}

// Helper function: count and return the screen's size
- (CGSize)countScreenSize
{
    if (buttonTitles!=NULL && [buttonTitles count] > 0) {
        buttonHeight       = kCustomIOSAlertViewDefaultButtonHeight;
        buttonSpacerHeight = kCustomIOSAlertViewDefaultButtonSpacerHeight;
    } else {
        buttonHeight = 0;
        buttonSpacerHeight = 0;
    }

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    // On iOS7, screen width and height doesn't automatically follow orientation
//    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
//        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
//        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
//            CGFloat tmp = screenWidth;
//            screenWidth = screenHeight;
//            screenHeight = tmp;
//        }
//    }
    
    return CGSizeMake(screenWidth, screenHeight);
}

#if (defined(__IPHONE_7_0))
// Add motion effects
- (void)applyMotionEffects {

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return;
    }

    UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                                    type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalEffect.minimumRelativeValue = @(-kCustomIOS7MotionEffectExtent);
    horizontalEffect.maximumRelativeValue = @( kCustomIOS7MotionEffectExtent);

    UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                                  type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalEffect.minimumRelativeValue = @(-kCustomIOS7MotionEffectExtent);
    verticalEffect.maximumRelativeValue = @( kCustomIOS7MotionEffectExtent);

    UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects = @[horizontalEffect, verticalEffect];

    [dialogView addMotionEffect:motionEffectGroup];
}
#endif

- (void)dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

// Rotation changed, on iOS7
- (void)changeOrientationForIOS7 {

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGFloat startRotation = [[self valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CGAffineTransform rotation;
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 270.0 / 180.0);
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 90.0 / 180.0);
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 180.0 / 180.0);
            break;
            
        default:
            rotation = CGAffineTransformMakeRotation(-startRotation + 0.0);
            break;
    }

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         dialogView.transform = rotation;
                         
                     }
                     completion:nil
     ];
    
}

// Rotation changed, on iOS8
- (void)changeOrientationForIOS8: (NSNotification *)notification {

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         CGSize dialogSize = [self countDialogSize];
                         CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
                         self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
                         dialogView.frame = CGRectMake((screenWidth - dialogSize.width) / 2, (screenHeight - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                     }
                     completion:nil
     ];
    

}

// Handle device orientation changes
- (void)deviceOrientationDidChange: (NSNotification *)notification
{
    // If dialog is attached to the parent view, it probably wants to handle the orientation change itself
    if (parentView != NULL) {
        return;
    }

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        [self changeOrientationForIOS7];
    } else {
        [self changeOrientationForIOS8:notification];
    }
}

// Handle keyboard show/hide changes
- (void)keyboardWillShow: (NSNotification *)notification
{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation) && NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
        CGFloat tmp = keyboardSize.height;
        keyboardSize.height = keyboardSize.width;
        keyboardSize.width = tmp;
    }

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
                         dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
					 }
					 completion:nil
	 ];
}

- (void)keyboardWillHide: (NSNotification *)notification
{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
                         dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
					 }
					 completion:nil
	 ];
}

#pragma mark - LVKeyboardDelegate
- (void)keyboard:(LVKeyboardView *)keyboard didClickButton:(UIButton *)button {
    if (self.password.length > 5) return;
    
    [self.password appendString:button.currentTitle];

    // 调用 passwordView 的新方法
    [self.passwordFieldView passwordAppendChar:button.currentTitle];
    // 监控 确定 按钮的状态
    for (int i = 1; i < self.mutableArrayButtons.count; i++) {
        UIButton* button = [self.mutableArrayButtons objectAtIndex:i];
        if ((_password.length == 6) && (!button.enabled)) {
            [button setEnabled:YES];
            [button setHighlighted:YES];
        }
    }
}

- (void)keyboard:(LVKeyboardView *)keyboard didClickDeleteBtn:(UIButton *)deleteBtn {
    if (self.password.length < 1) return;
    
    [self.password deleteCharactersInRange:NSMakeRange(self.password.length - 1, 1)];
    // 监控 确定 按钮的状态
    for (int i = 1; i < self.mutableArrayButtons.count; i++) {
        UIButton* button = [self.mutableArrayButtons objectAtIndex:i];
        if ((_password.length < 6) && button.enabled) {
            [button setEnabled:NO];
            [button setHighlighted:NO];
        }
    }
    [self.passwordFieldView passwordRemoveChar];
    
}


#pragma mask ::: setter & getter
- (NSString *)password {
    if (_password == nil) {
        _password = [[NSMutableString alloc] init];
    }
    return _password;
}

- (passwordView *)passwordFieldView {
    if (_passwordFieldView == nil) {
        _passwordFieldView = [[passwordView alloc] init];
    }
    return _passwordFieldView;
}

- (NSMutableArray *)mutableArrayButtons {
    if (_mutableArrayButtons == nil) {
        _mutableArrayButtons = [[NSMutableArray alloc] init];
    }
    return _mutableArrayButtons;
}

@end
