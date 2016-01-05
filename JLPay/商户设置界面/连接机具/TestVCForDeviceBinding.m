//
//  TestVCForDeviceBinding.m
//  JLPay
//
//  Created by jielian on 15/12/25.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "TestVCForDeviceBinding.h"
#import "BLEDeviceManagerTY.h"
#import "PublicInformation.h"

@interface TestVCForDeviceBinding()
<UITableViewDataSource, UITableViewDelegate, BLEDeviceManagerTYDelegate>
{
    NSMutableArray* deviceSNList;
    id device;
}
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIButton* btnSearchDevice;    // 搜索设备
@property (nonatomic, strong) UIButton* btnDisconnectDevice; // 断开设备
@property (nonatomic, strong) UIButton* btnConnectDevice; // 连接设备
@property (nonatomic, strong) UIButton* btnRereadSN; // 读取SN
@property (nonatomic, strong) UIButton* btnWriteMainKey;
@property (nonatomic, strong) UIButton* btnWriteWorkKey;
@property (nonatomic, strong) UIButton* btnSwipeCard;

@end

@implementation TestVCForDeviceBinding

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        deviceSNList = [[NSMutableArray alloc] init];
        device = [BLEDeviceManagerTY sharedInstance];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubviews];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [device setDelegate:self];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [device setDelegate:nil];
    [device disConnectAllDevices];
}
- (void) loadSubviews {
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    CGFloat heightStatus = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat heightNavigation = self.navigationController.navigationBar.frame.size.height;
    CGFloat heightTabBar = self.tabBarController.tabBar.frame.size.height;
    CGFloat heightValid = self.view.frame.size.height - heightStatus - heightNavigation - heightTabBar;
    
    CGFloat insetHeight = 10.f;
    CGFloat insetWidth = 15.f;
    CGFloat heightButton = 40;
    CGFloat widthButton = (self.view.frame.size.width - insetWidth*3)/2.0;
    
    CGRect frame = CGRectMake(0, heightStatus + heightNavigation, self.view.frame.size.width, heightValid/3.0);
    [self.tableView setFrame:frame];
    [self.view addSubview:self.tableView];
    
    // 连接设备
    frame.origin.x += insetWidth;
    frame.origin.y += frame.size.height + insetHeight;
    frame.size.width = widthButton;
    frame.size.height = heightButton;
    [self.btnConnectDevice setFrame:frame];
    [self.view addSubview:self.btnConnectDevice];
    // 断开设备
    frame.origin.x += frame.size.width + insetWidth;
    [self.btnDisconnectDevice setFrame:frame];
    [self.view addSubview:self.btnDisconnectDevice];
    // 读取SN
    frame.origin.x = 0 + insetWidth;
    frame.origin.y += frame.size.height + insetHeight;
    [self.btnRereadSN setFrame:frame];
    [self.view addSubview:self.btnRereadSN];
    // 写主密钥
    frame.origin.x += frame.size.width + insetWidth;
    [self.btnWriteMainKey setFrame:frame];
    [self.view addSubview:self.btnWriteMainKey];
    // 写工作密钥
    frame.origin.x = 0 + insetWidth;
    frame.origin.y += frame.size.height + insetHeight;
    [self.btnWriteWorkKey setFrame:frame];
    [self.view addSubview:self.btnWriteWorkKey];
    // 刷卡
    frame.origin.x += frame.size.width + insetWidth;
    [self.btnSwipeCard setFrame:frame];
    [self.view addSubview:self.btnSwipeCard];
}


#pragma mask ---- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return deviceSNList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"cellIdentifier__";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell.textLabel setText:[self SNVersionAtIndex:indexPath.row]];
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"连接的设备SN如下";
}
#pragma mask ---- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if ( cell.accessoryType == UITableViewCellAccessoryCheckmark ) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

