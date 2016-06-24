//
//  WatingPayViewController.m
//  JLPay
//
//  Created by jielian on 16/4/27.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "WatingPayViewController.h"

@implementation WatingPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;

    if (self.payType == OtherPayTypeAlipay) {
        self.title = @"支付宝收款";
    } else {
        self.title = @"微信收款";
    }

    [self addSubviews];
    [self layoutSubviews];
    [self viewOnVMDatas];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = YES;

    NameWeakSelf(wself);
    // 分支: alipay | wecaht
    if (self.payType == OtherPayTypeAlipay) {
        [self.progressHud showNormalWithText:self.httpAlipay.stateMessage andDetailText:nil];
        [self.httpAlipay startPayingOnFinished:^{
            [wself.progressHud showSuccessWithText:wself.httpAlipay.stateMessage andDetailText:nil onCompletion:nil];
            [wself.tableView reloadData];
            wself.revokeButton.hidden = NO;
        } onError:^(NSError *error) {
            JLPrint(@"---支付失败[%@]",[error localizedDescription]);
            [wself.progressHud showFailWithText:wself.httpAlipay.stateMessage andDetailText:[error localizedDescription] onCompletion:nil];
            [wself.tableView reloadData];
        }];
    } else {
        [self.progressHud showNormalWithText:self.httpWechat.stateMessage andDetailText:nil];
        self.httpWechat.state = VMHttpWechatPayStatePaying;
    }
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    self.httpWechat.state = VMHttpWechatPayStateTerminate;
}


- (void) addSubviews {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.doneButton];
    [self.view addSubview:self.revokeButton];
    [self.view addSubview:self.progressHud];
}
- (void) layoutSubviews {
    CGFloat heightButton = 50;
    CGFloat inset = 15;
    
    NameWeakSelf(wself);
    [self.revokeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(wself.view.mas_bottom);
        make.left.equalTo(wself.view.mas_left).offset(inset);
        make.right.equalTo(wself.view.mas_right).offset(-inset);
        make.height.mas_equalTo(heightButton);
    }];
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(wself.revokeButton.mas_top);
        make.left.equalTo(wself.revokeButton.mas_left);
        make.right.equalTo(wself.revokeButton.mas_right);
        make.height.equalTo(wself.revokeButton.mas_height);
        wself.doneButton.layer.cornerRadius = heightButton * 0.5;
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.view.mas_top).offset(64);
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.bottom.equalTo(wself.doneButton.mas_top);
    }];
}


# pragma mask 1 IBAction
// -- done button: pop to root VC
- (IBAction) paidDoneToPopVC:(UIButton*)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
// -- revoke button: revoke
- (IBAction) revokePay:(UIButton*)sender {
    
    
//    NameWeakSelf(wself);
//    [self.progressHud showNormalWithText:@"正在撤销交易..." andDetailText:nil];
//    if (self.payType == OtherPayTypeAlipay) {
//        [self.httpAlipay startRevokeOnFinished:^{
//            [wself.tableView reloadData];
//            [wself.progressHud showSuccessWithText:wself.httpAlipay.stateMessage andDetailText:nil onCompletion:nil];
//        } onError:^(NSError *error) {
//            [wself.tableView reloadData];
//            [wself.progressHud showFailWithText:wself.httpAlipay.stateMessage andDetailText:[error localizedDescription] onCompletion:nil];
//        }];
//    } else {
//        [self.httpWechat startRevokeOnFinished:^{
//            [wself.tableView reloadData];
//            [wself.progressHud showSuccessWithText:wself.httpWechat.stateMessage andDetailText:nil onCompletion:nil];
//        } onError:^(NSError *error) {
//            [wself.tableView reloadData];
//            [wself.progressHud showFailWithText:wself.httpWechat.stateMessage andDetailText:[error localizedDescription] onCompletion:nil];
//        }];
//    }
    
}

