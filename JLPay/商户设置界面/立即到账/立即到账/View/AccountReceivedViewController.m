//
//  AccountReceivedViewController.m
//  JLPay
//
//  Created by jielian on 16/5/20.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "AccountReceivedViewController.h"

@implementation AccountReceivedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"立即到账";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    [self loadSubviews];
    [self layoutSubviews];
    [self addKVOs];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.timeCircle fire];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.timeCircle) {
        if ([self.timeCircle isValid]) {
            [self.timeCircle invalidate];
        }
        self.timeCircle = nil;
    }
}

- (void) loadSubviews {
    [self.view addSubview:self.buttonDispatchOrder];
    [self.view addSubview:self.labelNowTime];
    [self.view addSubview:self.labelNoteDispatchOrder];
    
    [self.view addSubview:self.settledListTBV];
    
    [self.view addSubview:self.backView];
    [self.view addSubview:self.labelAccountReceived];
    [self.view addSubview:self.labelTitleMoney];
    
    [self.view addSubview:self.downPullBtn];

    [self.view addSubview:self.progressHud];
    [self.navigationItem setLeftBarButtonItem:self.cancelBarBtn];
}
- (void) layoutSubviews {
    NameWeakSelf(wself);
    
    CGFloat heightBig = self.view.frame.size.height * 1/14.f;
    CGFloat heightLit = heightBig * 0.5;
    CGFloat widthBtn = self.view.frame.size.width * 0.9;
    CGFloat heightBackView = self.view.frame.size.height * 0.33;
    
    CGFloat heightTBV = self.view.frame.size.height - 64 - heightBackView;
    
    self.labelNowTime.font = [UIFont systemFontOfSize:[@"tet" resizeFontAtHeight:heightLit scale:0.618]];
    self.labelTitleMoney.font = [UIFont systemFontOfSize:[@"tet" resizeFontAtHeight:heightLit scale:0.68]];
    self.labelAccountReceived.font = [UIFont boldSystemFontOfSize:[@"tet" resizeFontAtHeight:heightBig scale:1.2]];
    self.labelNoteDispatchOrder.font = [UIFont systemFontOfSize:[@"tet" resizeFontAtHeight:heightLit scale:0.85]];

    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.top.equalTo(wself.view.mas_top).offset(64);
        make.height.mas_equalTo(heightBackView);
    }];
    [self.labelAccountReceived mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.centerY.equalTo(wself.backView.mas_centerY);
        make.height.mas_equalTo(heightBig);
    }];
    [self.labelTitleMoney mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.top.equalTo(wself.backView.mas_top).offset(5);
        make.height.mas_equalTo(heightLit);
    }];
    
    [self.downPullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.backView.mas_centerX);
        make.bottom.equalTo(wself.backView.mas_bottom).offset(-10);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.settledListTBV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.bottom.equalTo(wself.backView.mas_bottom);
        make.height.mas_equalTo(heightTBV);
    }];
    
    [self.labelNowTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.top.equalTo(wself.backView.mas_bottom).offset(0);
        make.height.mas_equalTo(heightLit);
    }];
    
    [self.labelNoteDispatchOrder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.top.equalTo(wself.labelNowTime.mas_bottom).offset(45);
        make.height.mas_equalTo(heightLit);
    }];
    [self.buttonDispatchOrder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.view.mas_centerX);
        make.width.mas_equalTo(widthBtn);
        make.top.equalTo(wself.labelNoteDispatchOrder.mas_bottom).offset(5);
        make.height.mas_equalTo(heightBig);
    }];
}


