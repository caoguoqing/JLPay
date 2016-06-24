//
//  VMHttpWechatPay.m
//  JLPay
//
//  Created by jielian on 16/4/15.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMHttpWechatPay.h"


static NSString* WechatDisplayColumnNameOrderNo = @"订单编号:";
static NSString* WechatDisplayColumnNameBuyerId = @"买家账号:";
static NSString* WechatDisplayColumnNamePaidOrderNo = @"微信订单编号:";
static NSString* WechatDisplayColumnNamePaidTime = @"支付时间:";
static NSString* WechatDisplayColumnNameRevokeOrderNo = @"撤销订单号:";
static NSString* WechatDisplayColumnNameRevokeTime = @"撤销时间:";





@implementation VMHttpWechatPay

- (instancetype)init {
    self = [super init];
    if (self) {
        self.stateMessage = @"交易处理中...";
        self.payCode = [[VMOtherPayType sharedInstance] payCode];
        self.payAmount = [[VMOtherPayType sharedInstance] payAmount];
        self.goodsName = [[VMOtherPayType sharedInstance] goodsName];
        [self actionOnKVO];
    }
    return self;
}
- (void)dealloc {
    [self doTerminateAndClean];
}


- (void) actionOnKVO {
    @weakify(self);
    [RACObserve(self, state) subscribeNext:^(NSNumber* state) {
        @strongify(self);
        switch (state.integerValue) {
            case VMHttpWechatPayStatePaying:
            {
                if (self.payType == VMHttpWechatPayTypePay) {
                    [self doPaying];
                } else {
                    [self doRevoking];
                }
            }
                break;
            case VMHttpWechatPayStateEnquiring:
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self doCircleEnquiring];
                });
            }
                break;
            case VMHttpWechatPayStateTerminate:
            {
                [self doTerminateAndClean];
            }
                break;
            case VMHttpWechatPayStatePaySuc:
            case VMHttpWechatPayStatePayFail:
            {
                // 停止轮询
                [self stopCircleEnquiring];
            }
                break;
            default:
                break;
        }
    }];
}

// -- 终止交易并清空列表
- (void) doTerminateAndClean {
    [self.httpPays terminateRequesting];
    // 清理队列
}


// -- 支付
- (void) doPaying {
    self.stateMessage = @"交易处理中...";
    self.httpPays = [self httpForTransName:@"winxinPay"];
    NameWeakSelf(wself);
    [self.httpPays requestingOnPackingHandle:^(ASIFormDataRequest *http) {
        [wself makeMD5bySignkeys:wself.keyPayList];
        for (NSString* columnName in wself.keyPayList) {
            [http addPostValue:[wself.columnsDic objectForKey:columnName] forKey:columnName];
        }
    } onSucBlock:^(NSDictionary *info) {
        [wself.columnsDic addEntriesFromDictionary:info]; // 重复的字段会不会导致失败.....?????
        wself.stateMessage = @"微信收款成功!";
        [wself resetDisplaidColumnNames];
        wself.state = VMHttpWechatPayStatePaySuc;
    } onErrBlock:^(NSError *error) {
        NSInteger errCode = [error code];
        JLPrint(@"支付结果:[%d]",errCode);
        if (errCode == 901 || errCode == 95) { // 支付中\超时
            wself.state = VMHttpWechatPayStateEnquiring;
        }
        else { // 失败
            wself.stateMessage = @"微信收款失败!";
            wself.payError = [error copy];
            wself.state = VMHttpWechatPayStatePayFail;
        }
    }];
}

// -- 撤销
- (void) doRevoking {
    self.stateMessage = @"正在撤销交易...";
    self.httpPays = [self httpForTransName:@"wxOrderRevoke"];
    // 更新订单编号、撤销订单号
    [self.columnsDic setObject:[self orderNumberWithRandomNumber] forKey:@"orderNo"];
    [self.columnsDic setObject:[self.columnsDic objectForKey:@"wxOrderNo"] forKey:@"revokeOrder"];
    [self.columnsDic setObject:@"wxOrderRevoke" forKey:@"service"];

    NameWeakSelf(wself);
    [self.httpPays requestingOnPackingHandle:^(ASIFormDataRequest *http) {
        [wself makeMD5bySignkeys:wself.keyRevokeList];
        for (NSString* columnName in wself.keyRevokeList) {
            [http addPostValue:[wself.columnsDic objectForKey:columnName] forKey:columnName];
        }
    } onSucBlock:^(NSDictionary *info) {
        [wself.columnsDic addEntriesFromDictionary:info]; // 重复的字段会不会导致失败.....?????
        wself.stateMessage = @"撤销成功!";
        [wself resetDisplaidColumnNames];
        wself.state = VMHttpWechatPayStatePaySuc;
    } onErrBlock:^(NSError *error) {
        NSInteger errCode = [error code];
        if (errCode == 901 || errCode == 95) { // 撤销中\超时
            wself.state = VMHttpWechatPayStateEnquiring;
        }
        else { // 失败
            wself.stateMessage = @"撤销失败!";
            wself.payError = [error copy];
            wself.state = VMHttpWechatPayStatePayFail;
        }
    }];
}


