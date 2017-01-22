//
//  JLTransDetailVC.m
//  JLPay
//
//  Created by jielian on 2017/1/19.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "JLTransDetailVC.h"
#import "Define_Header.h"
#import "TDVC_vLogoHeadView.h"

@interface JLTransDetailVC ()

@property (nonatomic, strong) UITableView* tableView;

@end

@implementation JLTransDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"交易详情";
    [self.view addSubview:self.tableView];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

# pragma mask 4 getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)
                                                  style:UITableViewStylePlain];
        _tableView.dataSource = self.dataSource;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 35;
        _tableView.sectionHeaderHeight = 70;
        TDVC_vLogoHeadView* logoHeadView = [[TDVC_vLogoHeadView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 70)];
        _tableView.tableHeaderView = logoHeadView;
        
    }
    return _tableView;
}
- (TDVC_vmDataSource *)dataSource {
    if (!_dataSource) {
        _dataSource = [TDVC_vmDataSource new];
    }
    return _dataSource;
}

@end