# pragma mask 1 KVOs
- (void) addKVOs {
    @weakify(self);
    RAC(self.labelNowTime, text) = [[RACObserve(self, curDisplayedTime) deliverOnMainThread] map:^NSString* (NSString* curTime) {
        return [NSString stringWithFormat:@"更新于 %@/%@/%@ %@:%@",
                [curTime substringToIndex:4],
                [curTime substringWithRange:NSMakeRange(4, 2)],
                [curTime substringWithRange:NSMakeRange(6, 2)],
                [curTime substringWithRange:NSMakeRange(8, 2)],
                [curTime substringWithRange:NSMakeRange(10, 2)]
                ];
    }];
    
    RAC(self.labelAccountReceived, text) = [[RACObserve(self.vmAccountReceived, accountReceived) deliverOnMainThread]
                                            map:^NSString* (NSNumber* account) {
                                                // 需要动态显示金额...浮动增加
                                                return [NSString stringWithFormat:@"￥%.02lf",account.floatValue];
    }];
    
    [RACObserve(self.labelNowTime, text) subscribeNext:^(id x) {
        @strongify(self);
        self.vmAccountReceived.requestPropDateBegin = [self.curDisplayedTime substringToIndex:8];
        self.vmAccountReceived.requestPropDateEnd = [self.curDisplayedTime substringToIndex:8];
        self.vmAccountReceived.state = VMAccountReceivedStateRequesting;
    }];
    
    [RACObserve(self.vmAccountReceived, state) subscribeNext:^(NSNumber* state) {
        @strongify(self);
        switch (state.integerValue) {
            case VMAccountReceivedStateRequesting:
            {
                [self.progressHud showNormalWithText:@"" andDetailText:nil];
            }
                break;
            case VMAccountReceivedStateRequestSuc:
            {
                [self.settledListTBV reloadData];
                [self.progressHud showSuccessWithText:@"" andDetailText:nil onCompletion:nil];
            }
                break;
            case VMAccountReceivedStateRequestFail:
            {
                [self.settledListTBV reloadData];
                [self.progressHud showFailWithText:[self.vmAccountReceived.errorRequested localizedDescription] andDetailText:nil onCompletion:nil];
            }
                break;

            default:
                break;
        }
    }];
    
    [[RACObserve(self.downPullBtn, down) deliverOnMainThread] subscribeNext:^(NSNumber* down) {
        if (!down.boolValue) {
            [UIView animateWithDuration:0.2 animations:^{
                @strongify(self);
                self.settledListTBV.transform = CGAffineTransformMakeTranslation(0, self.settledListTBV.frame.size.height);
            }];
        } else {
            @strongify(self);
            [UIView animateWithDuration:0.2 animations:^{
                @strongify(self);
                self.settledListTBV.transform = CGAffineTransformMakeTranslation(0, 0);
            }];
        }
    }];
    
    RAC(self.downPullBtn, hidden) = [[RACObserve(self.vmAccountReceived, accountReceived) map:^id(NSNumber* money) {
        if (money.floatValue < 0.01) {
            return @(YES);
        } else {
            return @(NO);
        }
    }] deliverOnMainThread];
}

# pragma mask 1 UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

# pragma mask 2 action 

- (void) runTimerOnTimeLabel {
    NSString* nowTime = [self formationTimeStringOnDate:[NSDate date]];
    nowTime = [nowTime substringToIndex:nowTime.length - 2];
    if (![nowTime isEqualToString:self.curDisplayedTime]) {
        self.curDisplayedTime = nowTime;
    }
}

- (NSString*) formationTimeStringOnDate:(NSDate*)date {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMddhhmmss";
    return [dateFormatter stringFromDate:date];
}