// 查询: 轮询(间隔5秒)
- (void) doCircleEnquiring {
    self.stateMessage = @"交易确认中...";
    self.httpPays = [self httpForTransName:@"wxOrderQuery"];
    [self.columnsDic setObject:@"wxOrderQuery" forKey:@"service"];
    
    NameWeakSelf(wself);
    [self.httpPays requestingOnPackingHandle:^(ASIFormDataRequest *http) {
        [wself makeMD5bySignkeys:wself.keyEnquireList];
        for (NSString* columnName in wself.keyEnquireList) {
            [http addPostValue:[wself.columnsDic objectForKey:columnName] forKey:columnName];
        }
    } onSucBlock:^(NSDictionary *info) {
        [wself.columnsDic addEntriesFromDictionary:info]; // 重复的字段会不会导致失败.....?????
        wself.stateMessage = @"微信收款成功!";
        [wself resetDisplaidColumnNames];
        wself.state = VMHttpWechatPayStatePaySuc;
    } onErrBlock:^(NSError *error) {
        NSInteger errCode = [error code];

        if (errCode == 901 || errCode == 95) { // 支付中\超时
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                wself.state = VMHttpWechatPayStateEnquiring;
            });
        }
        else { // 失败
            wself.stateMessage = @"微信收款失败!";
            wself.payError = [error copy];
            wself.state = VMHttpWechatPayStatePayFail;
        }
    }];
}
- (void) stopCircleEnquiring {
    [self.httpPays terminateRequesting];
}





# pragma maks 2 UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayColumnsName.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"cellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, tableView.rowHeight) andScale:0.6]];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, tableView.rowHeight) andScale:0.6]];
    }
    
    cell.textLabel.text = [self.displayColumnsName objectAtIndex:indexPath.row];
    
    NSString* key = [self.columnsDic objectForKey:cell.textLabel.text];
    
    if ([cell.textLabel.text isEqualToString:WechatDisplayColumnNameBuyerId]) {
        cell.detailTextLabel.text = [self.columnsDic objectForKey:key];
    }
    else if ([cell.textLabel.text isEqualToString:WechatDisplayColumnNamePaidTime]) {
        NSString* allTime = [self.columnsDic objectForKey:key];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",
                                     [allTime substringToIndex:4],
                                     [allTime substringWithRange:NSMakeRange(4, 2)],
                                     [allTime substringWithRange:NSMakeRange(6, 2)],
                                     [allTime substringWithRange:NSMakeRange(8, 2)],
                                     [allTime substringWithRange:NSMakeRange(10, 2)],
                                     [allTime substringWithRange:NSMakeRange(12, 2)]];
    }
    else {
        cell.detailTextLabel.text = [self cuttingMidSomeCharWithString:[self.columnsDic objectForKey:key]];
    }
    
    return cell;
}


# pragma mask 3 private interface
// -- http生成器
- (HTTPInstance*) httpForTransName:(NSString*)transName {
    NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/onlinepay/%@",[PublicInformation getOnlinePayIp],[PublicInformation getOnlinePayPort], transName];
    return [[HTTPInstance alloc] initWithURLString:urlString];
}
// -- 生成订单号: yyyyMMddHHmmssSSS + businessNumber
- (NSString*) orderNumberWithBusinessNumber:(NSString*)businessNumber {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMddHHmmssSSS";
    NSString* orderNumber = [dateFormatter stringFromDate:[NSDate date]];
    return [orderNumber stringByAppendingString:businessNumber];
}
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
            [source appendFormat:@"%@=%@&", key, [self.columnsDic objectForKey:key]];
        }
    }
    [source appendString:@"key=shisongcheng"];
    NSString* md5Pin = [[MD5Util encryptWithSource:source] lowercaseString];
    [self.columnsDic setObject:md5Pin forKey:@"sign"];
}
// -- 隐藏字符串中间位数
- (NSString*) cuttingMidSomeCharWithString:(NSString*)source {
    NSMutableString* cuttingString = [NSMutableString string];
    if (source && source.length > 6 + 4) {
        [cuttingString appendString:[source substringToIndex:6]];
        [cuttingString appendString:@"****"];
        [cuttingString appendString:[source substringFromIndex:source.length - 4]];
    }
    return cuttingString;
}
// -- 重置需显示的字段名
- (void) resetDisplaidColumnNames {
    if (self.payType == VMHttpWechatPayTypePay) { // pay suc
        [self.displayColumnsName removeAllObjects];
        [self.displayColumnsName addObject:WechatDisplayColumnNameOrderNo];
        [self.displayColumnsName addObject:WechatDisplayColumnNamePaidTime];
    }
    else if (self.state == VMHttpWechatPayTypeRevoke) { // revoke suc
        [self.displayColumnsName removeAllObjects];
        [self.displayColumnsName addObject:WechatDisplayColumnNameOrderNo];
        [self.displayColumnsName addObject:WechatDisplayColumnNameRevokeTime];
    }
}




