//
//  ChooseDeviceTabelViewController.m
//  JLPay
//
//  Created by jielian on 15/6/17.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "ChooseDeviceTabelViewController.h"
#import "Define_Header.h"
#import "TCP/TcpClientService.h"
#import "Unpacking8583.h"
#import "GroupPackage8583.h"
#import "Toast+UIView.h"
#import "JLActivity.h"
#import "DeviceManager.h"


@interface ChooseDeviceTabelViewController()<wallDelegate,managerToCard,DeviceManagerDelegate>
@property (nonatomic, strong) NSArray* terminalNums;
@property (nonatomic, strong) JLActivity* activitor;
@property (nonatomic, strong) NSString* selectedTerminalNum;
@property (nonatomic, strong) NSString* selectedBusinessNum;
@end


@implementation ChooseDeviceTabelViewController
@synthesize terminalNums = _terminalNums;
@synthesize activitor = _activitor;
@synthesize selectedTerminalNum;
@synthesize selectedBusinessNum;

#pragma mask ::: 主视图加载
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.activitor];
    self.title = @"绑定机具";
    
    // 注册写工作密钥的结果通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(workKeyWritingSuccNote:) name:Noti_WorkKeyWriting_Success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(workKeyWritingFailNote:) name:Noti_WorkKeyWriting_Fail object:nil];
    
    [[DeviceManager sharedInstance] setDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 重置终端号的缓存
    NSString* terminalNum = [[NSUserDefaults standardUserDefaults] valueForKey:SelectedTerminalNum];
    if (terminalNum != nil) {
        self.selectedTerminalNum = terminalNum;
    } else {
        self.selectedTerminalNum = nil;
    }
    
    
    // 在后台识别,并连接所有可以连接的设备.....
    
    // 先屏蔽掉音频设备:因为接口还不支持读取终端号
    [[DeviceManager sharedInstance] openAllDevices];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[DeviceManager sharedInstance] setDelegate:nil];
}


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
        rows = 1;
    }
    return rows;
}

#pragma mask ::: 装载终端编号单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"terminalNoCell"];
        cell.textLabel.text = @"终端编号";
        if ([tableView numberOfRowsInSection:indexPath.section] == 1 &&
            self.terminalNums.count == 0) {
            cell.detailTextLabel.text = @"无";
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            NSString* terNumAndBusinessNum = [self.terminalNums objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [terNumAndBusinessNum substringToIndex:8];
            // 如果当前cell 的对应的终端号跟配置中的终端号一致，就添加标记
            if ([self.selectedTerminalNum isEqualToString:cell.detailTextLabel.text]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"buttonDoneCell"];
    }
    return cell;
}

#pragma mask ::: 设置section 头
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"终端列表";
    } else {
        return nil;
    }
}


