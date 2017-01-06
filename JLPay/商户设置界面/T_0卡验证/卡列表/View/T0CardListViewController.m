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


@interface T0CardListViewController()

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) UIBarButtonItem* additionBarBtnItem;

@property (nonatomic, strong) UIBarButtonItem* homeBarBtnItem;

@property (nonatomic, strong) VMT0CardListRequest* cardListRequester;



@end

@implementation T0CardListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"卡列表";
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
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
    [self.navigationItem setRightBarButtonItem:self.additionBarBtnItem];
    [self.navigationItem setLeftBarButtonItem:self.homeBarBtnItem];
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
            [MBProgressHUD showNormalWithText:@"正在加载数据..." andDetailText:nil];
        } error:^(NSError *error) {
            @strongify(self);
            if ([self.tableView.mj_header isRefreshing]) [self.tableView.mj_header endRefreshing];
            [MBProgressHUD showFailWithText:@"加载失败" andDetailText:[error localizedDescription] onCompletion:nil];
        } completed:^{
            @strongify(self);
            [self.tableView reloadData];
            if ([self.tableView.mj_header isRefreshing]) [self.tableView.mj_header endRefreshing];
            [MBProgressHUD showSuccessWithText:@"加载成功" andDetailText:nil onCompletion:nil];
        }];
    }];
}


# pragma mask 3 IBAction

- (IBAction) clickAddition:(id)sender {
    T0CardUploadViewController* cardUploadVC = [[T0CardUploadViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:cardUploadVC animated:YES];
}

- (IBAction) clickedHomeBtn:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
        _additionBarBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(clickAddition:)];
    }
    return _additionBarBtnItem;
}

- (UIBarButtonItem *)homeBarBtnItem {
    if (!_homeBarBtnItem) {
        UIButton* homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [homeButton setTitle:[NSString fontAwesomeIconStringForEnum:FAHome] forState:UIControlStateNormal];
        [homeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [homeButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
        homeButton.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:23 scale:1]];
        [homeButton addTarget:self action:@selector(clickedHomeBtn:) forControlEvents:UIControlEventTouchUpInside];
        _homeBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
    }
    return _homeBarBtnItem;
}

- (VMT0CardListRequest *)cardListRequester {
    if (!_cardListRequester) {
        _cardListRequester = [[VMT0CardListRequest alloc] init];
    }
    return _cardListRequester;
}


@end
