//
//  JLTransDetailListVC.m
//  JLPay
//
//  Created by jielian on 2017/1/13.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "JLTransDetailListVC.h"
#import "TLVC_vmCtrl.h"
#import "MLIconButtonR.h"
#import "TLVC_vTotalDetailView.h"
#import "MLFilterView1Section.h"
#import "MLFilterView2Section.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>
#import "JLViewNoData.h"
#import <MJRefresh.h>
#import "JLTransDetailVC.h"


@interface JLTransDetailListVC ()

/* 数据控制流程 */
@property (nonatomic, strong) TLVC_vmCtrl* dataProcession;

/* 总金额头视图 */
@property (nonatomic, strong) TLVC_vTotalDetailView* totalInfoHeaderView;

/* 表视图 */
@property (nonatomic, strong) UITableView* tableView;

/* 月份切换按钮 */
@property (nonatomic, strong) MLIconButtonR* monthSwitchBtn;
/* 月份筛选器 */
@property (nonatomic, strong) MLFilterView1Section* monthFilterView;


/* 筛选视图按钮 */
@property (nonatomic, strong) UIBarButtonItem* filterBarBtn;
/* 数据筛选器 */
@property (nonatomic, strong) MLFilterView2Section* dataFilterView;

@property (nonatomic, strong) UIBarButtonItem* homeBarBtn;
@property (nonatomic, strong) JLViewNoData* noDataView;

@end

@implementation JLTransDetailListVC


# pragma mask 2 IBAction 
- (IBAction) backToHomeVC:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

# pragma mask 3 生命周期 & 布局
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubviews];
    [self addKVO];
    // 执行交易查询
    [self.dataProcession.cmd_dataRequesting execute:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void) loadSubviews {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setTitleView:self.monthSwitchBtn];
    [self.navigationItem setRightBarButtonItem:self.filterBarBtn];
    [self.navigationItem setLeftBarButtonItem:self.homeBarBtn];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.noDataView];
}

- (void) addKVO {
    @weakify(self);
    /* 绑定月份按钮的值 */
    [RACObserve(self.dataProcession, month) subscribeNext:^(NSString* month) {
        @strongify(self);
        [self.monthSwitchBtn setTitle:month forState:UIControlStateNormal];
    }];
    
    /* 旋转月份按钮方向 */
    [RACObserve(self.monthFilterView, isSpread) subscribeNext:^(id x) {
        [UIView animateWithDuration:0.2 animations:^{
            @strongify(self);
            self.monthSwitchBtn.rightIconLabel.transform = CGAffineTransformMakeRotation([x boolValue] ? M_PI : 0);
        }];
    }];
    
    /* 绑定: 总金额 */
    RAC(self.totalInfoHeaderView.totalMoneyLabel, text) = RACObserve(self.dataProcession, totalMoney);
    
    // 绑定: 筛选器的源数据
    RAC(self.dataFilterView, mainItems) = RACObserve(self.dataProcession.filterCtrl, mainItems);
    RAC(self.dataFilterView, subItems) = RACObserve(self.dataProcession.filterCtrl, subItems);
    
    // 无数据图片提示
    RAC(self.noDataView, hidden) = [RACObserve(self.dataProcession.seperatorCtrl, originList) map:^id(NSArray* list) {
        return @(list && list.count > 0);
    }];
    
    // 刷新完数据要停止
    [[self.dataProcession.cmd_dataRequesting executionSignals] subscribeNext:^(RACSignal* sig) {
        [[sig dematerialize] subscribeNext:^(id x) {
            
        } error:^(NSError *error) {
            @strongify(self);
            if ([self.tableView.mj_header isRefreshing]) {
                [self.tableView.mj_header endRefreshing];
            }
        } completed:^{
            @strongify(self);
            if ([self.tableView.mj_header isRefreshing]) {
                [self.tableView.mj_header endRefreshing];
            }
        }];
    }];
}


# pragma mask 4 getter

