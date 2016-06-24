//
//  VMHttpMposDetails.m
//  JLPay
//
//  Created by jielian on 16/5/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMHttpMposDetails.h"

@implementation VMHttpMposDetails

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addKVOs];
    }
    return self;
}
- (void)dealloc {
    JLPrint(@"'''''''''''' VMHttpMposDetails dealloc ''''''''''''''");
    [self.http terminateRequesting];
}

- (void)requestDetailsOnBeginDate:(NSString *)beginDate
                       andEndDate:(NSString *)endDate
                       onFinished:(void (^)(void))finishedBlock
                          onError:(void (^)(NSError *))errorBlock
{
    NameWeakSelf(wself);
    [self.http requestingOnPackingHandle:^(ASIFormDataRequest *http) {
        [http addRequestHeader:@"queryBeginTime" value:beginDate];
        [http addRequestHeader:@"queryEndTime" value:endDate];
        [http addRequestHeader:@"mchntNo" value:[PublicInformation returnBusiness]];
    } onSucBlock:^(NSDictionary *info) {
        NSArray* details = [info objectForKey:@"MchntInfoList"];
        if (!details || details.count == 0) {
            wself.detailsData.originDetails = [NSArray array];
            if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:908 localizedDescription:@"查无明细"]);
        } else {
            wself.detailsData.originDetails = [details copy];
            if (finishedBlock) finishedBlock();
        }
    } onErrBlock:^(NSError *error) {
        wself.detailsData.originDetails = [NSArray array];
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
    cell.detailsLabel.text = [@"卡号:" stringByAppendingString:[self.detailsData cardNoAtDateIndex:indexPath.section andInnerIndex:indexPath.row]];
    cell.timeLabel.text = [self.detailsData transTimeAtDateIndex:indexPath.section andInnerIndex:indexPath.row];
    return cell;
}

# pragma mask 4 getter
- (MMposDetails *)detailsData {
    if (!_detailsData) {
        _detailsData = [MMposDetails sharedMposDetails];
    }
    return _detailsData;
}
- (HTTPInstance *)http {
    if (!_http) {
        NSString* url = [NSString stringWithFormat:@"http://%@:%@/jlagent/getMchntInfo",
                         [PublicInformation getServerDomain],[PublicInformation getHTTPPort]];
        _http = [[HTTPInstance alloc] initWithURLString:url];
    }
    return _http;
}

@end
