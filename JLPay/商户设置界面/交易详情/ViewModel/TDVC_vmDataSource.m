//
//  TDVC_vmDataSource.m
//  JLPay
//
//  Created by jielian on 2017/1/19.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "TDVC_vmDataSource.h"
#import "TDVC_vCell.h"
#import "TDVC_vLogoHeadView.h"
#import <ReactiveCocoa.h>
#import "Define_Header.h"

@implementation TDVC_vmDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
       @weakify(self);
        // 如果是微信或支付宝,要另外建立解析方法
        RAC(self, titlesAndContexts) = [[RACObserve(self, detaiNode) filter:^BOOL(TLVC_mDetailMpos* node) {
            return node != nil;
        }] map:^id(id value) {
            @strongify(self);
            return [self mposDetailTitlesAndContextAnalysed];
        }];
    }
    return self;
}



# pragma mask 2 UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titlesAndContexts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TDVC_vCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TDVC_vCell"];
    if (!cell) {
        cell = [[TDVC_vCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDVC_vCell"];
    }
    TDVC_mItem* item = [self.titlesAndContexts objectAtIndex:indexPath.row];
    cell.titleLabel.text = item.title;
    cell.contextLabel.text = item.context;
    UIColor* contextColor = [UIColor colorWithHex:0x777777 alpha:1];
    if ([item.title isEqualToString:@"交易金额 :"]) {
        contextColor = [UIColor colorWithHex:0x00a1dc alpha:1];
    } else if ([item.title isEqualToString:@"结算状态 :"]) {
        if (self.detaiNode.settleFlag == 0) {
            contextColor = [UIColor colorWithHex:0x00a1dc alpha:1];
        }
        else if (self.detaiNode.settleFlag == 1) {
            contextColor = [UIColor colorWithHex:0x777777 alpha:1];
        }
        else {
            contextColor = [UIColor colorWithHex:0xef454b alpha:1];
        }

    }
    cell.contextLabel.textColor = contextColor;
    return cell;
}



# pragma mask 3 tools 
/* 生成需要显示的数据 */
- (NSArray*) mposDetailTitlesAndContextAnalysed {
    NSMutableArray* titlesAndContexts = [NSMutableArray array];
    [titlesAndContexts addObject:[TDVC_mItem itemWithTitle:@"交易类型 :" context:self.detaiNode.txnNum]];
    [titlesAndContexts addObject:[TDVC_mItem itemWithTitle:@"商户编号 :" context:self.detaiNode.cardAccpId]];
    [titlesAndContexts addObject:[TDVC_mItem itemWithTitle:@"商户名称 :" context:self.detaiNode.cardAccpName]];
    [titlesAndContexts addObject:[TDVC_mItem itemWithTitle:@"交易金额 :" context:[@"￥" stringByAppendingString:[PublicInformation dotMoneyFromNoDotMoney:self.detaiNode.amtTrans]]]];
    [titlesAndContexts addObject:[TDVC_mItem itemWithTitle:@"交易卡号 :" context:[PublicInformation cuttingOffCardNo:self.detaiNode.pan]]];
    [titlesAndContexts addObject:[TDVC_mItem itemWithTitle:@"交易日期 :" context:[self formatedWithDate:self.detaiNode.instDate]]];
    [titlesAndContexts addObject:[TDVC_mItem itemWithTitle:@"交易时间 :" context:[self formatedWithTime:self.detaiNode.instTime]]];
    [titlesAndContexts addObject:[TDVC_mItem itemWithTitle:@"交易状态 :" context:self.detaiNode.respCode ? @"交易成功" : @"交易失败"]];
    [titlesAndContexts addObject:[TDVC_mItem itemWithTitle:@"订单编号 :" context:self.detaiNode.retrivlRef]];
    [titlesAndContexts addObject:[TDVC_mItem itemWithTitle:@"终端编号 :" context:self.detaiNode.cardAccpTermId]];
    
    [titlesAndContexts addObject:[TDVC_mItem itemWithTitle:@"结算方式 :" context:[self clearTypeWithType:self.detaiNode.clearType]]];
    if (self.detaiNode.clearType == 20 ||
        self.detaiNode.clearType == 21 ||
        self.detaiNode.clearType == 22 ||
        self.detaiNode.clearType == 23)
    {
        [titlesAndContexts addObject:[TDVC_mItem itemWithTitle:@"结算状态 :" context:[self settleTypeWithType:self.detaiNode.settleFlag]]];
        [titlesAndContexts addObject:[TDVC_mItem itemWithTitle:@"结算金额 :" context:[@"￥" stringByAppendingString:self.detaiNode.settleMoney]]];
        if (self.detaiNode.settleFlag == 2) {
            [titlesAndContexts addObject:[TDVC_mItem itemWithTitle:@"拒绝原因 :" context:self.detaiNode.refuseReason]];
        }
    }
    return [titlesAndContexts copy];
}

- (NSString*) formatedWithDate:(NSString*)date {
    return [NSString stringWithFormat:@"%@-%@-%@",
            [date substringWithRange:NSMakeRange(0, 4)],
            [date substringWithRange:NSMakeRange(4, 2)],
            [date substringWithRange:NSMakeRange(6, 2)]];
}
- (NSString*) formatedWithTime:(NSString*)time {
    return [NSString stringWithFormat:@"%@:%@:%@",
            [time substringWithRange:NSMakeRange(0, 2)],
            [time substringWithRange:NSMakeRange(2, 2)],
            [time substringWithRange:NSMakeRange(4, 2)]];
}
- (NSString*) clearTypeWithType:(NSInteger)type {
    switch (type) {
        case 0:
            return @"T+1";
            break;
        case 1:
            return @"D+1(商户出手续费)";
            break;
        case 2:
            return @"D+1(代理商出手续费)";
            break;
        case 20:
            return @"T+0";
            break;
        case 21:
            return @"D+0";
            break;
        case 22:
            return @"D+0秒到";
            break;
        case 23:
            return @"D+0钱包";
            break;
        case 26:
            return @"T+6";
            break;
        case 27:
            return @"T+15";
            break;
        case 28:
            return @"T+30";
            break;
        default:
            return @"T+1";
            break;
    }
}
/* 结算标志: 0已结算; 1正在结算; 2拒绝; 3:冻结; */
- (NSString*) settleTypeWithType:(NSInteger)type {
    switch (type) {
        case 0:
            return @"已结算";
            break;
        case 1:
            return @"正在结算";
            break;
        case 2:
            return @"拒绝结算";
            break;
        case 3:
            return @"已冻结";
            break;
        default:
            return @"已结算";
            break;
    }
}

@end
