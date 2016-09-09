//
//  BR_chooseBusinessVC.m
//  JLPay
//
//  Created by jielian on 16/8/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "BR_chooseBusinessVC.h"
#import "Define_Header.h"
#import "Masonry.h"


@interface BR_chooseBusinessVC()

@property (nonatomic, strong) UITableView* tableView;

@end

@implementation BR_chooseBusinessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NameWeakSelf(wself);
    [self.dataSource getBusinessListOnFinished:^{
        [wself.tableView reloadData];
        NSInteger index = [wself.dataSource rowBusinessIndexSelected];
        if (index >= 0) {
            [wself.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    } onError:^(NSError *error) {
        [wself.tableView reloadData];
    }];

}

- (void)updateViewConstraints {
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [super updateViewConstraints];
}

# pragma mask 4 getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.dataSource = self.dataSource;
        _tableView.delegate = self.dataSource;
    }
    return _tableView;
}

- (VMBR_chooseBusiness *)dataSource {
    if (!_dataSource) {
        _dataSource = [[VMBR_chooseBusiness alloc] init];
    }
    return _dataSource;
}

@end
