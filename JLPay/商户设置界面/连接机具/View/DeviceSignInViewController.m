//
//  DeviceSignInViewController.m
//  JLPay
//
//  Created by jielian on 15/7/13.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "DeviceSignInViewController.h"
#import "Define_Header.h"
#import "Toast+UIView.h"
#import "MBProgressHUD+CustomSate.h"
#import "DeviceManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "MLoginSavedResource.h"
#import "ViewModelTCPHandleWithDevice.h"
#import "ModelDeviceBindedInformation.h"

typedef enum {
    DeviceSignInAlertTagNoTerminals
}DeviceSignInAlertTag;


@interface DeviceSignInViewController()
<
DeviceManagerDelegate,
ViewModelTCPHandleWithDeviceDelegate,
UITableViewDataSource,UITableViewDelegate,CBCentralManagerDelegate,
UIActionSheetDelegate,UIAlertViewDelegate
>
{
    BOOL needCheckoutToCustVC;
    BOOL blueToothIsOn;
    CBCentralManager* bleManager;
}
@property (nonatomic, strong) NSMutableArray* SNVersionNums;        // SN号列表

@property (nonatomic, strong) NSString* selectedTerminalNum;        // 终端号:已勾选的
@property (nonatomic, strong) NSString* selectedSNVersionNum;       // SN号:已勾选的

@property (nonatomic, strong) NSString* selectedDevice;             // 已选取的设备类型

@property (nonatomic, strong) UIButton* sureButton;                 // “确定”按钮
@property (nonatomic, strong) UITableView* tableView;               // 设备列表的表视图
@property (nonatomic, strong) NSTimer*  deviceWaitingTimer;               // 等待超时定时器

@property (nonatomic, strong) MBProgressHUD* progressHud;
@end


@implementation DeviceSignInViewController

@synthesize SNVersionNums = _SNVersionNums;
@synthesize tableView = _tableView;
@synthesize sureButton = _sureButton;
@synthesize deviceWaitingTimer;
@synthesize selectedTerminalNum;
@synthesize selectedDevice;

