//
//  VMHttpAlipay.m
//  JLPay
//
//  Created by jielian on 16/4/14.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMHttpAlipay.h"

@implementation VMHttpAlipay


- (void) startAlipayTransOnFinished:(void (^) (void))finished onError:(void (^) (NSError* error))errorBlock {
    NameWeakSelf(wself);
    [self.http requestingOnPackingHandle:^(ASIFormDataRequest *http) {
        [http addPostValue:[ModelUserLoginInformation businessNumber] forKey:@"mchtNo"];
        [http addPostValue:wself.payCode forKey:@"payCode"];
        [http addPostValue:wself.payAmount forKey:@"payMoney"];
        [http addPostValue:[PublicInformation exchangeNumber] forKey:@"orderNo"];
        [http addPostValue:@"" forKey:@"alipayAcc"];
        [http addPostValue:@"" forKey:@"alipayPanter"];
        [http addPostValue:@"" forKey:@"alipayKey"];
        [http addPostValue:@"" forKey:@"orderTitle"];
        [http addPostValue:@"" forKey:@"goodsDes"];
        [http addPostValue:@"" forKey:@"authCode"];
        [http addPostValue:@"" forKey:@"storeNo"];
        [http addPostValue:[wself signMadeByMchtNo:[ModelUserLoginInformation businessNumber] andPayCode:wself.payCode] forKey:@"sign"];
    } onSucBlock:^(NSDictionary *info) {
        finished();
    } onErrBlock:^(NSError *error) {
        errorBlock(error);
    }];
}
- (void) stopAlipayTrans {
    [self.http terminateRequesting];
}


- (NSString*) signMadeByMchtNo:(NSString*)mchtNo andPayCode:(NSString*)payCode {
    NSString* source = [NSString stringWithFormat:@"mchtNo=%@&payCode=%@&key=shisongcheng", mchtNo, payCode];
    return [MD5Util encryptWithSource:source];
}


# pragma mask 4 getter
- (HTTPInstance *)http {
    if (!_http) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/onlinepay/alibarCodePay",[PublicInformation getServerDomain],[PublicInformation getHTTPPort]];
        _http = [[HTTPInstance alloc] initWithURLString:urlString];
    }
    return _http;
}


@end
