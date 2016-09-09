//
//  BR_chooseRateVC.m
//  JLPay
//
//  Created by jielian on 16/8/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "BR_chooseRateVC.h"
#import <ReactiveCocoa.h>

@interface BR_chooseRateVC()

@property (nonatomic, strong) UITableView* tableView;

@end


@implementation BR_chooseRateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.frame = self.view.bounds;
}

# pragma mask 4 getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self.dataSource;
        _tableView.dataSource = self.dataSource;
    }
    return _tableView;
}

- (VMBR_chooseRate *)dataSource {
    if (!_dataSource) {
        _dataSource = [[VMBR_chooseRate alloc] init];
    }
    return _dataSource;
}

@end
