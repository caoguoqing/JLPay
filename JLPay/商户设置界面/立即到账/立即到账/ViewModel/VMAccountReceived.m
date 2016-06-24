//
//  VMAccountReceived.m
//  JLPay
//
//  Created by jielian on 16/5/20.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMAccountReceived.h"

@implementation VMAccountReceived

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addKVOs];
    }
    return self;
}

- (void)dealloc {
    JLPrint(@"-----------VMAccountReceived dealloc-----------");
    [self.http terminateRequesting];
}


# pragma mask 1 KVO

- (void) addKVOs {
    @weakify(self);
    [RACObserve(self, state) subscribeNext:^(NSNumber* state) {
        @strongify(self);
        switch (state.integerValue) {
            case VMAccountReceivedStateRequesting:
            {
                [self doDetailListRequesting];
            }
                break;
            default:
                break;
        }
    }];

}


# pragma mask 2 UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.curDateSettleDetailList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DispatchDetailCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ssssss"];
    if (!cell) {
        cell = [[DispatchDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ssssss"];
    }
    
    NSDictionary* node = [self.curDateSettleDetailList objectAtIndex:indexPath.row];
    NSString* time = [node objectForKey:@"instTime"];
    NSString* date = [node objectForKey:@"instDate"];
    NSString* dateTime = [date stringByAppendingString:time];
    NSInteger settled = [[node objectForKey:@"settleFlag"] integerValue];
    NSInteger clearType = [[node objectForKey:@"clearType"] integerValue];
    
    NSString* clearName = nil;
    if (clearType == 20) {
        clearName = @"  (T+0)";
    }
    else if (clearType == 21) {
        clearName = @"  (D+0)";
    }
    else if (clearType == 22) {
        clearName = @"  (D+0秒到)";
    }

    
    cell.cardNoLabel.text = [PublicInformation cuttingOffCardNo:[node objectForKey:@"pan"]];
    cell.moneyLabel.text = [@"￥" stringByAppendingString:[node objectForKey:@"settleMoney"]];
    cell.timeLabel.text = [[NSString stringWithFormat:@"%@ %@",[NSString formatedDateStringFromSourceTime:dateTime], [NSString formatedTimeStringFromSourceTime:dateTime]] stringByAppendingString:clearName];
    if (settled == 0) {
        cell.detailTextLabel.text = @"已结算";
    }
    else if (settled == 1) {
        cell.detailTextLabel.text = @"正在结算";
    }
    else {
        cell.detailTextLabel.text = @"结算失败";
    }
    return cell;
}


# pragma mask 3 action

// -- 执行明细查询
- (void) doDetailListRequesting {
    NameWeakSelf(wself);
    
    [self.http requestingOnPackingHandle:^(ASIFormDataRequest *http) {
        [http addRequestHeader:@"queryBeginTime" value:wself.requestPropDateBegin];
        [http addRequestHeader:@"queryEndTime" value:wself.requestPropDateEnd];
        [http addRequestHeader:@"mchntNo" value:[PublicInformation returnBusiness]];
    } onSucBlock:^(NSDictionary *info) {
        NSArray* list = [[info objectForKey:@"MchntInfoList"] copy];
        
        [wself.curDateSettleDetailList removeAllObjects];
        for (NSDictionary* node in list) {
            NSInteger clearType = [[node objectForKey:@"clearType"] integerValue];
            if (clearType == 20 || clearType == 21 || clearType == 22) {
                [wself.curDateSettleDetailList addObject:node];
            }
        }
        [wself doAccountReceivedCalculating];
        
        wself.state = VMAccountReceivedStateRequestSuc;
    } onErrBlock:^(NSError *error) {
        [wself.curDateSettleDetailList removeAllObjects];
        [wself doAccountReceivedCalculating];

        wself.errorRequested = [error copy];
        wself.state = VMAccountReceivedStateRequestFail;
    }];
}

// -- 执行金额计算
- (void) doAccountReceivedCalculating {
        CGFloat moneyReceived = 0.f;
        for (NSDictionary* node in self.curDateSettleDetailList) {
            NSString* transMoney = [node objectForKey:@"settleMoney"];
            NSInteger settleFlag = [[node objectForKey:@"settleFlag"] integerValue];
            
            if (settleFlag == 0) {
                moneyReceived += [transMoney floatValue];
            }
        }
        self.accountReceived = moneyReceived;
}

# pragma mask 4 getter

- (HTTPInstance *)http {
    if (!_http) {
        NSString* url = [NSString stringWithFormat:@"http://%@:%@/jlagent/getMchntInfo",
                         [PublicInformation getServerDomain], [PublicInformation getHTTPPort]];
        _http = [[HTTPInstance alloc] initWithURLString:url];
    }
    return _http;
}
- (NSMutableArray *)curDateSettleDetailList {
    if (!_curDateSettleDetailList) {
        _curDateSettleDetailList = [NSMutableArray array];
    }
    return _curDateSettleDetailList;
}

@end