- (MLIconButtonR *)monthSwitchBtn {
    if (!_monthSwitchBtn) {
        CGFloat height = 40;
        _monthSwitchBtn = [[MLIconButtonR alloc] initWithFrame:CGRectMake(0, 0, 100, height)];
        [_monthSwitchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_monthSwitchBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.4] forState:UIControlStateHighlighted];
        _monthSwitchBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _monthSwitchBtn.rightIconLabel.text = [NSString fontAwesomeIconStringForEnum:FACaretDown];
        _monthSwitchBtn.rightIconLabel.font = [UIFont fontAwesomeFontOfSize:15];
        _monthSwitchBtn.rightIconLabel.textColor = [UIColor whiteColor];
        _monthSwitchBtn.rac_command = self.dataProcession.cmd_monthSelecting;
        _monthSwitchBtn.rac_command.allowsConcurrentExecution = YES;
    }
    return _monthSwitchBtn;
}

- (UIBarButtonItem *)filterBarBtn {
    if (!_filterBarBtn) {
        CGFloat height = 22;
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, height, height)];
        [btn setTitle:[NSString fontAwesomeIconStringForEnum:FAFilter] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:height scale:1]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.4] forState:UIControlStateHighlighted];
        btn.rac_command = self.dataProcession.cmd_dataFiltering;
        btn.rac_command.allowsConcurrentExecution = YES;
        _filterBarBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    return _filterBarBtn;
}

- (TLVC_vmCtrl *)dataProcession {
    if (!_dataProcession) {
        _dataProcession = [TLVC_vmCtrl new];
        _dataProcession.monthFilterView = self.monthFilterView;
        _dataProcession.dataFilterView = self.dataFilterView;
        _dataProcession.tableView = self.tableView;
        @weakify(self);
        _dataProcession.doDisplayDetailWithNode = ^(TLVC_mDetailMpos* mposNode) {
            @strongify(self);
            JLTransDetailVC* transDetailVC = [[JLTransDetailVC alloc] init];
            transDetailVC.dataSource.detaiNode = mposNode;
            [self.navigationController pushViewController:transDetailVC animated:YES];
        };
    }
    return _dataProcession;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)
                                                  style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = self.totalInfoHeaderView;
        _tableView.dataSource = self.dataProcession;
        _tableView.delegate = self.dataProcession;
        _tableView.rowHeight = 56;
        _tableView.sectionHeaderHeight = 44;
        NameWeakSelf(wself);
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [wself.dataProcession.cmd_dataRequesting execute:nil];
        }];
        _tableView.mj_header.automaticallyChangeAlpha = YES;
    }
    return _tableView;
}

- (TLVC_vTotalDetailView *)totalInfoHeaderView {
    if (!_totalInfoHeaderView) {
        _totalInfoHeaderView = [[TLVC_vTotalDetailView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight * 0.2)];
    }
    return _totalInfoHeaderView;
}

- (MLFilterView1Section *)monthFilterView {
    if (!_monthFilterView) {
        _monthFilterView = [[MLFilterView1Section alloc] initWithSuperVC:self];
        _monthFilterView.tintColor = [UIColor colorWithHex:0x00a1dc alpha:1];
        _monthFilterView.normalColor = [UIColor colorWithHex:0x999999 alpha:1];
        _monthFilterView.backgroundColorOfCell = [UIColor whiteColor];
    }
    return _monthFilterView;
}

- (MLFilterView2Section *)dataFilterView {
    if (!_dataFilterView) {
        _dataFilterView = [[MLFilterView2Section alloc] initWithSuperVC:self];
        _dataFilterView.tintColor = [UIColor colorWithHex:0x00a1dc alpha:1];
        _dataFilterView.mainNormalColor = [UIColor colorWithHex:0x999999 alpha:1];
        _dataFilterView.subNormalColor = [UIColor colorWithHex:0x999999 alpha:1];
    }
    return _dataFilterView;
}

- (UIBarButtonItem *)homeBarBtn {
    if (!_homeBarBtn) {
        CGFloat height = 22;
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, height, height)];
        [btn setTitle:[NSString fontAwesomeIconStringForEnum:FAHome] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.4] forState:UIControlStateHighlighted];
        btn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:height scale:1]];
        [btn addTarget:self action:@selector(backToHomeVC:) forControlEvents:UIControlEventTouchUpInside];
        _homeBarBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    return _homeBarBtn;
}
- (JLViewNoData *)noDataView {
    if (!_noDataView) {
        CGRect frame = self.tableView.bounds;
        frame.origin.y = self.totalInfoHeaderView.frame.size.height;
        frame.size.height -= self.totalInfoHeaderView.frame.size.height;
        _noDataView = [[JLViewNoData alloc] initWithFrame:frame];
    }
    return _noDataView;
}

@end