- (IBAction) toPushToDispatchListVC:(UIButton*)sender {
    OrderDispatchListViewController* orderDispListVC = [[OrderDispatchListViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:orderDispListVC animated:YES];
}

- (IBAction) toDisplaySettledDetailList:(DownPullButton*)sender {
    sender.down = !sender.down;
}

- (IBAction) clickedCancelBtn:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

# pragma mask 4 getter

- (UIView *)backView {
    if (!_backView) {
        _backView = [UIView new];
        _backView.backgroundColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
    }
    return _backView;
}
- (NSString *)curDisplayedTime {
    if (!_curDisplayedTime) {
        _curDisplayedTime = [[self formationTimeStringOnDate:[NSDate date]] substringToIndex:8+4];
    }
    return _curDisplayedTime;
}
- (UILabel *)labelNowTime {
    if (!_labelNowTime) {
        _labelNowTime = [UILabel new];
        _labelNowTime.textAlignment = NSTextAlignmentCenter;
        _labelNowTime.textColor = [UIColor colorWithHex:HexColorTypeBlackGray alpha:0.7];
    }
    return _labelNowTime;
}
- (UILabel *)labelTitleMoney {
    if (!_labelTitleMoney) {
        _labelTitleMoney = [UILabel new];
        _labelTitleMoney.textAlignment = NSTextAlignmentCenter;
        _labelTitleMoney.textColor = [UIColor whiteColor];
        _labelTitleMoney.text = @"已到账金额(仅当日交易并已结算的总金额)";
    }
    return _labelTitleMoney;
}
- (UILabel *)labelAccountReceived {
    if (!_labelAccountReceived) {
        _labelAccountReceived = [UILabel new];
        _labelAccountReceived.textAlignment = NSTextAlignmentCenter;
        _labelAccountReceived.textColor = [UIColor whiteColor];
    }
    return _labelAccountReceived;
}
- (UILabel *)labelNoteDispatchOrder {
    if (!_labelNoteDispatchOrder) {
        _labelNoteDispatchOrder = [UILabel new];
        _labelNoteDispatchOrder.textAlignment = NSTextAlignmentCenter;
        _labelNoteDispatchOrder.textColor = [UIColor colorWithHex:HexColorTypeLightBlue alpha:1];
        _labelNoteDispatchOrder.text = @"温馨提示";
    }
    return _labelNoteDispatchOrder;
}
- (UIButton *)buttonDispatchOrder {
    if (!_buttonDispatchOrder) {
        _buttonDispatchOrder = [UIButton new];
        [_buttonDispatchOrder setBackgroundColor:[UIColor colorWithHex:HexColorTypeBlackBlue alpha:1]];
        [_buttonDispatchOrder setTitle:@"调单资料上传" forState:UIControlStateNormal];
        [_buttonDispatchOrder setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_buttonDispatchOrder setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateHighlighted];
        [_buttonDispatchOrder addTarget:self action:@selector(toPushToDispatchListVC:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonDispatchOrder;
}

- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _progressHud;
}

- (VMAccountReceived *)vmAccountReceived {
    if (!_vmAccountReceived) {
        _vmAccountReceived = [[VMAccountReceived alloc] init];
    }
    return _vmAccountReceived;
}
- (NSTimer *)timeCircle {
    if (!_timeCircle) {
        _timeCircle = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(runTimerOnTimeLabel) userInfo:nil repeats:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[NSRunLoop currentRunLoop] addTimer:_timeCircle forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
    }
    return _timeCircle;
}
- (DownPullButton *)downPullBtn {
    if (!_downPullBtn) {
        _downPullBtn = [[DownPullButton alloc] init];
        [_downPullBtn addTarget:self action:@selector(toDisplaySettledDetailList:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downPullBtn;
}
- (UITableView *)settledListTBV {
    if (!_settledListTBV) {
        _settledListTBV = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _settledListTBV.backgroundColor = [UIColor whiteColor];
        _settledListTBV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _settledListTBV.rowHeight = 50;
        _settledListTBV.dataSource = self.vmAccountReceived;
        _settledListTBV.delegate = self;
    }
    return _settledListTBV;
}

- (UIBarButtonItem *)cancelBarBtn {
    if (!_cancelBarBtn) {
        UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [cancelBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAHome] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:25 scale:1]];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(clickedCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBarBtn = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    }
    return _cancelBarBtn;
}

@end
