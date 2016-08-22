//
//  MHttpBusinessInfo.m
//  JLPay
//
//  Created by jielian on 16/5/5.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MHttpBusinessInfo.h"

@implementation MHttpBusinessInfo

+ (instancetype) sharedVM {
    static MHttpBusinessInfo* sharedVMHttp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedVMHttp = [[MHttpBusinessInfo alloc] init];
    });
    return sharedVMHttp;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)requestBusinessInfoOnFinished:(void (^) (void))finished onErrorBlock:(void (^)(NSError * error))errorBlock
{
    NameWeakSelf(wself);
    [self.http requestingOnPackingHandle:^(ASIFormDataRequest *http) {
        [http addPostValue:[PublicInformation returnBusiness] forKey:@"mchtInf"];
        NSString* source = [NSString stringWithFormat:@"mchtInf=%@&key=shisongcheng",[PublicInformation returnBusiness]];
        [http addPostValue:[MD5Util encryptWithSource:source] forKey:@"sign"];
    } onSucBlock:^(NSDictionary *info) {
        // packing info
        [wself.businessInfo removeAllObjects];
        [wself.businessInfo addEntriesFromDictionary:info];
        [wself.businessInfo setObject:[info objectForKey:MHttpBusinessKeyMchntNm] forKey:@"mchntNm"];
        [wself.businessInfo setObject:[info objectForKey:MHttpBusinessKeyMail] forKey:@"mail"];

        if (finished) finished();
    } onErrBlock:^(NSError *error) {
        if (errorBlock) errorBlock(error);
    }];
}

- (void)stopRequest {
    [self.http terminateRequesting];
}




# pragma mask 4 getter
- (HTTPInstance *)http {
    if (!_http) {
        NSString* urlString;
        if (TestOrProduce == 11) {
            urlString = [NSString stringWithFormat:@"http://%@:%@/kftagent/queryMchtInfo",
                         [PublicInformation getServerDomain],[PublicInformation getHTTPPort]];
        } else {
            urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/queryMchtInfo",
                         [PublicInformation getServerDomain],[PublicInformation getHTTPPort]];
        }
        _http = [[HTTPInstance alloc] initWithURLString:urlString];
    }
    return _http;
}
- (NSMutableDictionary *)businessInfo {
    if (!_businessInfo) {
        _businessInfo = [NSMutableDictionary dictionary];
    }
    return _businessInfo;
}

@end
