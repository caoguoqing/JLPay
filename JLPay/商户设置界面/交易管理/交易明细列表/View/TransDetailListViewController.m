//
//  TransDetailListViewController.m
//  JLPay
//
//  Created by jielian on 16/5/4.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "TransDetailListViewController.h"

@implementation TransDetailListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    [self addSubviews];
    [self layoutSubviews];
    [self viewsOnKVOs];
    
}

- (void) addSubviews {
    [self.navigationItem setTitleView:self.downPullBtn];
    
    [self.view addSubview:self.platSegmentView];
    [self.view addSubview:self.detailsTableView];
    [self.view addSubview:self.nearestMonthsTBV];
    [self.view addSubview:self.progressHud];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:self.filterBtn]];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:self.backHomeBtn]];
    
}
- (void)dealloc {
    JLPrint(@"*********** TransDetailListViewController dealloc *************");
}

- (void) layoutSubviews {
    NameWeakSelf(wself);
//    CGFloat heightNearestTBV = self.view.frame.size.height - 64;
    
    /*
     微信支付功能暂不上线,先屏蔽掉微信明细的查询
     */
//    [self.platSegmentView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(wself.view.mas_top).offset(64);
//        make.left.equalTo(wself.view.mas_left);
//        make.right.equalTo(wself.view.mas_right);
//        make.height.mas_equalTo(44);
//    }];
    
//    [self.nearestMonthsTBV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(wself.view.mas_top).offset(64);
//        make.left.equalTo(wself.view.mas_left);
//        make.right.equalTo(wself.view.mas_right);
//        make.height.mas_equalTo(heightNearestTBV);
//    }];

    [self.detailsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.view.mas_top).offset(64);
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.bottom.equalTo(wself.view.mas_bottom);
    }];
    
}

- (void) viewsOnKVOs{
    @weakify(self);
    
    /* binding: totalMoneyLabel.text from dataSource */
    RAC(self.totalMoneyLabelView.totalMoneyLabel, text) = [[[RACSignal merge:@[RACObserve(self.mposDataSource.detailsData, totalMoney), RACObserve(self.otherPayDataSource.detailsData, totalMoney)]] map:^NSString* (NSNumber* money) {
        return [NSString stringWithFormat:@"￥%.02lf", [money floatValue]];
    }] deliverOnMainThread];
    
    /* binding: platform for delegate */
    RAC(self.delegateForTBV, platform) = [RACObserve(self.platSegmentView, selectedItem) map:^id(NSNumber* index) {
        @strongify(self);
        return [self.platSegmentView.items objectAtIndex:index.integerValue];
    }];
    
    /* observing: month list pull up or down  */
    [[[RACObserve(self.downPullBtn, downDirection) replayLast] skip:1] subscribeNext:^(NSNumber* down) {
        @strongify(self);
        [self.nearestMonthsTBV reloadData];
        if (down.boolValue) {
            [UIView animateWithDuration:0.2 animations:^{
                @strongify(self);
                self.nearestMonthsTBV.frame = CGRectMake(0, 64, self.view.frame.size.width, 0);
                self.nearestMonthsTBV.backgroundColor = [UIColor clearColor];
            }];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                @strongify(self);
                self.nearestMonthsTBV.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
                self.nearestMonthsTBV.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            }];
        }
    }];
    
    /* observing: selected month in month list */
    [RACObserve(self.nearestMonths, selectedIndex) subscribeNext:^(NSNumber* index) {
        @strongify(self);
        NSString* originDate = [self.nearestMonths.months objectAtIndex:index.integerValue];
        originDate = [NSString stringWithFormat:@"%@年%@月", [originDate substringToIndex:4], [originDate substringFromIndex:4]];
        [self.downPullBtn setTitle:originDate forState:UIControlStateNormal];
        self.downPullBtn.downDirection = YES;
    }];
    
    /* observing: date changing */
    [[RACObserve(self.downPullBtn.titleLabel, text) skip:1] subscribeNext:^(id x) {
        @strongify(self);
        [self doRequestingDetails];
    }];

    /* observing: switch request when segment switched */
    [[RACObserve(self.platSegmentView, selectedItem) replayLast] subscribeNext:^(id x) {
        @strongify(self);
        [self doRequestingDetails];
    }];
    
    /* binding: 切换平台-重置已选择选项 */
    [RACObserve(self.platSegmentView, selectedItem) subscribeNext:^(id x) {
        @strongify(self);
        self.siftViewCtr.siftDataSources.mainSelected = -1;
        self.siftViewCtr.siftDataSources.assistantSelected = -1;
    }];

    
    /* binding: 主筛选项-mpos明细的 mainSiftTitles */
    RAC(self.siftViewCtr.siftDataSources, mainDataSourcesList) = [RACObserve(self.platSegmentView, selectedItem) map:^NSArray* (NSNumber* index) {
        @strongify(self);
        self.siftViewCtr.siftDataSources.assistantDataSourcesList = [NSArray array];
        if (index.integerValue == 0) {
            return self.mposDataSource.detailsData.mainSiftTitles;
        } else {
            return self.otherPayDataSource.detailsData.mainSiftTitles;
        }
    }];
    
    /* binding: 副筛选项-mpos明细的 assistantSiftTitles */
    RACSignal* bindingSigMposAssis = [RACSignal combineLatest:@[RACObserve(self.mposDataSource.detailsData, allDaysInOriginList),
                                                                RACObserve(self.mposDataSource.detailsData, allCardNosInOriginList),
                                                                RACObserve(self.mposDataSource.detailsData, allTransTypesInOriginList),
                                                                RACObserve(self.mposDataSource.detailsData, allMoneysInOriginList)]
                                                       reduce:^id (NSArray* allDays, NSArray* allCards, NSArray* allTransTypes, NSArray* allMoneys){
                                                           return @[allDays, allCards, allTransTypes, allMoneys];
                                                       }];
    
    RACSignal* bindingSigOtherPayAssis = [RACSignal combineLatest:@[RACObserve(self.otherPayDataSource.detailsData, allDaysInOriginList),
                                                                    RACObserve(self.otherPayDataSource.detailsData, allTransTypesInOriginList),
                                                                    RACObserve(self.otherPayDataSource.detailsData, allMoneysInOriginList)] reduce:^id(NSArray* allDates, NSArray* allTypes, NSArray* allMoneys){
                                                                        return @[allDates, allTypes, allMoneys];
                                                                    }];
    
    RAC(self.siftViewCtr.siftDataSources, assistantDataSourcesList) = [RACObserve(self.platSegmentView, selectedItem) flattenMap:^RACStream *(NSNumber* index) {
        if (index.integerValue == 0) {
            return bindingSigMposAssis;
        } else {
            return bindingSigOtherPayAssis;
        }
        
    }];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self doDismissSiftWindow:nil];
}


