//
//  DeviceConnectViewController.m
//  JLPay
//
//  Created by jielian on 16/9/5.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DeviceConnectViewController.h"
#import "Define_Header.h"
#import "MBProgressHUD+CustomSate.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"
#import "MLStepSegmentView.h"
#import "DC_mposView.h"
#import "DeviceManager.h"
#import "DC_titleViewChooseTerminal.h"
#import "LaydownNaviTableViewChoose.h"
#import "VMTerminalsDataSource.h"
#import <objc/runtime.h>
#import "DC_VMDeviceDataSource.h"
#import "TCPKeysVModel.h"
#import "ModelDeviceBindedInformation.h"
#import "UIAlertController+JLShow.h"



@interface DeviceConnectViewController() <UIGestureRecognizerDelegate>

/* 模拟mpos界面 */
@property (nonatomic, strong) DC_mposView* mposView;

/* 进度显示视图 */
@property (nonatomic, strong) MLStepSegmentView* stepSegView;

/* 终端号显示、切换视图 */
@property (nonatomic, strong) DC_titleViewChooseTerminal* titleViewChooseTerminal;

/* 终端号列表视图 */
@property (nonatomic, strong) LaydownNaviTableViewChoose* laydownChooseView;

/* 终端号列表数据源 */
@property (nonatomic, strong) VMTerminalsDataSource* termsDataSource;

/* 设备操作数据交互 */
@property (nonatomic, strong) DC_VMDeviceDataSource* deviceDataSource;

/* 下载密钥数据源 */
@property (nonatomic, strong) TCPKeysVModel* tcpKeysDataSource;

/* 完成按钮 */
@property (nonatomic, strong) UIBarButtonItem* doneBarBtn;

/* 取消按钮 */
@property (nonatomic, strong) UIBarButtonItem* cancelBarBtn;

/* 绑定完成的回调 */
@property (nonatomic, copy) void (^ connectedBlock) (void);

/* 取消绑定的回调 */
@property (nonatomic, copy) void (^ canceledBlock) (void);

@end


@implementation DeviceConnectViewController

- (instancetype)initWithConnected:(void (^)(void))connectedBlock orCanceled:(void (^)(void))canceledBlock {
    self = [super init];
    if (self) {
        self.connectedBlock = connectedBlock;
        self.canceledBlock = canceledBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xeeeeee alpha:1];
    [self loadSubviews];
    [self addKVOs];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];

    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
        
    [self.stepSegView setNeedsUpdateConstraints];
    [self.stepSegView updateConstraintsIfNeeded];
    [self.stepSegView layoutIfNeeded];

    [self.mposView setNeedsUpdateConstraints];
    [self.mposView updateConstraintsIfNeeded];
    [self.mposView layoutIfNeeded];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /* 检查如果商户未配置终端号就退出界面 */
    if (self.termsDataSource.terminalSelected == nil || self.termsDataSource.terminalSelected.length == 0) {
        NameWeakSelf(wself);
        [UIAlertController showAlertWithTitle:@"您的商户未配置终端号" message:@"请联系代理商或客服配置终端号后再绑定设备" target:self clickedHandle:^(UIAlertAction *action) {
            [wself clickedCancelBtn:nil];
        } buttons:@{@(UIAlertActionStyleDefault):@"知道了"}, nil];
    }
    
    [self.deviceDataSource startDeviceScanning];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.deviceDataSource stopDeviceScanning];
    [self.deviceDataSource disconnectDeviceOnFinished:nil];
}


- (void) loadSubviews {
    [self.navigationItem setTitleView:self.titleViewChooseTerminal];
    [self.view addSubview:self.stepSegView];
    [self.view addSubview:self.mposView];
    [self.navigationItem setRightBarButtonItem:self.doneBarBtn];
    [self.navigationItem setLeftBarButtonItem:self.cancelBarBtn];
    
    [self.titleViewChooseTerminal setNeedsUpdateConstraints];
    [self.titleViewChooseTerminal updateConstraintsIfNeeded];
    [self.titleViewChooseTerminal layoutIfNeeded];
}


- (void)updateViewConstraints {
    NameWeakSelf(wself);
    CGFloat inset = ScreenWidth * 20/320.f;
    [self.stepSegView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(wself.view.mas_top).offset(64 + 0);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(inset);
        make.right.mas_equalTo(- inset);
    }];
    
    [self.mposView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(wself.stepSegView.mas_bottom).offset(inset);
        make.bottom.mas_equalTo(wself.view.mas_bottom).offset(- inset);
        make.centerX.mas_equalTo(wself.view.mas_centerX);
        make.width.mas_equalTo(wself.mposView.mas_height).multipliedBy(535.4/955.f);
    }];
    
    [super updateViewConstraints];
}



