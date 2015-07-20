//
//  DeviceSignInViewController.m
//  JLPay
//
//  Created by jielian on 15/7/13.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "DeviceSignInViewController.h"
#import "Define_Header.h"
#import "TCP/TcpClientService.h"
#import "Unpacking8583.h"
#import "GroupPackage8583.h"
#import "Toast+UIView.h"
#import "JLActivity.h"
#import "DeviceManager.h"

@interface DeviceSignInViewController()<wallDelegate,managerToCard,DeviceManagerDelegate,UITableViewDataSource,UITableViewDelegate
                                        /*,UIPickerViewDataSource, UIPickerViewDelegate*/>
@property (nonatomic, strong) NSArray* SNVersionNums;                // SN号列表
@property (nonatomic, strong) NSArray* terminalNums;                // 终端号列表
@property (nonatomic, strong) JLActivity* activitor;                // 捷联通商标转轮
@property (nonatomic, strong) NSString* selectedTerminalNum;        // 已选择的终端号:设置到本地,交易时读取
@property (nonatomic, strong) NSString* selectedSNVersionNum;       // 已选择的设备SN号
@property (nonatomic, strong) UIButton* sureButton;                 // “确定”按钮
//@property (nonatomic, strong) UIButton* refreshButton;              // “刷新”按钮
@property (nonatomic, strong) UITableView* tableView;               // 设备列表的表视图
@property (nonatomic, strong) NSTimer*  waitingTimer;               // 等待超时时间
@end


@implementation DeviceSignInViewController

@synthesize SNVersionNums = _SNVersionNums;
@synthesize activitor = _activitor;
@synthesize tableView = _tableView;
@synthesize sureButton = _sureButton;
//@synthesize refreshButton = _refreshButton;
@synthesize waitingTimer;
@synthesize selectedTerminalNum;

#pragma mask ::: 主视图加载
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绑定机具";
    [self.view addSubview:self.sureButton];
    [self.view addSubview:self.tableView];
//    [self.view addSubview:self.refreshButton];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self setExtraCellLineHidden:self.tableView];
    [self.view addSubview:self.activitor];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    // 刷新按钮
    frame.origin.y += frame.size.height + inset*2;
    frame.size.height = buttonHeight;
//    self.refreshButton.frame = frame;
    // 绑定按钮
//    frame.origin.y += frame.size.height + inset;
    self.sureButton.frame = frame;
    
    
    // 检查设备是否已经签到 - 签到了就重置已选择终端号
    self.selectedTerminalNum = nil;
    self.selectedSNVersionNum = nil;
    [[DeviceManager sharedInstance] setDelegate:self];
    
    // 将绑定设备的ID设置为空,让后台设备扫描能扫所有设备
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:DeviceIDOfBinded];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadData];
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.sureButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.sureButton addTarget:self action:@selector(buttonTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
    [self.sureButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
//    [self.refreshButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
//    [self.refreshButton addTarget:self action:@selector(buttonTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
//    [self.refreshButton addTarget:self action:@selector(buttonClickedToRefresh:) forControlEvents:UIControlEventTouchUpInside];

    // 重新打开所有设备
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[DeviceManager sharedInstance] startScanningDevices];
    });
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 在界面退出后控制器可能会被释放,所以要将 delegate 置空
    [[DeviceManager sharedInstance] stopScanningDevices];
    [[DeviceManager sharedInstance] closeAllDevices];
    [[DeviceManager sharedInstance] setDelegate:nil];
    if ([self.waitingTimer isValid]) {
        [self.waitingTimer invalidate];
        self.waitingTimer = nil;
    }
}

#pragma mask ------------------------------ 表视图 delegate & dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;
    if (section == 0) {
        if (self.terminalNums.count == 0) {
            rows = 1;
        } else {
            rows = self.terminalNums.count;
        }
    } else if (section == 1) {
        if (self.SNVersionNums.count == 0) {
            rows = 1;
        } else {
            
            rows = self.SNVersionNums.count;
        }
    }
    return rows;
}

