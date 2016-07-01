//
//  DeviceBindingViewController.m
//  JLPay
//
//  Created by jielian on 16/4/12.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DeviceBindingViewController.h"



@implementation DeviceBindingViewController

# pragma mask 0 界面周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绑定设备";
    [self.navigationItem setRightBarButtonItem:self.doneBarBtn];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self addSubviews];
    [self relayoutSubviews];
    [self viewOnKVOs];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.deviceVModel.connected) {
        [self alertForDeviceScanning];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.deviceVModel stopScanning];
    self.tabBarController.tabBar.hidden = NO;
}
- (void)dealloc {
    [self.deviceVModel stopScanning];
    [self.deviceVModel disconnectDeviceOnFinished:nil];
}

// -- add sub views
- (void) addSubviews {
    [self.view addSubview:self.alertView];
    [self.view addSubview:self.rescanBtn];
    [self.view addSubview:self.bindingButton];
    [self.view addSubview:self.terminalLabel];
    [self.view addSubview:self.terminalLabelPre];
    [self.view addSubview:self.pullButton];
    [self.view addSubview:self.stateLabel];
    [self.view addSubview:self.deviceNameLabel];
    [self.view addSubview:self.backView];
    [self.view addSubview:self.posImageView];
    [self.view addSubview:self.pullListSegView];
    [self.view addSubview:self.progressHud];
}
// -- layout sub views
- (void) relayoutSubviews {
    CGRect screenFrame = self.view.frame;
    CGFloat inset = 15.f;
    
    CGFloat rateBtnHeight = 1/13.f;
    CGFloat heightLabel = 30;
    CGFloat avilableHeight = screenFrame.size.height - 64 - screenFrame.size.height * rateBtnHeight *2 - heightLabel *3 - inset *7;
    CGFloat widthBackView = 0;
    CGFloat maxWidthBackView = screenFrame.size.width * 0.75;
    
    if (avilableHeight > maxWidthBackView) {
        widthBackView = maxWidthBackView;
    } else {
        widthBackView = avilableHeight;
    }
    
    NameWeakSelf(wself);
    
    self.bindingButton.titleLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:heightLabel scale:0.618]];
    self.bindingButton.layer.cornerRadius = self.view.frame.size.height * rateBtnHeight * 0.5;
    self.terminalLabel.font = [UIFont systemFontOfSize:[self.terminalLabel.text resizeFontAtHeight:heightLabel scale:0.85]];
    self.terminalLabelPre.font = [UIFont systemFontOfSize:[self.terminalLabelPre.text resizeFontAtHeight:heightLabel scale:0.6]];
    self.deviceNameLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:heightLabel scale:0.6]];
    self.stateLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:heightLabel scale:0.618]];
    self.backView.layer.cornerRadius = widthBackView * 0.5;
    self.rescanBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:self.view.frame.size.height * rateBtnHeight scale:0.5]];
    
    
    [self.terminalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([wself.terminalLabel.text resizeAtHeight:heightLabel scale:1].width);
        make.height.mas_equalTo(heightLabel);
        make.top.equalTo(wself.view.mas_top).offset(64 + inset);
        make.centerX.equalTo(wself.view.mas_centerX);
    }];
    
    [self.terminalLabelPre mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(wself.terminalLabel.mas_height);
        make.right.equalTo(wself.terminalLabel.mas_left);
        make.left.equalTo(wself.view.mas_left);
        make.centerY.equalTo(wself.terminalLabel.mas_centerY);
    }];
    
    [self.pullButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.terminalLabel.mas_right).offset(5);
        make.top.equalTo(wself.terminalLabel.mas_top);
        make.bottom.equalTo(wself.terminalLabel.mas_bottom);
        make.width.equalTo(wself.pullButton.mas_height);
    }];
    
    [self.pullListSegView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(wself.backView.mas_width);
        make.height.equalTo(wself.backView.mas_height);
        make.centerX.equalTo(wself.terminalLabel.mas_centerX);
        make.top.equalTo(wself.terminalLabel.mas_bottom).offset(0);
    }];

    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(widthBackView);
        make.height.mas_equalTo(widthBackView);
        make.centerX.equalTo(wself.view.mas_centerX);
        make.top.equalTo(wself.terminalLabel.mas_bottom).offset(inset);
    }];
    
    [self.posImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.backView.mas_centerX);
        make.centerY.equalTo(wself.backView.mas_centerY);
        make.width.equalTo(wself.backView.mas_width).multipliedBy(0.46);
        CGSize imageSize = wself.posImageView.image.size;
        make.height.equalTo(wself.backView.mas_height).multipliedBy(imageSize.height/imageSize.width * 0.46);
    }];
    
    [self.deviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.view.mas_centerX);
        make.width.mas_equalTo([wself.deviceNameLabel.text resizeAtHeight:heightLabel scale:1].width);
        make.height.mas_equalTo(heightLabel);
        make.top.equalTo(wself.backView.mas_bottom).offset(5);
    }];
    
    [self.rescanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.deviceNameLabel.mas_right).offset(0);
        make.centerY.equalTo(wself.deviceNameLabel.mas_centerY);
        make.height.equalTo(wself.deviceNameLabel.mas_height);
        make.width.equalTo(wself.rescanBtn.mas_height);
    }];
    
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left).offset(inset);
        make.right.equalTo(wself.view.mas_right).offset(-inset);
        make.height.equalTo(wself.view.mas_height).multipliedBy(rateBtnHeight);
        make.top.equalTo(wself.deviceNameLabel.mas_bottom).offset(inset * 1.5);
    }];
    
    
    [self.bindingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.stateLabel.mas_bottom).offset(inset);
        make.height.equalTo(wself.view.mas_height).multipliedBy(rateBtnHeight);
        make.left.equalTo(wself.view.mas_left).offset(inset);
        make.right.equalTo(wself.view.mas_right).offset(-inset);
    }];

}

