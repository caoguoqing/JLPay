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

@interface HelperAndAboutTableViewController ()
@property (nonatomic, strong) NSMutableArray* cellTitles;
@property (nonatomic, strong) NSMutableDictionary* dictTitlesAndImages;
@property (nonatomic, strong) NSMutableDictionary* dictTitlesAndDatas;
@end

@implementation HelperAndAboutTableViewController
@synthesize cellTitles = _cellTitles;
@synthesize dictTitlesAndImages = _dictTitlesAndImages;
@synthesize dictTitlesAndDatas = _dictTitlesAndDatas;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:view];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseCellIdentifier" forIndexPath:indexPath];
    cell.textLabel.text = [self.cellTitles objectAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* viewController;

    if (indexPath.row != 3) {
        viewController = [storyBoard instantiateViewControllerWithIdentifier:@"帮助界面"];
        BangdingViewController* tongyong = (BangdingViewController*)viewController;
        NSString* viewTitle = [[self.cellTitles objectAtIndex:indexPath.row] substringFromIndex:2];
        [tongyong setTitle:viewTitle];
        
        NSString* key = [self.cellTitles objectAtIndex:indexPath.row];
        NSArray* imageTitles = [self.dictTitlesAndImages objectForKey:key];
        NSDictionary* imagesAndDescs = [self.dictTitlesAndDatas objectForKey:key];
        [tongyong setArrayTitles:imageTitles];
        [tongyong setDictTitlesAndDesc:imagesAndDescs];
        
    } else {
        viewController = [storyBoard instantiateViewControllerWithIdentifier:@"关于我们"];
    }
    
    
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mask ---- getter & setter 
- (NSMutableArray *)cellTitles {
    if (_cellTitles == nil) {
        _cellTitles = [[NSMutableArray alloc] init];
        [_cellTitles addObject:@"1.绑定设备"];
        [_cellTitles addObject:@"2.刷卡指引"];
        [_cellTitles addObject:@"3.交易明细"];
        [_cellTitles addObject:@"4.关于我们"];
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
                [imageTitles addObject:@"搜索设备"];
                [imageTitles addObject:@"选择设备"];
            } else if (i == 1) {
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
                [datas setValue:@"1.自动搜索蓝牙POS设备，获取SN号" forKey:@"搜索设备"];
                [datas setValue:@"2.手动选择设备终端编号和SN号，执行绑定" forKey:@"选择设备"];
            } else if (i == 1) {
                [datas setValue:@"1.请输入交易金额" forKey:@"输入金额"];
                [datas setValue:@"2.连接设备，提示刷卡" forKey:@"提示刷卡"];
                [datas setValue:@"3.输入支付密码" forKey:@"输入密码"];
            } else if (i == 2) {
                [datas setValue:@"1.点击列表，查看单笔交易明细" forKey:@"点击列表"];
                [datas setValue:@"2.选择交易日期，查询指定日期交易" forKey:@"指定日期"];
                [datas setValue:@"3.点击查询按钮，输入后4位卡号或交易金额" forKey:@"模糊查询"];
            }
            [_dictTitlesAndDatas setObject:datas forKey:key];
        }
    }
    return _dictTitlesAndDatas;
}


@end