#pragma mask ::: 主视图加载
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绑定设备";
    self.view.backgroundColor = [UIColor whiteColor];
    self.selectedDevice = nil;
    
    bleManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    if (bleManager.state == CBCentralManagerStatePoweredOn) {
        blueToothIsOn = YES;
    } else {
        blueToothIsOn = NO;
    }
    // 加载已绑定信息:如果已经绑定过
    if ([ModelDeviceBindedInformation hasBindedDevice]) {
        self.selectedTerminalNum = [ModelDeviceBindedInformation terminalNoBinded];
        self.selectedSNVersionNum = [ModelDeviceBindedInformation deviceSNBinded];
    }
    // 更新切换视图标记:切换到金额输入界面
    needCheckoutToCustVC = NO;
    [self loadSubviews];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [[ViewModelTCPHandleWithDevice getInstance] setDelegate: self];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([MLoginSavedResource sharedLoginResource].terminalCount == 0) {
        [PublicInformation alertSureWithTitle:@"商户未配置终端号" message:@"请等待后台配置终端,或联系客服人员处理" tag:DeviceSignInAlertTagNoTerminals delegate:self];
    } else {
        if (self.selectedDevice == nil && blueToothIsOn) {
            // 加载设备选择框
            [self actionSheetShowForSelectingDevice];
        }
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.progressHud hide:YES];
    // 在界面退出后控制器可能会被释放,所以要将 delegate 置空
    [[DeviceManager sharedInstance] clearAndCloseAllDevices];
    [[ViewModelTCPHandleWithDevice getInstance] stopDownloading];
    [self stopDeviceTimer];
    if (needCheckoutToCustVC) {
        // 切换到金额输入界面
        [self.tabBarController setSelectedIndex:0];
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


- (void) loadSubviews {
    CGFloat inset = 8;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.bounds.size.height;
    CGFloat tabBarHeignth = self.tabBarController.tabBar.bounds.size.height;
    CGFloat buttonHeight = 50;
    CGFloat tableViewHeight = self.view.bounds.size.height - statusBarHeight - navigationBarHeight - tabBarHeignth - buttonHeight - inset*4;
    // 表视图
    CGRect frame = CGRectMake(0,
                              statusBarHeight + navigationBarHeight,
                              self.view.bounds.size.width,
                              tableViewHeight);
    self.tableView.frame = frame;
    
    // 绑定按钮
    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset*2;
    frame.size.width -= inset * 2;
    frame.size.height = buttonHeight;
    self.sureButton.frame = frame;
    self.sureButton.layer.cornerRadius = frame.size.height/2.0;
    
    [self.view addSubview:self.sureButton];
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.progressHud];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

#pragma mask ------------------------------ 表视图 delegate & dataSource
// section numbers
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
// row numbers
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;
    if (section == 0) {
        rows = [MLoginSavedResource sharedLoginResource].terminalCount;
    } else if (section == 1) {
        rows = self.SNVersionNums.count;
    }
    return rows;
}
// header height
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40;
}
// pragma mask ::: 装载终端编号、SN号单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 重用或创建 cell
    NSString* identifier = @"tableViewCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
    }
    
    // 加载终端号 cell
    if (indexPath.section == 0) {
        // textLabel
        cell.textLabel.text = @"终端编号";
        // detailTextLabel
        cell.detailTextLabel.text = [[MLoginSavedResource sharedLoginResource].terminalList objectAtIndex:indexPath.row];
        
        
        if ([self.selectedTerminalNum isEqualToString:cell.detailTextLabel.text]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    // 加载SN号 cell
    else if (indexPath.section == 1) {
        cell.textLabel.text = @"设备SN编号";
        cell.detailTextLabel.text = [self.SNVersionNums objectAtIndex:indexPath.row];
        
        if ([self.selectedSNVersionNum isEqualToString:cell.detailTextLabel.text]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    return cell;
}

// 自定义 tableview 的 headerView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    CGRect frame = [tableView rectForHeaderInSection:section];
    UIView* headerView = nil;
    // 只对设备SN列表的header自定义
    if (section == 1) {
        CGFloat inset = 5;
        headerView = [[UIView alloc] initWithFrame:frame];
        // 标题
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(15, inset*2, frame.size.width/2.0, frame.size.height - inset*2)];
        label.text = @"2.请选择设备";
        label.font = cell.textLabel.font;
        label.textColor = [UIColor colorWithWhite:0.4 alpha:1];
        [headerView addSubview:label];
        // 按钮-"搜索"
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 15 - frame.size.width/4.0, inset, frame.size.width/4.0, frame.size.height - inset*2)];
        [button setTitle:@"搜索" forState:UIControlStateNormal];
        button.titleLabel.font = cell.textLabel.font;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = button.frame.size.height/2.0;
        button.backgroundColor = [PublicInformation returnCommonAppColor:@"red"];
        [button addTarget:self action:@selector(buttonTouchToOpenDevices:) forControlEvents:UIControlEventTouchUpInside];
        
        [headerView addSubview:button];
    }
    return headerView;
}

// pragma mask ::: 设置section 头
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"1.请选择终端号";
    } else {
        return nil;
    }
}

// -- 底部视图自定义
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGRect frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.sectionFooterHeight);
    UIView* footerView = [[UIView alloc] initWithFrame:frame];
    UILabel* footerLabel = [[UILabel alloc] init];
    frame.origin.x += 15;
    frame.size.width -= 15;
    frame.size.height = 40.f;
    [footerLabel setFrame:frame];
    [footerView addSubview:footerLabel];
    footerLabel.textColor = [UIColor brownColor];
    footerLabel.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:frame.size andScale:0.4]];
    if (section == 0) {
        footerLabel.text = [NSString stringWithFormat:@"(已绑定终端号: %@)", [self terminalBinded]];
    } else {
        footerLabel.text = [NSString stringWithFormat:@"(已绑定设备 SN: %@)", [self SNVersionNumBinded]];
    }
    return footerView;
}