# pragma mask 1 KVO

- (void) viewOnKVOs {
    @weakify(self);
    /* '完成'按钮.enabled */
    RAC(self.doneBarBtn, enabled) = [RACObserve(self.deviceVModel, stateMessage) map:^id(NSString* state) {
        return ([state isEqualToString:@"设备绑定成功!!"])?(@(YES)):(@(NO));
    }];
    
    /* 状态标签的文本 */
    RACSignal* deviceStateMsgSignal = RACObserve(self.deviceVModel, stateMessage);
    RACSignal* tcpStateMsgSignal = [RACObserve(self.tcpVModel, stateMessage) skip:1];
    RAC(self.stateLabel, text) = [[RACSignal merge:@[deviceStateMsgSignal, tcpStateMsgSignal]] deliverOnMainThread];
    
    /* 设备SN号文本 */
    RAC(self.deviceNameLabel, text) = [[RACObserve(self.deviceVModel, selectedPeripheral) map:^NSString*(CBPeripheral* peripheral) {
        return peripheral.name;
    }] deliverOnMainThread];
    
    /* 终端号标签文本 */
    RAC(self.terminalLabel, text) = [RACObserve(self.terminalSelector, selectedTerminal) deliverOnMainThread];
    
    /* TCP VM的终端号 */
    RAC(self.tcpVModel, terminalNumber) = RACObserve(self.terminalSelector, selectedTerminal);
    
    
    /* '绑定'按钮的 enabled */
    RACSignal* deviceConnectedSignal = RACObserve(self.deviceVModel, enableWriteKey);
    RACSignal* terminalNumberNotNullSignal = [RACObserve(self.terminalLabel, text) map:^id(NSString* terminal) {
        return @(terminal && terminal.length > 0);
    }];
    RAC(self.bindingButton, enabled) = [[RACSignal combineLatest:@[deviceConnectedSignal,terminalNumberNotNullSignal]
                                                         reduce:^id(NSNumber* connected, NSNumber* terminal){
                                                             return @(connected.boolValue && terminal.boolValue);
    }] deliverOn:[RACScheduler mainThreadScheduler]];
    
    /* 更新设备SN+刷新的布局: 当SN文本变动时 */
    [[RACObserve(self.deviceNameLabel, text) deliverOnMainThread] subscribeNext:^(NSString* text) {
        @strongify(self);
        
        [self.deviceNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            @strongify(self);
            make.width.mas_equalTo([self.deviceNameLabel.text resizeAtHeight:self.deviceNameLabel.frame.size.height scale:0.85].width);
        }];
        [self.rescanBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            @strongify(self);
            make.centerX.equalTo(self.deviceNameLabel.mas_right);
        }];
    }];
    
    /* 下拉显示按钮 hidden */
    RACSignal* sigTerminalsOnlyOne = [RACObserve(self.terminalSelector, terminals) map:^id(NSArray* terminals) {
        return @(terminals && terminals.count == 1);
    }];
    RACSignal* sigSigninDone = [RACObserve(self.deviceVModel, stateMessage) map:^id(NSString* state) {
        return @([state isEqualToString:@"设备绑定成功!!"]);
    }];
    RAC(self.pullButton,hidden) = [[RACSignal combineLatest:@[sigTerminalsOnlyOne, sigSigninDone]
                                                     reduce:^id(NSNumber* onlyOne, NSNumber* done ){
                                                         return @(onlyOne.boolValue || done.boolValue);
    }] deliverOnMainThread];

    /* 隐藏终端号列表: 当选择了终端号 */
    [[[[RACObserve(self.terminalSelector, selectedTerminal) skip:1] deliverOnMainThread] delay:0.1] subscribeNext:^(CBPeripheral* peripheral) {
        @strongify(self);
        [self.pullListSegView hideWithCompletion:^{
            @strongify(self);
            [self pullButtonTurnUp];
        }];
    }];
    
    /* 连接设备: 当选择了设备后 */
    [[[[RACObserve(self.deviceVModel, selectedPeripheral) filter:^BOOL(CBPeripheral* peripheral) {
        return (peripheral)?(YES):(NO);
    }] deliverOnMainThread] delay:0.3] subscribeNext:^(CBPeripheral* peripheral) {
        @strongify(self);
        [self.progressHud showNormalWithText:nil andDetailText:nil];
        [self.alertView dismissWithCompletion:^{
            @strongify(self);
             [self.deviceVModel conntectDeviceOnConnected:^(NSString *SNVersion) {
                 // 更新状态
                @strongify(self);
                [self.progressHud hideOnCompletion:nil];
             } onError:^(NSError *error) {
                 // 更新状态
                 dispatch_sync(dispatch_get_main_queue(), ^{
                     @strongify(self);
                     [self.progressHud hide:YES];
                 });
             }];
         }];
    }];
    
}