// pragma mask ::: 装载终端编号单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* identifier = @"tableViewCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
    }
    if (indexPath.section == 0) { // 加载终端号
        cell.textLabel.text = @"终端编号";
        if ([tableView numberOfRowsInSection:indexPath.section] == 1 &&
            self.terminalNums.count == 0) {
            cell.detailTextLabel.text = @"无";
        } else {
            cell.detailTextLabel.text = [self.terminalNums objectAtIndex:indexPath.row];
            // 如果当前cell 的对应的终端号跟缓存中的终端号一致，就添加标记
            if ([self.selectedTerminalNum isEqualToString:cell.detailTextLabel.text]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    } else if (indexPath.section == 1) { // 加载SN号
        cell.textLabel.text = @"设备SN编号";
        if ([tableView numberOfRowsInSection:indexPath.section] == 1 &&
            self.SNVersionNums.count == 0) {
            cell.detailTextLabel.text = @"无";
        } else {
            NSString* snNum = [[self.SNVersionNums objectAtIndex:indexPath.row] valueForKey:@"SNVersion"];
            cell.detailTextLabel.text = snNum;
            // 如果当前cell 的对应的SN号跟配置中的SN号一致，就添加标记
            if ([self.selectedSNVersionNum isEqualToString:cell.detailTextLabel.text]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    return cell;
}

// pragma mask ::: 设置section 头
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString* headerTitle = @"";
    if (section == 0) {
        headerTitle = @"请选择终端号";
    } else if (section == 1) {
        headerTitle = @"请选择设备";
    }
    return headerTitle;
}


/*
 * pragma mask ::: 点击终端编号对应的单元格
 *  1.显示标记
 *  2.登记已选择的终端号到缓存
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.section == 0) {
            self.selectedTerminalNum = nil;
        }
        else if (indexPath.section == 1) {
            self.selectedSNVersionNum = nil;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if (indexPath.section == 0) {
            self.selectedTerminalNum = cell.detailTextLabel.text;
        } else if (indexPath.section == 1) {
            self.selectedSNVersionNum = cell.detailTextLabel.text;
        }
    }
    // 取消其它的 checkmark 标记
    for (int i = 0; i < [tableView numberOfRowsInSection:indexPath.section]; i++) {
        NSIndexPath* otherIndex = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
        UITableViewCell* otherCell = [tableView cellForRowAtIndexPath:otherIndex];
        if (otherIndex.row != indexPath.row && otherCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            otherCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}


#pragma mask : -------------  DeviceManagerDelegate

// 设备管理器读到终端号变更后的回调--更新列表
- (void)deviceManager:(DeviceManager *)deviceManager updatedSNVersionArray:(NSArray *)SNVersionArray {
    if (SNVersionArray != nil) {
        self.SNVersionNums = SNVersionArray;
    } else {
        self.SNVersionNums = [[NSArray alloc] init];
    }
    // 更新终端号列表后就刷新列表
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.SNVersionNums.count > 0) {
            if ([self.waitingTimer isValid]) {
                [self.waitingTimer invalidate];
                self.waitingTimer = nil;
            }
            [self.activitor stopAnimating];
        }
        [self.tableView reloadData];
    });
}
// 设置主密钥的回调
- (void)deviceManager:(DeviceManager *)deviceManager didWriteMainKeySuccessOrNot:(BOOL)yesOrNot withMessage:(NSString *)msg {
        // 主密钥下载成功了就继续签到
        dispatch_async(dispatch_get_main_queue(), ^{
            if (yesOrNot) {
            [[TcpClientService getInstance] sendOrderMethod:[GroupPackage8583 signIn]
                                                         IP:Current_IP
                                                       PORT:Current_Port
                                                   Delegate:self
                                                     method:@"tcpsignin"];
            } else {
                [self.activitor stopAnimating];
                [self alertForMessage:@"绑定设备失败!"];
            }
        });
}
// 设置工作密钥的回调
- (void)deviceManager:(DeviceManager *)deviceManager didWriteWorkKeySuccessOrNot:(BOOL)yesOrNot {
    // 停止等待转轮
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activitor stopAnimating];
    });
    if (yesOrNot) {
        // 保存已绑定设备的信息到本地列表
        [self saveBindedDevice];
        [self alertForMessage:@"绑定设备成功!"];
    } else {
        [self alertForMessage:@"绑定设备失败!"];
    }
}



#pragma mask : -------------  wallDelegate: 本模块用到了“签到”+"主密钥下载"
// 成功接收到数据
- (void)receiveGetData:(NSString *)data method:(NSString *)str {
    if (![str isEqualToString:@"tcpsignin"] && ![str isEqualToString:@"downloadMainKey"]) {
        return;
    }
    if ([data length] > 0) {
        // 拆包
        [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activitor stopAnimating];
            [self alertForMessage:@"连接设备失败:签到失败"];
        });
    }
}
// 接收数据失败
- (void)falseReceiveGetDataMethod:(NSString *)str {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activitor stopAnimating];
    });
    [self alertForMessage:@"连接设备失败:签到失败"];
}
// 拆包结果的回调方法
- (void)managerToCardState:(NSString *)type isSuccess:(BOOL)state method:(NSString *)metStr {
    if (![metStr isEqualToString:@"tcpsignin"] && ![metStr isEqualToString:@"downloadMainKey"]) return;
    if (state) {    // 成功
        // 先判断设备是否连接
        int connectedState = [[DeviceManager sharedInstance] isConnectedOnSNVersionNum:self.selectedSNVersionNum];
        if (connectedState == 1) { // 已连接
            if ([metStr isEqualToString:@"downloadMainKey"]) {  // 下载主密钥
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [[DeviceManager sharedInstance] writeMainKey:[PublicInformation signinPin] onSNVersion:self.selectedSNVersionNum];
                });
            }
            else if ([metStr isEqualToString:@"tcpsignin"]) {   // 下载工作密钥
                // 更新批次号 returnSignSort -> Get_Sort_Number
                NSString* signSort = [PublicInformation returnSignSort];
                int intSignSort = [signSort intValue] + 1;
                if (intSignSort > 999999) {
                    intSignSort = 1;
                }
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%06d", intSignSort] forKey:Get_Sort_Number];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // 写工作密钥 ----- 到了这里就可以直接写了
                NSString* workStr = [[NSUserDefaults standardUserDefaults] objectForKey:WorkKey];
                NSLog(@"工作密钥: [%@]", workStr);
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [[DeviceManager sharedInstance] writeWorkKey:workStr onSNVersion:self.selectedSNVersionNum];
                });
            }
        } else {
            [self.activitor stopAnimating];
            [self alertForMessage:@"设备未连接"];
            if (connectedState == 0) { // 如果设备已识别，但未连接，进行连接
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [[DeviceManager sharedInstance] openDevice:self.selectedSNVersionNum];
                });
            }
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activitor stopAnimating];
        });
        [self alertForMessage:@"连接设备失败:签到报文解析失败"];
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
    button.highlighted = NO;
    button.transform = CGAffineTransformIdentity;

    NSLog(@"点击了确定按钮");
    // 设置选择的终端号到本地配置 并签到
    if (self.selectedTerminalNum == nil) {
        [self alertForMessage:@"请选择终端号"];
        return;
    }
    if (self.selectedSNVersionNum == nil) {
        [self alertForMessage:@"请选择设备SN号"];
        return;
    }
    
    // 保存已选择的终端号/SN号到本地
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedSNVersionNum forKey:SelectedSNVersionNum];
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedTerminalNum forKey:Terminal_Number];
    // 下载主密钥 -- 需要判断设备是否连接
    int beingConnect = [[DeviceManager sharedInstance] isConnectedOnSNVersionNum:self.selectedSNVersionNum];
    if (beingConnect == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TcpClientService getInstance] sendOrderMethod:[GroupPackage8583 downloadMainKey]
                                                         IP:Current_IP
                                                       PORT:Current_Port
                                                   Delegate:self
                                                     method:@"downloadMainKey"];
            [self.activitor startAnimating];
        });
    } else {
        [self alertForMessage:@"设备未连接"];
    }
    
}
/*
 * 1.打开所有已识别但未打开的设备
 */
//- (IBAction) buttonClickedToRefresh:(id)sender {
//    UIButton* button = (UIButton*)sender;
//    button.highlighted = NO;
//    button.transform = CGAffineTransformIdentity;
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//        });
//    });
//}


// 按钮按下事件
- (IBAction) buttonTouchDown:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformMakeScale(0.98, 0.98);
    button.highlighted = YES;
}
// 按钮抬起在外部
- (IBAction) buttonTouchUpOutSide:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformIdentity;
    button.highlighted = NO;
}


// 小工具: 为简化弹窗代码
- (void) alertForMessage: (NSString*) messageStr {
    UIAlertView* alert  = [[UIAlertView alloc] initWithTitle:@"提示" message:messageStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

// pragma mask ::: 去掉多余的单元格的分割线
- (void) setExtraCellLineHidden: (UITableView*)tableView {
    UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}


// 保存绑定的设备到本地
- (void) saveBindedDevice {
    // 最开始是维护的一个列表:现在不是列表了,只保留一个节点
    NSMutableArray* deviceList = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:BindedDeviceList]];
    NSString* identifier = nil;
    for (NSDictionary* dataDic in self.SNVersionNums) {
        if ([self.selectedSNVersionNum isEqualToString:[dataDic valueForKey:@"SNVersion"]]) {
            identifier = [dataDic valueForKey:@"identifier"];
            break;
        }
    }
    // 如果本地列表中已经有了旧的绑定设备信息，就更新；否则新建
    NSMutableDictionary* hasDevice = nil;
    for (NSMutableDictionary* dataDic in deviceList) {
        NSString* SNVersion = [dataDic valueForKey:@"SNVersion"];
        if ([SNVersion isEqualToString:self.selectedSNVersionNum]) {
            hasDevice = [NSMutableDictionary dictionaryWithDictionary:dataDic];
            break;
        }
    }
    if (hasDevice != nil) {
        [hasDevice setValue:self.selectedTerminalNum forKey:@"terminalNum"];
        [hasDevice setValue:identifier forKey:@"identifier"];
    } else {
        [deviceList removeAllObjects];  // 先清空列表;因为只能保留一个节点
        /*
         * 字典包含4个元素:
         * 1.设备类型
         * 2.终端号
         * 3.设备SN号
         * 4.蓝牙设备 identifier
         */
        NSDictionary* dic = [[NSMutableDictionary alloc] init];
        NSString* deviceType = [[NSUserDefaults standardUserDefaults] valueForKey:DeviceType];
        [dic setValue:deviceType forKey:DeviceType];
        [dic setValue:self.selectedSNVersionNum forKey:@"SNVersion"];
        [dic setValue:self.selectedTerminalNum forKey:@"terminalNum"];
        [dic setValue:identifier forKey:@"identifier"];
        [deviceList addObject:dic];
    }
    // 一旦设置了 DeviceIDOfBinded ，再扫描设备时，就只尝试打开这个id的设备了
    [[NSUserDefaults standardUserDefaults] setValue:identifier forKey:DeviceIDOfBinded];
    // list 中只有一个节点
    [[NSUserDefaults standardUserDefaults] setObject:deviceList forKey:BindedDeviceList];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 超时后解除转轮，并输出错误信息
- (void) waitingTimeoutWithMsg {
    if ([self.activitor isAnimating]) {
        [self.activitor stopAnimating];
    }
    [self alertForMessage:@"设备连接超时"];
    [self.waitingTimer invalidate];
    self.waitingTimer = nil;
}

#pragma mask ::: getter & setter
- (NSArray *)SNVersionNums {
    if (_SNVersionNums == nil) {
        _SNVersionNums = [[NSArray alloc] init];
    }
    return _SNVersionNums;
}
- (NSArray *)terminalNums {
    if (_terminalNums == nil) {
        _terminalNums = [[NSUserDefaults standardUserDefaults] valueForKey:Terminal_Numbers];
    }
    return _terminalNums;
}
- (JLActivity *)activitor {
    if (_activitor == nil) {
        _activitor = [[JLActivity alloc] init];
    }
    return _activitor;
}
- (UIButton *)sureButton {
    if (_sureButton == nil) {
        _sureButton = [[UIButton alloc] init];
        [_sureButton setTitle:@"绑定" forState:UIControlStateNormal];
        _sureButton.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:69.0/255.0 blue:75.0/255.0 alpha:1.0];
        _sureButton.layer.cornerRadius = 8.0;
    }
    return _sureButton;
}
//- (UIButton *)refreshButton {
//    if (_refreshButton == nil) {
//        _refreshButton = [[UIButton alloc] init];
//        [_refreshButton setTitle:@"刷新列表" forState:UIControlStateNormal];
//        _refreshButton.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:69.0/255.0 blue:75.0/255.0 alpha:1.0];
//        _refreshButton.layer.cornerRadius = 8.0;
//    }
//    return _refreshButton;
//}
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.layer.borderWidth = 0.5;
        _tableView.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:0.5].CGColor;
    }
    return _tableView;
}


@end

