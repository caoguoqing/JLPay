//
//  T_0CardListViewController.m
//  JLPay
//
//  Created by jielian on 15/12/29.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "T_0CardListViewController.h"
#import "T_0CardUploadViewController.h"
#import "HttpRequestT0CardList.h"
#import "PublicInformation.h"
#import "SubAndDetailLabelCell.h"
#import "KVNProgress.h"
#import "PullRefrashView.h"

@interface T_0CardListViewController()
<UITableViewDataSource, UITableViewDelegate, HttpRequestT0CardListDelegate>
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIBarButtonItem* addtionButton;
@property (nonatomic, assign) CGFloat lastScrollOffsetY;
@property (nonatomic, strong) PullRefrashView* pullRefrashView;
@end

@implementation T_0CardListViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    self.title = @"T+0银行卡列表";
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self loadSubviews];
    
    // 查询列表
    [self startRequestCardInfoList];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[HttpRequestT0CardList sharedInstance] terminateRequesting];
}
- (void) loadSubviews {
    CGFloat heightStates = [PublicInformation returnStatusHeight];
    CGFloat heightNavi = self.navigationController.navigationBar.frame.size.height;
    CGFloat heightTabbar = self.tabBarController.tabBar.frame.size.height;
    CGFloat heightPullRefrash = 50;
    
    CGRect frame = CGRectMake(0,
                              heightStates + heightNavi,
                              self.view.frame.size.width,
                              self.view.frame.size.height - heightStates - heightNavi - heightTabbar);
    [self.tableView setFrame:frame];
    [self.view addSubview:self.tableView];
    
    frame.origin.y = -heightPullRefrash;
    frame.size.height = heightPullRefrash;
    self.pullRefrashView = [[PullRefrashView alloc] initWithFrame:frame];
    [self.tableView addSubview:self.pullRefrashView];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCardPicture:)]];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1];
}

- (IBAction) addCardPicture:(id)sender {
    UIViewController* viewC = [[T_0CardUploadViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:viewC animated:YES];
}

#pragma mask ---- HttpRequst &&  HttpRequestT0CardListDelegate
// -- 申请数据
- (void) startRequestCardInfoList {
    [KVNProgress show];
    [[HttpRequestT0CardList sharedInstance] requestT_0CardListOnDelegate:self];
}
- (void)didRequestSuccess {
    [KVNProgress dismiss];
    
    [self.tableView reloadData];
    if (self.pullRefrashView.isRefreshing) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.pullRefrashView turnPullDown];
            [UIView animateWithDuration:0.5 animations:^{
                [self.tableView setContentInset:UIEdgeInsetsZero];
            }];
        });
    }
}
- (void)didRequestFail:(NSString *)failMessage {
    [KVNProgress showErrorWithStatus:[NSString stringWithFormat:@"查询失败:%@",failMessage]];
    [self.tableView reloadData];
    if (self.pullRefrashView.isRefreshing) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.pullRefrashView turnPullDown];
            [UIView animateWithDuration:0.5 animations:^{
                [self.tableView setContentInset:UIEdgeInsetsZero];
            }];
        });
    }
}

#pragma mask ---- UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[HttpRequestT0CardList sharedInstance] countOfCardsRequested];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"cellIdentifier__";
    SubAndDetailLabelCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SubAndDetailLabelCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    if ([[HttpRequestT0CardList sharedInstance] cardRequestedAtIndex:indexPath.row].length < 16) {
        [cell setLeftText:[[HttpRequestT0CardList sharedInstance] cardRequestedAtIndex:indexPath.row]];
    } else {
        [cell setLeftText:[PublicInformation cuttingOffCardNo:[[HttpRequestT0CardList sharedInstance] cardRequestedAtIndex:indexPath.row]]];
    }
    [cell setRightText:[self nameCuttedByOrigin:[[HttpRequestT0CardList sharedInstance] nameRequestedAtIndex:indexPath.row]]];
    [self setSubTextForCell:cell atIndex:indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}
- (void) setSubTextForCell:(SubAndDetailLabelCell*)cell atIndex:(NSInteger)index {
    NSString* cardflag = [[HttpRequestT0CardList sharedInstance] stateRequestedAtIndex:index];
    NSString* text = [[HttpRequestT0CardList sharedInstance] descriptionStateAtIndex:index];
    if ([cardflag isEqualToString:kT0CardCheckFlagChecked]) {
        [cell setSubText:text color:EnumSubTextColorGreen];
    } else {
        [cell setSubText:text];
    }
}


#pragma mask ---- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat curScrollOffsetY = scrollView.contentOffset.y;
    BOOL directionDown = (self.lastScrollOffsetY - curScrollOffsetY > 0)?(YES):(NO);
    
    if (scrollView.isDragging) { // 拖动中
        if (directionDown) { // 向下
            if (curScrollOffsetY <= -self.pullRefrashView.frame.size.height && !self.pullRefrashView.isPullingUp) {
                [self.pullRefrashView turnPullUp];
            }
        } else { // 向下或停止/启动
            if (curScrollOffsetY >= -self.pullRefrashView.frame.size.height && !self.pullRefrashView.isPullingDown) {
                [self.pullRefrashView turnPullDown];
            }
        }
    }
    self.lastScrollOffsetY = curScrollOffsetY;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastScrollOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y < -self.pullRefrashView.frame.size.height && self.pullRefrashView.isPullingUp) {
        [self.pullRefrashView turnWaiting];
        CGPoint lastOffset = scrollView.contentOffset;
        [scrollView setContentInset:UIEdgeInsetsMake(self.pullRefrashView.frame.size.height, 0, 0, 0)]; // 导致了滚动
        [scrollView setContentOffset:lastOffset];
        [self startRequestCardInfoList];
    }
}

#pragma mask 2 PRIVATE INTERFACE

// -- 截取姓名长度
- (NSString*) nameCuttedByOrigin:(NSString*)originName {
    NSMutableString* name = [[NSMutableString alloc] init];
    for (int i = 0; i < originName.length - 1; i++) {
        [name appendString:@"*"];
    }
    [name appendString:[originName substringFromIndex:originName.length - 1]];
    return name;
}

#pragma mask ---- getter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
    }
    return _tableView;
}


@end