# pragma mask 2 Action
- (void) doRequestingDetails {
    /* 清空筛选条件 */
    [self.siftViewCtr.siftDataSources clearsSiftedIndexs];
    
    NSString* curBtnDate = [self.downPullBtn titleForState:UIControlStateNormal];
    curBtnDate = [[NSString stringWithFormat:@"%@%@",
                   [curBtnDate substringToIndex:4],
                   [curBtnDate substringWithRange:NSMakeRange(4+1, 2)]] stringByAppendingString:@"01"];
    NSString* endDate = [curBtnDate lastDayOfCurMonth];
    NameWeakSelf(wself);
    [self.progressHud showNormalWithText:@"正在查询..." andDetailText:nil];
    id dataSource ;
    if ([[self.platSegmentView.items objectAtIndex:self.platSegmentView.selectedItem] isEqualToString:TransPlatformTypeSwipe]) {
        self.detailsTableView.dataSource = self.mposDataSource;
        dataSource = self.mposDataSource;
    } else {
        self.detailsTableView.dataSource = self.otherPayDataSource;
        dataSource = self.otherPayDataSource;
    }
    
    [dataSource requestDetailsOnBeginDate:curBtnDate andEndDate:endDate onFinished:^{
        [wself.detailsTableView reloadData];
        if ([wself.detailsTableView.mj_header isRefreshing]) {
            [wself.detailsTableView.mj_header endRefreshing];
        }
        [wself.progressHud hideOnCompletion:^{
        }];
    } onError:^(NSError *error) {
        [wself.detailsTableView reloadData];
        if ([wself.detailsTableView.mj_header isRefreshing]) {
            [wself.detailsTableView.mj_header endRefreshing];
        }
        [wself.progressHud showFailWithText:@"查询失败" andDetailText:[error localizedDescription] onCompletion:^{
        }];
    }];
}

- (IBAction) clickToPullDateBtn:(DownPullListBtn*)sender {
    sender.downDirection = !sender.downDirection;
}

- (IBAction) doDisplaySiftWindow:(UIButton*)sender {
    NameWeakSelf(wself);
    if ([self.siftWindow isKeyWindow]) {
        [self.siftWindow resignKeyWindow];
        
        [UIView animateWithDuration:0.2 animations:^{
            wself.siftWindow.hidden = YES;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            [wself.siftWindow makeKeyAndVisible];
            [wself.siftViewCtr.mainSectionTBV reloadData];
            [wself.siftViewCtr.assistantSectionTBV reloadData];
        }];
    }
}
- (IBAction) doDismissSiftWindow:(UIButton*)sender {
    [self.siftWindow resignKeyWindow];
    NameWeakSelf(wself);
    [UIView animateWithDuration:0.2 animations:^{
        wself.siftWindow.hidden = YES;
    }];

}

/* home按钮 */
- (IBAction) clickedHomeBtn:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}


# pragma mask 4 getter

- (NewCustomSegmentView *)platSegmentView {
    if (!_platSegmentView) {
        _platSegmentView = [[NewCustomSegmentView alloc] initWithItems:@[TransPlatformTypeSwipe,TransPlatformTypeOtherPay]];
        _platSegmentView.backgroundColor = [UIColor whiteColor];
        _platSegmentView.segmentType = CustomSegmentViewStypeUnderLineDown;
        _platSegmentView.tintColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:0.9];
    }
    return _platSegmentView;
}

