//
//  VMDelegateForTableView.m
//  JLPay
//
//  Created by jielian on 16/5/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMDelegateForTableView.h"
#import "TransDetailListViewController.h"

@implementation VMDelegateForTableView

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

# pragma mask 2 UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString* headerIdentifier = @"headerIdentifier";
    TransDetailTBVHeader* header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    
    if (!header) {
        header = [[TransDetailTBVHeader alloc] initWithReuseIdentifier:headerIdentifier];
    }
        
    NSString* date = nil;
    NSInteger countOfTrans;
    if ([self.platform isEqualToString:TransPlatformTypeSwipe]) {
        date = [[MMposDetails sharedMposDetails] dateAtDateIndex:section];
        countOfTrans = [[[[MMposDetails sharedMposDetails] separatedDetailsOnDates] objectAtIndex:section] count];
    } else {
        date = [[MOtherPayDetails sharedOtherPayDetails] dateAtDateIndex:section];
        countOfTrans = [[[[MOtherPayDetails sharedOtherPayDetails] separatedDetailsOnDates] objectAtIndex:section] count];

    }
    
    header.titleLabel.text = [NSString stringWithFormat:@"%@月%@日",
                                     [date substringWithRange:NSMakeRange(4, 2)],
                                     [date substringWithRange:NSMakeRange(6, 2)]];

    header.countTransLabel.text = [NSString stringWithFormat:@"%d笔",countOfTrans];
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.platform isEqualToString:TransPlatformTypeSwipe]) {
        [[MMposDetails sharedMposDetails] setSelectedIndexPath:[indexPath copy]];
    } else {
        [[MOtherPayDetails sharedOtherPayDetails] setSelectedIndexPath:[indexPath copy]];
    }
    if (self.selectedBlock) self.selectedBlock(indexPath.row);
}

@end
