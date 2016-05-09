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

#import "RateChooseViewController.h"
#import "MyBusinessViewController.h"


static NSString* const kTitleSettingBusinessName = @"账号名称";
static NSString* const kTitleSettingTransDetails = @"交易明细";
static NSString* const kTitleSettingDeviceBinding = @"绑定设备";
static NSString* const kTitleSettingFeeChoose = @"费率选择";
static NSString* const kTitleSettingPinUpdate = @"修改密码";
static NSString* const kTitleSettingT_0CardVerify = @"卡验证";
static NSString* const kTitleSettingBalanceSelect = @"余额查询";
static NSString* const kTitleSettingHelper = @"帮助与关于";


typedef enum {
    SettingVCAlertTagBusiChecking
} SettingVCAlertTag;


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
    if ([ModelUserLoginInformation checkSate] == BusinessCheckStateChecked && ![ModelDeviceBindedInformation hasBindedDevice]) {
        UIViewController* viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"deviceSigninVC"];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:NO];
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
        businessInfoCell.labelUserId.text = [ModelUserLoginInformation userID];
        businessInfoCell.labelBusinessName.text = [ModelUserLoginInformation businessName];
        businessInfoCell.labelBusinessNo.text = [ModelUserLoginInformation businessNumber];
        if ([ModelUserLoginInformation checkSate] == BusinessCheckStateChecked) {
            businessInfoCell.labelCheckedState.hidden = YES;
        }
        else if ([ModelUserLoginInformation checkSate] == BusinessCheckStateChecking) {
            businessInfoCell.labelCheckedState.hidden = NO;
            businessInfoCell.labelCheckedState.text = @"审核中";
        }
        else if ([ModelUserLoginInformation checkSate] == BusinessCheckStateCheckRefused) {
            businessInfoCell.labelCheckedState.hidden = NO;
            businessInfoCell.labelCheckedState.text = @"审核拒绝";
        }
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
    
    CGRect frame = [tableView rectForRowAtIndexPath:indexPath];
    UIView* selectedBView = [[UIView alloc] initWithFrame:frame];
    selectedBView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.2];
    [cell setSelectedBackgroundView:selectedBView];
    
    
    if ([cellName isEqualToString:kTitleSettingTransDetails]) {
        if ([ModelUserLoginInformation checkSate] == BusinessCheckStateChecked) {
            viewController = [storyBoard instantiateViewControllerWithIdentifier:@"transDetailsVC"];
            TransDetailsViewController* vc = (TransDetailsViewController*)viewController;
            vc.tradePlatform = NameTradePlatformMPOSSwipe;
        } else {
            [PublicInformation alertSureWithTitle:@"温馨提示" message:@"商户正在审核中,不允许操作" tag:SettingVCAlertTagBusiChecking delegate:self];
        }
    }
    else if ([cellName isEqualToString:kTitleSettingDeviceBinding]) {
        if ([ModelUserLoginInformation checkSate] == BusinessCheckStateChecked) {
            viewController = [storyBoard instantiateViewControllerWithIdentifier:@"deviceSigninVC"];
        } else {
            [PublicInformation alertSureWithTitle:@"温馨提示" message:@"商户正在审核中,不允许操作" tag:SettingVCAlertTagBusiChecking delegate:self];
        }
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
        if ([ModelUserLoginInformation checkSate] == BusinessCheckStateChecked) {
            viewController = [[RateChooseViewController alloc] initWithNibName:nil bundle:nil];
            [viewController setTitle:cellName];
        } else {
            [PublicInformation alertSureWithTitle:@"温馨提示" message:@"商户正在审核中,不允许操作" tag:SettingVCAlertTagBusiChecking delegate:self];
        }
    }
    else if ([cellName isEqualToString:kTitleSettingBalanceSelect]) {
        if ([ModelUserLoginInformation checkSate] == BusinessCheckStateChecked) {
            viewController = [storyBoard instantiateViewControllerWithIdentifier:@"brush"];
            BrushViewController* brushVC = (BrushViewController*)viewController;
            brushVC.stringOfTranType = TranType_YuE;
        } else {
            [PublicInformation alertSureWithTitle:@"温馨提示" message:@"商户正在审核中,不允许操作" tag:SettingVCAlertTagBusiChecking delegate:self];
        }
    }
    else if ([cellName isEqualToString:kTitleSettingT_0CardVerify]) {
        if ([ModelUserLoginInformation checkSate] == BusinessCheckStateChecked) {
            viewController = [[T_0CardListViewController alloc] initWithNibName:nil bundle:nil];
        } else {
            [PublicInformation alertSureWithTitle:@"温馨提示" message:@"商户正在审核中,不允许操作" tag:SettingVCAlertTagBusiChecking delegate:self];
        }
    }
    else if ([cellName isEqualToString:kTitleSettingBusinessName]) {
        viewController = [[MyBusinessViewController alloc] initWithNibName:nil bundle:nil];
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



#pragma mask ---- getter & setter
// 功能名称:cell名
- (NSArray *)cellNames {
    if (_cellNames == nil) {
        NSMutableArray* cellNames = [NSMutableArray array];
        [cellNames addObject:kTitleSettingBusinessName];
        [cellNames addObject:kTitleSettingTransDetails];
        [cellNames addObject:kTitleSettingDeviceBinding];
        if ([ModelUserLoginInformation allowedMoreBusiness] || [ModelUserLoginInformation allowedMoreRate]) {
            if (BranchAppName != 3) {
                [cellNames addObject:kTitleSettingFeeChoose];
            }
        }
        if ([ModelUserLoginInformation allowedT_0] && BranchAppName != 3) {
            [cellNames addObject:kTitleSettingT_0CardVerify];
        }
        [cellNames addObject:kTitleSettingPinUpdate];
        if (BranchAppName != 3) {
            [cellNames addObject:kTitleSettingHelper];
        }
        _cellNames = [NSArray arrayWithArray:cellNames];
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