#pragma mask ::: 点击终端编号对应的单元格
/*
 * 1.显示标记
 * 2.登记已选择的终端号到缓存
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        NSString* terminalNo = cell.detailTextLabel.text;
        cell.selected = NO;
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            self.selectedTerminalNum = @"无";
            self.selectedBusinessNum = nil;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.selectedTerminalNum = terminalNo;
        }
        // 取消其它的 checkmark 标记
        for (int i = 0; i < [tableView numberOfRowsInSection:indexPath.section]; i++) {
            NSIndexPath* otherIndex = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
            UITableViewCell* otherCell = [tableView cellForRowAtIndexPath:otherIndex];
            if (otherIndex.row != indexPath.row && otherCell.accessoryType == UITableViewCellAccessoryCheckmark) {
                otherCell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
    } else if (indexPath.section == 1) {
        // 点击事件产生在 buttonClicked 中
    }
}


#pragma mask : -------------  DeviceManagerDelegate
// 设备管理器读到终端号变更后的回调--更新列表
- (void)deviceManager:(DeviceManager *)deviceManager updatedTerminalArray:(NSArray *)terminalArray {
    if (terminalArray != nil) {
        self.terminalNums = terminalArray;
    } else {
        self.terminalNums = [[NSArray alloc] init];
    }
    // 更新终端号列表后就刷新列表
    [self.tableView reloadData];
}
// 设置工作密钥的回调
- (void)deviceManager:(DeviceManager *)deviceManager didWriteWorkKeySuccessOrNot:(BOOL)yesOrNot {
    if (yesOrNot) {
        [self alertForMessage:@"绑定设备成功!"];
    } else {
        [self alertForMessage:@"绑定设备失败!"];
    }
}



#pragma mask : -------------  wallDelegate
// 成功接收到数据
- (void)receiveGetData:(NSString *)data method:(NSString *)str {
    if (![str isEqualToString:@"tcpsignin"]) {
        return;
    }
    if ([data length] > 0) {
        // 拆包
        NSLog(@"开始拆包: 签到返回");
        [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.activitor isAnimating]) {
                [self.activitor stopAnimating];
            }
            [self alertForMessage:@"绑定失败:签到报文返回空"];
        });
    }
}
// 接收数据失败
- (void)falseReceiveGetDataMethod:(NSString *)str {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.activitor isAnimating]) {
            [self.activitor stopAnimating];
        }
        [self alertForMessage:@"连接设备失败:签到失败"];
    });
}
// 拆包结果的处理方法
- (void)managerToCardState:(NSString *)type isSuccess:(BOOL)state method:(NSString *)metStr {
    if (![metStr isEqualToString:@"tcpsignin"]) return;
    if (state) {    // 签到成功
        // 更新批次号 returnSignSort -> Get_Sort_Number
        NSString* signSort = [PublicInformation returnSignSort];
        int intSignSort = [signSort intValue] + 1;
        if (intSignSort > 999999) {
            intSignSort = 1;
        }
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%06d", intSignSort] forKey:Get_Sort_Number];
        
        // 写工作密钥 ----- 到了这里就可以直接写了
        NSString* workStr = [[NSUserDefaults standardUserDefaults] objectForKey:WorkKey];
        NSLog(@"工作密钥: [%@]", workStr);
        if ([[DeviceManager sharedInstance] isConnectedOnTerminalNum:self.selectedTerminalNum]) {
//            [self alertForMessage:@"签到成功,可以写工作密钥了"];
//            [[DeviceManager sharedInstance] WriteWorkKey:57 :workStr];
            NSLog(@"--------1");
            [[DeviceManager sharedInstance] writeWorkKey:workStr onTerminal:self.selectedTerminalNum];
        } else {
            [self alertForMessage:@"设备未连接"];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.activitor isAnimating]) {
                [self.activitor stopAnimating];
            }
            [self alertForMessage:@"连接设备失败:签到报文解析失败"];
        });
    }
}


#pragma mask ::: 确定按钮 的点击事件
- (IBAction) buttonClicked:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.highlighted = NO;

    NSLog(@"点击了确定按钮");
    // 设置选择的终端号到本地配置 并签到
    if (self.selectedTerminalNum != nil &&
        ![self.selectedTerminalNum isEqualToString:@"无"]) {
        NSArray* terminalArray = [[NSUserDefaults standardUserDefaults] valueForKey:Terminal_Numbers];
        if (terminalArray.count == 0 || terminalArray == nil) {
            [self alertForMessage:[NSString stringWithFormat:@"商户无此终端号:[%@]", self.selectedTerminalNum]];
        } else {
            // 判断选择的终端号是否在商户的服务端终端号列表中
            BOOL compared = NO;
            for (NSString* terNo in terminalArray) {
                if ([terNo isEqualToString:self.selectedTerminalNum]) {
                    compared = YES;
                    break;
                }
            }
            if (compared) {
                // 提取商户号
                for (NSString* terBusiNum in self.terminalNums) {
                    if ([[terBusiNum substringToIndex:8] isEqualToString:self.selectedTerminalNum]) {
                        [[NSUserDefaults standardUserDefaults] setObject:[terBusiNum substringFromIndex:8] forKey:Business_Number];
                    }
                }
                // 终端号合法 - 设置终端号到本地
                [[NSUserDefaults standardUserDefaults] setObject:self.selectedTerminalNum forKey:Terminal_Number];
                // 进行签到 -- 需要判断设备是否连接
                if ([[DeviceManager sharedInstance] isConnectedOnTerminalNum:self.selectedTerminalNum]) {
                    [[TcpClientService getInstance] sendOrderMethod:[GroupPackage8583 signIn]
                                                                 IP:Current_IP
                                                               PORT:Current_Port
                                                           Delegate:self
                                                             method:@"tcpsignin"];
                } else {
                    [self alertForMessage:@"设备未连接"];
                }
            } else {
                // 终端号不合法
                [self alertForMessage:[NSString stringWithFormat:@"商户无此终端号:[%@]", self.selectedTerminalNum]];
            }
        }
        
    } else {
        [self alertForMessage:@"未选择设备"];
    }

}
- (IBAction) buttonTouchDown:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.highlighted = YES;
}
- (IBAction) buttonTouchUpOutSide:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.highlighted = NO;
}

#pragma mask ::: 写工作密钥结果的通知处理
- (void) workKeyWritingSuccNote: (NSNotification*)noti {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.activitor isAnimating]) {
            [self.activitor stopAnimating];
        }
        [self alertForMessage:@"绑定设备成功"];
    });
    // 保存设备签到标志到本地;供刷卡时读取
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DeviceBeingSignedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void) workKeyWritingFailNote: (NSNotification*)noti {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.activitor isAnimating]) {
            [self.activitor stopAnimating];
        }
        [self alertForMessage:@"绑定设备失败:写工作密钥失败"];
    });
}

// 小工具: 为简化弹窗代码
- (void) alertForMessage: (NSString*) messageStr {
    UIAlertView* alert  = [[UIAlertView alloc] initWithTitle:@"提示" message:messageStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}


#pragma mask ::: getter & setter 
- (NSArray *)terminalNums {
    if (_terminalNums == nil) {
        _terminalNums = [[NSArray alloc] init];
    }
    return _terminalNums;
}
- (JLActivity *)activitor {
    if (_activitor == nil) {
        _activitor = [[JLActivity alloc] init];
    }
    return _activitor;
}


@end
