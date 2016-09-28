//
//  MBProgressHUD+CustomSate.m
//  CustomViewMaker
//
//  Created by jielian on 16/3/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MBProgressHUD+CustomSate.h"

#import "CustomCheckView.h"
#import <ReactiveCocoa.h>


static CGFloat const fMBProgressHUDSucDuration = 0.8;   // 成功时的显示持续时间
static CGFloat const fMBProgressHUDFailDuration = 2.5;  // 失败时的显示持续时间


@implementation MBProgressHUD (CustomSate)



+ (instancetype) showNormalWithText:(NSString*)text andDetailText:(NSString*)detailText {
    UIWindow* mainWindow = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD hideHUDForView:mainWindow animated:YES];
    
    MBProgressHUD* progressHud = [MBProgressHUD showHUDAddedTo:mainWindow animated:YES];
    progressHud.labelText = text;
    progressHud.detailsLabelText = detailText;
//    progressHud.removeFromSuperViewOnHide = YES;
    return progressHud;
}

+ (void)showSuccessWithText:(NSString *)text andDetailText:(NSString *)detailText onCompletion:(void (^)(void))completion {
    UIWindow* mainWindow = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD hideHUDForView:mainWindow animated:YES];
    
    MBProgressHUD* progressHud = [MBProgressHUD showHUDAddedTo:mainWindow animated:YES];
    progressHud.labelText = text;
    progressHud.detailsLabelText = detailText;
    progressHud.mode = MBProgressHUDModeCustomView;
    CustomCheckView* customStateView = [progressHud stateViewOnStyle:CustomCheckViewStyleRight];
    progressHud.customView = customStateView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [customStateView showAnimation];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fMBProgressHUDSucDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideHUDForView:mainWindow animated:YES];
            if (completion) {
                completion();
            }
        });
    });
}

+ (void) showFailWithText:(NSString *)text andDetailText:(NSString *)detailText onCompletion:(void (^)(void))completion {
    UIWindow* mainWindow = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD hideHUDForView:mainWindow animated:YES];

    MBProgressHUD* progressHud = [MBProgressHUD showHUDAddedTo:mainWindow animated:YES];
    progressHud.labelText = text;
    progressHud.detailsLabelText = detailText;
    progressHud.mode = MBProgressHUDModeCustomView;
    CustomCheckView* customStateView = [progressHud stateViewOnStyle:CustomCheckViewStyleWrong];
    progressHud.customView = customStateView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [customStateView showAnimation];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fMBProgressHUDFailDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideHUDForView:mainWindow animated:YES];
            if (completion) {
                completion();
            }
        });
    });
}

+ (void)showWarnWithText:(NSString *)text andDetailText:(NSString *)detailText onCompletion:(void (^)(void))completion {
    UIWindow* mainWindow = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD hideHUDForView:mainWindow animated:YES];

    MBProgressHUD* progressHud = [MBProgressHUD showHUDAddedTo:mainWindow animated:YES];
    progressHud.labelText = text;
    progressHud.detailsLabelText = detailText;
    progressHud.mode = MBProgressHUDModeCustomView;
    CustomCheckView* customStateView = [progressHud stateViewOnStyle:CustomCheckViewStyleWarn];
    progressHud.customView = customStateView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [customStateView showAnimation];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fMBProgressHUDFailDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideHUDForView:mainWindow animated:YES];
            if (completion) {
                completion();
            }
        });
    });
}


+ (instancetype) showHorizontalProgressWithText:(NSString *)text andDetailText:(NSString *)detailText {
    UIWindow* mainWindow = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD hideHUDForView:mainWindow animated:YES];
    MBProgressHUD* progressHud = [MBProgressHUD showHUDAddedTo:mainWindow animated:YES];
    progressHud.labelText = text;
    progressHud.detailsLabelText = detailText;
    progressHud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    progressHud.removeFromSuperViewOnHide = YES;
    return progressHud;
}





- (void) showNormalWithText:(NSString*)text andDetailText:(NSString*)detailText {
    self.mode = MBProgressHUDModeIndeterminate;
    self.labelText = text;
    self.detailsLabelText = detailText;
    [self show:YES];
}


- (void)showCircleProgressWithText:(NSString *)text andDetailText:(NSString *)detailText //onCompletion:(void (^)(void))completion
{
    self.mode = MBProgressHUDModeDeterminateHorizontalBar; //MBProgressHUDModeDeterminateHorizontalBar MBProgressHUDModeAnnularDeterminate
    self.labelText = text;
    self.detailsLabelText = detailText;
    [self show:YES];
}


- (void) showSuccessWithText:(NSString*)text andDetailText:(NSString*)detailText onCompletion:(void (^) (void))completion {
    CustomCheckView* customStateView = [self stateViewOnStyle:CustomCheckViewStyleRight];
    __weak typeof(self)wself = self;

    [self hideOnCompletion:^{
        wself.mode = MBProgressHUDModeCustomView;
        wself.customView = customStateView;
        
        wself.labelText = text;
        wself.detailsLabelText = detailText;
        [wself show:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [customStateView showAnimation];
        });
        [wself hide:YES afterDelay:fMBProgressHUDSucDuration];
        dispatch_async(dispatch_get_main_queue(), ^{
            wself.completionBlock = completion;
        });
    }];
    
}
- (void) showFailWithText:(NSString*)text andDetailText:(NSString*)detailText onCompletion:(void (^) (void))completion {
    CustomCheckView* customStateView = [self stateViewOnStyle:CustomCheckViewStyleWrong];
    __weak typeof(self)wself = self;

    [self hideOnCompletion:^{
        wself.mode = MBProgressHUDModeCustomView;
        wself.customView = customStateView;
        
        wself.labelText = text;
        wself.detailsLabelText = detailText;
        [wself show:YES];
        [wself hide:YES afterDelay:fMBProgressHUDFailDuration];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [customStateView showAnimation];
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            wself.completionBlock = completion;
        });
    }];
}
- (void) showWarnWithText:(NSString*)text andDetailText:(NSString*)detailText onCompletion:(void (^) (void))completion {
    CustomCheckView* customStateView = [self stateViewOnStyle:CustomCheckViewStyleWarn];
    __weak typeof(self)wself = self;
    
    [self hideOnCompletion:^{
        wself.mode = MBProgressHUDModeCustomView;
        wself.customView = customStateView;
        
        wself.labelText = text;
        wself.detailsLabelText = detailText;
        [wself show:YES];
        [wself hide:YES afterDelay:fMBProgressHUDFailDuration];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [customStateView showAnimation];
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            wself.completionBlock = completion;
        });
    }];
}



- (void) hideOnCompletion:(void (^) (void))completion {
    __weak typeof(self)wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        wself.completionBlock = completion;
        [wself hide:YES];
    });
}
- (void) hideDelay:(NSTimeInterval)delay onCompletion:(void (^) (void))completion {
    __weak typeof(self)wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        wself.completionBlock = completion;
        [wself hide:YES afterDelay:delay];
    });
}



- (CustomCheckView*) stateViewOnStyle:(CustomCheckViewStyle)style {
    CGFloat width = 37;
    CustomCheckView* stateView = [[CustomCheckView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    stateView.layer.borderColor = [UIColor whiteColor].CGColor;
    stateView.layer.borderWidth = 2.f;
    stateView.layer.cornerRadius = width/2.f;
    
    stateView.lineWidth = 2.f;
    stateView.lineColor = [UIColor whiteColor];
    
    stateView.checkViewStyle = style | CustomCheckViewStyleLineRound;
    return stateView;
}

@end