# pragma mask 4 getter
- (NSArray *)keyPayList {
    if (!_keyPayList) {
        _keyPayList = @[@"mchtNo",
                        @"orderNo",
                        @"service",
                        @"versionId",
                        @"payCode",
                        @"payMoney",
                        @"goodName",
                        @"sign"];
    }
    return _keyPayList;
}
- (NSArray *)keyRevokeList {
    if (!_keyRevokeList) {
        _keyRevokeList = @[@"mchtNo",
                           @"orderNo",
                           @"revokeOrder",
                           @"service",
                           @"versionId",
                           @"sign"];
    }
    return _keyRevokeList;
}
- (NSArray *)keyEnquireList {
    if (!_keyEnquireList) {
        _keyEnquireList = @[@"mchtNo",
                            @"orderNo",
                            @"service",
                            @"versionId",
                            @"sign"];
    }
    return _keyEnquireList;
}

- (NSMutableDictionary *)columnsDic {
    if (!_columnsDic) {
        _columnsDic = [NSMutableDictionary dictionary];
        for (NSString* key in self.keyPayList) {
            if ([key isEqualToString:@"mchtNo"]) {
                [_columnsDic setObject:[PublicInformation returnBusiness] forKey:key];
            }
            else if ([key isEqualToString:@"payCode"]) {
                [_columnsDic setObject:self.payCode forKey:key];
            }
            else if ([key isEqualToString:@"payMoney"]) {
                [_columnsDic setObject:[PublicInformation intMoneyFromDotMoney:self.payAmount] forKey:key];
            }
            else if ([key isEqualToString:@"orderNo"]) {
                [_columnsDic setObject:[self orderNumberWithRandomNumber] forKey:key];
            }
            else if ([key isEqualToString:@"goodName"]) {
                [_columnsDic setObject:[VMOtherPayType sharedInstance].goodsName forKey:key];
            }
            else if ([key isEqualToString:@"orderTitle"]) {
                [_columnsDic setObject:[VMOtherPayType sharedInstance].orderDes forKey:key];
            }
            /* 以下信息默认 */
            else if ([key isEqualToString:@"service"]) {
                [_columnsDic setObject:@"wxBarcodePay" forKey:key];
            }
            else if ([key isEqualToString:@"versionId"]) {
                [_columnsDic setObject:@"1.0" forKey:key];
            }
        }
        [_columnsDic setObject:@"orderNo" forKey:WechatDisplayColumnNameOrderNo];
        [_columnsDic setObject:@"buyerId" forKey:WechatDisplayColumnNameBuyerId];
        [_columnsDic setObject:@"wxOrderNo" forKey:WechatDisplayColumnNamePaidOrderNo];
        [_columnsDic setObject:@"payDateTime" forKey:WechatDisplayColumnNamePaidTime];
        [_columnsDic setObject:@"wxOrderNo" forKey:WechatDisplayColumnNameRevokeOrderNo];
        [_columnsDic setObject:@"payDateTime" forKey:WechatDisplayColumnNameRevokeTime];
    }
    return _columnsDic;
}
- (NSMutableArray *)displayColumnsName {
    if (!_displayColumnsName) {
        _displayColumnsName = [NSMutableArray array];
        [_displayColumnsName addObject:WechatDisplayColumnNameOrderNo];
    }
    return _displayColumnsName;
}
- (NSMutableArray *)httpEnquireArray {
    if (!_httpEnquireArray) {
        _httpEnquireArray = [NSMutableArray array];
    }
    return _httpEnquireArray;
}


@end