/*
 * pragma mask ::: 点击终端编号对应的单元格
 *  1.显示标记
 *  2.登记已选择的终端号到缓存
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.detailTextLabel.text isEqualToString:@"无"]) {
        return;
    }
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.section == 0) {
            self.selectedTerminalNum = nil;
        }
        else if (indexPath.section == 1) {
            self.selectedSNVersionNum = nil;
        }
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if (indexPath.section == 0) {
            self.selectedTerminalNum = cell.detailTextLabel.text;
        } else if (indexPath.section == 1) {
            self.selectedSNVersionNum = cell.detailTextLabel.text;
        }
    }
    [self.tableView reloadData];
}


#pragma mask : -------------  CBCentrolManagerDelegate 
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        blueToothIsOn = YES;
    } else {
        blueToothIsOn = NO;
    }
}

#pragma mask : -------------  DeviceManagerDelegate
- (void)didConnectedDeviceResult:(BOOL)result onSucSN:(NSString *)SNVersion onErrMsg:(NSString *)errMsg
{
    [self stopDeviceTimer];
    if (!result) {
        [self.progressHud showFailWithText:@"连接设备失败" andDetailText:errMsg onCompletion:^{}];
        return;
    }
    [self.progressHud showSuccessWithText:@"连接设备成功" andDetailText:@"请选择设备,并'绑定'" onCompletion:^{
    }];
    if (self.SNVersionNums.count == 1 && [[self.SNVersionNums objectAtIndex:0] isEqualToString:@"无"]) {
        [self.SNVersionNums removeAllObjects];
    }
    if (![self.SNVersionNums containsObject:SNVersion]) {
        [self.SNVersionNums addObject:SNVersion];
    }
    [self reloadTableView];

}

// 设备丢失:SN
- (void)didDisconnectDeviceOnSN:(NSString *)SNVersion {
    if (SNVersion && [self.SNVersionNums containsObject:SNVersion]) {
        [self.SNVersionNums removeObject:SNVersion];
    }
    if (self.SNVersionNums.count == 0) {
        [self.SNVersionNums addObject:@"无"];
    }
    [self reloadTableView];
}



// 设置主密钥的回调
- (void)didWroteMainKeyResult:(BOOL)result onErrMsg:(NSString *)errMsg {
    if (result) {
        [self downloadWorkKey];
    } else {
        [self.progressHud showFailWithText:@"绑定设备失败" andDetailText:errMsg onCompletion:^{
            
        }];
    }
}
// 设置工作密钥的回调
- (void)didWroteWorkKeyResult:(BOOL)result onErrMsg:(NSString *)errMsg {
    NameWeakSelf(wself);
    if (result) {
        // 更新批次号
        [PublicInformation updateSignSort];
        [self saveBindedDevice];
        [self reloadTableView];
        needCheckoutToCustVC = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 部分设备退出比较慢，放在副线程
            [[DeviceManager sharedInstance] clearAndCloseAllDevices];
        });
        [self.progressHud showSuccessWithText:@"绑定设备成功" andDetailText:nil onCompletion:^{
            [wself.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [self.progressHud showFailWithText:@"绑定设备失败" andDetailText:errMsg onCompletion:^{
            
        }];
    }
}


#pragma mask ---- TCP & ViewModelTCPHandleWithDeviceDelegate
/* 主密钥下载 */
- (void) downloadMainKey {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ViewModelTCPHandleWithDevice getInstance] downloadMainKeyWithBusinessNum:[MLoginSavedResource sharedLoginResource].businessNumber andTerminalNum:self.selectedTerminalNum];
    });
}
/* 工作密钥下载 */
- (void) downloadWorkKey {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ViewModelTCPHandleWithDevice getInstance] downloadWorkKeyWithBusinessNum:[MLoginSavedResource sharedLoginResource].businessNumber andTerminalNum:self.selectedTerminalNum];
    });
}
/* 主密钥下载回调 */
- (void)didDownloadedMainKeyResult:(BOOL)result withMainKey:(NSString *)mainKey orErrorMessage:(NSString *)errorMessge
{
    if (result) {
        [[DeviceManager sharedInstance] writeMainKey:mainKey onSNVersion:self.selectedSNVersionNum];
    } else {
        [self.progressHud showFailWithText:@"下载主密钥失败" andDetailText:errorMessge onCompletion:^{
            
        }];
    }
}
/* 工作密钥下载回调 */
- (void)didDownloadedWorkKeyResult:(BOOL)result withWorkKey:(NSString *)workKey orErrorMessage:(NSString *)errorMessge
{
    if (result) {
        JLPrint(@"写工作密钥:[%@]",workKey);
        [[DeviceManager sharedInstance] writeWorkKey:workKey onSNVersion:self.selectedSNVersionNum];
    } else {
        [self.progressHud showFailWithText:@"下载工作密钥失败" andDetailText:errorMessge onCompletion:^{}];
    }
}


