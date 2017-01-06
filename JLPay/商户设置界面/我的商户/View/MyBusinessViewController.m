//
//  MyBusinessViewController.m
//  JLPay
//
//  Created by jielian on 16/5/4.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MyBusinessViewController.h"

@interface MyBusinessViewController()

@property (nonatomic, copy) void (^ finishedBlock) (void);
@property (nonatomic, copy) void (^ canceledBlock) (void);

@end

@implementation MyBusinessViewController

- (instancetype)initWithFinished:(void (^)(void))finishedBlock orCanceled:(void (^)(void))canceledBlock {
    self = [super init];
    if (self) {
        self.finishedBlock = finishedBlock;
        self.canceledBlock = canceledBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"商户信息界面";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];

    [self addSubviews];
    [self layoutSubviews];
}

- (void) addSubviews {
    [self.navigationItem setLeftBarButtonItem:[self newCancelBarBtn]];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.uploadBtn];
    [self.view addSubview:self.reaplyBtn];
    [self.view addSubview:self.refreshBtn];
}

- (void) layoutSubviews {
    CGFloat inset = 10;
    CGFloat heightBtn = self.view.frame.size.height * 1/14.f;
    //uploadBtn
    NameWeakSelf(wself);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.top.equalTo(wself.view.mas_top).offset(64);
        make.bottom.equalTo(wself.view.mas_bottom).offset(0);
    }];
    [self.refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.tableView.mas_left);
        make.right.equalTo(wself.tableView.mas_right);
        make.top.equalTo(wself.tableView.mas_top);
        make.bottom.equalTo(wself.tableView.mas_bottom);
    }];
    [self.uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left).offset(inset);
        make.right.equalTo(wself.view.mas_right).offset(-inset);
        make.top.equalTo(wself.view.mas_bottom).offset(inset * 2 + heightBtn);
        make.height.mas_equalTo(heightBtn);
        wself.uploadBtn.layer.cornerRadius = heightBtn * 0.5;
    }];
    [self.reaplyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.uploadBtn.mas_left);
        make.right.equalTo(wself.uploadBtn.mas_right);
        make.bottom.equalTo(wself.uploadBtn.mas_top).offset(-inset);
        make.height.equalTo(wself.uploadBtn.mas_height);
        wself.reaplyBtn.layer.cornerRadius = heightBtn * 0.5;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    [self doMyBusinessInfoRequesting];
}

# pragma mask 1 IBAction

- (IBAction) clickedHomeBarBtn:(id)sender {
    NameWeakSelf(wself);
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (wself.canceledBlock) {
            wself.canceledBlock();
        }
    }];
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
    return NO;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableView.sectionFooterHeight)];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

# pragma mask 2 IBAction & UIAlertViewDelegate


- (IBAction) toReRequstBusinessInfo:(BusinessVCRefreshButton*)sender {
    [self doMyBusinessInfoRequesting];
}

- (IBAction) toReaplyBusinessInfo:(UIButton*)sender {
    [PublicInformation alertCancleAndOther:@"重新申请" title:@"重新申请商户" message:@"重新申请的上传资料需要重新审核，确定要重新申请?" tag:MyBusiAlertTagReaplyBusinessInfo delegate:self];
}
- (IBAction) toUploadBusinessInfo:(UIButton*)sender {
    [PublicInformation alertCancleAndOther:@"确定" title:@"申请资料上传" message:@"补充上传的资料需要重新审核，确定要申请并上传?" tag:MyBusiAlertTagReaplyBusinessInfo delegate:self];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == MyBusiAlertTagReaplyBusinessInfo && buttonIndex == 1) {
        [self doVCPushToUserRegister];
    }
    else if (alertView.tag == MyBusiAlertTagUploadBusinessInfo && buttonIndex == 1) {
        [self doVCPushToUserRegister];
    }
}

- (void) doMyBusinessInfoRequesting {
    NameWeakSelf(wself);
    [MBProgressHUD showNormalWithText:@"正在加载商户数据..." andDetailText:nil];
    [self.dataSource requestMyBusinessInfoOnFinished:^{
        [MBProgressHUD hideCurNormalHud];
        wself.refreshBtn.hidden = YES;
        wself.tableView.hidden = NO;
        [wself.tableView reloadData];
        // 根据审核状态更新按钮的布局.....
        [wself updateButtonsLayout];
    } onErrorBlock:^(NSError *error) {
        [MBProgressHUD showFailWithText:@"加载失败" andDetailText:[error localizedDescription] onCompletion:^{
            wself.refreshBtn.hidden = NO;
            wself.tableView.hidden = YES;
        }];
    }];
}

- (void) doVCPushToUserRegister {
    UserRegisterViewController* viewController = [[UserRegisterViewController alloc] init];
    [viewController setRegisterType:RegisterTypeRefused];
    [viewController loadLastRegisterInfo:[MHttpBusinessInfo sharedVM].businessInfo];
    [self.navigationController pushViewController:viewController animated:YES];
}
- (void) updateButtonsLayout {
    NameWeakSelf(wself);
    CGFloat heightBtn = self.view.frame.size.height * 1/14.f;
    CGFloat inset = 10;

    if (self.dataSource.businessState == VMDataSourceMyBusiCodeCheckRefuse) {
        self.reaplyBtn.hidden = NO;
        [self.uploadBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(wself.view.mas_bottom).offset(-(inset + heightBtn));
        }];
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(wself.view.mas_bottom).offset(-inset*3 - heightBtn*2);
        }];
        
    } else if (self.dataSource.businessState == VMDataSourceMyBusiCodeChecked) {
        self.uploadBtn.hidden = YES;
        self.reaplyBtn.hidden = YES;
    }
    else {
        self.reaplyBtn.hidden = YES;
        [self.uploadBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(wself.view.mas_bottom).offset(-(inset + heightBtn));
        }];
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(wself.view.mas_bottom).offset(-inset*2 - heightBtn);
        }];
    }
}

# pragma mask 4 getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self.dataSource;
        _tableView.delegate = self;
        _tableView.sectionFooterHeight = 20;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor colorWithHex:0xefeff4 alpha:1];
    }
    return _tableView;
}

- (VMDataSourceMyBusiness *)dataSource {
    if (!_dataSource) {
        _dataSource = [[VMDataSourceMyBusiness alloc] init];
    }
    return _dataSource;
}

- (UIButton *)uploadBtn {
    if (!_uploadBtn) {
        _uploadBtn = [UIButton new];
        _uploadBtn.backgroundColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        [_uploadBtn setTitle:@"申请资料上传" forState:UIControlStateNormal];
        [_uploadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_uploadBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.4] forState:UIControlStateHighlighted];
        [_uploadBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.4] forState:UIControlStateDisabled];
        [_uploadBtn addTarget:self action:@selector(toUploadBusinessInfo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _uploadBtn;
}
- (UIButton *)reaplyBtn {
    if (!_reaplyBtn) {
        _reaplyBtn = [UIButton new];
        _reaplyBtn.backgroundColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        [_reaplyBtn setTitle:@"重新申请" forState:UIControlStateNormal];
        [_reaplyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_reaplyBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.4] forState:UIControlStateHighlighted];
        [_reaplyBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.4] forState:UIControlStateDisabled];
        [_reaplyBtn addTarget:self action:@selector(toReaplyBusinessInfo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reaplyBtn;
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


- (UIBarButtonItem*) newCancelBarBtn {
    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [cancelBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAHome] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:25 scale:1]];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(clickedHomeBarBtn:) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
}

@end
