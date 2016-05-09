//
//  MyBusinessViewController.m
//  JLPay
//
//  Created by jielian on 16/5/4.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MyBusinessViewController.h"

@implementation MyBusinessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"我的商户";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];

    [self addSubviews];
    [self layoutSubviews];
}

- (void) addSubviews {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.logoutBtn];
    [self.view addSubview:self.refreshBtn];
    [self.view addSubview:self.progressHud];
}

- (void) layoutSubviews {
    CGFloat inset = 15;
    
    NameWeakSelf(wself);
    [self.logoutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left).offset(inset);
        make.right.equalTo(wself.view.mas_right).offset(-inset);
        make.bottom.equalTo(wself.view.mas_bottom).offset(-inset);
        make.height.mas_equalTo(45);
        wself.logoutBtn.layer.cornerRadius = 45 * 0.5;
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.top.equalTo(wself.view.mas_top).offset(64);
        make.bottom.equalTo(wself.logoutBtn.mas_top).offset(-inset);
    }];
    [self.refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.tableView.mas_left);
        make.right.equalTo(wself.tableView.mas_right);
        make.top.equalTo(wself.tableView.mas_top);
        make.bottom.equalTo(wself.tableView.mas_bottom);
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    [self doMyBusinessInfoRequesting];
}

# pragma mask 2 UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return  100;
    }
    else {
        return 40;
    }
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return YES;
    }
    else {
        return NO;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString* title = [[self.dataSource.displayTitles objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (indexPath.section == 1 && [title isEqualToString:VMMyBusinessTitleState]) {
        [PublicInformation alertCancleAndOther:@"修改" title:@"温馨提示"
                                       message:@"修改需要重新上传卡和证件照片\n确定要继续修改?"
                                           tag:MyBusiAlertTagUpdateBusiness delegate:self];
    }
}


# pragma mask 2 IBAction & UIAlertViewDelegate


- (IBAction) toReRequstBusinessInfo:(BusinessVCRefreshButton*)sender {
    [self doMyBusinessInfoRequesting];
}

- (IBAction) toLogout:(UIButton*)sender {
    [PublicInformation alertCancleAndOther:@"退出登录" title:@"是否退出用户登录"
                                   message:nil tag:MyBusiAlertTagLogout delegate:self];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString* btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if (alertView.tag == MyBusiAlertTagLogout) {
        if (![btnTitle isEqualToString:@"取消"]) {
            [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else if (alertView.tag == MyBusiAlertTagUpdateBusiness && buttonIndex == 1) {
        [self doVCPushToUserRegister];
    }
}

- (void) doMyBusinessInfoRequesting {
    NameWeakSelf(wself);
    [self.progressHud showNormalWithText:@"正在加载商户数据..." andDetailText:nil];
    [self.dataSource requestMyBusinessInfoOnFinished:^{
        [wself.progressHud hideOnCompletion:^{
            wself.refreshBtn.hidden = YES;
            wself.tableView.hidden = NO;
            [wself.tableView reloadData];
        }];
    } onErrorBlock:^(NSError *error) {
        if (error.code == VMDataSourceMyBusiCodeCheckRefuse) {
            wself.refreshBtn.hidden = NO;
            wself.tableView.hidden = YES;
            [PublicInformation alertSureWithTitle:@"商户审核被拒绝" message:@"请耐心等待审核,亦可在登录时修改商户信息" tag:MyBusiAlertTagLogout delegate:wself];
        } else {
            [wself.progressHud showFailWithText:@"加载失败" andDetailText:[error localizedDescription] onCompletion:^{
                wself.refreshBtn.hidden = NO;
                wself.tableView.hidden = YES;
            }];
        }
    }];
}

- (void) doVCPushToUserRegister {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserRegisterViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"userRegisterVC"];
    [viewController setRegisterType:RegisterTypeRefused];
    [viewController loadLastRegisterInfo:[MHttpBusinessInfo sharedVM].businessInfo];
    [self.navigationController pushViewController:viewController animated:YES];
}

# pragma mask 4 getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.dataSource = self.dataSource;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (VMDataSourceMyBusiness *)dataSource {
    if (!_dataSource) {
        _dataSource = [[VMDataSourceMyBusiness alloc] init];
    }
    return _dataSource;
}

- (UIButton *)logoutBtn {
    if (!_logoutBtn) {
        _logoutBtn = [UIButton new];
        _logoutBtn.backgroundColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        [_logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
        [_logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_logoutBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.4] forState:UIControlStateHighlighted];
        [_logoutBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.4] forState:UIControlStateDisabled];
        [_logoutBtn addTarget:self action:@selector(toLogout:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _logoutBtn;
}

- (BusinessVCRefreshButton *)refreshBtn {
    if (!_refreshBtn) {
        _refreshBtn = [[BusinessVCRefreshButton alloc] initWithFrame:CGRectZero];
        _refreshBtn.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.15];
        [_refreshBtn setTitle:@"刷新我的商户数据" forState:UIControlStateNormal];
        [_refreshBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateNormal];
        [_refreshBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_refreshBtn addTarget:self action:@selector(toReRequstBusinessInfo:) forControlEvents:UIControlEventTouchUpInside];
        _refreshBtn.hidden = YES;
    }
    return _refreshBtn;
}

- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _progressHud;
}

@end
