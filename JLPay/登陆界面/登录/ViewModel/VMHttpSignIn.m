//
//  VMHttpSignIn.m
//  JLPay
//
//  Created by jielian on 16/6/14.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMHttpSignIn.h"
#import <AFNetworking.h>
#import "MCacheSavedLogin.h"
#import "MSettlementTypeLocalConfig.h"


@interface VMHttpSignIn()

/* app版本号(整数) */
@property (nonatomic, copy) NSString* appVersionInteger;

/* 平台标志: 0(ios), 1(android) */
@property (nonatomic, copy) NSString* systemFlag;



@end


@implementation VMHttpSignIn

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}



# pragma mask 3 private interface

- (RACSignal*) enableUserNameSig {
    return [RACObserve(self, userNameStr) map:^NSNumber* (NSString* userName) {
        if (userName && userName.length > 0) {
            return @(YES);
        } else {
            return @(NO);
        }
    }];
}

- (RACSignal*) enableUserPwdSig {
    return [RACObserve(self, userPwdStr) map:^NSNumber* (NSString* userPwd) {
        if (userPwd && userPwd.length > 0) {
            return @(YES);
        } else {
            return @(NO);
        }
    }];
}


- (RACSignal*) newSignInSignalWithAFNetWorking {
    @weakify(self);
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        
        AFHTTPSessionManager* httpManager = [AFHTTPSessionManager manager];
        httpManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        httpManager.requestSerializer.timeoutInterval = 10;
        httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [subscriber sendNext:nil];

        [httpManager POST:[NSString stringWithFormat:@"http://%@:%@/jlagent/LoginService",
                           [PublicInformation getServerDomain],
                           [PublicInformation getHTTPPort]]
               parameters:@{kFieldNameSignInUpUserID:self.userNameStr,
                            kFieldNameSignInUpUserPWD:self.userPwdStr,
                            kFieldNameSignInUpVersionNum:self.appVersionInteger,
                            kFieldNameSignInUpSysFlag:self.systemFlag}
                 progress:^(NSProgress * _Nonnull uploadProgress) {
                     
                 } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     NSDictionary* resData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                     NSInteger code = [[resData objectForKey:kFieldNameSignInDownCode] integerValue];
                     NSString* message = [resData objectForKey:kFieldNameSignInDownMessage];
                     BOOL success;
                     if (code == 0) {            /* 成功 */
                         success = YES;
                     }
                     else if (code == 801 || code == 802) {     /* 审核中/审核拒绝 */
                         success = YES;
                     }
                     else {                      /* 版本低、其他 */
                         success = NO;
                     }
                     
                     if (success) {
                         @strongify(self);
                         self.responseData = [resData copy];
                         
                         /* 登录成功要保存缓存信息 */
                         [self savingLoginInfoIntoCacheAfterSuccess];
                         
                         /* 缓存结算方式到本地 */
                         [self updateSettlementTypeLocalConfig];
                         
                         /* 并回调 */
                         [subscriber sendCompleted];
                     } else {
                         [subscriber sendError:[NSError errorWithDomain:@"SignInError" code:code localizedDescription:message]];
                     }
                 
                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     /* 登录响应失败 */
                     [subscriber sendError:error];
                 }
         ];
        
        return nil;
    }] materialize];
}



