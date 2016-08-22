//
//  MT0CardUploadHttp.m
//  JLPay
//
//  Created by jielian on 16/7/12.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMT0CardUploadHttp.h"
#import <AFNetworking.h>
#import <ReactiveCocoa.h>
#import "Define_Header.h"


@implementation VMT0CardUploadHttp



- (RACCommand *)cmdUploading {
    @weakify(self);
    if (!_cmdUploading) {
        _cmdUploading = [[RACCommand alloc] initWithEnabled:[self enableSigOnInputs] signalBlock:^RACSignal *(id input) {
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [subscriber sendNext:nil];
                
                AFHTTPSessionManager* httpManager = [AFHTTPSessionManager manager];
                httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                
                [httpManager POST:[self urlString]
                       parameters:[self parametersDic]
        constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            @strongify(self);
            NSData* imgData = UIImageJPEGRepresentation(self.imageUploaded, 0.1);
            [formData appendPartWithFileData:imgData name:self.cardNo fileName:[self.cardNo stringByAppendingString:@".png"] mimeType:@"image/jpeg"];
        }
                         progress:^(NSProgress * _Nonnull uploadProgress) {
                             [subscriber sendNext:uploadProgress];
                         }
                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                              NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                              NSInteger code = [[responseData objectForKey:@"code"] integerValue];
                              NSString* message = [responseData objectForKey:@"message"];
                              if (code == 0) {
                                  [subscriber sendCompleted];
                              } else {
                                  [subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:message]];
                              }
                          }
                          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                              [subscriber sendError:error];
                          }
                 ];
                
                return nil;
            }] replayLast] materialize];
        }];
    }
    return _cmdUploading;
}

- (RACSignal* ) enableSigOnInputs {
    
    RACSignal* enableSigUsername = [RACObserve(self, userName) map:^id(NSString* userName) {
        return @(userName && userName.length > 0);
    }];
    
    RACSignal* enableSigCardno = [RACObserve(self, cardNo) map:^id(NSString* cardNo) {
        return @(cardNo && cardNo.length > 0);
    }];
    
    RACSignal* enableSigUserID = [RACObserve(self, userId) map:^id(NSString* userId) {
        return @(userId && userId.length > 0);
    }];

    RACSignal* enableSigMobPhone = [RACObserve(self, mobilePhone) map:^id(NSString* mobilePhone) {
        return @(mobilePhone && mobilePhone.length > 0);
    }];
    
    RACSignal* enableSigImage = [RACObserve(self, imageUploaded) map:^id(UIImage* image) {
        return @(image != nil);
    }];
    
    return [RACSignal combineLatest:@[enableSigUsername, enableSigCardno, enableSigUserID, enableSigMobPhone, enableSigImage]
                             reduce:^id (NSNumber* enableUserName, NSNumber* enableCardNo,NSNumber* enableUserId, NSNumber* enablePhone, NSNumber* enableImage){
                                 return @(enableCardNo.boolValue && enableUserName.boolValue && enableUserId.boolValue && enablePhone.boolValue && enableImage.boolValue);
                             }];
}

- (NSString* ) urlString {
    return [NSString stringWithFormat:@"http://%@:%@/jlagent/cardUpload", [PublicInformation getServerDomain],
            [PublicInformation getHTTPPort]];
}

- (NSDictionary* ) parametersDic {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[PublicInformation returnBusiness] forKey:@"mchtNo"];
    [parameters setObject:self.cardNo forKey:@"cardId"];
    [parameters setObject:self.userName forKey:@"cardUserName"];
    [parameters setObject:self.cardType forKey:@"cardType"];
    [parameters setObject:self.mobilePhone forKey:@"telephone"];
    [parameters setObject:self.userId forKey:@"identityNo"];
    return parameters;
}

@end
