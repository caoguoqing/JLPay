//
//  VMMposDetailInfo.m
//  JLPay
//
//  Created by jielian on 16/5/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMMposDetailInfo.h"

@implementation VMMposDetailInfo

# pragma mask 1 <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.keyDisplayList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* identifier = @"sodjfosjd";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.textLabel.text = [self.keyDisplayList objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [self formatedDisplayValueAtIndexPath:indexPath];
    return cell;
}
# pragma mask 1 <UITableViewDelegate>
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

# pragma mask 2 action
- (NSString*) formatedDisplayValueAtIndexPath:(NSIndexPath*)indexPath{
    NSString* title = [self.keyDisplayList objectAtIndex:indexPath.row];
    NSString* key = [self.keysAndTitles objectForKey:title];
    NSString* originValue = [self.detailNode objectForKey:key];
    // 格式化...
    if ([title isEqualToString:kMposInfoNameTransMoney]) {             /* 金额: 单位为分 */
        originValue = [NSString stringWithFormat:@"%@元",[PublicInformation dotMoneyFromNoDotMoney:originValue]];
    }
    else if ([title isEqualToString:kMposInfoNameSettleMoney]) {       /* 结算金额: 单位为元 */
        originValue = [NSString stringWithFormat:@"%.02lf元",[originValue floatValue]];
    }
    else if ([title isEqualToString:kMposInfoNameCardNo]) {             /* 卡号 */
        originValue = [PublicInformation cuttingOffCardNo:originValue];
    }
    else if ([title isEqualToString:kMposInfoNameTransDate]) {          /* 交易日期 */
        originValue = [NSString stringWithFormat:@"%@/%@/%@",
                       [originValue substringToIndex:4],
                       [originValue substringWithRange:NSMakeRange(4, 2)],
                       [originValue substringWithRange:NSMakeRange(6, 2)]];
    }
    else if ([title isEqualToString:kMposInfoNameTransTime]) {          /* 交易时间 */
        originValue = [NSString stringWithFormat:@"%@:%@:%@",
                       [originValue substringToIndex:2],
                       [originValue substringWithRange:NSMakeRange(2, 2)],
                       [originValue substringWithRange:NSMakeRange(4, 2)]];
    }
    else if ([title isEqualToString:kMposInfoNameTransState]) {         /* 交易状态 */
        if (originValue.integerValue == 0) {
            originValue = @"交易成功";
        } else {
            originValue = @"交易失败";
        }
    }
    else if ([title isEqualToString:kMposInfoNameSettleType]) {         /* 结算类型 */
        switch (originValue.integerValue) {
            case 0:
                originValue = @"T+1";
                break;
            case 1:
                originValue = @"D+1(商户出手续费)";
                break;
            case 2:
                originValue = @"D+1(代理商出手续费)";
                break;
            case 20:
                originValue = @"T+0";
                break;
            case 21:
                originValue = @"D+0";
                break;
            case 22:
                originValue = @"D+0秒到";
                break;
            case 23:
                originValue = @"D+0钱包";
                break;
            case 26:
                originValue = @"T+6";
                break;
            case 27:
                originValue = @"T+15";
                break;
            case 28:
                originValue = @"T+30";
                break;
            default:
                break;
        }
    }
    else if ([title isEqualToString:kMposInfoNameSettleState]) {        /* 结算状态 */
        if (originValue.integerValue == 0) {
            originValue = @"已结算";
        }
        else if (originValue.integerValue == 1) {
            originValue = @"正在结算";
        }
        else {
            originValue = @"拒绝结算";
        }
    }
    return originValue;
}

# pragma mask 4 getter
- (NSDictionary *)detailNode {
    if (!_detailNode) {
        MMposDetails* datasSource = [MMposDetails sharedMposDetails];
        _detailNode = [[[datasSource.separatedDetailsOnDates objectAtIndex:datasSource.selectedIndexPath.section]
                        objectAtIndex:datasSource.selectedIndexPath.row] copy];
    }
    return _detailNode;
}
- (NSMutableArray *)keyDisplayList {
    if (!_keyDisplayList) {
        _keyDisplayList = [NSMutableArray array];
        [_keyDisplayList addObject:kMposInfoNameTransType   ];
        [_keyDisplayList addObject:kMposInfoNameBusinessNo  ];
        [_keyDisplayList addObject:kMposInfoNameBusinessName];
        [_keyDisplayList addObject:kMposInfoNameTransMoney  ];
        [_keyDisplayList addObject:kMposInfoNameCardNo      ];
        [_keyDisplayList addObject:kMposInfoNameTransDate   ];
        [_keyDisplayList addObject:kMposInfoNameTransTime   ];
        [_keyDisplayList addObject:kMposInfoNameTransState  ];
        [_keyDisplayList addObject:kMposInfoNameOrderNo     ];
        [_keyDisplayList addObject:kMposInfoNameTerminalNo  ];
        NSString* transType = [[self.detailNode objectForKey:kMMposNodeTxnType] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        /* 只有消费交易才显示结算信息 */
        if ([transType isEqualToString:MposInfoNameTransTypeCust]) {
            [_keyDisplayList addObject:kMposInfoNameSettleType  ];
            NSInteger settleType = [[self.detailNode objectForKey:kMMposNodeClearType] integerValue];
            if (settleType == 20 || settleType == 21 || settleType == 22) {
                [_keyDisplayList addObject:kMposInfoNameSettleState ];
                NSInteger settleState = [[self.detailNode objectForKey:kMMposNodeSettleFlag] integerValue];
                if (settleState == 0) {
                    [_keyDisplayList addObject:kMposInfoNameSettleMoney ];
                }
                else if (settleState == 2) {
                    [_keyDisplayList addObject:kMposInfoNameSettleRefuse];
                }
            }
        }
    }
    return _keyDisplayList;
}
- (NSDictionary *)keysAndTitles {
    if (!_keysAndTitles) {
        _keysAndTitles = @{kMposInfoNameTransType      : kMMposNodeTxnType,
                           kMposInfoNameBusinessNo     : kMMposNodeCardAccpId,
                           kMposInfoNameBusinessName   : kMMposNodeCardAccpName,
                           kMposInfoNameTransMoney     : kMMposNodeMoney ,
                           kMposInfoNameCardNo         : kMMposNodeCardNo,
                           kMposInfoNameTransDate      : kMMposNodeDate,
                           kMposInfoNameTransTime      : kMMposNodeTime,
                           kMposInfoNameTransState     : kMMposNodeRespCode,
                           kMposInfoNameOrderNo        : kMMposNodeRetrivlRef,
                           kMposInfoNameTerminalNo     : kMMposNodeCardAccpTermId,
                           kMposInfoNameSettleType     : kMMposNodeClearType,
                           kMposInfoNameSettleState    : kMMposNodeSettleFlag,
                           kMposInfoNameSettleMoney    : kMMposNodeSettleMoney,
                           kMposInfoNameSettleRefuse   : kMMposNodeRefuseReason};
    }
    return _keysAndTitles;
}


@end