# pragma mask 2 action

// -- 开启设备扫描
- (void) alertForDeviceScanning {
    AppDelegate* appDelegate = APPMainDelegate;
    if (appDelegate.CBManager.state == CBCentralManagerStatePoweredOn) {
        NameWeakSelf(wself);
        [self.alertView show];
        [self.deviceListTable reloadData]; // 防止上一次遗留数据未刷新
        self.deviceListTable.hidden = NO;
        [self.deviceVModel startScanningOnDiscovered:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.deviceListTable reloadData];
            });
        }];
    }
    else if (appDelegate.CBManager.state == CBCentralManagerStatePoweredOff) {
        [JCAlertView showTwoButtonsWithTitle:@"手机蓝牙未开启" Message:@"是否跳转'设置-蓝牙'界面开启蓝牙?" ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"取消" Click:nil ButtonType:JCAlertViewButtonTypeDefault ButtonTitle:@"去开启" Click:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Bluetooth"]];
        }];
    }
    else {
        [JCAlertView showOneButtonWithTitle:@"手机蓝牙状态异常" Message:nil ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"确定" Click:nil];
    }
    
}

// -- 重新扫描
- (IBAction) rescanDevice:(UIButton*)sender {
    [self.deviceVModel stopScanning];
    NameWeakSelf(wself);
    [self.deviceVModel disconnectDeviceOnFinished:^{
        [wself alertForDeviceScanning];
    }];
}