- (void) addKVOs {
    @weakify(self);
    
    /* 监控: 标题视图展开 */
    [RACObserve(self.titleViewChooseTerminal, disclosured) subscribeNext:^(id x) {
        @strongify(self);
        if ([x boolValue]) {
            [self.laydownChooseView show];
        } else {
            [self.laydownChooseView hide];
        }
    }];
    
    /* bind: 是否可切换 */
    RAC(self.titleViewChooseTerminal.switchBtn, hidden) = [RACObserve(self.termsDataSource, terminalList) map:^id(NSArray* list) {
        return @(list.count <= 1);
    }];
    
    /* bind: 终端号 */
    RAC(self.titleViewChooseTerminal.contentLabel, text) = RACObserve(self.termsDataSource, terminalSelected);
    RAC(self.tcpKeysDataSource, terminalNumber) = RACObserve(self.termsDataSource, terminalSelected);
    
    
    /* 监控: 选择终端号,关闭展开;重扫设备 */
    [[RACObserve(self.termsDataSource, terminalSelected) skip:1] subscribeNext:^(id x) {
        @strongify(self);
        self.titleViewChooseTerminal.disclosured = NO;
        if (self.stepSegView.itemSelected == 2) {
            [self clickedRescanBtn:nil];
        }
    }];
    
    /* 监控: 扫描设备 */
    [[RACObserve(self.deviceDataSource, deviceList) deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self);
        [self.mposView.devicesTBV reloadData];
    }];
    
    /* 设备状态信息 */
    RAC(self.mposView.stateTextLab, text) = [[RACSignal merge:@[RACObserve(self.deviceDataSource, deviceStatus), RACObserve(self.tcpKeysDataSource, stateMessage)]] deliverOnMainThread];
    
    /* bind: 主密钥 + 工作密钥 */
    RAC(self.deviceDataSource, mainKeyPin) = RACObserve(self.tcpKeysDataSource, mainKey);
    RAC(self.deviceDataSource, workKeyPin) = RACObserve(self.tcpKeysDataSource, workKey);
    
    /* 监控: 连接设备 on 点击了deviceCell */
    [[RACObserve(self.deviceDataSource, deviceSelected) filter:^BOOL(CBPeripheral* device) {
        return (device != nil);
    }] subscribeNext:^(id x) {
        @strongify(self);
        self.stepSegView.itemSelected = 1;
        [MBProgressHUD showNormalWithText:nil andDetailText:nil];
        [self.deviceDataSource connectDeviceOnFinished:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showSuccessWithText:@"连接成功" andDetailText:nil onCompletion:nil];
            });
        } onError:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showFailWithText:@"连接失败" andDetailText:nil onCompletion:nil];
            });
        }];
    }];
    
    /* bind: 绑定按钮 enable */
    RAC(self.mposView.bindBtn, enabled) = [RACSignal combineLatest:@[RACObserve(self.deviceDataSource.deviceManager, connected), RACObserve(self.deviceDataSource, deviceSelected)] reduce:^id(NSNumber* connected, CBPeripheral* device){
        return @(connected && (device != nil));
    }];
    
    /* bind: 完成按钮 enable */
    RAC(self.doneBarBtn, enabled) = [RACObserve(self.mposView, state) map:^id(NSNumber* state) {
        return @([state integerValue] == DC_VIEW_STATE_DONE);
    }];
}


# pragma mask 2 IBAction

/* 切换终端号 */
- (IBAction) clickedOnTerminalListChooseView:(UITapGestureRecognizer*)gesture {
    self.titleViewChooseTerminal.disclosured = NO;
}


/* 绑定设备 */
- (IBAction) clickedBindingBtn:(id)sender {
    @weakify(self);
    self.stepSegView.itemSelected = 2;
    self.mposView.state = DC_VIEW_STATE_WAITTING;
    [MBProgressHUD showNormalWithText:nil andDetailText:nil];
    [self.tcpKeysDataSource gettingKeysOnFinished:^{
        @strongify(self);
        [self.deviceDataSource writeKeyPinsOnFinished:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                self.mposView.state = DC_VIEW_STATE_DONE;
                [MBProgressHUD showSuccessWithText:@"绑定设备成功!" andDetailText:nil onCompletion:^{
                    @strongify(self);
                    [ModelDeviceBindedInformation saveBindedDeviceInfoWithIdentifier:self.deviceDataSource.deviceSelected.identifier.UUIDString
                                                                          deviceName:self.deviceDataSource.deviceSelected.name
                                                                      businessNumber:[PublicInformation returnBusiness]
                                                                      terminalNumber:self.termsDataSource.terminalSelected];
                    
                }];
            });
        } onError:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                self.mposView.state = DC_VIEW_STATE_WRONG;
                [MBProgressHUD showFailWithText:@"设备写密钥失败" andDetailText:[error localizedDescription] onCompletion:nil];
            });
        }];
    } onError:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self.mposView.state = DC_VIEW_STATE_WRONG;
            [MBProgressHUD showFailWithText:@"下载密钥失败" andDetailText:[error localizedDescription] onCompletion:nil];
        });
    }];
}

