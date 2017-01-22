//
//  TLVC_vmListRequesterMpos.m
//  JLPay
//
//  Created by jielian on 2017/1/13.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "TLVC_vmListRequesterMpos.h"
#import <ReactiveCocoa.h>
#import "Define_Header.h"
#import <AFNetworking.h>
#import "MBProgressHUD+CustomSate.h"

@implementation TLVC_vmListRequesterMpos


# pragma mask 2 tools

- (NSString*) urlString {
    return [NSString stringWithFormat:@"http://%@:%@/jlagent/getMchntInfo", [PublicInformation getServerDomain], [PublicInformation getHTTPPort]];
}

- (NSDictionary*) params {
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:self.mchntNo forKey:@"mchntNo"];
    [params setObject:self.queryBeginTime forKey:@"queryBeginTime"];
    NSString* curDate = [[PublicInformation currentDateAndTime] substringToIndex:4 + 2 + 2];
    [params setObject:[self.queryEndTime integerValue] > curDate.integerValue ? curDate : self.queryEndTime forKey:@"queryEndTime"];
    return params;
}

- (void) analyseDetaiListWithList:(NSArray*)originList {
    NSMutableArray* list = [NSMutableArray arrayWithCapacity:originList.count];
    for (NSDictionary* node in originList) {
        [list addObject:[TLVC_mDetailMpos detailWidthNode:node]];
    }
    self.detailList = [NSArray arrayWithArray:list];
}

# pragma mask 4 getter

- (NSString *)mchntNo {
    if (!_mchntNo) {
        _mchntNo = [PublicInformation returnBusiness];
    }
    return _mchntNo;
}

- (NSString *)termNo {
    if (!_termNo) {
        _termNo = [PublicInformation returnTerminal];
    }
    return _termNo;
}

- (RACCommand *)cmd_requesting {
    if (!_cmd_requesting) {
        @weakify(self);
        _cmd_requesting = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                AFHTTPSessionManager* http = [AFHTTPSessionManager manager];
                http.requestSerializer = [AFHTTPRequestSerializer serializer];
                // 这个奇葩的接口，将参数写在了头部
                NSDictionary* params = [self params];
                for (NSString* key in params) {
                    [http.requestSerializer setValue:[params objectForKey:key] forHTTPHeaderField:key];
                }
                http.responseSerializer = [AFHTTPResponseSerializer serializer];
                http.requestSerializer.timeoutInterval = 20;
                NameWeakSelf(wself);
                [MBProgressHUD showNormalWithText:@"数据加载中..." andDetailText:nil];
                
                [http POST:[self urlString] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSError* error;
                    NSDictionary* resData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
                    if (!resData || error) {
                        [MBProgressHUD showFailWithText:@"加载失败" andDetailText:nil onCompletion:nil];
                        [subscriber sendError:error];
                    } else {
                        NSInteger code = [[resData objectForKey:@"HttpResult"] integerValue];
                        NSString* message = [resData objectForKey:@"HttpMessage"];
                        if (code == 0) {
                            [wself analyseDetaiListWithList:[resData objectForKey:@"MchntInfoList"]];
                            [MBProgressHUD showSuccessWithText:@"加载成功" andDetailText:nil onCompletion:nil];
                            [subscriber sendCompleted];
                        } else {
                            [MBProgressHUD showFailWithText:@"加载失败" andDetailText:nil onCompletion:nil];
                            [subscriber sendError:[NSError errorWithDomain:@"" code:code localizedDescription:message]];
                        }
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [MBProgressHUD showFailWithText:@"加载失败" andDetailText:nil onCompletion:nil];
                    [subscriber sendError:error];
                }];
                return nil;
            }] replayLast] materialize];
        }];
    }
    return _cmd_requesting;
}

@end