#pragma mask -------------------------------- UIActionSheetDelegate 点击事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        self.selectedDevice = nil;
        return;
    }
    if (!blueToothIsOn) {
        return;
    }
    // 保存选择的设备类型
    NSString* title = [actionSheet buttonTitleAtIndex:buttonIndex];
    self.selectedDevice = title;
    [[DeviceManager sharedInstance] setDelegate:self];
    [[DeviceManager sharedInstance] makeDeviceEntryOnDeviceType:title];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (!blueToothIsOn) {
        [PublicInformation makeCentreToast:@"手机蓝牙未打开,请打开蓝牙"];
        return;
    }
    if (buttonIndex != 0) {
        // 启动设备扫描
        [[DeviceManager sharedInstance] openDeviceWithIdentifier:nil];
        [self.progressHud showNormalWithText:@"设备连接中..." andDetailText:nil];
        // 异步启动等待定时器
        [self startDeviceTimer];
    }
}

#pragma mask 2 UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.message isEqualToString:@"绑定设备成功!"]) {
        // 绑定成功后就跳转到金额输入界面
        [self.navigationController popViewControllerAnimated:YES];
        needCheckoutToCustVC = YES;
    }
}


#pragma mask ::: 确定按钮 的点击事件 --
/*
 * 1.校验选择的终端号是否在商户登陆的终端号列表中
 * 2.设置选择的终端号+商户号到本地配置中
 * 3.发送签到报文 -- 改为先下载主密钥、后下载工作密钥
 * 4.写工作密钥在签到报文的回调中执行
 */
- (IBAction) buttonClicked:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformIdentity;

    // 设置选择的终端号到本地配置 并签到
    if (self.selectedTerminalNum == nil) {
        [PublicInformation makeCentreToast:@"请选择终端号"];
        return;
    }
    if (self.selectedSNVersionNum == nil) {
        [PublicInformation makeCentreToast:@"请选择设备SN号"];
        return;
    }
    // 下载主密钥 -- 需要判断设备是否连接
    if ([[DeviceManager sharedInstance] isConnectedOnSNVersionNum:self.selectedSNVersionNum]) {
        [self.progressHud showNormalWithText:@"设备绑定中..." andDetailText:nil];
        [self downloadMainKey];
    } else {
        [PublicInformation makeCentreToast:@"设备未连接"];
    }
}
// 打开设备并读取sn号
- (IBAction) buttonTouchToOpenDevices:(id)sender {
    [self.SNVersionNums removeAllObjects];
    [self.SNVersionNums addObject:@"无"];
    [self reloadTableView];
    if (!blueToothIsOn) {
        [PublicInformation makeCentreToast:@"手机蓝牙未打开,请先打开蓝牙"];
        return;
    }
    if (self.selectedDevice == nil) {
        [self actionSheetShowForSelectingDevice];
    } else {
        // 异步调起等待定时器
        [self startDeviceTimer];
        [[DeviceManager sharedInstance] clearAndCloseAllDevices];
        [self.progressHud showNormalWithText:@"设备连接中..." andDetailText:nil];
        [[DeviceManager sharedInstance] setDelegate:self];
        [[DeviceManager sharedInstance] makeDeviceEntryOnDeviceType:self.selectedDevice];
        [[DeviceManager sharedInstance] openDeviceWithIdentifier:nil];
    }
}
// 按钮按下事件
- (IBAction) buttonTouchDown:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformMakeScale(0.98, 0.98);
}
// 按钮抬起在外部
- (IBAction) buttonTouchUpOutSide:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformIdentity;
}



