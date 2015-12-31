//
//  T_0CardListViewController.m
//  JLPay
//
//  Created by jielian on 15/12/29.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "T_0CardListViewController.h"
#import "T_0CardUploadViewController.h"
#import "PublicInformation.h"
#import "SubAndDetailLabelCell.h"

@interface T_0CardListViewController()
<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIBarButtonItem* addtionButton;

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
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void) loadSubviews {
    CGFloat heightStates = [PublicInformation returnStatusHeight];
    CGFloat heightNavi = self.navigationController.navigationBar.frame.size.height;
    CGFloat heightTabbar = self.tabBarController.tabBar.frame.size.height;
    
    CGRect frame = CGRectMake(0,
                              heightStates + heightNavi,
                              self.view.frame.size.width,
                              self.view.frame.size.height - heightStates - heightNavi - heightTabbar);
    [self.tableView setFrame:frame];
    [self.view addSubview:self.tableView];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCardPicture:)]];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1];
}

- (IBAction) addCardPicture:(id)sender {
    NSLog(@"点击添加卡号照片");
    UIViewController* viewC = [[T_0CardUploadViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:viewC animated:YES];
}

#pragma mask ---- UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"cellIdentifier__";
    SubAndDetailLabelCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SubAndDetailLabelCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    // testing ......
    if (indexPath.row == 0) {
        [cell setLeftText:[PublicInformation cuttingOffCardNo: @"1234567890123456789"]];
        [cell setRightText:[self nameCuttedByOrigin:@"搜集地方能"]];
        [cell setSubText:@"是不搜索京东金佛搜到金佛i"];
    }
    else if (indexPath.row == 1) {
        [cell setLeftText:[PublicInformation cuttingOffCardNo: @"622657363762777"]];
        [cell setRightText:[self nameCuttedByOrigin:@"搜集地"]];
        [cell setSubText:@"不允许;作弊卡"];
    }
    else {
        [cell setLeftText:[PublicInformation cuttingOffCardNo: @"62265736376273723"]];
        [cell setRightText:[self nameCuttedByOrigin:@"测试"]];
        [cell setSubText:@"允许"];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

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
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
    }
    return _tableView;
}


@end
