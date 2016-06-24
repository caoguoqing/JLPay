//
//  VMHttpAlipay.m
//  JLPay
//
//  Created by jielian on 16/4/14.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMHttpAlipay.h"



static NSString* AlipayDisplayColumnNameOrderNo = @"订单编号";
static NSString* AlipayDisplayColumnNameBuyerId = @"买家账号";
static NSString* AlipayDisplayColumnNamePaidOrderNo = @"支付宝订单编号";
static NSString* AlipayDisplayColumnNamePaidTime = @"支付时间";
static NSString* AlipayDisplayColumnNameRevokeOrderNo = @"撤销订单号";
static NSString* AlipayDisplayColumnNameRevokeTime = @"撤销时间";


@implementation VMHttpAlipay

- (instancetype)init {
    self = [super init];
    if (self) {
        self.state = 0;
        self.stateMessage = @"交易处理中...";
        self.payCode = [[VMOtherPayType sharedInstance] payCode];
        self.payAmount = [[VMOtherPayType sharedInstance] payAmount];
        self.goodsName = [[VMOtherPayType sharedInstance] goodsName];
//        self.orderDes = [[VMOtherPayType sharedInstance] orderDes];
    }
    return self;
}

- (void) startPayingOnFinished:(void (^) (void))finished onError:(void (^) (NSError* error))errorBlock {
    self.state = 0;
    self.stateMessage = @"交易处理中...";
    
    // 先从后台获取商户的支付宝账户信息，然后发送支付；失败则直接错误退出
    
    NameWeakSelf(wself);
    [self.http requestingOnPackingHandle:^(ASIFormDataRequest *http) {
        [wself updateColumnDicOnSignKeys:self.keyPayList];
        for (NSString* key in wself.keyPayList) {
            [http addPostValue:[wself.columnsDic objectForKey:key] forKey:key];
        }
    } onSucBlock:^(NSDictionary *info) {
        
        /* 支付成功后将支付结果信息保存到字典，留待撤销用 */
        [wself.columnsDic addEntriesFromDictionary:info]; // 重复的字段会不会导致失败.....?????
        
        wself.state = 1;
        wself.stateMessage = @"支付宝收款成功!";
//        wself.paidOrderNumber = [info objectForKey:@"alipayOrderNo"];
//        wself.buyerId = [info objectForKey:@"buyerId"];
//        wself.transTime = [info objectForKey:@"payDateTime"];
        [wself resetDisplaidColumnNames];
        
        if (finished) finished();
    } onErrBlock:^(NSError *error) {
        wself.state = -1;
        wself.stateMessage = @"支付宝收款失败!";
        if (errorBlock) errorBlock(error);
    }];
}

- (void)startRevokeOnFinished:(void (^)(void))finished onError:(void (^)(NSError *))errorBlock {
    self.state = 0;
    self.stateMessage = @"正在撤销交易...";
    self.http = [self httpForTransName:@"alipayOrderRevoke"];
    // 更新订单编号、撤销订单号
    self.orderNumber = [self orderNumberWithRandomNumber];
    [self.columnsDic setObject:self.orderNumber forKey:@"orderNo"];
    [self.columnsDic setObject:[self.columnsDic objectForKey:@"alipayOrderNo"] forKey:@"revokeOrder"];
    
    NameWeakSelf(wself);
    [self.http requestingOnPackingHandle:^(ASIFormDataRequest *http) {
        [wself updateColumnDicOnSignKeys:self.keyRevokeList];
        for (NSString* key in wself.keyRevokeList) {
            [http addPostValue:[wself.columnsDic objectForKey:key] forKey:key];
        }
    } onSucBlock:^(NSDictionary *info) {
        [wself.columnsDic addEntriesFromDictionary:info]; // 重复的字段会不会导致失败.....?????
        wself.state = 2;
        wself.stateMessage = @"撤销成功!";
//        wself.transTime = nil;
        [wself resetDisplaidColumnNames];
        
        if (finished) finished();
    } onErrBlock:^(NSError *error) {
        wself.state = -2;
        wself.stateMessage = @"撤销失败!";
        if (errorBlock) errorBlock(error);
    }];
}

- (void) stopTrans {
    [self.http terminateRequesting];
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
    }
    
    cell.textLabel.text = [self.displayColumnsName objectAtIndex:indexPath.row];
    NSString* key = [self.columnsDic objectForKey:cell.textLabel.text];
    if ([key isEqualToString:AlipayDisplayColumnNameBuyerId] ||
        [key isEqualToString:AlipayDisplayColumnNamePaidTime] ||
        [key isEqualToString:AlipayDisplayColumnNameRevokeTime])
    {
        cell.detailTextLabel.text = [self.columnsDic objectForKey:key];
    }
    else {
        cell.detailTextLabel.text = [self cuttingMidSomeCharWithString:[self.columnsDic objectForKey:key]];
    }
    
    return cell;
}