#pragma mask ---- BLEDeviceManagerTYDelegate
/* 回调: 连接设备成功 */
- (void)didConnectedDeviceSucOnSN:(NSString *)SNVersion identifier:(NSString *)identifier {
    [self addDeviceSN:SNVersion];
    [self reloadTableView];
}
/* 回调: 连接设备失败 */
- (void)didConnectedDeviceFail:(NSString *)failMessage OnSN:(NSString *)SNVersion {
    [PublicInformation makeCentreToast:[NSString stringWithFormat:@"连接设备失败:%@",failMessage]];
}
/* 回调: 断开连接 */
- (void)didDisConnectedDeviceOnSN:(NSString *)SNVersion {
    [self deleteDeviceSN:SNVersion];
    [self reloadTableView];
}

#pragma mask ---- 按钮事件组
//
- (IBAction) searchDevicesOnButton:(UIButton*)sender {
    [device connectAllDevices];
}
//
- (IBAction) connectDeviceOnButton:(UIButton*)sender {
    [device connectAllDevices];
}
//
- (IBAction) disConnectDeviceOnButton:(UIButton*)sender {
    [device disConnectAllDevices];
}
- (IBAction) rereadDeviceSNOnButton:(UIButton*)sender {
    [device readSN];
}
//
- (IBAction) writeDeviceMainKeyOnButton:(UIButton*)sender {
}
//
- (IBAction) writeDeviceWorkKeyOnButton:(UIButton*)sender {
}
//
- (IBAction) swipeCardOnButton:(UIButton*)sender {
}

#pragma mask ---- PRIVATE INTERFACE

/* 设备SN组相关 */
- (void) addDeviceSN:(NSString*)SNVersion {
    [deviceSNList addObject:SNVersion];
}
- (void) deleteDeviceSN:(NSString*)SNVersion {
    if ([deviceSNList containsObject:SNVersion]) {
        [deviceSNList removeObject:SNVersion];
    }
}
- (void) clearDeviceSNList {
    [deviceSNList removeAllObjects];
}
- (NSString*) SNVersionAtIndex:(NSInteger)index {
    return [deviceSNList objectAtIndex:index];
}

#pragma mask : 表格相关
- (void) reloadTableView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (UIButton*) newButtonWithTitle:(NSString*)title andSelector:(SEL)selector {
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [button.layer setCornerRadius:5.f];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}


#pragma mask ---- getter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        [_tableView.layer setBorderWidth:1.5];
        [_tableView.layer setBorderColor:[UIColor orangeColor].CGColor];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
    }
    return _tableView;
}

- (UIButton *)btnSearchDevice {
    if (_btnSearchDevice == nil) {
        _btnSearchDevice = [self newButtonWithTitle:@"搜索设备" andSelector:@selector(searchDevicesOnButton:)];
    }
    return _btnSearchDevice;
}
- (UIButton *)btnConnectDevice {
    if (_btnConnectDevice == nil) {
        _btnConnectDevice = [self newButtonWithTitle:@"连接设备" andSelector:@selector(connectDeviceOnButton:)];
    }
    return _btnConnectDevice;
}
- (UIButton *)btnDisconnectDevice {
    if (_btnDisconnectDevice == nil) {
        _btnDisconnectDevice = [self newButtonWithTitle:@"断开设备" andSelector:@selector(disConnectDeviceOnButton:)];
    }
    return _btnDisconnectDevice;
}
- (UIButton *)btnRereadSN {
    if (_btnRereadSN == nil) {
        _btnRereadSN = [self newButtonWithTitle:@"读取SN" andSelector:@selector(rereadDeviceSNOnButton:)];
    }
    return _btnRereadSN;
}
- (UIButton *)btnWriteMainKey {
    if (_btnWriteMainKey == nil) {
        _btnWriteMainKey = [self newButtonWithTitle:@"写主密钥" andSelector:@selector(writeDeviceMainKeyOnButton:)];
    }
    return _btnWriteMainKey;
}
- (UIButton *)btnWriteWorkKey {
    if (_btnWriteWorkKey == nil) {
        _btnWriteWorkKey = [self newButtonWithTitle:@"写工作密钥" andSelector:@selector(writeDeviceWorkKeyOnButton:)];
    }
    return _btnWriteWorkKey;
}
- (UIButton *)btnSwipeCard {
    if (_btnSwipeCard == nil) {
        _btnWriteWorkKey = [self newButtonWithTitle:@"刷卡" andSelector:@selector(swipeCardOnButton:)];
    }
    return _btnSwipeCard;
}


@end
