//
//  MNearestMonths.m
//  JLPay
//
//  Created by jielian on 16/5/16.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MNearestMonths.h"

@implementation MNearestMonths

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

# pragma mask 1 UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = indexPath.row;
}

# pragma mask 1 UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.months.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"sssssss"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sssssss"];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    NSString* month = [self.months objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@年%@月", [month substringToIndex:4], [month substringWithRange:NSMakeRange(4, 2)]];
    cell.textLabel.textColor = (self.selectedIndex == indexPath.row)?([UIColor orangeColor]):([UIColor colorWithHex:HexColorTypeBlackBlue alpha:1]);
    return cell;
}

# pragma mask 4 getter
- (NSArray *)months {
    if (!_months) {
        NSMutableArray* addedMonths = [NSMutableArray array];
        NSString* curMonth = [[NSString curDateString] substringToIndex:4+2];
        [addedMonths addObject:curMonth];
        [addedMonths addObject:[curMonth lastMonth]];
        [addedMonths addObject:[[curMonth lastMonth] lastMonth]];
        [addedMonths addObject:[[[curMonth lastMonth] lastMonth] lastMonth]];
        _months = [NSArray arrayWithArray:addedMonths];
    }
    return _months;
}

@end
