//
//  BankBranchListViewController.m
//  JLPay
//
//  Created by 冯金龙 on 16/7/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "BankBranchListViewController.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"



@implementation BankBranchListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"请选择结算银行分支行";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self loadSubviews];
    [self layoutSubviews];
    [self addKVOs];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self.bankBranchListRequester.cmdBankBranchListRequesting execute:nil];
}

- (void) loadSubviews {
    [self.view addSubview:self.tableView];
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
    [self.bankBranchListRequester.cmdBankBranchListRequesting.executionSignals subscribeNext:^(RACSignal* sig) {
        [[[sig dematerialize] deliverOnMainThread] subscribeNext:^(id x) {
        } error:^(NSError *error) {
            @strongify(self);
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } completed:^{
            @strongify(self);
            [self.tableView reloadData];
        }];
    }];
}


# pragma mask 3 IBAction 

- (IBAction) clickedDoneBarItem:(UIBarButtonItem*)sender {
    NameWeakSelf(wself);
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (wself.bankBranchListRequester.selectedIndex >= 0 && wself.selectedBlock) {
            wself.selectedBlock([wself.bankBranchListRequester.filteredBankBranchList objectAtIndex:wself.bankBranchListRequester.selectedIndex]);
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
        _tableView.delegate = self.bankBranchListRequester;
        _tableView.dataSource = self.bankBranchListRequester;
    }
    return _tableView;
}

- (VMBankBranchListRequester *)bankBranchListRequester {
    if (!_bankBranchListRequester) {
        _bankBranchListRequester = [[VMBankBranchListRequester alloc] init];
        NameWeakSelf(wself);
        _bankBranchListRequester.filterKeyInputedBlock = ^ {
            [wself.tableView reloadData];
        };
    }
    return _bankBranchListRequester;
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
