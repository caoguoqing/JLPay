//
//  MBR_HTTP_getBusiness.m
//  JLPay
//
//  Created by jielian on 16/8/30.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MBR_HTTP_getBusiness.h"
#import "Define_Header.h"
#import "MBProgressHUD+CustomSate.h"
#import <AFNetworking.h>


@implementation MBR_HTTP_getBusiness

+ (void)getBusinessListWithRateType:(NSString *)rateType
                        andCityCode:(NSString *)cityCode
                         onFinished:(void (^)(NSArray *))finishedBlock
                            onError:(void (^)(NSError *))errorBlock
{
    AFHTTPSessionManager* httpManager = [AFHTTPSessionManager manager];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString* url = [NSString stringWithFormat:@"http://%@:%@/jlagent/getInstMchtInfo",
                     [PublicInformation getServerDomain],
                     [PublicInformation getHTTPPort]];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:cityCode forKey:@"areaCode"];
    [params setObject:[PublicInformation returnBusiness] forKey:@"mchtNo"];
    [params setObject:rateType forKey:@"feeType"];

    MBProgressHUD* hud = [MBProgressHUD showNormalWithText:nil andDetailText:nil];
    
    
    [httpManager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [hud hide:YES];

        NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSString* code = [responseData objectForKey:@"code"];
        NSString* message = [responseData objectForKey:@"message"];
        NSArray* businessList = [responseData objectForKey:@"merchInfoList"];
        if (code.integerValue == 0) {
            if (businessList && businessList.count > 0) {
                if (finishedBlock) {
                    finishedBlock(businessList);
                }
            } else {
                [MBProgressHUD showWarnWithText:@"查无数据" andDetailText:@"没有查询到商户列表,请切换[费率]或[省/市]后继续!" onCompletion:^{
                }];
                if (errorBlock) {
                    errorBlock([NSError errorWithDomain:@"" code:185 localizedDescription:@"查无数据"]);
                }
            }
            
        } else {
            [MBProgressHUD showFailWithText:@"加载失败" andDetailText:message onCompletion:^{
            }];
            if (errorBlock) {
                errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:message]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud hide:YES];
        [MBProgressHUD showFailWithText:@"加载失败" andDetailText:[error localizedDescription] onCompletion:^{
        }];
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}


@end
