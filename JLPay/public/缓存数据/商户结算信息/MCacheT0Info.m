//
//  MCacheT0Info.m
//  JLPay
//
//  Created by jielian on 16/10/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MCacheT0Info.h"
#import "Define_Header.h"
#import <AFNetworking.h>


@implementation MCacheT0Info

- (void)reloadCacheWithBusinessCode:(NSString *)businessCode
                         onFinished:(void (^)(void))finishedBlock
                            onError:(void (^)(NSError *))errorBlock
{
    
    if (!businessCode || businessCode.length == 0) {
        if (errorBlock) {
            errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"商户编号为空"]);
        }
        return;
    }
    
    AFHTTPSessionManager* httpManager = [AFHTTPSessionManager manager];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:businessCode forKey:@"mchtNo"];
    
    [httpManager POST:[self t_0URL] parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* responseInfo = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSString* code = [responseInfo objectForKey:@"code"];
        NSString* message = [responseInfo objectForKey:@"message"];
        if (code.integerValue == 0) {
            /* 先清空历史缓存,再更新 */
            [self resetT_0Info];
            NSInteger T_0EnableValue = [[responseInfo objectForKey:@"allowFlag"] integerValue]; // 0:不允许,1:允许
            if (T_0EnableValue) {
                self.T_0Enable = YES;
                self.amountLimit = [[responseInfo objectForKey:@"dayTotal"] floatValue];
                self.amountMinCust = [[responseInfo objectForKey:@"minTradeMoney"] floatValue];
                CGFloat amountCusted = [[responseInfo objectForKey:@"cumMoney"] floatValue];
                self.amountAvilable = self.amountLimit - amountCusted;
                self.T_0MoreRate = [[responseInfo objectForKey:@"t0Fee"] floatValue];
                self.T_0ExtraFee = [[responseInfo objectForKey:@"extraFee"] floatValue];
                self.compareMoney = [[responseInfo objectForKey:@"compareMoney"] floatValue];
                
            }
            if (finishedBlock) {
                finishedBlock();
            }
        } else {
            if (errorBlock) {
                errorBlock([NSError errorWithDomain:@"" code:[code integerValue] localizedDescription:message]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}


+ (instancetype)cache {
    static MCacheT0Info* sharedCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[MCacheT0Info alloc] init];
    });
    return sharedCache;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.T_0Enable = NO;
    }
    return self;
}



- (void) resetT_0Info {
    self.T_0Enable = NO;
    self.amountLimit = 0;
    self.amountMinCust = 0;
    self.amountAvilable = 0;
    self.T_0ExtraFee = 0;
    self.T_0MoreRate = 0;
    self.compareMoney = 0;
}

- (NSString* ) t_0URL {
    return [NSString stringWithFormat:@"http://%@:%@/jlagent/getT0Info", [PublicInformation getServerDomain], [PublicInformation getHTTPPort]];
}


@end
