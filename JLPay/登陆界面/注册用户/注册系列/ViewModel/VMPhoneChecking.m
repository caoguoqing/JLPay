//
//  VMPhoneChecking.m
//  JLPay
//
//  Created by jielian on 16/7/20.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMPhoneChecking.h"
#import "MBProgressHUD+CustomSate.h"
#import <AFNetworking.h>
#import <ReactiveCocoa.h>
#import "Define_Header.h"



@implementation VMPhoneChecking

# pragma maks 1 private funcs

- (RACSignal*) sigEnablePhoneNumber {
    return [RACObserve(self, phoneNumber) map:^id(NSString* phoneNumber) {
        return @((phoneNumber && phoneNumber.length == 11) ? (YES) : (NO));
    }];
}

- (RACSignal*) sigEnableCheckNumber {
    return [RACObserve(self, checkNumber) map:^id(NSString* checkNumber) {
        return @((checkNumber && checkNumber.length > 0) ? (YES) : (NO));
    }];
}

- (RACSignal*) sigEnableChecking {
    return [RACSignal combineLatest:@[[self sigEnablePhoneNumber], [self sigEnableCheckNumber]]
                             reduce:^id(NSNumber* phoneEnable, NSNumber* checkNoEnable){
                                 return @(phoneEnable.boolValue && checkNoEnable.boolValue);
    }];
}

/* 获取验证码接口 */
- (NSString* ) checkNumRequetingUrlString {
    if (TestOrProduce == 11) {
        return [NSString stringWithFormat:@"http://%@:%@/kftagent/SendMsg",
                [PublicInformation getServerDomain], [PublicInformation getHTTPPort]];
    } else {
        return [NSString stringWithFormat:@"http://%@:%@/jlagent/SendMsg",
                [PublicInformation getServerDomain], [PublicInformation getHTTPPort]];
    }
}
/* 验证验证码接口 */
- (NSString*) numCheckingUrlString {
    if (TestOrProduce == 11) {
        return [NSString stringWithFormat:@"http://%@:%@/kftagent/ValidationMsg",
                [PublicInformation getServerDomain], [PublicInformation getHTTPPort]];
    } else {
        return [NSString stringWithFormat:@"http://%@:%@/jlagent/ValidationMsg",
                [PublicInformation getServerDomain], [PublicInformation getHTTPPort]];
    }
}

- (NSDictionary* ) httpParametersRequestCheckNo {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setObject:self.phoneNumber forKey:@"telephoneNo"];
    return parameters;
}

- (NSDictionary*) httpParametersCheckingNo {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setObject:self.phoneNumber forKey:@"telephoneNo"];
    [parameters setObject:self.checkNumber forKey:@"validcode"];
    return parameters;
}

# pragma mask 2 getter

- (RACCommand *)cmdCheckNumberRequest {
    @weakify(self);
    if (!_cmdCheckNumberRequest) {
        _cmdCheckNumberRequest = [[RACCommand alloc] initWithEnabled:[self sigEnablePhoneNumber]
                                                         signalBlock:^RACSignal *(id input) {
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                /* 启动定时器 */
                [self.checkWaitingTimer startTimer];
                
                /* 打包并发送请求 */
                AFHTTPSessionManager* httpManager = [AFHTTPSessionManager manager];
                httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
                httpManager.requestSerializer.timeoutInterval = 10;
                
                MBProgressHUD* hud = [MBProgressHUD showNormalWithText:nil andDetailText:nil];
                
                [httpManager POST:[self checkNumRequetingUrlString] parameters:[self httpParametersRequestCheckNo] progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [hud hide:YES];
                    NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                    NSInteger code = [[responseData objectForKey:@"code"] integerValue];
                    NSString* message = [responseData objectForKey:@"message"];
                    if (code == 0) {
                        [subscriber sendCompleted];
                    } else {
                        [MBProgressHUD showFailWithText:@"获取验证码失败" andDetailText:message onCompletion:^{
                            [subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:message]];
                        }];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [hud hide:YES];
                    [MBProgressHUD showFailWithText:@"获取验证码失败" andDetailText:[error localizedDescription] onCompletion:^{
                        [subscriber sendError:error];
                    }];
                }];
                
                return nil;
            }] replayLast] materialize];
        }];
    }
    return _cmdCheckNumberRequest;
}

- (RACSignal *)sigNumberChecking {
    if (!_sigNumberChecking) {
        _sigNumberChecking = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            AFHTTPSessionManager* httpManager = [AFHTTPSessionManager manager];
            httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
            httpManager.requestSerializer.timeoutInterval = 10;
            
            MBProgressHUD* hud = [MBProgressHUD showNormalWithText:@"正在校验验证码..." andDetailText:nil];
            
            [httpManager POST:[self numCheckingUrlString]
                   parameters:[self httpParametersCheckingNo]
                     progress:^(NSProgress * _Nonnull uploadProgress) {
                         
                     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         [hud hide:YES];
                         NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                         NSInteger code = [[responseData objectForKey:@"code"] integerValue];
                         NSString* message = [responseData objectForKey:@"message"];
                         if (code == 0) {
                             [subscriber sendCompleted];
                         } else {
                             [MBProgressHUD showFailWithText:@"验证失败" andDetailText:message onCompletion:^{
                                 [subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:message]];
                             }];
                         }
                         
                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         [hud hide:YES];
                         [MBProgressHUD showFailWithText:@"验证失败" andDetailText:[error localizedDescription] onCompletion:^{
                             [subscriber sendError:error];
                         }];
                     }];

            return nil;
        }];
    }
    return _sigNumberChecking;
}

- (VMCheckNumTimer *)checkWaitingTimer {
    if (!_checkWaitingTimer) {
        _checkWaitingTimer = [VMCheckNumTimer new];
    }
    return _checkWaitingTimer;
}


@end
