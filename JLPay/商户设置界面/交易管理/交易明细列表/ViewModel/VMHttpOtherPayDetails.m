//
//  VMHttpOtherPayDetails.m
//  JLPay
//
//  Created by jielian on 16/5/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMHttpOtherPayDetails.h"

@implementation VMHttpOtherPayDetails

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addKVOs];
    }
    return self;
}
- (void)dealloc {
    JLPrint(@";;;;;;;;;;;;;;; dealloc ;;;;;;;;;;;");
    [self.http terminateRequesting];
}


- (void)requestDetailsOnBeginDate:(NSString *)beginDate
                       andEndDate:(NSString *)endDate
                       onFinished:(void (^)(void))finishedBlock
                          onError:(void (^)(NSError *))errorBlock
{
    @weakify(self);
    [self.http requestingOnPackingHandle:^(ASIFormDataRequest *http) {
        [http addPostValue:beginDate forKey:@"queryBeginTime"];
        [http addPostValue:endDate forKey:@"queryEndTime"];
        [http addPostValue:[PublicInformation returnBusiness] forKey:@"mchtNo"];
        [http addPostValue:@"1.0" forKey:@"versionId"];

        NSMutableString* md5Source = [NSMutableString string];
        [md5Source appendFormat:@"mchtNo=%@&", [PublicInformation returnBusiness]];
        [md5Source appendFormat:@"queryBeginTime=%@&", beginDate];
        [md5Source appendFormat:@"queryEndTime=%@&", endDate];
        [md5Source appendString:@"versionId=1.0&"];
        [md5Source appendString:@"key=shisongcheng"];
        [http addPostValue:[[MD5Util encryptWithSource:md5Source] lowercaseString] forKey:@"sign"];
    } onSucBlock:^(NSDictionary *info) {
        @strongify(self);
        NSArray* details = [info objectForKey:@"DetailList"];
        if (!details || details.count == 0) {
            self.detailsData.originDetails = [NSArray array];
            if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:908 localizedDescription:@"查无明细"]);
        } else {
            self.detailsData.originDetails = [details copy];
            if (finishedBlock) finishedBlock();
        }
    } onErrBlock:^(NSError *error) {
        @strongify(self);
        self.detailsData.originDetails = [NSArray array];
        if (errorBlock) errorBlock(error);
    }];
}

# pragma mask 1 KVO
- (void) addKVOs {
    /* 总金额 */
    RAC(self, totalMoney) = RACObserve(self.detailsData, totalMoney);
}

# pragma mask 2 UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.detailsData.separatedDetailsOnDates && self.detailsData.separatedDetailsOnDates.count > 0) {
        return self.detailsData.separatedDetailsOnDates.count;
    } else {
        return 0;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* datas = [self.detailsData.separatedDetailsOnDates objectAtIndex:section];
    return datas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"cellIdentifier";
    TransDetailTBVCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[TransDetailTBVCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.moneyLabel.text = [@"￥" stringByAppendingString:[self.detailsData moneyAtDateIndex:indexPath.section andInnerIndex:indexPath.row]];
    cell.transTypeLabel.text = [self.detailsData transTypeAtDateIndex:indexPath.section andInnerIndex:indexPath.row];
    cell.detailsLabel.text = [@"订单号:" stringByAppendingString:[self.detailsData orderNoAtDateIndex:indexPath.section andInnerIndex:indexPath.row]];
    cell.timeLabel.text = [self.detailsData transTimeAtDateIndex:indexPath.section andInnerIndex:indexPath.row];
    return cell;
}


# pragma mask 4 getter
- (MOtherPayDetails *)detailsData {
    if (!_detailsData) {
        _detailsData = [MOtherPayDetails sharedOtherPayDetails];
    }
    return _detailsData;
}
- (HTTPInstance *)http {
    if (!_http) {
        NSString* url = [NSString stringWithFormat:@"http://%@:%@/onlinepay/queryTradeDetails",
                         [PublicInformation getOnlinePayIp],[PublicInformation getOnlinePayPort]];
        _http = [[HTTPInstance alloc] initWithURLString:url];
    }
    return _http;
}


@end