/* 保存登陆信息到缓存 */
- (void) savingLoginInfoIntoCacheAfterSuccess {
    MCacheSavedLogin* loginCache = [MCacheSavedLogin cache];
    loginCache.userName = self.userNameStr;
    loginCache.userPassword = self.userPwdStr;
    loginCache.appVersion = self.appVersionInteger;
    loginCache.systemType = self.systemFlag;
    
    loginCache.logined = YES;
    loginCache.businessCode = [self.responseData objectForKey:kFieldNameSignInDownBusinessNum];
    loginCache.businessName = [self.responseData objectForKey:kFieldNameSignInDownBusinessName];
    loginCache.email = [self.responseData objectForKey:kFieldNameSignInDownBusinessEmail];

    /* 终端号组 */
    loginCache.terminalCount = [[self.responseData objectForKey:kFieldNameSignInDownTerminalCount] integerValue];
    if (loginCache.terminalCount > 0) {
        NSString* terminalList = [self.responseData objectForKey:kFieldNameSignInDownTerminalList];
        if (terminalList && terminalList.length > 0) {
            NSArray* terminals = [NSMutableArray arrayWithArray:[terminalList componentsSeparatedByString:@","]];
            NSMutableArray* visibleTerminals = [NSMutableArray array];
            for (NSString* terminal in terminals) {
                [visibleTerminals addObject:[terminal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }
            loginCache.terminalList = [NSArray arrayWithArray:visibleTerminals];
        }
    }
    
    
    /* 允许标志位 */
    NSString* allowTypes = [self.responseData objectForKey:kFieldNameSignInDownAllowTypes];
    loginCache.T_N_enable = [allowTypes substringWithRange:NSMakeRange(0, 1)].integerValue == 1 ? YES:NO;
    loginCache.N_fee_enable = [allowTypes substringWithRange:NSMakeRange(1, 1)].integerValue == 1 ? YES:NO;
    loginCache.N_business_enable = [allowTypes substringWithRange:NSMakeRange(2, 1)].integerValue == 1 ? YES:NO;
    loginCache.T_0_enable = [allowTypes substringWithRange:NSMakeRange(3, 1)].integerValue == 1 ? YES:NO;
    
    /* 审核状态 */
    NSInteger code = [[self.responseData objectForKey:kFieldNameSignInDownCode] integerValue];
    if (code == VMSigninSpecialErrorTypeCheckStill) {
        loginCache.checkedState = MCacheSignUpCheckStateChecking;
    }
    else if (code == VMSigninSpecialErrorTypeCheckRefuse) {
        loginCache.checkedState = MCacheSignUpCheckStateCheckRefused;
        loginCache.checkRefuseReason = [self.responseData objectForKey:kFieldNameSignInDownMessage];
    }
    else {
        loginCache.checkedState = MCacheSignUpCheckStateChecked;
    }
    
}

/* 缓存结算方式到本地 */
- (void) updateSettlementTypeLocalConfig {
    MSettlementTypeLocalConfig* settlementConfig = [MSettlementTypeLocalConfig localConfig];
    MCacheSavedLogin* loginInfo = [MCacheSavedLogin cache];
    if (!loginInfo.T_0_enable) {
        if (!loginInfo.T_N_enable) {
            [settlementConfig updateLocalConfitWithSettlementType:SettlementType_T1];
        } else {
            [settlementConfig updateLocalConfitWithSettlementType:SettlementType_TN];
        }
    }
}





# pragma mask 4 getter

- (RACCommand *)signInCommand {
    if (!_signInCommand) {
        @weakify(self);
        _signInCommand = [[RACCommand alloc] initWithEnabled:[RACSignal combineLatest:@[[self enableUserNameSig], [self enableUserPwdSig]]
                                                                               reduce:^id(NSNumber* enableUserName, NSNumber* enableUserPwd){
                                                                                   return @(enableUserName.boolValue && enableUserPwd.boolValue);
                                                                               }]
                                                 signalBlock:^RACSignal *(id input) {
                                                     @strongify(self);
                                                     return [self newSignInSignalWithAFNetWorking];
        }];
    }
    return _signInCommand;
}


- (NSString *)appVersionInteger {
    if (!_appVersionInteger) {
        _appVersionInteger = [[PublicInformation AppVersionNumber] stringByReplacingOccurrencesOfString:@"." withString:@""];
    }
    return _appVersionInteger;
}

- (NSString *)systemFlag {
    if (!_systemFlag) {
        _systemFlag = @"0";
    }
    return _systemFlag;
}

@end
