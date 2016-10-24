//
//  VMTerminalsDataSource.m
//  JLPay
//
//  Created by jielian on 16/9/7.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMTerminalsDataSource.h"
#import "Define_Header.h"
#import "MCacheSavedLogin.h"

@interface VMTerminalsDataSource()


@end

@implementation VMTerminalsDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        if (self.terminalList.count > 0) {
            self.terminalSelected = [self.terminalList objectAtIndex:0];
        }
    }
    return self;
}



# pragma mask 2 UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.terminalList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cellidentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellidentifier"];
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.separatorInset = UIEdgeInsetsZero;
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    cell.textLabel.text = [self.terminalList objectAtIndex:indexPath.row];
    if ([cell.textLabel.text isEqualToString:self.terminalSelected]) {
        cell.textLabel.textColor = [UIColor orangeColor];
    } else {
        cell.textLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
    }
    
    return cell;
}

# pragma mask 2 UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.terminalSelected = [self.terminalList objectAtIndex:indexPath.row];
    [tableView reloadData];
}



# pragma mask 4 getter

- (NSArray *)terminalList {
    if (!_terminalList) {
        MCacheSavedLogin* logincache = [MCacheSavedLogin cache];
        if ([logincache terminalCount] > 0) {
            _terminalList = [NSArray arrayWithArray:logincache.terminalList];
        } else {
            _terminalList = [NSArray array];
        }
    }
    return _terminalList;
}

@end