/* 重新扫描设备 */
- (IBAction) clickedRescanBtn:(id)sender {
    @weakify(self);
    self.stepSegView.itemSelected = 0;
    self.mposView.state = DC_VIEW_STATE_WAITTING;
    [self.deviceDataSource disconnectDeviceOnFinished:^{
        @strongify(self);
        
        self.deviceDataSource.deviceSelected = nil;
        
        [self.deviceDataSource stopDeviceScanning];
        [self.deviceDataSource startDeviceScanning];
    }];
}


/* 完成并退出 */
- (IBAction) clickedDoneBtn:(id)sender {
    NameWeakSelf(wself);
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (wself.canceledBlock) {
            wself.canceledBlock();
        }
    }];
}

/* 取消并退出 */
- (IBAction) clickedCancelBtn:(id)sender {
    NameWeakSelf(wself);
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (wself.canceledBlock) {
            wself.canceledBlock();
        }
    }];
}

# pragma mask 3 UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view class] == [UITableView class]) {
        return YES;
    }
    else {
        return NO;
    }
}


# pragma mask 4 getter


- (DC_mposView *)mposView {
    if (!_mposView) {
        _mposView = [[DC_mposView alloc] initWithFrame:CGRectZero];
        _mposView.devicesTBV.separatorInset = UIEdgeInsetsZero;
        _mposView.devicesTBV.layoutMargins = UIEdgeInsetsZero;
        [_mposView.bindBtn addTarget:self action:@selector(clickedBindingBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_mposView.reScanBtn addTarget:self action:@selector(clickedRescanBtn:) forControlEvents:UIControlEventTouchUpInside];
        _mposView.devicesTBV.dataSource = self.deviceDataSource;
        _mposView.devicesTBV.delegate = self.deviceDataSource;
    }
    return _mposView;
}

- (MLStepSegmentView *)stepSegView {
    if (!_stepSegView) {
        _stepSegView = [[MLStepSegmentView alloc] initWithTitles:@[@"扫描设备", @"连接设备", @"绑定设备"]];
        _stepSegView.tintColor = [UIColor colorWithHex:0x4b9993 alpha:1];
        _stepSegView.normalColor = [UIColor colorWithHex:0x999999 alpha:1];
        _stepSegView.stepIsSingle = NO;
        _stepSegView.userInteractionEnabled = NO;
        _stepSegView.itemSelected = 0;
    }
    return _stepSegView;
}

- (DC_titleViewChooseTerminal *)titleViewChooseTerminal {
    if (!_titleViewChooseTerminal) {
        _titleViewChooseTerminal = [[DC_titleViewChooseTerminal alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
        _titleViewChooseTerminal.titleLabel.text = @"绑定终端号:";
    }
    return _titleViewChooseTerminal;
}

- (LaydownNaviTableViewChoose *)laydownChooseView {
    if (!_laydownChooseView) {
        _laydownChooseView = [[LaydownNaviTableViewChoose alloc] initWithSuperView:self.view];
        _laydownChooseView.dataTableView.dataSource = self.termsDataSource;
        _laydownChooseView.dataTableView.delegate = self.termsDataSource;
        _laydownChooseView.dataTableView.separatorInset = UIEdgeInsetsZero;
        _laydownChooseView.dataTableView.layoutMargins = UIEdgeInsetsZero;
        UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedOnTerminalListChooseView:)];
        tapGes.delegate = self;
        [_laydownChooseView addGestureRecognizer:tapGes];
    }
    return _laydownChooseView;
}

- (VMTerminalsDataSource *)termsDataSource {
    if (!_termsDataSource) {
        _termsDataSource = [[VMTerminalsDataSource alloc] init];
    }
    return _termsDataSource;
}

- (DC_VMDeviceDataSource *)deviceDataSource {
    if (!_deviceDataSource) {
        _deviceDataSource = [[DC_VMDeviceDataSource alloc] init];
    }
    return _deviceDataSource;
}

- (TCPKeysVModel *)tcpKeysDataSource {
    if (!_tcpKeysDataSource) {
        _tcpKeysDataSource = [[TCPKeysVModel alloc] init];
    }
    return _tcpKeysDataSource;
}

- (UIBarButtonItem *)doneBarBtn {
    if (!_doneBarBtn) {
        _doneBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(clickedDoneBtn:)];
    }
    return _doneBarBtn;
}

- (UIBarButtonItem *)cancelBarBtn {
    if (!_cancelBarBtn) {
        UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [cancelBtn setTitle:[NSString fontAwesomeIconStringForEnum:FATimesCircle] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:25 scale:1]];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
        [cancelBtn addTarget:self action:@selector(clickedCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        _cancelBarBtn = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    }
    return _cancelBarBtn;
}

@end
