//
//  settingViewController.m
//  JLPay
//
//  Created by jielian on 15/4/10.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "settingViewController.h"
#import "BusinessInfoTableViewCell.h"
#import "NormalTableViewCell.h"
#import "TransDetailsViewController.h"
#import "Define_Header.h"
#import "DeviceSignInViewController.h"
#import "BrushViewController.h"
#import "T_0CardListViewController.h"
#import "Packing8583.h"

#import "ModelUserLoginInformation.h"
#import "ModelDeviceBindedInformation.h"

#import "TestVCForDeviceBinding.h"
#import "RateChooseViewController.h"


static NSString* const kTitleSettingBusinessName = @"账号名称";
static NSString* const kTitleSettingTransDetails = @"交易明细";
static NSString* const kTitleSettingDeviceBinding = @"绑定设备";
static NSString* const kTitleSettingFeeChoose = @"费率选择";
static NSString* const kTitleSettingPinUpdate = @"修改密码";
static NSString* const kTitleSettingT_0CardVerify = @"T+0卡验证";
static NSString* const kTitleSettingBalanceSelect = @"余额查询";
static NSString* const kTitleSettingHelper = @"帮助与关于";



@interface settingViewController ()<UIAlertViewDelegate>
@property (nonatomic, strong) NSArray *cellNames;           // 单元格对应的功能名称
@property (nonatomic, strong) NSMutableDictionary *cellNamesAndImages; // 单元格表示的数据字典
@end


@implementation settingViewController
@synthesize cellNames  = _cellNames;
@synthesize cellNamesAndImages      = _cellNamesAndImages;



- (void)viewDidLoad {
    self.tableView.rowHeight        = 50.f;                               // 设置cell的行高
    
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    
    [super viewDidLoad];
    // 将多余的cell的下划线置空
    [self setExtraCellLineHidden:self.tableView];
    
    // 只校验一次: 如果未绑定设备就直接跳转到设备绑定界面
    if (![ModelDeviceBindedInformation hasBindedDevice]) {
        UIViewController* viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"deviceSigninVC"];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mask ---- UITableViewDelegate & UITableViewDataSource

/*************************************
 * 功  能 : 设置 tableView 的 section 个数;
 *************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*************************************
 * 功  能 : UITableViewDelegate :numberOfRowsInSection 协议;
 *************************************/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellNames.count;
}


/*************************************
 * 功  能 : UITableViewDataSource :heightForRowAtIndexPath 协议:设置行高
 *************************************/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return tableView.rowHeight * 1.5f;
    }
    return tableView.rowHeight;
}

/*************************************
 * 功  能 : UITableViewDelegate :屏蔽指定cell 的点击高亮效果
 *************************************/
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

