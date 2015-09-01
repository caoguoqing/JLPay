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
#import "JLActivitor.h"
#import "DeviceManager.h"

@interface DeviceSignInViewController()
<
wallDelegate,managerToCard,DeviceManagerDelegate,
UITableViewDataSource,UITableViewDelegate,
UIActionSheetDelegate,UIAlertViewDelegate
>
@property (nonatomic, strong) NSMutableArray* SNVersionNums;        // SN号列表
@property (nonatomic, strong) NSMutableArray* terminalNums;         // 终端号列表
@property (nonatomic, strong) NSString* selectedTerminalNum;        // 终端号:已勾选的
@property (nonatomic, strong) NSString* selectedSNVersionNum;       // SN号:已勾选的
@property (nonatomic, strong) NSString* terminalNumBinded;          // 终端号:已绑定的
@property (nonatomic, strong) NSString* SNVersionNumBinded;         // SN号:已绑定的
@property (nonatomic, strong) UIButton* sureButton;                 // “确定”按钮
@property (nonatomic, strong) UITableView* tableView;               // 设备列表的表视图
@property (nonatomic, strong) NSTimer*  waitingTimer;               // 等待超时时间
@property (nonatomic) CGRect activitorFrame;
@end


@implementation DeviceSignInViewController

@synthesize SNVersionNums = _SNVersionNums;
@synthesize tableView = _tableView;
@synthesize sureButton = _sureButton;
@synthesize waitingTimer;
@synthesize selectedTerminalNum;
@synthesize activitorFrame;
@synthesize terminalNumBinded;
@synthesize SNVersionNumBinded;

