//
//  MHttpAreaCode.m
//  JLPay
//
//  Created by jielian on 16/8/30.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MHttpAreaCode.h"
#import <AFNetworking.h>
#import "MBProgressHUD+CustomSate.h"
#import "Define_Header.h"


@implementation MHttpAreaCode


+ (void)getAllProvincesOnFinished:(void (^)(NSArray *))finishedBlock onError:(void (^)(NSError *))errorBlock {
    AFHTTPSessionManager* sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString* url = [NSString stringWithFormat:@"http://%@:%@/jlagent/getAreaList",
                     [PublicInformation getServerDomain],
                     [PublicInformation getHTTPPort]];
    
    [MBProgressHUD showNormalWithText:nil andDetailText:nil];
    
    [sessionManager POST:url parameters:@{@"descr":@"156"} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSString* code = [responseData objectForKey:@"code"];
        NSString* message = [responseData objectForKey:@"message"];
        if (code.integerValue == 0) {
            [MBProgressHUD hideCurNormalHud];
            NSMutableArray* areaArray = [NSMutableArray array];
            for (NSDictionary* node in [responseData objectForKey:@"areaList"]) {
                NSMutableDictionary* areaNode = [NSMutableDictionary dictionary];
                [areaNode setObject:[node objectForKey:@"key"] forKey:@"code"];
                [areaNode setObject:[node objectForKey:@"value"] forKey:@"name"];
                [areaArray addObject:areaNode];
            }
            finishedBlock(areaArray);
        } else {
            [MBProgressHUD showFailWithText:@"加载失败" andDetailText:message onCompletion:^{
                errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:message]);
            }];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showFailWithText:@"加载失败" andDetailText:[error localizedDescription] onCompletion:^{
            errorBlock(error);
        }];
    }];
}

+ (void)getAllCitiesWithProvinceCode:(NSString *)provinceCode onFinished:(void (^)(NSArray *))finishedBlock onError:(void (^)(NSError *))errorBlock
{
    AFHTTPSessionManager* sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString* url = [NSString stringWithFormat:@"http://%@:%@/jlagent/getAreaList",
                     [PublicInformation getServerDomain],
                     [PublicInformation getHTTPPort]];
    
    MBProgressHUD* hud = [MBProgressHUD showNormalWithText:nil andDetailText:nil];
    
    [sessionManager POST:url parameters:@{@"descr":provinceCode} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSString* code = [responseData objectForKey:@"code"];
        NSString* message = [responseData objectForKey:@"message"];
        if (code.integerValue == 0) {
            [hud hide:YES];
            NSMutableArray* areaArray = [NSMutableArray array];
            for (NSDictionary* node in [responseData objectForKey:@"areaList"]) {
                NSMutableDictionary* areaNode = [NSMutableDictionary dictionary];
                [areaNode setObject:[node objectForKey:@"key"] forKey:@"code"];
                [areaNode setObject:[node objectForKey:@"value"] forKey:@"name"];
                [areaArray addObject:areaNode];
            }
            finishedBlock(areaArray);
        } else {
            [MBProgressHUD showFailWithText:@"加载失败" andDetailText:message onCompletion:^{
                errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:message]);
            }];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud hide:YES];
        [MBProgressHUD showFailWithText:@"加载失败" andDetailText:[error localizedDescription] onCompletion:^{
            errorBlock(error);
        }];
    }];

}


@end