- (UITableView *)detailsTableView {
    if (!_detailsTableView) {
        _detailsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        NameWeakSelf(wself);
        _detailsTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [wself doRequestingDetails];
        }];
        _detailsTableView.mj_header.automaticallyChangeAlpha = YES;
        _detailsTableView.sectionHeaderHeight = 30;
        _detailsTableView.sectionFooterHeight = 0;
        _detailsTableView.delegate = self.delegateForTBV;
        _detailsTableView.tableHeaderView = self.totalMoneyLabelView;
        _detailsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _detailsTableView;
}

- (TotalMoneyLabView *)totalMoneyLabelView {
    if (!_totalMoneyLabelView) {
        _totalMoneyLabelView = [[TotalMoneyLabView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    }
    return _totalMoneyLabelView;
}

- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _progressHud;
}

- (VMHttpMposDetails *)mposDataSource {
    if (!_mposDataSource) {
        _mposDataSource = [[VMHttpMposDetails alloc] init];
    }
    return _mposDataSource;
}

- (VMHttpOtherPayDetails *)otherPayDataSource {
    if (!_otherPayDataSource) {
        _otherPayDataSource = [[VMHttpOtherPayDetails alloc] init];
    }
    return _otherPayDataSource;
}

- (VMDelegateForTableView *)delegateForTBV {
    if (!_delegateForTBV) {
        _delegateForTBV = [[VMDelegateForTableView alloc] init];
        NameWeakSelf(wself);
        _delegateForTBV.selectedBlock = ^ (NSInteger selectedIndex) {
            TransDetailInfoViewController* viewController = [[TransDetailInfoViewController alloc] initWithNibName:nil bundle:nil];
            viewController.platform = [wself.platSegmentView.items objectAtIndex:wself.platSegmentView.selectedItem];
            [wself.navigationController pushViewController:viewController animated:YES];
        };
    }
    return _delegateForTBV;
}

- (MNearestMonths *)nearestMonths {
    if (!_nearestMonths) {
        _nearestMonths = [[MNearestMonths alloc] init];
    }
    return _nearestMonths;
}

- (UITableView *)nearestMonthsTBV {
    if (!_nearestMonthsTBV) {
        _nearestMonthsTBV = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _nearestMonthsTBV.delegate = self.nearestMonths;
        _nearestMonthsTBV.dataSource = self.nearestMonths;
        _nearestMonthsTBV.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _nearestMonthsTBV.scrollEnabled = NO;
        [_nearestMonthsTBV setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        _nearestMonthsTBV.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _nearestMonthsTBV;
}

- (UIWindow *)siftWindow {
    if (!_siftWindow) {
        CGSize sreenSize = [UIScreen mainScreen].bounds.size;
        _siftWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 64, sreenSize.width, sreenSize.height - 64)];
        _siftWindow.windowLevel = UIWindowLevelAlert;
        _siftWindow.backgroundColor = [UIColor clearColor];
        _siftWindow.rootViewController = self.siftViewCtr;
    }
    return _siftWindow;
}

- (SiftViewController *)siftViewCtr {
    if (!_siftViewCtr) {
        _siftViewCtr = [[SiftViewController alloc] initWithNibName:nil bundle:nil];

        NameWeakSelf(wself);
        _siftViewCtr.siftFinished = ^ (NSArray<NSArray<NSNumber*>*>* siftedIndexs) {
            [wself doDismissSiftWindow:nil];
            
            if (wself.platSegmentView.selectedItem == 0) {
                [wself.mposDataSource.detailsData doSiftingOnSelectedIndexs:siftedIndexs];
            } else {
                [wself.otherPayDataSource.detailsData doSiftingOnSelectedIndexs:siftedIndexs];
            }
            [wself.detailsTableView reloadData];
        };
        
        _siftViewCtr.siftCanceled = ^ {
            [wself doDismissSiftWindow:nil];
        };
    }
    return _siftViewCtr;
}

- (DownPullListBtn *)downPullBtn {
    if (!_downPullBtn) {
        _downPullBtn = [[DownPullListBtn alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
        _downPullBtn.downLabel.textColor = [UIColor whiteColor];
        [_downPullBtn setTitle:@"2016年06月" forState:UIControlStateNormal];
        [_downPullBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_downPullBtn addTarget:self action:@selector(clickToPullDateBtn:) forControlEvents:UIControlEventTouchUpInside];
        _downPullBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    return _downPullBtn;
}

- (UIButton *)backHomeBtn {
    if (!_backHomeBtn) {
        _backHomeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [_backHomeBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAHome] forState:UIControlStateNormal];
        _backHomeBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:25 scale:1]];
        [_backHomeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backHomeBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
        [_backHomeBtn addTarget:self action:@selector(clickedHomeBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backHomeBtn;
}

- (UIButton *)filterBtn {
    if (!_filterBtn) {
        _filterBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [_filterBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAFilter] forState:UIControlStateNormal];
        _filterBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:25 scale:1]];
        [_filterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_filterBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
        [_filterBtn addTarget:self action:@selector(doDisplaySiftWindow:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _filterBtn;
}

@end
