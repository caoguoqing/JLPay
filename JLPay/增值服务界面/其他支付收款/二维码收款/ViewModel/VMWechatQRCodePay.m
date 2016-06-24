//
//  VMWechatQRCodePay.m
//  JLPay
//
//  Created by jielian on 16/5/12.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMWechatQRCodePay.h"

@implementation VMWechatQRCodePay
- (instancetype)init {
    self = [super init];
    if (self) {
        [self addKVOs];
    }
    return self;
}
- (void)dealloc {
    JLPrint(@"-=-=-=-=-=-=-=-=- VMWechatQRCodePay dealloc");
    [self.httpQRCode terminateRequesting];
    [self.httpEnquiring terminateRequesting];
}

- (void) addKVOs {
    @weakify(self);
        
    /* 监控流程 */
    [[RACObserve(self, state) replayLast] subscribeNext:^(NSNumber* state) {
        @strongify(self);
        switch (state.integerValue) {
            case VMWechatQRCodeRequesting:
                [self doQRCodeRequesting];
                break;
            case VMWechatQRCodeRequestedSuc:
                self.QRCodeImage = [ViewModelQRImageMaker imageForQRCode:[self.httpQRCodeResult objectForKey:@"pic"]];
                break;
            case VMWechatPayStateEnquiring:
                [self doPayResultEnquiring];
                break;
            default:
                break;
        }
    }];
        
}

# pragma mask 1 action
// -- 请求二维码
- (void) doQRCodeRequesting {
    NameWeakSelf(wself);
    self.stateMessage = @"正在生成二维码...";
    [self.httpQRCode requestingOnPackingHandle:^(ASIFormDataRequest *http) {
        [wself makeMD5bySignkeys:wself.keyQRCodeRequestList];
        for (NSString* key in wself.keyQRCodeRequestList) {
            [http addPostValue:[wself.httpQRCodeResult objectForKey:key] forKey:key];
        }
    } onSucBlock:^(NSDictionary *info) {
        [wself.httpQRCodeResult addEntriesFromDictionary:info];
        wself.state = VMWechatQRCodeRequestedSuc;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            wself.state = VMWechatPayStateEnquiring; // KVO: 启动轮询
        });
    } onErrBlock:^(NSError *error) {
        wself.stateMessage = @"获取二维码失败";
        wself.error = [error copy];
        wself.state = VMWechatQRCodeRequestedFail;
    }];
}
// -- 轮训交易结果
- (void) doPayResultEnquiring {
    NameWeakSelf(wself);
    // 查询: 轮询(间隔1秒)
    self.stateMessage = @"正在查询交易结果，请勿离开...";
    [self.httpQRCodeResult setObject:@"wxOrderQuery" forKey:@"service"];
        
    [self.httpEnquiring requestingOnPackingHandle:^(ASIFormDataRequest *http) {
        [wself makeMD5bySignkeys:wself.keyPayEnquireList];
        for (NSString* columnName in wself.keyPayEnquireList) {
            [http addPostValue:[wself.httpQRCodeResult objectForKey:columnName] forKey:columnName];
        }
    } onSucBlock:^(NSDictionary *info) {
        [wself.httpQRCodeResult addEntriesFromDictionary:info];
        wself.stateMessage = @"微信收款成功!";
        wself.state = VMWechatPayStateSuc;
    } onErrBlock:^(NSError *error) {
        NSInteger errCode = [error code];
        if (errCode == 901 || errCode == 95) { // 支付中\超时
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                wself.state = VMWechatPayStateEnquiring;
            });
        }
        else { // 失败
            wself.stateMessage = @"微信收款失败!";
            wself.error = [error copy];
            wself.state = VMWechatPayStateFail;
        }
    }];
}

# pragma mask 3 tools 
// -- 订单号生成
- (NSString*) orderNumberWithRandomNumber {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMddHHmmssSSS";
    NSString* orderNumber = [dateFormatter stringFromDate:[NSDate date]];
    NSString* randomString = [NSString stringWithFormat:@"%u",arc4random()];
    int len = (int)randomString.length;
    if (len < 24 - orderNumber.length) {
        for (int i = 0; i < 24 - orderNumber.length - len; i++) {
            randomString = [randomString stringByAppendingString:@"0"];
        }
    }
    else if (randomString.length > 24 - orderNumber.length) {
        randomString = [randomString substringToIndex:24 - orderNumber.length];
    }
    return [orderNumber stringByAppendingString:randomString];
}

// -- 生成MD5校验串，并更新到字典
- (void) makeMD5bySignkeys:(NSArray*)keys {
    NSMutableString* source = [NSMutableString string];
    for (NSString* key in keys) {
        if (![key isEqualToString:@"sign"]) {
            [source appendFormat:@"%@=%@&", key, [self.httpQRCodeResult objectForKey:key]];
        }
    }
    [source appendString:@"key=shisongcheng"];
    NSString* md5Pin = [[MD5Util encryptWithSource:source] lowercaseString];
    [self.httpQRCodeResult setObject:md5Pin forKey:@"sign"];
}



# pragma mask 4 getter
- (HTTPInstance *)httpQRCode {
    if (!_httpQRCode) {
        NSString* url = [NSString stringWithFormat:@"http://%@:%@/onlinepay/wxDimCodePay",
                         [PublicInformation getOnlinePayIp],[PublicInformation getOnlinePayPort]];
        _httpQRCode = [[HTTPInstance alloc] initWithURLString:url];
    }
    return _httpQRCode;
}

- (HTTPInstance *)httpEnquiring {
    if (!_httpEnquiring) {
        NSString* url = [NSString stringWithFormat:@"http://%@:%@/onlinepay/wxOrderQuery",
                         [PublicInformation getOnlinePayIp],[PublicInformation getOnlinePayPort]];
        _httpEnquiring = [[HTTPInstance alloc] initWithURLString:url];
    }
    return _httpEnquiring;
}

- (NSArray *)keyQRCodeRequestList {
    if (!_keyQRCodeRequestList) {
        _keyQRCodeRequestList = @[@"mchtNo",
                                  @"orderNo",
                                  @"service",
                                  @"versionId",
                                  @"payMoney",
                                  @"goodName",
                                  @"sign"];
    }
    return _keyQRCodeRequestList;
}

- (NSArray *)keyPayEnquireList {
    if (!_keyPayEnquireList) {
        _keyPayEnquireList = @[@"mchtNo",
                               @"orderNo",
                               @"service",
                               @"versionId",
                               @"sign"];
    }
    return _keyPayEnquireList;
}

- (NSMutableDictionary *)httpQRCodeResult {
    if (!_httpQRCodeResult) {
        _httpQRCodeResult = [NSMutableDictionary dictionary];
        [_httpQRCodeResult setObject:[PublicInformation returnBusiness] forKey:@"mchtNo"];
        [_httpQRCodeResult setObject:[self orderNumberWithRandomNumber] forKey:@"orderNo"];
        [_httpQRCodeResult setObject:@"wxDimcodePay" forKey:@"service"];
        [_httpQRCodeResult setObject:@"1.0" forKey:@"versionId"];
        [_httpQRCodeResult setObject:self.payGoodsName forKey:@"goodName"];
        [_httpQRCodeResult setObject:[PublicInformation intMoneyFromDotMoney:self.payMoney] forKey:@"payMoney"];
    }
    return _httpQRCodeResult;
}
- (UIImage *)QRCodeImage {
    if (!_QRCodeImage) {
        _QRCodeImage = [UIImage imageNamed:@"QRCodeImage"];
    }
    return _QRCodeImage;
}


@end
