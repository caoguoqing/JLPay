//
//  TransDetailsTableViewController.m
//  JLPay
//
//  Created by jielian on 15/6/8.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "TransDetailsTableViewController.h"
#import "TotalAmountCell.h"
#import "DetailsCell.h"

@implementation TransDetailsTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mask ::: UITableViewDataSource -- section 个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mask ::: UITableViewDataSource -- row 个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

#pragma mask ::: UITableViewDelegate -- cell的重用
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSString* identifier = @"transDetailCell";
//    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    UITableViewCell* cell = nil;
    
    if (cell == nil) {

        if (indexPath.row == 0) {
//            cell = [[TotalAmountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell = [[TotalAmountCell alloc]  init];
        } else {
//            cell = [[DetailsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell = [[DetailsCell alloc] init];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 150.0;
    }
    else {
        return 50.0;
    }
}


@end
