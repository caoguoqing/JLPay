//
//  LeftMenuViewController.m
//  CustomViewMaker
//
//  Created by jielian on 16/10/9.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "UIColor+HexColor.h"
#import "Define_Header.h"


@interface LeftMenuViewController ()

@property (nonatomic, strong) CAGradientLayer* gradientColorLayer;

@property (nonatomic, strong) LMVC_userHeadView* userHeadView;

@property (nonatomic, strong) UITableView* menuTableView;

@property (nonatomic, strong) LMVC_logoutButton* logoutBtn;

@property (nonatomic, strong) LMVC_modelMenuData* modelMenuData;


@end

@implementation LeftMenuViewController



# pragma mask 2 重载数据
- (void) reloadDatas {
    [self.modelMenuData reloadData];
    
    self.userHeadView.busiNameLabel.text = self.modelMenuData.userName;
    self.userHeadView.busiNumLabel.text = self.modelMenuData.businessCode;
    self.logoutBtn.logined = self.modelMenuData.logined;
    
    // 商户审核状态
    if (self.modelMenuData.checkedState != MCacheSignUpCheckStateChecked) {
        self.userHeadView.busiCheckedStateLabel.hidden = NO;
        if (self.modelMenuData.checkedState == MCacheSignUpCheckStateChecking) {
            self.userHeadView.busiCheckedStateLabel.text = @"正在审核";
            self.userHeadView.busiCheckedStateLabel.backgroundColor = [UIColor colorWithHex:0xffd300 alpha:1];
        }
        else if (self.modelMenuData.checkedState == MCacheSignUpCheckStateCheckRefused) {
            self.userHeadView.busiCheckedStateLabel.text = @"审核不通过";
            self.userHeadView.busiCheckedStateLabel.backgroundColor = [UIColor colorWithHex:0xef454b alpha:1];
        }
    } else {
        self.userHeadView.busiCheckedStateLabel.hidden = YES;
    }
    
    // 刷新菜单
    [self.menuTableView reloadData];
}

# pragma mask 2 IBAction
/* 点击了用户按钮 */
- (IBAction) clickedUserHeadBtn:(id)sender {
    if (!self.modelMenuData.logined) {
        [self.modelMenuData gotoRelogin];
    } else {
        [self.modelMenuData gotoMyBusiness];
    }
}

/* 点击了登录登出按钮 */
- (IBAction) clickedLoginBtn:(id)sender {
    if (self.modelMenuData.logined) {
        NameWeakSelf(wself);
        [UIAlertController showAlertWithTitle:@"是否确认要重新登录?" message:nil target:self clickedHandle:^(UIAlertAction *action) {
            if ([action.title isEqualToString:@"重新登录"]) {
                [wself.modelMenuData gotoRelogin];
            }
        } buttons:@{@(UIAlertActionStyleDefault):@"取消"},@{@(UIAlertActionStyleCancel):@"重新登录"}, nil];
    } else {
        [self.modelMenuData gotoRelogin];
    }
}


# pragma mask 3 布局

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self loadSubviews];
    [self initialFrame];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadDatas];
}

- (void) loadSubviews {
    [self.view.layer addSublayer:self.gradientColorLayer];
    [self.view addSubview:self.userHeadView];
    [self.view addSubview:self.menuTableView];
    [self.view addSubview:self.logoutBtn];
}

- (void) initialFrame {
    
    CGFloat leftInset = self.view.frame.size.width * 15/320.f;
    
    CGFloat avilableWidth = self.view.frame.size.width * (1 - 0.7 * 0.5) + 30 * 0.8 - leftInset;
    
    CGFloat heightUserHeadView = self.view.frame.size.height * 0.35 * 0.3;
    
    CGFloat heightTBV = self.view.frame.size.height * (1 - (1 - 0.7) * 1.5 );
    
    CGFloat heightLogouBtn = self.view.frame.size.height * 44 / 568.f;
    
    CGFloat widthLogoutBtn = self.view.frame.size.width * 110 / 320.f;
    
    CGRect frame = CGRectMake(leftInset,
                              self.view.frame.size.height * 0.15 - heightUserHeadView * 0.5,
                              avilableWidth,
                              heightUserHeadView);
    self.userHeadView.frame = frame;
    
    frame.origin.y = self.view.frame.size.height * 0.3;
    frame.size.height = heightTBV;
    self.menuTableView.frame = frame;
    
    frame.origin.y = self.view.frame.size.height - leftInset - heightLogouBtn;
    frame.size.width = widthLogoutBtn;
    frame.size.height = heightLogouBtn;
    self.logoutBtn.frame = frame;
    
}


# pragma mask 4 getter

- (CAGradientLayer *)gradientColorLayer {
    if (!_gradientColorLayer) {
        _gradientColorLayer = [CAGradientLayer layer];
        _gradientColorLayer.colors = @[(__bridge id)[UIColor colorWithHex:0x99cccc alpha:1].CGColor,
                                       (__bridge id)[UIColor colorWithHex:0x27384b alpha:1].CGColor];
        _gradientColorLayer.locations = @[@0, @0.35];
        _gradientColorLayer.startPoint = CGPointMake(0.5, 0);
        _gradientColorLayer.endPoint = CGPointMake(0.5, 1);
        _gradientColorLayer.frame = self.view.bounds;
    }
    return _gradientColorLayer;
}

- (LMVC_userHeadView *)userHeadView {
    if (!_userHeadView) {
        _userHeadView = [[LMVC_userHeadView alloc] init];
        [_userHeadView addTarget:self action:@selector(clickedUserHeadBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _userHeadView;
}

- (LMVC_logoutButton *)logoutBtn {
    if (!_logoutBtn) {
        _logoutBtn = [[LMVC_logoutButton alloc] init];
        [_logoutBtn addTarget:self action:@selector(clickedLoginBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _logoutBtn;
}

- (UITableView *)menuTableView {
    if (!_menuTableView) {
        _menuTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _menuTableView.backgroundColor = [UIColor clearColor];
        _menuTableView.tableFooterView = [UIView new];
        _menuTableView.dataSource = self.modelMenuData;
        _menuTableView.delegate = self.modelMenuData;
        _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _menuTableView;
}

- (LMVC_modelMenuData *)modelMenuData {
    if (!_modelMenuData) {
        _modelMenuData = [[LMVC_modelMenuData alloc] init];
    }
    return _modelMenuData;
}

@end