# pragma mask 3 private interface

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
    int len = randomString.length;
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

// -- 更新columns
- (void) updateColumnDicOnSignKeys:(NSArray*)keys {
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
    if (self.state == 1) { // pay suc
        [self.displayColumnsName removeAllObjects];
        [self.displayColumnsName addObject:AlipayDisplayColumnNameOrderNo];
        [self.displayColumnsName addObject:AlipayDisplayColumnNameBuyerId];
        [self.displayColumnsName addObject:AlipayDisplayColumnNamePaidOrderNo];
        [self.displayColumnsName addObject:AlipayDisplayColumnNamePaidTime];
    }
    else if (self.state == 2) { // revoke suc
        [self.displayColumnsName removeAllObjects];
        [self.displayColumnsName addObject:AlipayDisplayColumnNameOrderNo];
        [self.displayColumnsName addObject:AlipayDisplayColumnNameBuyerId];
        [self.displayColumnsName addObject:AlipayDisplayColumnNameRevokeOrderNo];
        [self.displayColumnsName addObject:AlipayDisplayColumnNameRevokeTime];
    }
}


- (HTTPInstance*) httpForTransName:(NSString*)transName {
    NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/onlinepay/%@",[PublicInformation getOnlinePayIp],[PublicInformation getOnlinePayPort], transName];
    return [[HTTPInstance alloc] initWithURLString:urlString];
}


# pragma mask 4 getter
- (HTTPInstance *)http {
    if (!_http) {
        _http = [self httpForTransName:@"alibarCodePay"];
    }
    return _http;
}
- (NSArray *)keyPayList {
    if (!_keyPayList) {
        _keyPayList = @[@"mchtNo",
                     @"payCode",
                     @"payMoney",
                     @"orderNo",
                     @"alipayAcc",
                     @"alipayPanter",
                     @"alipayKey",
                     @"orderTitle",
                     @"goodsDes",
                     @"authCode",
                     @"storeNo",
                     @"sign"];
    }
    return _keyPayList;
}
- (NSArray *)keyRevokeList {
    if (!_keyRevokeList) {
        _keyRevokeList = @[@"mchtNo",
                           @"orderNo",
                           @"revokeOrder",
                           @"alipayPanter",
                           @"authCode",
                           @"sign"];
    }
    return _keyRevokeList;
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
                [_columnsDic setObject:self.orderNumber forKey:key];
            }
            else if ([key isEqualToString:@"goodsDes"]) {
                [_columnsDic setObject:self.goodsName forKey:key];
            }
            else if ([key isEqualToString:@"orderTitle"]) {
                [_columnsDic setObject:[VMOtherPayType sharedInstance].orderDes forKey:key];
            }
            
            /* 以下信息都要从后台获取 */
            else if ([key isEqualToString:@"alipayAcc"]) {
                [_columnsDic setObject:@"service@cccpay.cn" forKey:key];
            }
            else if ([key isEqualToString:@"alipayPanter"]) {
                [_columnsDic setObject:@"2088021765492648" forKey:key];
            }
            else if ([key isEqualToString:@"alipayKey"]) {
                [_columnsDic setObject:@"j32fsqmz34font98x0hgzl1b3e2mlh0y" forKey:key];
            }
            else if ([key isEqualToString:@"authCode"]) {
                [_columnsDic setObject:@"201603BB8513f04b6c4745e8be97f7cfd8d20X64" forKey:key];
            }
            else if ([key isEqualToString:@"storeNo"]) {
                [_columnsDic setObject:@"120" forKey:key];
            }
        }
        [_columnsDic setObject:@"orderNo" forKey:AlipayDisplayColumnNameOrderNo];
        [_columnsDic setObject:@"buyerId" forKey:AlipayDisplayColumnNameBuyerId];
        [_columnsDic setObject:@"alipayOrderNo" forKey:AlipayDisplayColumnNamePaidOrderNo];
        [_columnsDic setObject:@"payDateTime" forKey:AlipayDisplayColumnNamePaidTime];
        [_columnsDic setObject:@"alipayOrderNo" forKey:AlipayDisplayColumnNameRevokeOrderNo];
        [_columnsDic setObject:@"payDateTime" forKey:AlipayDisplayColumnNameRevokeTime];

    }
    return _columnsDic;
}

- (NSString *)orderNumber {
    if (!_orderNumber) {
        _orderNumber = [self orderNumberWithRandomNumber];
    }
    return _orderNumber;
}
- (NSMutableArray *)displayColumnsName {
    if (!_displayColumnsName) {
        _displayColumnsName = [NSMutableArray array];
        [_displayColumnsName addObject:AlipayDisplayColumnNameOrderNo];
    }
    return _displayColumnsName;
}

@end
