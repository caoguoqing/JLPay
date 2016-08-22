//
//  VMSignUpHttpRequest.m
//  JLPay
//
//  Created by jielian on 16/7/21.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMSignUpHttpRequest.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>
#import <AFNetworking.h>
#import "MBProgressHUD+CustomSate.h"


@implementation VMSignUpHttpRequest


- (RACSignal *)sigHttpRequesting {
    if (!_sigHttpRequesting) {
        @weakify(self);
        _sigHttpRequesting = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            AFHTTPSessionManager* httpManager = [AFHTTPSessionManager manager];
            httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
            
            MBProgressHUD* hud = [MBProgressHUD showHorizontalProgressWithText:@"正在上传资料..." andDetailText:nil];
            
            
            [httpManager POST:[self urlString] parameters:[self parameters]  constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                @strongify(self);
                [formData appendPartWithFileData:UIImageJPEGRepresentation(self.img_03, 0.1) name:@"03" fileName:@"03.png" mimeType:@"image/png"];
                [formData appendPartWithFileData:UIImageJPEGRepresentation(self.img_06, 0.1) name:@"06" fileName:@"06.png" mimeType:@"image/png"];
                [formData appendPartWithFileData:UIImageJPEGRepresentation(self.img_08, 0.1) name:@"08" fileName:@"08.png" mimeType:@"image/png"];
                [formData appendPartWithFileData:UIImageJPEGRepresentation(self.img_09, 0.1) name:@"09" fileName:@"09.png" mimeType:@"image/png"];
                
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                hud.progress = (CGFloat)uploadProgress.completedUnitCount/(CGFloat)uploadProgress.totalUnitCount;
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                NSInteger code = [[responseData objectForKey:@"code"] integerValue];
                NSString* message = [responseData objectForKey:@"message"];
                [hud hide:YES];
                if (code == 0) {
                    [MBProgressHUD showSuccessWithText:@"注册成功,请退出并登录!" andDetailText:nil onCompletion:^{
                        [subscriber sendCompleted];
                    }];
                } else {
                    [MBProgressHUD showFailWithText:@"上传失败!" andDetailText:message onCompletion:^{
                        [subscriber sendError:[NSError errorWithDomain:@"" code:88 localizedDescription:message]];
                    }];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [hud hide:YES];
                [MBProgressHUD showFailWithText:@"上传失败!" andDetailText:[error localizedDescription] onCompletion:^{
                    [subscriber sendError:error];
                }];
            }];
            
            return nil;
        }];
    }
    return _sigHttpRequesting;
}

- (RACCommand *)cmdHttpRequesting {
    if (!_cmdHttpRequesting) {
        _cmdHttpRequesting = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                
                AFHTTPSessionManager* httpManager = [AFHTTPSessionManager manager];
                httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                MBProgressHUD* hud = [MBProgressHUD showHorizontalProgressWithText:@"正在上传资料..." andDetailText:nil];
                
                [httpManager POST:[self urlString] parameters:[self parameters]  constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    [formData appendPartWithFileData:UIImageJPEGRepresentation(self.img_03, 0.1) name:@"03" fileName:@"03.png" mimeType:@"image/png"];
                    [formData appendPartWithFileData:UIImageJPEGRepresentation(self.img_06, 0.1) name:@"06" fileName:@"06.png" mimeType:@"image/png"];
                    [formData appendPartWithFileData:UIImageJPEGRepresentation(self.img_08, 0.1) name:@"08" fileName:@"08.png" mimeType:@"image/png"];
                    [formData appendPartWithFileData:UIImageJPEGRepresentation(self.img_09, 0.1) name:@"09" fileName:@"09.png" mimeType:@"image/png"];
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    hud.progress = (CGFloat)(uploadProgress.completedUnitCount/uploadProgress.totalUnitCount);
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                    NSInteger code = [[responseData objectForKey:@"code"] integerValue];
                    NSString* message = [responseData objectForKey:@"message"];
                    [hud hide:YES];
                    if (code == 0) {
                        [MBProgressHUD showSuccessWithText:@"注册成功,请退出并登录!" andDetailText:nil onCompletion:^{
                            [subscriber sendCompleted];
                        }];
                    } else {
                        [MBProgressHUD showFailWithText:@"上传失败!" andDetailText:message onCompletion:^{
                            [subscriber sendError:[NSError errorWithDomain:@"" code:88 localizedDescription:message]];
                        }];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [hud hide:YES];
                    [MBProgressHUD showFailWithText:@"上传失败!" andDetailText:[error localizedDescription] onCompletion:^{
                        [subscriber sendError:error];
                    }];
                }];
                return nil;
            }] replayLast] materialize];
        }];
    }
    return _cmdHttpRequesting;
}


- (NSString*) urlString {
    if (TestOrProduce == 11) {
        return [NSMutableString stringWithFormat:@"http://%@:%@/kftagent/MchntRegister",
                [PublicInformation getServerDomain],
                [PublicInformation getHTTPPort]];
    } else {
        return [NSMutableString stringWithFormat:@"http://%@:%@/jlagent/MchntRegister",
                [PublicInformation getServerDomain],
                [PublicInformation getHTTPPort]];
    }
}

- (NSDictionary*) parameters {
    NSMutableDictionary* para = [NSMutableDictionary dictionary];
    
    [para setObject:self.mchntNm forKey:@"mchntNm"];
    [para setObject:self.userName forKey:@"userName"];
    [para setObject:self.passWord forKey:@"passWord"];
    [para setObject:self.identifyNo forKey:@"identifyNo"];
    [para setObject:self.telNo forKey:@"telNo"];
    [para setObject:self.speSettleDs forKey:@"speSettleDs"];
    [para setObject:self.settleAcct forKey:@"settleAcct"];
    [para setObject:self.settleAcctNm forKey:@"settleAcctNm"];
    [para setObject:self.areaNo forKey:@"areaNo"];
    [para setObject:self.addr forKey:@"addr"];
    [para setObject:self.openStlno forKey:@"openStlno"];
    if (self.ageUserName && self.ageUserName.length > 0) {
        [para setObject:self.ageUserName forKey:@"ageUserName"]; // SN号
    } else {
        [para setObject:@"" forKey:@"ageUserName"];
    }
    [para setObject:@"testForUseless@email.com" forKey:@"mail"];
    return para;
}


@end
