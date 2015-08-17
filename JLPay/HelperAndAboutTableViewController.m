//
//  HelperAndAboutTableViewController.m
//  JLPay
//
//  Created by jielian on 15/8/14.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "HelperAndAboutTableViewController.h"

@interface HelperAndAboutTableViewController ()
@property (nonatomic, strong) NSMutableArray* cellTitles;
@end

@implementation HelperAndAboutTableViewController
@synthesize cellTitles = _cellTitles;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:view];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseCellIdentifier" forIndexPath:indexPath];
    cell.textLabel.text = [self.cellTitles objectAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:[self.cellTitles objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mask ---- getter & setter 
- (NSMutableArray *)cellTitles {
    if (_cellTitles == nil) {
        _cellTitles = [[NSMutableArray alloc] init];
        [_cellTitles addObject:@"1.绑定设备"];
        [_cellTitles addObject:@"2.刷卡"];
        [_cellTitles addObject:@"3.查看交易明细"];
        [_cellTitles addObject:@"4.增值服务"];
        [_cellTitles addObject:@"关于我们"];
    }
    return _cellTitles;
}


@end