#pragma mask ::: 主视图加载
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绑定机具";
    [self.view addSubview:self.sureButton];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self setExtraCellLineHidden:self.tableView];
    
    // 不要放在 viewWillAppear 中
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择设备类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    [actionSheet addButtonWithTitle:DeviceType_JHL_M60];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
    
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat inset = 8;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.bounds.size.height;
    CGFloat tabBarHeignth = self.tabBarController.tabBar.bounds.size.height;
    CGFloat buttonHeight = 50;
    CGFloat tableViewHeight = self.view.bounds.size.height - statusBarHeight - navigationBarHeight - tabBarHeignth - buttonHeight - inset*4;
    self.activitorFrame = CGRectMake(0,
                                     navigationBarHeight + statusBarHeight,
                                     self.view.bounds.size.width,
                                     self.view.bounds.size.height - navigationBarHeight - statusBarHeight - tabBarHeignth);
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
    
    
    // 加载已绑定信息:如果已经绑定过
    NSDictionary* infoBinded = [[NSUserDefaults standardUserDefaults] objectForKey:KeyInfoDictOfBinded];
    if (infoBinded) {
        self.terminalNumBinded = [infoBinded valueForKey:KeyInfoDictOfBindedTerminalNum];
        self.SNVersionNumBinded = [infoBinded valueForKey:KeyInfoDictOfBindedDeviceSNVersion];
        self.selectedTerminalNum = self.terminalNumBinded;
        self.selectedSNVersionNum = self.SNVersionNumBinded;
    }
    
    
    
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"%s",__func__);
    [[JLActivitor sharedInstance] stopAnimating];
    // 在界面退出后控制器可能会被释放,所以要将 delegate 置空
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[DeviceManager sharedInstance] clearAndCloseAllDevices];
    });
    if ([self.waitingTimer isValid]) {
        [self.waitingTimer invalidate];
        self.waitingTimer = nil;
    }
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
        rows = self.terminalNums.count;
    } else if (section == 1) {
        rows = self.SNVersionNums.count;
    }
    return rows;
}
// header height
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
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
        cell.detailTextLabel.text = [self.terminalNums objectAtIndex:indexPath.row];
        
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
        label.text = @"请选择设备";
        label.font = cell.textLabel.font;
        label.textColor = [UIColor colorWithWhite:0.4 alpha:1];
        [headerView addSubview:label];
        // 按钮
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 15 - frame.size.width/4.0, inset, frame.size.width/4.0, frame.size.height - inset*2)];
        [button setTitle:@"搜索" forState:UIControlStateNormal];
        button.titleLabel.font = cell.textLabel.font;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = button.frame.size.height/2.0;
        button.backgroundColor = [PublicInformation returnCommonAppColor:@"red"];
        [button addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(buttonTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [button addTarget:self action:@selector(buttonTouchToOpenDevices:) forControlEvents:UIControlEventTouchUpInside];
        
        [headerView addSubview:button];
        
    }
    return headerView;
}
// pragma mask ::: 设置section 头
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"请选择终端号";
    } else {
        return nil;
    }
}
// pragma mask ::: 设置section 尾
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSMutableString* headerTitle = [[NSMutableString alloc] init];
    if (section == 0) {
        [headerTitle appendString: @"已绑定终端号: "];
        if (self.terminalNumBinded) {
            [headerTitle appendString:self.terminalNumBinded];
        }
    } else if (section == 1) {
        [headerTitle appendString: @"已绑定设备 SN: "];
        if (self.SNVersionNumBinded) {
            [headerTitle appendString:self.SNVersionNumBinded];
        }
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
// SN号读取结果
- (void)didReadSNVersion:(NSString *)SNVersion sucOrFail:(BOOL)yesOrNo withError:(NSString *)error {
    NSLog(@"%s, DeviceSignInViewC didReadSNVersion:%@",__func__, SNVersion);
    if (!yesOrNo) {
        [self alertForMessage:error];
        return;
    }
    if (self.SNVersionNums.count == 1 && [[self.SNVersionNums objectAtIndex:0] isEqualToString:@"无"]) {
        [self.SNVersionNums removeAllObjects];
    }
    [self.SNVersionNums addObject:SNVersion];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
// 设备丢失:SN
- (void)deviceDisconnectOnSNVersion:(NSString *)SNVersion {
    if (SNVersion && [self.SNVersionNums containsObject:SNVersion]) {
        [self.SNVersionNums removeObject:SNVersion];
    }
    if ([self.selectedSNVersionNum isEqualToString:SNVersion]) {
        self.selectedSNVersionNum = nil;
    }
    if (self.SNVersionNums.count == 0) {
        [self.SNVersionNums addObject:@"无"];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
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
                [[JLActivitor sharedInstance] stopAnimating];
                [self alertForMessage:@"绑定设备失败!"];
            }
        });
}
// 设置工作密钥的回调
- (void)deviceManager:(DeviceManager *)deviceManager didWriteWorkKeySuccessOrNot:(BOOL)yesOrNot {
    // 停止等待转轮
    dispatch_async(dispatch_get_main_queue(), ^{
        [[JLActivitor sharedInstance] stopAnimating];
        return;
    });
    if (yesOrNot) {
        // 保存已绑定设备的信息到本地列表
        [self saveBindedDevice];
        // 更新tool显示
        self.terminalNumBinded = self.selectedTerminalNum;
        self.SNVersionNumBinded = self.selectedSNVersionNum;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
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
            [[JLActivitor sharedInstance] stopAnimating];
            [self alertForMessage:@"连接设备失败:签到失败"];
        });
    }
}
// 接收数据失败
- (void)falseReceiveGetDataMethod:(NSString *)str {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[JLActivitor sharedInstance] stopAnimating];
    });
    [self alertForMessage:@"连接设备失败:签到失败"];
}
// 拆包结果的回调方法
- (void)managerToCardState:(NSString *)type isSuccess:(BOOL)state method:(NSString *)metStr {
//    if (![metStr isEqualToString:@"tcpsignin"] && ![metStr isEqualToString:@"downloadMainKey"]) return;
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
            [[JLActivitor sharedInstance] stopAnimating];
            [self alertForMessage:@"设备未连接"];
            if (connectedState == 0) { // 如果设备已识别，但未连接，进行连接
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [[DeviceManager sharedInstance] openDevice:self.selectedSNVersionNum];
                });
            }
        }
    } else { // 失败
        dispatch_async(dispatch_get_main_queue(), ^{
            [[JLActivitor sharedInstance] stopAnimating];
        });
        [self alertForMessage:@"连接设备失败:签到报文解析失败"];
    }
}