// -- 签到
- (IBAction) signInBlueDevice:(UIButton*)sender {
    NameWeakSelf(wself);
    [self.progressHud showNormalWithText:@"正在绑定设备..." andDetailText:nil];
    [self.tcpVModel gettingKeysOnFinished:^{
        [wself.deviceVModel writeMainKey:wself.tcpVModel.mainKey onFinished:^{
            [wself.deviceVModel writeWorkKey:wself.tcpVModel.workKey onFinished:^{
                [wself.progressHud showSuccessWithText:@"绑定设备成功" andDetailText:nil onCompletion:^{
                }];
            } onError:^(NSError *error) {
                [wself.progressHud showFailWithText:@"写工作密钥失败" andDetailText:[error localizedDescription] onCompletion:nil];
            }];
        } onError:^(NSError *error) {
            [wself.progressHud showFailWithText:@"写主密钥失败" andDetailText:[error localizedDescription] onCompletion:nil];
        }];
    } onError:^(NSError *error) {
        [wself.progressHud showFailWithText:@"下载密钥失败" andDetailText:[error localizedDescription] onCompletion:nil];
    }];
}

// -- 完成按钮
- (IBAction) doneToPopVC:(id)sender {
    // 保存绑定设备的信息
    [ModelDeviceBindedInformation saveBindedDeviceInfoWithIdentifier:self.deviceVModel.selectedPeripheral.identifier.UUIDString
                                                          deviceName:self.deviceVModel.selectedPeripheral.name
                                                      businessNumber:[MLoginSavedResource sharedLoginResource].businessNumber
                                                      terminalNumber:self.terminalSelector.selectedTerminal];

    [self.navigationController popViewControllerAnimated:YES];
}

// -- 展开终端号列表
- (IBAction) pullListOfTerminals:(UIButton*)sender {
    [self pullButtonTurnDown];
    [self.pullListSegView showWithCompletion:nil];
}

- (void) pullButtonTurnDown {
    NameWeakSelf(wself);
    [UIView animateWithDuration:0.2 animations:^{
        wself.pullButton.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    }];
}
- (void) pullButtonTurnUp {
    NameWeakSelf(wself);
    [UIView animateWithDuration:0.2 animations:^{
        wself.pullButton.transform = CGAffineTransformIdentity;
    }];
}


# pragma mask 4 getter

