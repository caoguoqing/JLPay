//
//  AvilableBankListViewController.m
//  JLPay
//
//  Created by jielian on 16/7/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "AvilableBankListViewController.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"



@implementation AvilableBankListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"请选择结算银行";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self loadSubviews];
    [self layoutSubviews];
    [self addKVOs];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self.bankListRequester.cmdAviBankListRequesting execute:nil];
}

- (void) loadSubviews {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.progressHud];
    [self.navigationItem setRightBarButtonItem:self.doneBarBtn];
    [self.navigationItem setLeftBarButtonItem:self.cancleBarBtn];
}

- (void) layoutSubviews {
    NameWeakSelf(wself);
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.bottom.equalTo(wself.view.mas_bottom);
        make.top.equalTo(wself.view.mas_top).offset(64);
    }];
}

- (void) addKVOs {
    @weakify(self);
    [self.bankListRequester.cmdAviBankListRequesting.executionSignals subscribeNext:^(RACSignal* sig) {
        [[[sig dematerialize] deliverOnMainThread] subscribeNext:^(id x) {
            @strongify(self);
            [self.progressHud showNormalWithText:nil andDetailText:nil];
        } error:^(NSError *error) {
            @strongify(self);
            [self.progressHud showFailWithText:@"加载失败" andDetailText:[error localizedDescription] onCompletion:^{
                @strongify(self);
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }];
        } completed:^{
            @strongify(self);
            [self.progressHud hide:YES];
            [self.tableView reloadData];
        }];
    }];
}


# pragma mask 3 IBAction

- (IBAction) clickedDoneBarItem:(UIBarButtonItem*)sender {
    NameWeakSelf(wself);
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (wself.bankListRequester.selectedIndex >= 0 && wself.selectedBlock) {
            wself.selectedBlock([wself.bankListRequester.filteredBankList objectAtIndex:wself.bankListRequester.selectedIndex]);
        }
    }];
}
- (IBAction) clickedCancleBarItem:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



# pragma mask 4 getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self.bankListRequester;
        _tableView.dataSource = self.bankListRequester;
    }
    return _tableView;
}

- (VMAvilableBankListRequester *)bankListRequester {
    if (!_bankListRequester) {
        NameWeakSelf(wself);
        _bankListRequester = [[VMAvilableBankListRequester alloc] init];
        _bankListRequester.filterKeyInputedBlock = ^{
            [wself.tableView reloadData];
        };
    }
    return _bankListRequester;
}

- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _progressHud;
}

- (UIBarButtonItem *)doneBarBtn {
    if (!_doneBarBtn) {
        _doneBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(clickedDoneBarItem:)];
    }
    return _doneBarBtn;
}

- (UIBarButtonItem *)cancleBarBtn {
    if (!_cancleBarBtn) {
        _cancleBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(clickedCancleBarItem:)];
    }
    return _cancleBarBtn;
}


@end