#pragma mask ::: UIActionSheetDelegate 点击事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    }
    // 保存选择的设备类型
    NSString* title = [actionSheet buttonTitleAtIndex:buttonIndex];
    [[NSUserDefaults standardUserDefaults] setValue:title forKey:DeviceType];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DeviceManager sharedInstance] setDelegate:self];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        [[DeviceManager sharedInstance] startScanningDevices];
    });
    // 然后等待1s让设备被识别，再连接，连接后会自动读取SN号
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);
        [[DeviceManager sharedInstance] openAllDevices];
    });
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
    [[NSUserDefaults standardUserDefaults] synchronize];
    // 下载主密钥 -- 需要判断设备是否连接
    int beingConnect = [[DeviceManager sharedInstance] isConnectedOnSNVersionNum:self.selectedSNVersionNum];
    if (beingConnect == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TcpClientService getInstance] sendOrderMethod:[GroupPackage8583 downloadMainKey]
                                                         IP:Current_IP
                                                       PORT:Current_Port
                                                   Delegate:self
                                                     method:@"downloadMainKey"];
            [[JLActivitor sharedInstance] startAnimatingInFrame:self.activitorFrame];
        });
    } else {
        [self alertForMessage:@"设备未连接"];
    }
    
}
// 打开设备并读取sn号
- (IBAction) buttonTouchToOpenDevices:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformIdentity;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"打开设备");
        [[DeviceManager sharedInstance] openAllDevices];
    });
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

// 小工具: 为简化弹窗代码
- (void) alertForMessage: (NSString*) messageStr {
    UIAlertView* alert  = [[UIAlertView alloc] initWithTitle:@"提示" message:messageStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.message isEqualToString:@"绑定设备成功!"]) {
        // 绑定成功后就跳转到金额输入界面
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                [self.tabBarController setSelectedViewController:[[self.tabBarController viewControllers] objectAtIndex:0]];
            } completion:nil];
        });
    }
}

// pragma mask ::: 去掉多余的单元格的分割线
- (void) setExtraCellLineHidden: (UITableView*)tableView {
    UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}


// 保存绑定的设备到本地
- (void) saveBindedDevice {
    NSString* identifier = [[DeviceManager sharedInstance] identifierOnDeviceSN:self.selectedSNVersionNum];
    if (!identifier) {
        return;
    }
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    // 先清空配置
    if ([userDefault objectForKey:KeyInfoDictOfBinded]) {
        [userDefault removeObjectForKey:KeyInfoDictOfBinded];
        [userDefault synchronize];
    }
    // 再设置当前选择的信息
    NSMutableDictionary* infoDictWillBeSaved = [[NSMutableDictionary alloc] init];
    [infoDictWillBeSaved setValue:[userDefault valueForKey:DeviceType] forKey:KeyInfoDictOfBindedDeviceType];
    [infoDictWillBeSaved setValue:identifier forKey:KeyInfoDictOfBindedDeviceIdentifier];
    [infoDictWillBeSaved setValue:self.selectedSNVersionNum forKey:KeyInfoDictOfBindedDeviceSNVersion];
    [infoDictWillBeSaved setValue:self.selectedTerminalNum forKey:KeyInfoDictOfBindedTerminalNum];
    [infoDictWillBeSaved setValue:[userDefault valueForKey:Business_Number] forKey:KeyInfoDictOfBindedBussinessNum];
    
    [userDefault setValue:self.selectedTerminalNum forKey:Terminal_Number];
    [userDefault setObject:infoDictWillBeSaved forKey:KeyInfoDictOfBinded];
    [userDefault synchronize];
}

// 超时后解除转轮，并输出错误信息
- (void) waitingTimeoutWithMsg {
    [[JLActivitor sharedInstance] stopAnimating];
    [self alertForMessage:@"设备连接超时"];
    [self.waitingTimer invalidate];
    self.waitingTimer = nil;
}





#pragma mask ::: getter & setter
- (NSMutableArray *)SNVersionNums {
    if (_SNVersionNums == nil) {
        _SNVersionNums = [[NSMutableArray alloc] init];
        [_SNVersionNums addObject:@"无"];
    }
    return _SNVersionNums;
}
- (NSMutableArray *)terminalNums {
    if (_terminalNums == nil) {
        _terminalNums = [[NSMutableArray alloc] init];
        NSArray* terms = [[NSUserDefaults standardUserDefaults] valueForKey:Terminal_Numbers];
        if (!terms || terms.count == 0) {
            [_terminalNums addObject:@"无"];
        } else {
            [_terminalNums addObjectsFromArray:terms];
        }
    }
    return _terminalNums;
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


@end