- (TerminalSelectorVModel *)terminalSelector {
    if (!_terminalSelector) {
        _terminalSelector = [[TerminalSelectorVModel alloc] init];
    }
    return _terminalSelector;
}
- (DeviceVModel *)deviceVModel {
    if (!_deviceVModel) {
        _deviceVModel = [[DeviceVModel alloc] init];
    }
    return _deviceVModel;
}
- (TCPKeysVModel *)tcpVModel {
    if (!_tcpVModel) {
        _tcpVModel = [[TCPKeysVModel alloc] init];
    }
    return _tcpVModel;
}
- (UITableView *)deviceListTable {
    if (!_deviceListTable) {
        CGFloat width = self.view.frame.size.width * 0.7;
        CGFloat height = self.view.frame.size.height * 0.6;
        _deviceListTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height) style:UITableViewStylePlain];
        _deviceListTable.delegate = self.deviceVModel;
        _deviceListTable.dataSource = self.deviceVModel;
        _deviceListTable.rowHeight = 38;
        _deviceListTable.sectionHeaderHeight = 45;
        _deviceListTable.backgroundColor = [UIColor colorWithHex:HexColorTypeTextCyan alpha:1];
        _deviceListTable.layer.cornerRadius = 5.f;
        [_deviceListTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        _deviceListTable.hidden = YES;
    }
    return _deviceListTable;
}
- (UILabel *)terminalLabelPre {
    if (!_terminalLabelPre) {
        _terminalLabelPre = [UILabel new];
        _terminalLabelPre.text = @"终端号:";
        _terminalLabelPre.textAlignment = NSTextAlignmentRight;
        _terminalLabelPre.textColor = [UIColor colorWithHex:HexColorTypeDarkBlack alpha:1];
    }
    return _terminalLabelPre;
}
- (UILabel *)terminalLabel {
    if (!_terminalLabel) {
        _terminalLabel = [UILabel new];
        _terminalLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
        _terminalLabel.textAlignment = NSTextAlignmentCenter;
        if ([MLoginSavedResource sharedLoginResource].terminalCount > 0) {
            _terminalLabel.text = [[MLoginSavedResource sharedLoginResource].terminalList objectAtIndex:0];
        }
    }
    return _terminalLabel;
}
- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [UILabel new];
        _stateLabel.textColor = [UIColor colorWithHex:HexColorTypeDarkBlack alpha:1];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        _stateLabel.layer.masksToBounds = YES;
        _stateLabel.layer.cornerRadius = 5.f;
    }
    return _stateLabel;
}
- (UILabel *)deviceNameLabel {
    if (!_deviceNameLabel) {
        _deviceNameLabel = [UILabel new];
        _deviceNameLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
        _deviceNameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _deviceNameLabel;
}
- (UIView *)backView {
    if (!_backView) {
        _backView = [UIView new];
        _backView.backgroundColor = [UIColor colorWithHex:HexColorTypeViewCyan alpha:1];
    }
    return _backView;
}
- (UIImageView *)posImageView {
    if (!_posImageView) {
        _posImageView = [UIImageView new];
        _posImageView.image = [UIImage imageNamed:@"pos"];
    }
    return _posImageView;
}

- (UIButton *)rescanBtn {
    if (!_rescanBtn) {
        _rescanBtn = [UIButton new];
        [_rescanBtn setTitle:[NSString fontAwesomeIconStringForEnum:FARefresh]forState:UIControlStateNormal];
        [_rescanBtn setTitleColor:[UIColor colorWithHex:HexColorTypeBlackGray alpha:1] forState:UIControlStateNormal];
        [_rescanBtn setTitleColor:[UIColor colorWithHex:HexColorTypeBlackGray alpha:0.5] forState:UIControlStateHighlighted];
        [_rescanBtn addTarget:self action:@selector(rescanDevice:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rescanBtn;
}

- (UIButton *)bindingButton {
    if (!_bindingButton) {
        _bindingButton = [UIButton new];
        [_bindingButton setTitle:@"绑定" forState:UIControlStateNormal];
        [_bindingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_bindingButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
        [_bindingButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
        _bindingButton.backgroundColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        [_bindingButton addTarget:self action:@selector(signInBlueDevice:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bindingButton;
}
- (UIButton *)pullButton {
    if (!_pullButton) {
        _pullButton = [UIButton new];
        [_pullButton setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
        [_pullButton addTarget:self action:@selector(pullListOfTerminals:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pullButton;
}

- (JCAlertView *)alertView {
    if (!_alertView) {
        _alertView = [[JCAlertView alloc] initWithCustomView:self.deviceListTable dismissWhenTouchedBackground:YES];
    }
    return _alertView;
}
- (PullListSegView *)pullListSegView {
    if (!_pullListSegView) {
        _pullListSegView = [[PullListSegView alloc] initWithFrame:CGRectZero];
        _pullListSegView.tableView.delegate = self.terminalSelector;
        _pullListSegView.tableView.dataSource = self.terminalSelector;
    }
    return _pullListSegView;
}
- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _progressHud;
}

- (UIBarButtonItem *)doneBarBtn {
    if (!_doneBarBtn) {
        _doneBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneToPopVC:)];
    }
    return _doneBarBtn;
}

@end
