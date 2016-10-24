//
//  MTVC_vmLoginAtBack.m
//  JLPay
//
//  Created by jielian on 16/10/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MTVC_vmLoginAtBack.h"
#import "VMHttpSignIn.h"
#import <ReactiveCocoa.h>
#import "Define_Header.h"
#import "MBProgressHUD+CustomSate.h"
#import "ModelAppInformation.h"
#import "MPasswordEncrytor.h"
#import "MViewSwitchManager.h"
#import "MLocalConfigLogin.h"


@interface MTVC_vmLoginAtBack()

@property (nonatomic, copy) void (^ finishedBlock) (void);

@property (nonatomic, copy) void (^ errorBlock) (NSError* error);

@property (nonatomic, strong) VMHttpSignIn* signInHttp;



@end


@implementation MTVC_vmLoginAtBack


- (void)doLoginAtBackOnLoginSuccess:(void (^)(void))finishedBlock onLoginError:(void (^)(NSError *))errorBlock {
    self.finishedBlock = finishedBlock;
    self.errorBlock = errorBlock;
    
    self.signInHttp.userNameStr = [MLocalConfigLogin sharedConfig].userName;
    self.signInHttp.userPwdStr = [MLocalConfigLogin sharedConfig].userPassword;
    
    [self.signInHttp.signInCommand execute:nil];

}




- (instancetype)init {
    self = [super init];
    if (self) {
        if ([[MLocalConfigLogin sharedConfig] hasBeenSaved]) {
            _canAutoLogin = YES;
        } else {
            _canAutoLogin = NO;
        }
        
        @weakify(self);
        [self.signInHttp.signInCommand.executionSignals subscribeNext:^(RACSignal* sig) {
            [[[sig dematerialize] deliverOnMainThread] subscribeNext:^(id x) {
                [MBProgressHUD showNormalWithText:@"正在登录..." andDetailText:nil];
                _canAutoLogin = NO;
            } error:^(NSError *error) {
                NSInteger errorCode = [error code];
                if (errorCode == VMSigninSpecialErrorTypeLowVersion) {
                    [MBProgressHUD hideCurNormalHud];
                    [UIAlertController showAlertWithTitle:@"App版本过低,请下载更新版本" message:nil target:nil clickedHandle:^(UIAlertAction *action) {
                        if ([action.title isEqualToString:@"去下载"]) {
                            NSURL* url = [NSURL URLWithString:[ModelAppInformation URLStringInAppStore]];
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    } buttons:@{@(UIAlertActionStyleDefault):@"取消"}, @{@(UIAlertActionStyleCancel):@"去下载"}, nil];
                }
                else {
                    [MBProgressHUD showFailWithText:@"登录失败" andDetailText:[error localizedDescription] onCompletion:nil];
                }
                if (self.errorBlock) {
                    self.errorBlock(error);
                }
            } completed:^{
                @strongify(self);
                [MBProgressHUD hideCurNormalHud];
                /* 初始密码为8个0的: 强制修改密码 */
                if ([[MPasswordEncrytor pinSourceDecryptedOnPin:[MLocalConfigLogin sharedConfig].userPassword] isEqualToString:@"00000000"]) {
                    [[MViewSwitchManager manager] gotoPasswordExchanging];
                }
                if (self.finishedBlock) {
                    self.finishedBlock();
                }

            }];
        }];
        
    }
    return self;
}



# pragma mask 4 getter 

- (VMHttpSignIn *)signInHttp {
    if (!_signInHttp) {
        _signInHttp = [[VMHttpSignIn alloc] init];
    }
    return _signInHttp;
}

@end