/*************************************
 * 功  能 : UITableViewDataSource :cellForRowAtIndexPath 协议;
 * 参  数 :
 *          (UITableView *)tableView  当前表视图
 *          (NSIndexPath *)indexPath  cell的索引
 * 返  回 :
 *          UITableViewCell*          新创建或被复用的cell
 *************************************/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellIdentifier = [self reuseIdentifierAtIndexPath:indexPath];
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        if (indexPath.row == 0) {
            cell = [[BusinessInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        } else {
            cell = [[NormalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
    }
    // 下面是 cell 的装载
    if (indexPath.row == 0) {
        BusinessInfoTableViewCell* businessInfoCell = (BusinessInfoTableViewCell*)cell;
        [businessInfoCell setUserId:[ModelUserLoginInformation userID]];
        [businessInfoCell setBusinessName:[ModelUserLoginInformation businessName]];
        [businessInfoCell setBusinessNo:[ModelUserLoginInformation businessNumber]];
    } else {
        NormalTableViewCell* normalCell = (NormalTableViewCell*)cell;
        NSString *labelName         = [self.cellNames objectAtIndex:indexPath.row];
        NSString *imageName         = [self.cellNamesAndImages objectForKey:labelName];
        [normalCell setCellImage:[UIImage imageNamed:imageName]];
        [normalCell setCellName:labelName];

    }
    return cell;
}


/*************************************
 * 功  能 : 单元格的点击动作实现;
 *          -账号名称及信息
 *          -交易明细
 *          -绑定设备
 *          -额度查询
 *          -修改密码
 *          -意见反馈
 *          -参数设置
 *          -帮助和关于
 * 参  数 :
 *          (UITableView *)tableView  当前表视图
 *          (NSIndexPath *)indexPath  被点击单元格索引
 * 返  回 : 无
 *************************************/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    NSString* cellName = [self.cellNames objectAtIndex:indexPath.row];
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* viewController = nil;
    
    if ([cellName isEqualToString:kTitleSettingTransDetails]) {
        viewController = [storyBoard instantiateViewControllerWithIdentifier:@"transDetailsVC"];
        TransDetailsViewController* vc = (TransDetailsViewController*)viewController;
        vc.tradePlatform = NameTradePlatformMPOSSwipe;
    }
    else if ([cellName isEqualToString:kTitleSettingDeviceBinding]) {
        viewController = [storyBoard instantiateViewControllerWithIdentifier:@"deviceSigninVC"];
    }
    else if ([cellName isEqualToString:kTitleSettingPinUpdate]) {
        viewController = [storyBoard instantiateViewControllerWithIdentifier:@"changePinVC"];
        [viewController setTitle:cellName];
    }
    else if ([cellName isEqualToString:kTitleSettingHelper]) {
        viewController = [storyBoard instantiateViewControllerWithIdentifier:@"helperAndAboutVC"];
        [viewController setTitle:cellName];
    }
    else if ([cellName isEqualToString:kTitleSettingFeeChoose]) {
        viewController = [[RateChooseViewController alloc] initWithNibName:nil bundle:nil];
        [viewController setTitle:cellName];
    }
    else if ([cellName isEqualToString:kTitleSettingBalanceSelect]) {
        viewController = [storyBoard instantiateViewControllerWithIdentifier:@"brush"];
        BrushViewController* brushVC = (BrushViewController*)viewController;
        brushVC.stringOfTranType = TranType_YuE;
    }
    else if ([cellName isEqualToString:kTitleSettingT_0CardVerify]) {
        viewController = [[T_0CardListViewController alloc] initWithNibName:nil bundle:nil];
    }
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

/* cell 的重用标示 */
- (NSString*) reuseIdentifierAtIndexPath:(NSIndexPath*)indexPath {
    NSString* reuseIdentifier = nil;
    if (indexPath.row == 0) {
        reuseIdentifier = @"businessCellIdentifier";
    } else {
        reuseIdentifier = @"normalCellIdentifier";
    }
    return reuseIdentifier;
}

// pragma mask ::: 去掉多余的单元格的分割线
- (void) setExtraCellLineHidden: (UITableView*)tableView {
    UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

// 简化代码
- (void) alertShowWithMessage:(NSString*)msg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:msg message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}


#pragma mask ---- getter & setter
// 功能名称:cell名
- (NSArray *)cellNames {
    if (_cellNames == nil) {
        _cellNames = [NSArray arrayWithObjects:
                      kTitleSettingBusinessName,
                      kTitleSettingTransDetails,
                      kTitleSettingDeviceBinding,
                      kTitleSettingFeeChoose,
//                      kTitleSettingBalanceSelect,
                      kTitleSettingT_0CardVerify,
                      kTitleSettingPinUpdate,
                      kTitleSettingHelper, nil];
    }
    return _cellNames;
}
- (NSMutableDictionary *)cellNamesAndImages {
    if (_cellNamesAndImages == nil) {
        _cellNamesAndImages = [[NSMutableDictionary alloc] init];
        [_cellNamesAndImages setValue:@"01_01" forKey:kTitleSettingBusinessName];
        [_cellNamesAndImages setValue:@"01_10" forKey:kTitleSettingTransDetails];
        [_cellNamesAndImages setValue:@"01_14" forKey:kTitleSettingDeviceBinding];
        [_cellNamesAndImages setValue:@"01_18" forKey:kTitleSettingPinUpdate];
        [_cellNamesAndImages setValue:@"01_24" forKey:kTitleSettingHelper];
        [_cellNamesAndImages setValue:@"01_12" forKey:kTitleSettingFeeChoose];
        [_cellNamesAndImages setValue:@"01_16" forKey:kTitleSettingBalanceSelect];
        [_cellNamesAndImages setValue:@"T_0CardVerify" forKey:kTitleSettingT_0CardVerify];
    }
    return _cellNamesAndImages;
}


@end