#pragma mask --------- private interface
// 刷新tableView
- (void) reloadTableView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
// 获取绑定的终端号
- (NSString*) terminalBinded {
    NSString* terminal = @"无";
    if ([ModelDeviceBindedInformation hasBindedDevice]) {
        terminal = [ModelDeviceBindedInformation terminalNoBinded];
    }
    return terminal;
}
// 绑定的设备sn号
- (NSString*) SNVersionNumBinded {
    NSString* SNVersion = @"无";
    if ([ModelDeviceBindedInformation hasBindedDevice]) {
        SNVersion = [ModelDeviceBindedInformation deviceSNBinded];
    }
    return SNVersion;
}

// 弹出设备类型选择框
- (void) actionSheetShowForSelectingDevice {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择设备类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    [actionSheet addButtonWithTitle:DeviceType_DL01];
    [actionSheet addButtonWithTitle:DeviceType_LD_M18];
    [actionSheet addButtonWithTitle:DeviceType_JLpay_TY01];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}



// 保存绑定的设备信息
- (void) saveBindedDevice {
    NSString* identifier = [[DeviceManager sharedInstance] deviceIdentifierOnSN:self.selectedSNVersionNum];
    if (!identifier) {
        return;
    }
    [ModelDeviceBindedInformation saveBindedDeviceInfoWithDeviceType:self.selectedDevice
                                                            deviceID:identifier
                                                            deviceSN:self.selectedSNVersionNum
                                                      terminalNumber:self.selectedTerminalNum
                                                      businessNumber:[MLoginSavedResource sharedLoginResource].businessNumber];
}


// 启动设备等待定时器
- (void) startDeviceTimer {
    self.deviceWaitingTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(waitingTimeoutWithMsg) userInfo:nil repeats:NO];
}
// 关闭设备定时器
- (void) stopDeviceTimer {
    if ([self.deviceWaitingTimer isValid]) {
        [self.deviceWaitingTimer invalidate];
        self.deviceWaitingTimer = nil;
    }
}
- (void) waitingTimeoutWithMsg {
    [self stopDeviceTimer];
    [self.progressHud showWarnWithText:@"设备连接超时" andDetailText:@"请点击'搜索'按钮重新搜索" onCompletion:^{}];
}




#pragma mask ::: getter & setter
- (NSMutableArray *)SNVersionNums {
    if (_SNVersionNums == nil) {
        _SNVersionNums = [[NSMutableArray alloc] init];
        [_SNVersionNums addObject:@"无"];
    }
    return _SNVersionNums;
}
- (UIButton *)sureButton {
    if (_sureButton == nil) {
        _sureButton = [[UIButton alloc] init];
        [_sureButton setTitle:@"绑定" forState:UIControlStateNormal];
        
        _sureButton.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:69.0/255.0 blue:75.0/255.0 alpha:1.0];
        _sureButton.layer.cornerRadius = 8.0;
        
        [_sureButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_sureButton addTarget:self action:@selector(buttonTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_sureButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.layer.borderWidth = 0.5;
        _tableView.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:0.5].CGColor;
        [_tableView setCanCancelContentTouches:NO];
    }
    return _tableView;
}
- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _progressHud;
}

@end

