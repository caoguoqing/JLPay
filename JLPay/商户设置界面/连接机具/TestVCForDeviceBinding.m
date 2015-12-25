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
}
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIButton* btnSearchDevice;    // 搜索设备
@property (nonatomic, strong) UIButton* btnDisconnectDevice; // 断开设备
@property (nonatomic, strong) UIButton* btnConnectDevice; // 连接设备

@end

@implementation TestVCForDeviceBinding

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        deviceSNList = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubviews];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    CGFloat heightButton = 30;
    CGFloat widthButton = (self.view.frame.size.width - insetWidth*3)/2.0;
    
    CGRect frame = CGRectMake(0, heightStatus + heightNavigation, self.view.frame.size.width, heightValid/2.0);
    [self.tableView setFrame:frame];
    [self.view addSubview:self.tableView];
    
    frame.origin.x += insetWidth;
    frame.origin.y += frame.size.height + insetHeight;
    frame.size.width = widthButton;
    frame.size.height = heightButton;
    [self.btnConnectDevice setFrame:frame];
    [self.view addSubview:self.btnConnectDevice];
    
    frame.origin.x += frame.size.width + insetWidth;
    [self.btnDisconnectDevice setFrame:frame];
    [self.view addSubview:self.btnDisconnectDevice];
    
    frame.origin.x = 0 + insetWidth;
    frame.origin.y += frame.size.height + insetHeight;
    [self.btnSearchDevice setFrame:frame];
    [self.view addSubview:self.btnSearchDevice];
    
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
    if (cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell.textLabel setText:[self SNVersionAtIndex:indexPath.row]];
    return cell;
}
#pragma mask ---- UITableViewDelegate

#pragma mask ---- BLEDeviceManagerTYDelegate
- (void)didConnectedDeviceSucOnSN:(NSString *)SNVersion {
    [self addDeviceSN:SNVersion];
    [self.tableView reloadData];
}

#pragma mask ---- 按钮事件组
//
- (IBAction) searchDevicesOnButton:(UIButton*)sender {
    [[BLEDeviceManagerTY sharedInstance] connectAllDevices];
}
//
- (IBAction) connectDeviceOnButton:(UIButton*)sender {
    
}
//
- (IBAction) disConnectDeviceOnButton:(UIButton*)sender {
    
}



#pragma mask ---- PRIVATE INTERFACE

/* 设备SN组相关 */
- (void) addDeviceSN:(NSString*)SNVersion {
    [deviceSNList addObject:SNVersion];
}
- (void) deleteDeviceSN:(NSString*)SNVersion {
    [deviceSNList removeObject:SNVersion];
}
- (void) clearDeviceSNList {
    [deviceSNList removeAllObjects];
}
- (NSString*) SNVersionAtIndex:(NSInteger)index {
    return [deviceSNList objectAtIndex:index];
}



#pragma mask ---- getter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
    }
    return _tableView;
}

- (UIButton *)btnSearchDevice {
    if (_btnSearchDevice == nil) {
        _btnSearchDevice = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnSearchDevice setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        [_btnSearchDevice setTitle:@"搜索设备" forState:UIControlStateNormal];
        [_btnSearchDevice setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnSearchDevice setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_btnSearchDevice setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_btnSearchDevice.layer setCornerRadius:5.f];
        [_btnSearchDevice addTarget:self action:@selector(searchDevicesOnButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSearchDevice;
}
- (UIButton *)btnConnectDevice {
    if (_btnConnectDevice == nil) {
        _btnConnectDevice = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnConnectDevice setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        [_btnConnectDevice setTitle:@"连接设备" forState:UIControlStateNormal];
        [_btnConnectDevice setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnConnectDevice setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_btnConnectDevice setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_btnConnectDevice.layer setCornerRadius:5.f];
        [_btnSearchDevice addTarget:self action:@selector(connectDeviceOnButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnConnectDevice;
}
- (UIButton *)btnDisconnectDevice {
    if (_btnDisconnectDevice == nil) {
        _btnDisconnectDevice = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnDisconnectDevice setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        [_btnDisconnectDevice setTitle:@"断开设备" forState:UIControlStateNormal];
        [_btnDisconnectDevice setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnDisconnectDevice setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_btnDisconnectDevice setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_btnDisconnectDevice.layer setCornerRadius:5.f];
        [_btnSearchDevice addTarget:self action:@selector(disConnectDeviceOnButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnDisconnectDevice;
}



@end
