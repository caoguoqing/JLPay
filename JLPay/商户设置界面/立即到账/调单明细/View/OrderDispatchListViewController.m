//
//  OrderDispatchListViewController.m
//  JLPay
//
//  Created by jielian on 16/5/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "OrderDispatchListViewController.h"
#import "DispatchMaterialUploadViewCtr.h"
#import "MDispatchOrderDetail.h"


@implementation OrderDispatchListViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"调单明细";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];

    
    [self loadSubviews];
    [self layoutSubviews];
    [self addKVOs];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.dispatchListVM terminateRequesting];
}

- (void)dealloc {
    JLPrint(@"-----OrderDispatchListViewController dealloc-----");
}
- (void) loadSubviews {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.refreshBtn];
    [self.view addSubview:self.monthsTBV];
    [self.view addSubview:self.chooseMonthBtn];
    [self.view addSubview:self.progressHud];
}
- (void) layoutSubviews {
    NameWeakSelf(wself);
    
    CGFloat heightBtn = self.view.frame.size.height * 1/14.f;
    CGFloat heightMonthTBV = self.view.frame.size.height - 64 - heightBtn;
    
    [self.chooseMonthBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.view.mas_top).offset(64);
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.height.mas_equalTo(heightBtn);
    }];
    
    [self.monthsTBV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.bottom.equalTo(wself.chooseMonthBtn.mas_bottom);
        make.height.mas_equalTo(heightMonthTBV);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.chooseMonthBtn.mas_bottom);
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.bottom.equalTo(wself.view.mas_bottom);
    }];
    
    [self.refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.chooseMonthBtn.mas_bottom);
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.bottom.equalTo(wself.view.mas_bottom);
    }];
}

# pragma mask 1 KVOs 
- (void) addKVOs {
    @weakify(self);
    
    [[[RACObserve(self.chooseMonthBtn, tbvPulledDown) skip:1] deliverOnMainThread] subscribeNext:^(NSNumber* down) {
        if (down.boolValue) {
            [UIView animateWithDuration:0.2 animations:^{
                @strongify(self);
                self.monthsTBV.transform = CGAffineTransformMakeTranslation(0, self.monthsTBV.frame.size.height);
            }];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                @strongify(self);
                self.monthsTBV.transform = CGAffineTransformMakeTranslation(0, 0);
            }];
        }
    }];
    
    [[RACObserve(self.months, selectedIndex) deliverOnMainThread] subscribeNext:^(NSNumber* selectedIndex) {
        @strongify(self);
        self.chooseMonthBtn.tbvPulledDown = NO;
        [self.chooseMonthBtn updateCurDateBtnTitleByDate:[self.months.months objectAtIndex:selectedIndex.integerValue]];
    }];
    
    [RACObserve(self.chooseMonthBtn.curMonthBtn.titleLabel, text) subscribeNext:^(NSString* dateFormation) {
        @strongify(self);
        [self doDispatchListRequesting];
    }];
    
    [[[RACObserve(self.dispatchListVM, indexSelected) deliverOnMainThread] skip:1] subscribeNext:^(NSNumber* index) {
        @strongify(self);
        DispatchMaterialUploadViewCtr* viewC = [[DispatchMaterialUploadViewCtr alloc] initWithNibName:nil bundle:nil];
        viewC.dispatchUploader.originDispatchDetail = [MDispatchOrderDetail orderDetailWithNode:[self.dispatchListVM.listSequenced objectAtIndex:index.integerValue]];
        [self.navigationController pushViewController:viewC animated:YES];
    }];
}

# pragma mask 2 IBAction

- (void) doDispatchListRequesting {
    NSString* curDate = [self.chooseMonthBtn.curMonthBtn titleForState:UIControlStateNormal];
    NSString* beginDate = [NSString stringWithFormat:@"%@%@01", [curDate substringToIndex:4], [curDate substringWithRange:NSMakeRange(4+1, 2)]];
    NSString* endDate = [beginDate lastDayOfCurMonth];
    
    [self.progressHud showNormalWithText:@"查询数据..." andDetailText:nil];
    NameWeakSelf(wself);
    [self.dispatchListVM requestingWithBeginDate:beginDate andEndDate:endDate onFinished:^{
        if ([wself.tableView.mj_header isRefreshing]) {
            [wself.tableView.mj_header endRefreshing];
        }
        wself.refreshBtn.hidden = YES;
        [wself.tableView reloadData];
        [wself.progressHud showSuccessWithText:@"查询成功" andDetailText:nil onCompletion:^{}];
    } onError:^(NSError *error) {
        if ([wself.tableView.mj_header isRefreshing]) {
            [wself.tableView.mj_header endRefreshing];
        }
        [wself.tableView reloadData];
        wself.refreshBtn.hidden = NO;
        [wself.progressHud showFailWithText:@"查询失败" andDetailText:[error localizedDescription] onCompletion:nil];
    }];
}


# pragma mask 4 getter
- (MonthChooseBtnView *)chooseMonthBtn {
    if (!_chooseMonthBtn) {
        _chooseMonthBtn = [[MonthChooseBtnView alloc] init];
    }
    return _chooseMonthBtn;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            NameWeakSelf(wself);
            [wself doDispatchListRequesting];
        }];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.mj_header.automaticallyChangeAlpha = YES;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.rowHeight = 60;
        _tableView.delegate = self.dispatchListVM;
        _tableView.dataSource = self.dispatchListVM;
    }
    return _tableView;
}
- (BusinessVCRefreshButton *)refreshBtn {
    if (!_refreshBtn) {
        _refreshBtn = [[BusinessVCRefreshButton alloc] init];
        [_refreshBtn setTitle:@"点击刷新数据" forState:UIControlStateNormal];
        [_refreshBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_refreshBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateHighlighted];
        _refreshBtn.hidden = YES;
        [_refreshBtn addTarget:self action:@selector(doDispatchListRequesting) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshBtn;
}
- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _progressHud;
}
- (UITableView *)monthsTBV {
    if (!_monthsTBV) {
        _monthsTBV = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _monthsTBV.scrollEnabled = NO;
        _monthsTBV.dataSource = self.months;
        _monthsTBV.delegate = self.months;
        _monthsTBV.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];
        _monthsTBV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _monthsTBV ;
}
- (MNearestMonths *)months {
    if (!_months) {
        _months = [[MNearestMonths alloc] init];
    }
    return _months;
}
- (VMDispatchList *)dispatchListVM {
    if (!_dispatchListVM) {
        _dispatchListVM = [[VMDispatchList alloc] init];
    }
    return _dispatchListVM;
}

@end