# pragma mask 1 KVO
- (void) viewOnVMDatas {
    @weakify(self);
    /* state image */
    RACSignal* sigHttpState = [RACObserve(self.httpAlipay, state) merge:RACObserve(self.httpWechat, state)];
    
    /* state message */
    RAC(self.payStatusHeaderView.labelStatus, text) = [[RACObserve(self.httpAlipay, stateMessage) merge:RACObserve(self.httpWechat, stateMessage)] deliverOnMainThread];
    
    /* pay money */
    RAC(self.payStatusHeaderView.labelMoney, text) = [[[RACObserve(self.httpAlipay, payAmount) merge:RACObserve(self.httpWechat, payAmount)] map:^NSString* (NSString* money) {
        return [NSString stringWithFormat:@"￥ %.02lf",money.floatValue];
    }] deliverOnMainThread];
    
    /* goods name */
    RAC(self.payStatusHeaderView.labelGoodsName, text) = [[[RACObserve(self.httpAlipay, goodsName) merge:RACObserve(self.httpWechat, goodsName)] map:^NSString* (NSString* goodsName) {
        return [NSString stringWithFormat:@"[%@]",goodsName];
    }] deliverOnMainThread];
    
    
    /* done button background color */
    RAC(self.doneButton, backgroundColor) = [[sigHttpState map:^UIColor* (NSNumber* state) {
        if (state.integerValue == VMHttpWechatPayStatePayFail) {
            return [PublicInformation returnCommonAppColor:@"red"];
        } else {
            return [PublicInformation returnCommonAppColor:@"green"];
        }
    }] deliverOnMainThread];
    
    /* image for status */
    RAC(self.payStatusHeaderView.imageView, image) = [[sigHttpState map:^ UIImage* (NSNumber* state) {
        if (state.integerValue == VMHttpWechatPayStatePaySuc) {
            return [UIImage imageNamed:@"checkRight_green"];
        }
        else if (state.integerValue == VMHttpWechatPayStatePayFail) {
            return [UIImage imageNamed:@"checkWrong_red"];
        }
        else {
            return [UIImage imageNamed:@"hourGlass"];
        }
    }] deliverOnMainThread];
    
    /* text color for status label */
    RAC(self.payStatusHeaderView.labelStatus, textColor) = [[sigHttpState map:^UIColor* (NSNumber* state) {
        if (state.integerValue == VMHttpWechatPayStatePayFail) {
            return [PublicInformation returnCommonAppColor:@"red"];
        }
        else {
            return [PublicInformation returnCommonAppColor:@"green"];
        }
    }] deliverOnMainThread];

    /* HUD showed for status */
    [RACObserve(self.httpWechat, state) subscribeNext:^(NSNumber* state) {
        @strongify(self);
        if (state.integerValue == VMHttpWechatPayStatePaySuc) {
            if (self.httpWechat.payType == VMHttpWechatPayTypePay) {
                [self.progressHud showSuccessWithText:@"微信收款成功" andDetailText:nil onCompletion:nil];
                [self.tableView reloadData];
            } else {
                [self.progressHud showSuccessWithText:@"撤销成功" andDetailText:nil onCompletion:nil];
                [self.tableView reloadData];
            }
        }
        else if (state.integerValue == VMHttpWechatPayStatePayFail) {
            if (self.httpWechat.payType == VMHttpWechatPayTypePay) {
                JLPrint(@"---支付失败[%@]",[self.httpWechat.payError localizedDescription]);
                [self.progressHud showFailWithText:@"微信收款失败" andDetailText:[self.httpWechat.payError localizedDescription] onCompletion:nil];
            } else {
                [self.progressHud showFailWithText:@"撤销失败" andDetailText:[self.httpWechat.payError localizedDescription] onCompletion:nil];
            }
        }
    }];
}

# pragma mask 2 UITableViewDelegate
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    self.payStatusHeaderView.frame = [tableView rectForHeaderInSection:section];
    return self.payStatusHeaderView;
}



# pragma mask 4 getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.sectionHeaderHeight = (self.view.frame.size.height - 64 - 50 * 2/*两个按钮*/) * 0.5;
        _tableView.rowHeight = 30;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (self.payType == OtherPayTypeAlipay) {
            _tableView.dataSource = self.httpAlipay;
        } else {
            _tableView.dataSource = self.httpWechat;
        }
    }
    return _tableView;
}
- (PayStatusDisplayView *)payStatusHeaderView {
    if (!_payStatusHeaderView) {
        _payStatusHeaderView = [[PayStatusDisplayView alloc] initWithFrame:CGRectZero];
    }
    return _payStatusHeaderView;
}
- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor colorWithWhite:0.6 alpha:0.5] forState:UIControlStateHighlighted];
        [_doneButton setTitleColor:[UIColor colorWithWhite:0.6 alpha:0.5] forState:UIControlStateDisabled];
        [_doneButton addTarget:self action:@selector(paidDoneToPopVC:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}
- (UIButton *)revokeButton {
    if (!_revokeButton) {
        _revokeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_revokeButton setTitle:@"撤销" forState:UIControlStateNormal];
        [_revokeButton setTitleColor:[PublicInformation returnCommonAppColor:@"blueBlack"] forState:UIControlStateNormal];
        [_revokeButton setTitleColor:[UIColor colorWithWhite:0.6 alpha:0.5] forState:UIControlStateHighlighted];
        [_revokeButton setTitleColor:[UIColor colorWithWhite:0.6 alpha:0.5] forState:UIControlStateDisabled];
        _revokeButton.hidden = YES;
        [_revokeButton addTarget:self action:@selector(revokePay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _revokeButton;
}
- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _progressHud;
}

- (VMHttpAlipay *)httpAlipay {
    if (!_httpAlipay) {
        _httpAlipay = [[VMHttpAlipay alloc] init];
    }
    return _httpAlipay;
}
- (VMHttpWechatPay *)httpWechat {
    if (!_httpWechat) {
        _httpWechat = [[VMHttpWechatPay alloc] init];
    }
    return _httpWechat;
}
- (OtherPayType)payType {
    return [[VMOtherPayType sharedInstance] curPayType];
}

@end
