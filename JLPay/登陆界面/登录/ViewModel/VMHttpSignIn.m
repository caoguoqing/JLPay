//
//  VMHttpSignIn.m
//  JLPay
//
//  Created by jielian on 16/6/14.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMHttpSignIn.h"

static NSString* const pinTriEncKey = @"123456789012345678901234567890123456789012345678";

@implementation VMHttpSignIn

- (instancetype)init {
    self = [super init];
    if (self) {
        
        RAC(self, userPwdPinStr) = [[RACObserve(self, userPwdStr) filter:^BOOL(NSString* source) {
            if (source && source.length > 0) {
                return YES;
            } else {
                return NO;
            }
        }] map:^NSString* (NSString* source) {
            return [self pinEncryptBySource:source];
        }];
        
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

- (RACSignal*) siginSig {
    return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @weakify(self);
        [self.http requestingOnPackingBlock:^(ASIFormDataRequest *http) {
            [subscriber sendNext:nil];
            /* 打包 */
            @strongify(self);
            [http addPostValue:self.userNameStr forKey:kFieldNameSignInUpUserID];
            [http addPostValue:self.userPwdPinStr forKey:kFieldNameSignInUpUserPWD];
            [http addPostValue:[[PublicInformation AppVersionNumber] stringByReplacingOccurrencesOfString:@"." withString:@""]
                        forKey:kFieldNameSignInUpVersionNum];
            [http addPostValue:@"0" forKey:kFieldNameSignInUpSysFlag];
        } onFinishedBlock:^(NSDictionary *info) {
            /* 登录响应成功,解析响应码 */
            NSInteger code = [[info objectForKey:kFieldNameSignInDownCode] integerValue];
            NSString* message = [info objectForKey:kFieldNameSignInDownMessage];
            
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
                self.responseData = [info copy];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:[NSError errorWithDomain:@"SignInError" code:code localizedDescription:message]];
            }
        } onErrorBlock:^(NSError *error) {
            /* 登录响应失败 */
            [subscriber sendError:error];
        }];
        return nil;
    }] replayLast] materialize];
}


/* 加密 */
- (NSString*) pinEncryptBySource:(NSString*)source {
    return [ThreeDesUtil encryptUse3DES:[EncodeString encodeASC:source] key:pinTriEncKey];
}
/* 解密 */
- (NSString*) sourceByUnEncryptPin:(NSString*)pin {
    return [PublicInformation stringFromHexString:[ThreeDesUtil decryptUse3DES:pin key:pinTriEncKey]];
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
                                                     return [self siginSig];
        }];
    }
    return _signInCommand;
}

- (HTTPInstance *)http {
    if (!_http) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/LoginService",
                               [PublicInformation getServerDomain],
                               [PublicInformation getHTTPPort]];
        _http = [[HTTPInstance alloc] initWithURLString:urlString];
    }
    return _http;
}

@end
