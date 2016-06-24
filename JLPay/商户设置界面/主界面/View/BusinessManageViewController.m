//
//  BusinessManageViewController.m
//  JLPay
//
//  Created by jielian on 16/6/20.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "BusinessManageViewController.h"
#import <objc/runtime.h>
#import "Define_Header.h"
#import "Masonry.h"
#import "MLoginSavedResource.h"
#import "ModelDeviceBindedInformation.h"
#import "MyBusinessViewController.h"

@implementation BusinessManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"商户管理";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"签退" style:UIBarButtonItemStylePlain target:self action:@selector(logout)]];
    
    [self loadSubviews];
    [self layoutSubviews];
    
//    [self pushToDeviceBindingViewControllerIfNotBinded];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = NO;
}

- (void) loadSubviews {
    [self.view addSubview:self.tableView];
}

- (void) layoutSubviews {
    NameWeakSelf(wself);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.top.equalTo(wself.view.mas_top).offset(64);
        make.right.equalTo(wself.view.mas_right);
        make.bottom.equalTo(wself.view.mas_bottom).offset(- wself.tabBarController.tabBar.frame.size.height);
    }];
}


# pragma mask 1  UITableViewDelegate



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.businessFuncItems.funcItemTitles objectAtIndex:indexPath.row] isEqualToString:FuncItemTitleBusinessInfo]) {
        return 80;
    } else {
        return 46;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.businessFuncItems.funcItemTitles objectAtIndex:indexPath.row] isEqualToString:FuncItemTitleBusinessInfo]) {
        return NO;
    } else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString* title = [self.businessFuncItems.funcItemTitles objectAtIndex:indexPath.row];
    
    if ([title isEqualToString:FuncItemTitleCodeScanning]) {
        [PublicInformation makeCentreToast:@"敬请期待,即将开通!"];
    } else {
        
        if ([MLoginSavedResource sharedLoginResource].checkedState != BusinessCheckedStateChecked &&
            ![title isEqualToString:FuncItemTitlePinModifying] &&
            ![title isEqualToString:FuncItemTitleHelpAndUs]
            )
        {
            [PublicInformation makeCentreToast:@"商户正在审核中，不允许操作"];
        } else {
            NSString* viewControllerName = [self.businessFuncItems.viewControllersForTitles objectForKey:title];
            [self pushToViewController:viewControllerName];
        }
    }
    
}

# pragma mask 2 UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString* title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"退出登录"]) {
        [self.tabBarController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

# pragma mask 3 private inter

/* 如果未绑定设备，则跳到设备绑定界面 */
- (void) pushToDeviceBindingViewControllerIfNotBinded {
    if (![ModelDeviceBindedInformation hasBindedDevice]) {
        [self pushToViewController:[self.businessFuncItems.viewControllersForTitles objectForKey:FuncItemTitleDeviceBinding]];
    }
}

/* 跳转到指定的界面管理器:(管理器名) */
- (void) pushToViewController:(NSString*)vcName {
    UIViewController* viewController = [[objc_getClass([vcName UTF8String]) alloc] initWithNibName:nil bundle:nil];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

/* 退出登录 */
- (void) logout {
    [PublicInformation alertCancleAndOther:@"退出登录" title:@"签退" message:@"是否退出用户登录?" tag:99 delegate:self];
}

/* 跳转:我的商户界面 */
- (IBAction) pushToMyBusinessVC:(UIButton*)sender {
    [self.navigationController pushViewController:[[MyBusinessViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
}



# pragma mask 4 getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        _tableView.delegate = self;
        _tableView.dataSource = self.businessFuncItems;
        _tableView.tableHeaderView = self.headView;
    }
    return _tableView;
}

- (VMBusinessFuncItems *)businessFuncItems {
    if (!_businessFuncItems) {
        _businessFuncItems = [[VMBusinessFuncItems alloc] init];
    }
    return _businessFuncItems;
}

- (BusinessTBVHeadView *)headView {
    if (!_headView) {
        _headView = [[BusinessTBVHeadView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
        _headView.backgroundColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        _headView.businessNameLabel.text = [MLoginSavedResource sharedLoginResource].businessName;
        _headView.businessNoLabel.text = [MLoginSavedResource sharedLoginResource].businessNumber;
        _headView.checkStateBtn.layer.borderWidth = 1;
        _headView.checkStateBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        [_headView.checkStateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        BusinessCheckedState state = [MLoginSavedResource sharedLoginResource].checkedState;
        switch (state) {
            case BusinessCheckedStateChecked:
            {
                _headView.checkStateBtn.hidden = YES;
            }
                break;
            case BusinessCheckedStateChecking:
            {
                [_headView.checkStateBtn setTitle:@"审核中" forState:UIControlStateNormal];
            }
                break;
            case BusinessCheckedStateCheckRefused:
            {
                [_headView.checkStateBtn setTitle:@"审核拒绝" forState:UIControlStateNormal];
            }
                break;
            default:
                break;
        }
        [_headView.checkStateBtn addTarget:self action:@selector(pushToMyBusinessVC:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _headView;
}

@end
