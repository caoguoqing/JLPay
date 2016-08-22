//
//  VMOtherPayDetailInfo.m
//  JLPay
//
//  Created by jielian on 16/5/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMOtherPayDetailInfo.h"

@implementation VMOtherPayDetailInfo

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
    NSString* value = [self.detailNode objectForKey:[self.keysAndTitles objectForKey:title]];
    if ([title isEqualToString:kOtherPayInfoNamePayType]) {
        if ([value isEqualToString:@"A0"]) {
            value = @"支付宝消费";
        }
        else if ([value isEqualToString:@"A1"]) {
            value = @"支付宝冲正";
        }
        else if ([value isEqualToString:@"A2"]) {
            value = @"支付宝消费撤销";
        }
        else if ([value isEqualToString:@"W0"]) {
            value = @"微信消费";
        }
        else if ([value isEqualToString:@"W1"]) {
            value = @"微信冲正";
        }
        else if ([value isEqualToString:@"W2"]) {
            value = @"微信消费撤销";
        }

    }
    else if ([title isEqualToString:kOtherPayInfoNameMoney]) {
        value = [[PublicInformation dotMoneyFromNoDotMoney:value] stringByAppendingString:@"元"];
    }
    else if ([title isEqualToString:kOtherPayInfoNameStatus]) {
        if (value.integerValue == 0) {
            NSInteger revoked = [[self.detailNode objectForKey:kMOtherPayNodeRevokeStatus] integerValue];
            NSInteger reversaled = [[self.detailNode objectForKey:kMOtherPayNodeReverseStatus] integerValue];
            NSInteger refunded = [[self.detailNode objectForKey:kMOtherPayNodeRefundStatus] integerValue];
            if (!revoked) {
                value = @"已撤销";
            }
            else if (!reversaled) {
                value = @"已冲正";
            }
            else if (!refunded) {
                value = @"已退货";
            }
            else {
                value = @"支付成功";
            }
        }
        else if (value.integerValue == 9) {
            value = @"支付中";
        }
        else {
            value = @"支付失败";
        }
    }
    else if ([title isEqualToString:kOtherPayInfoNameOrderNo]) {
        value = [value stringCutting4XingInRange:NSMakeRange(6, value.length - 6 - 4)];
    }
    else if ([title isEqualToString:kOtherPayInfoNameTime]) {
        if (!value || value.length < 8 + 6) {
            value = @"";
        } else {
            value = [value substringFromIndex:8];
            value = [NSString stringWithFormat:@"%@:%@:%@",
                     [value substringToIndex:2],
                     [value substringWithRange:NSMakeRange(2, 2)],
                     [value substringWithRange:NSMakeRange(4, 2)]];
        }
    }
    else if ([title isEqualToString:kOtherPayInfoNameDate]) {
        if (!value || value.length < 8 + 6) {
            value = @"";
        } else {
            value = [value substringToIndex:8];
            value = [NSString stringWithFormat:@"%@/%@/%@",
                     [value substringToIndex:4],
                     [value substringWithRange:NSMakeRange(4, 2)],
                     [value substringWithRange:NSMakeRange(6, 2)]];
        }
    }
    return value;
}

# pragma mask 4 getter
- (NSDictionary *)detailNode {
    if (!_detailNode) {
        MOtherPayDetails* otherPayDetails = [MOtherPayDetails sharedOtherPayDetails];
        NSArray* dateArray = [[otherPayDetails separatedDetailsOnDates] objectAtIndex:otherPayDetails.selectedIndexPath.section];
        _detailNode = [dateArray objectAtIndex:otherPayDetails.selectedIndexPath.row];
    }
    return _detailNode;
}

- (NSMutableArray *)keyDisplayList {
    if (!_keyDisplayList) {
        _keyDisplayList = [NSMutableArray array];
        [_keyDisplayList addObject:kOtherPayInfoNamePayType];
        [_keyDisplayList addObject:kOtherPayInfoNameGoodsName];
        [_keyDisplayList addObject:kOtherPayInfoNameMoney];
        [_keyDisplayList addObject:kOtherPayInfoNameStatus];
        [_keyDisplayList addObject:kOtherPayInfoNameOrderNo];
        [_keyDisplayList addObject:kOtherPayInfoNameTime];
        [_keyDisplayList addObject:kOtherPayInfoNameDate];
        [_keyDisplayList addObject:kOtherPayInfoNameBusinessNo];
    }
    return _keyDisplayList;
}

- (NSDictionary *)keysAndTitles {
    if (!_keysAndTitles) {
        _keysAndTitles = @{kOtherPayInfoNamePayType     : kMOtherPayNodeOrderType,
                           kOtherPayInfoNameGoodsName   : kMOtherPayNodeGoodsName,
                           kOtherPayInfoNameMoney       : kMOtherPayNodeTradeMoney,
                           kOtherPayInfoNameStatus      : kMOtherPayNodePayStatus,
                           kOtherPayInfoNameOrderNo		: kMOtherPayNodeOrderNo,
                           kOtherPayInfoNameTime        : kMOtherPayNodePayTime,
                           kOtherPayInfoNameDate        : kMOtherPayNodePayTime,
                           kOtherPayInfoNameBusinessNo  : kMOtherPayNodeMchtNo};
    }
    return _keysAndTitles;
}

@end
