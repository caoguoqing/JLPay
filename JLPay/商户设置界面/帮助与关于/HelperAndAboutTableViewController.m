//
//  HelperAndAboutTableViewController.m
//  JLPay
//
//  Created by jielian on 15/8/14.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "HelperAndAboutTableViewController.h"
#import "BangdingViewController.h"
#import "PublicInformation.h"
#import "Define_Header.h"
#import "Masonry.h"
#import "MyBusinessViewController.h"
#import "ModelAppInformation.h"


@implementation HelperAndAboutTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"帮助与关于";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    
    NameWeakSelf(wself);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.top.equalTo(wself.view.mas_top).offset(64);
        make.right.equalTo(wself.view.mas_right);
        make.bottom.equalTo(wself.view.mas_bottom);
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"reuseCellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseCellIdentifier"];
    }
    cell.textLabel.text = [self.cellTitles objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* viewController;

    if (indexPath.row < 3) {
        viewController = [storyBoard instantiateViewControllerWithIdentifier:@"帮助界面"];
        BangdingViewController* tongyong = (BangdingViewController*)viewController;
        NSString* viewTitle = [[self.cellTitles objectAtIndex:indexPath.row] substringFromIndex:2];
        [tongyong setTitle:viewTitle];
        
        NSString* key = [self.cellTitles objectAtIndex:indexPath.row];
        NSArray* imageTitles = [self.dictTitlesAndImages objectForKey:key];
        NSDictionary* imagesAndDescs = [self.dictTitlesAndDatas objectForKey:key];
        [tongyong setArrayTitles:imageTitles];
        [tongyong setDictTitlesAndDesc:imagesAndDescs];
        
    }
    else if (indexPath.row == 3) {
        viewController = [[MyBusinessViewController alloc] initWithNibName:nil bundle:nil];
    }
    else if (indexPath.row == 4) {
        viewController = [storyBoard instantiateViewControllerWithIdentifier:@"关于我们"];
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mask ---- getter & setter 

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)cellTitles {
    if (_cellTitles == nil) {
        _cellTitles = [[NSMutableArray alloc] init];
        [_cellTitles addObject:@"1.绑定设备"];
        [_cellTitles addObject:@"2.刷卡指引"];
        [_cellTitles addObject:@"3.交易明细"];
        NSString* appName = [@"4.我的" stringByAppendingString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
        [_cellTitles addObject:appName];
        if (BranchAppName != 1) {
            [_cellTitles addObject:@"5.关于我们"];
        }
    }
    return _cellTitles;
}
- (NSMutableDictionary *)dictTitlesAndImages {
    if (_dictTitlesAndImages == nil) {
        _dictTitlesAndImages = [NSMutableDictionary dictionaryWithCapacity:3];
        for (int i = 0; i < 3; i++) {
            NSString* key = [self.cellTitles objectAtIndex:i];
            NSMutableArray* imageTitles = [[NSMutableArray alloc] init];
            if (i == 0) {
                [imageTitles addObject:@"选择设备"];
                [imageTitles addObject:@"选择终端号"];
                [imageTitles addObject:@"绑定设备"];
            } else if (i == 1) {
//                [imageTitles addObject:[PublicInformation imageNameCustPayViewShot]];
                [imageTitles addObject:@"输入金额"];
                [imageTitles addObject:@"提示刷卡"];
                [imageTitles addObject:@"输入密码"];
            } else if (i == 2) {
                [imageTitles addObject:@"点击列表"];
                [imageTitles addObject:@"指定日期"];
                [imageTitles addObject:@"模糊查询"];
            }
            [_dictTitlesAndImages setObject:imageTitles forKey:key];
        }
    }
    return _dictTitlesAndImages;
}

- (NSMutableDictionary *)dictTitlesAndDatas {
    if (_dictTitlesAndDatas == nil) {
        _dictTitlesAndDatas = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < 3; i++) {
            NSString* key = [self.cellTitles objectAtIndex:i];
            NSMutableDictionary* datas = [[NSMutableDictionary alloc] init];
            if (i == 0) {
                [datas setValue:@"1.自动或手动刷新扫描蓝牙POS设备，点击选择设备" forKey:@"选择设备"];
                [datas setValue:@"2.如有多个终端号，可切换终端号" forKey:@"选择终端号"];
                [datas setValue:@"3.连接设备后，点击'绑定'按钮进行设备签到和绑定" forKey:@"绑定设备"];
            } else if (i == 1) {
//                [datas setValue:@"1.请输入交易金额" forKey:[PublicInformation imageNameCustPayViewShot]];
                [datas setValue:@"1.请输入交易金额" forKey:@"输入金额"];
                [datas setValue:@"2.连接设备，提示刷卡" forKey:@"提示刷卡"];
                [datas setValue:@"3.输入支付密码" forKey:@"输入密码"];
            } else if (i == 2) {
                [datas setValue:@"1.点击列表，查看单笔交易详情" forKey:@"点击列表"];
                [datas setValue:@"2.点击月份按钮，查询指定月份交易" forKey:@"指定日期"];
                [datas setValue:@"3.点击筛选，可进行多选项多条件筛选明细" forKey:@"模糊查询"];
            }
            [_dictTitlesAndDatas setObject:datas forKey:key];
        }
    }
    return _dictTitlesAndDatas;
}


@end
