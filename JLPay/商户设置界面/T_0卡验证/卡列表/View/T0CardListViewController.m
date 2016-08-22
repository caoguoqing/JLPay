//
//  T0CardListViewController.m
//  JLPay
//
//  Created by jielian on 16/7/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "T0CardListViewController.h"
#import "T0CardUploadViewController.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"
#import "Define_Header.h"

@implementation T0CardListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"卡列表";
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    [self loadSubviews];
    [self layoutSubviews];
    [self addKVOs];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.tabBarController.tabBar.hidden = YES;
    [self.cardListRequester.cmdRequesting execute:nil];
}

- (void) loadSubviews {
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
    [self.navigationItem setRightBarButtonItem:self.additionBarBtnItem];
    [self.view addSubview:self.progressHud];
}

- (void) layoutSubviews {
    NameWeakSelf(wself);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.top.equalTo(wself.view.mas_top).offset(64);
        make.bottom.equalTo(wself.view.mas_bottom);
    }];
}

- (void) addKVOs {
    @weakify(self);
    [self.cardListRequester.cmdRequesting.executionSignals subscribeNext:^(RACSignal* sigRequest) {
        [[sigRequest dematerialize] subscribeNext:^(id x) {
            @strongify(self);
            [self.progressHud showNormalWithText:@"正在加载数据..." andDetailText:nil];
        } error:^(NSError *error) {
            @strongify(self);
            if ([self.tableView.mj_header isRefreshing]) [self.tableView.mj_header endRefreshing];
            [self.progressHud showFailWithText:@"加载失败" andDetailText:[error localizedDescription] onCompletion:nil];
        } completed:^{
            @strongify(self);
            [self.tableView reloadData];
            if ([self.tableView.mj_header isRefreshing]) [self.tableView.mj_header endRefreshing];
            [self.progressHud showSuccessWithText:@"加载成功" andDetailText:nil onCompletion:nil];
        }];
    }];
}


# pragma mask 3 IBAction

- (IBAction) clickAddition:(id)sender {
    T0CardUploadViewController* cardUploadVC = [[T0CardUploadViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:cardUploadVC animated:YES];
}

# pragma mask 4 getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self.cardListRequester;
        _tableView.dataSource = self.cardListRequester;
        _tableView.tableFooterView = [UIView new];
        NameWeakSelf(wself);
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [wself.cardListRequester.cmdRequesting execute:nil];
        }];
    }
    return _tableView;
}

- (UIBarButtonItem *)additionBarBtnItem {
    if (!_additionBarBtnItem) {
        _additionBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"添加银行卡" style:UIBarButtonItemStylePlain target:self action:@selector(clickAddition:)];
    }
    return _additionBarBtnItem;
}

- (VMT0CardListRequest *)cardListRequester {
    if (!_cardListRequester) {
        _cardListRequester = [[VMT0CardListRequest alloc] init];
    }
    return _cardListRequester;
}

- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _progressHud;
}

@end
