//
//  VMDispatchList.m
//  JLPay
//
//  Created by jielian on 16/5/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMDispatchList.h"
#import "HTTPInstance.h"
#import "Define_Header.h"
#import "MD5Util.h"
#import "MDispatchOrderDetail.h"
#import "DispatchDetailCell.h"

@implementation VMDispatchList

- (void)dealloc {
    JLPrint(@"----VMDispatchList dealloc----");
}

- (void)requestingWithBeginDate:(NSString *)beginDate
                     andEndDate:(NSString *)endDate
                     onFinished:(void (^)(void))finished
                        onError:(void (^)(NSError *))errorBlock
{
    NameWeakSelf(wself);
    [self.http requestingOnPackingHandle:^(ASIFormDataRequest *http) {
        [http addPostValue:[PublicInformation returnBusiness] forKey:@"mchtNo"];
        [http addPostValue:beginDate forKey:@"queryBeginTime"];
        [http addPostValue:endDate forKey:@"queryEndTime"];
        NSMutableString* source = [NSMutableString string];
        [source appendFormat:@"mchtNo=%@&",[PublicInformation returnBusiness]];
        [source appendFormat:@"queryBeginTime=%@&", beginDate];
        [source appendFormat:@"queryEndTime=%@&", endDate];
        [source appendFormat:@"key=shisongcheng"];
        [http addPostValue:[[MD5Util encryptWithSource:source] lowercaseString] forKey:@"sign"];
    } onSucBlock:^(NSDictionary *info) {
        NSArray* list = [info objectForKey:@"dispatchList"];
        if (!list || list.count == 0) {
            [wself.listSequenced removeAllObjects];
            if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:601 localizedDescription:@"查无数据"]);
        }
        else {
            wself.dispatchList = [list copy];
            [wself doSequence];
            if (finished) finished();
        }
    } onErrBlock:^(NSError *error) {
        [wself.listSequenced removeAllObjects];
        if (errorBlock) errorBlock(error);
    }];
}

- (void) terminateRequesting {
    [self.http terminateRequesting];
}


# pragma mask 2 UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.listSequenced && self.listSequenced.count > 0) {
        return self.listSequenced.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* identifier = @"ssssssssss";
    DispatchDetailCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[DispatchDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    MDispatchOrderDetail* detail = [MDispatchOrderDetail orderDetailWithNode:[self.listSequenced objectAtIndex:indexPath.row]];
    cell.cardNoLabel.text = detail.cardNo;
    cell.moneyLabel.text = [@"￥" stringByAppendingString:detail.transMoney];
    cell.timeLabel.text = [[detail.transDate stringByAppendingString:@"  "] stringByAppendingString:detail.transTime];
    
    
    if (detail.checkedFlag == 0) {
        cell.detailTextLabel.textColor = [UIColor colorWithHex:HexColorTypeGreen alpha:1];
        cell.detailTextLabel.text = @"(已审核)";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (detail.checkedFlag == 1) {
        if (detail.uploadted) {
            cell.detailTextLabel.text = @"(审核中)";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.detailTextLabel.text = @"(未上传调单资料)";
            cell.detailTextLabel.textColor = [UIColor colorWithHex:HexColorTypeLightOrangeRed alpha:1];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if (detail.checkedFlag == 2) {
        cell.detailTextLabel.textColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        cell.detailTextLabel.text = @"(审核未通过)";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];

    return cell;
}

# pragma mask 2 UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    MDispatchOrderDetail* detail = [MDispatchOrderDetail orderDetailWithNode:[self.listSequenced objectAtIndex:indexPath.row]];
    if (detail.checkedFlag == 0) {
        return NO;
    } else {
        return YES;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.indexSelected = indexPath.row;
}


# pragma mask 3 do sequence
- (void) doSequence {
    NSMutableArray* listChecked = [NSMutableArray array];
    NSMutableArray* listChecking = [NSMutableArray array];
    NSMutableArray* listCheckRefused = [NSMutableArray array];
    NSMutableArray* listNotUpload = [NSMutableArray array];

    for (NSDictionary* node in self.dispatchList) {
        MDispatchOrderDetail* detail = [MDispatchOrderDetail orderDetailWithNode:node];
        if (detail.checkedFlag == 0) {
            [listChecked addObject:node];
        }
        else if (detail.checkedFlag == 1) {
            if (detail.uploadted) {
                [listChecking addObject:node];
            } else {
                [listNotUpload addObject:node];
            }
        }
        else {
            [listCheckRefused addObject:node];
        }
    }
    
    [self.listSequenced removeAllObjects];
    [self.listSequenced addObjectsFromArray:listNotUpload];
    [self.listSequenced addObjectsFromArray:listCheckRefused];
    [self.listSequenced addObjectsFromArray:listChecking];
    [self.listSequenced addObjectsFromArray:listChecked];

}


# pragma mask 4 getter
- (HTTPInstance *)http {
    if (!_http) {
        NSString* url = [NSString stringWithFormat:@"http://%@:%@/jlagent/queryDispatchInfo",
                         [PublicInformation getServerDomain], [PublicInformation getHTTPPort]];
        _http = [[HTTPInstance alloc] initWithURLString:url];
    }
    return _http;
}
- (NSMutableArray *)listSequenced {
    if (!_listSequenced) {
        _listSequenced = [NSMutableArray array];
    }
    return _listSequenced;
}

@end
