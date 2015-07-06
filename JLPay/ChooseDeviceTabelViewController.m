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
@end


@implementation ChooseDeviceTabelViewController
@synthesize terminalNums = _terminalNums;
@synthesize activitor = _activitor;

#pragma mask ::: 主视图加载
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.activitor];
    self.title = @"绑定机具";
//    NSString* terminalCount = [[NSUserDefaults standardUserDefaults] objectForKey:Terminal_Count];
    
//    if ([terminalCount intValue] > 1) {
//        self.terminalNums = [[NSUserDefaults standardUserDefaults] objectForKey:Terminal_Numbers];
//    } else {
//        self.terminalNums = [NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:Terminal_Number], nil];
//    }
    
    
    
    // 注册写工作密钥的结果通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(workKeyWritingSuccNote:) name:Noti_WorkKeyWriting_Success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(workKeyWritingFailNote:) name:Noti_WorkKeyWriting_Fail object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 在后台识别,并连接所有可以连接的设备.....
    
    // 先屏蔽掉音频设备:因为接口还不支持读取终端号
//    AppDelegate* delegatte = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    if (![delegatte.device isConnected]) {
//        [delegatte.device open];
//    }
    DeviceManager* device = [DeviceManager sharedInstance];
//    [device open];
    [device setDelegate:self];
    [device openAllDevices];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSString* terminalCount = [[NSUserDefaults standardUserDefaults] objectForKey:Terminal_Count];
    if (self.terminalNums.count == 0) {
        return 1;
    } else {
        return self.terminalNums.count;
    }
}

#pragma mask ::: 装载终端编号单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"terminalNoCell"];
    cell.textLabel.text = @"终端编号";
    if ([tableView numberOfRowsInSection:indexPath.section] == 1 &&
        self.terminalNums.count == 0) {
        cell.detailTextLabel.text = @"无";
    } else {
        cell.detailTextLabel.text = [self.terminalNums objectAtIndex:indexPath.row];
    }
    
    return cell;
}

#pragma mask ::: 点击终端编号对应的单元格: 进行签到、写工作密钥
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString* terminalNo = cell.detailTextLabel.text;
    cell.selected = NO;
    // 设置选择的终端号到本地配置
    [[NSUserDefaults standardUserDefaults] setValue:terminalNo forKey:Terminal_Number];
    
    // 尝试打开对应终端号的设备
    // [delegatte.device openDeviceOfTerminalNo:terminalNo];
    
    
    // 成功了:::下一步就可以进行签到、写工作密钥了
    
    
    
//    AppDelegate* delegatte    = (AppDelegate*)[UIApplication sharedApplication].delegate;
    // 先判断设备是否连接
    DeviceManager* device = [DeviceManager sharedInstance];
    if ([device isConnected]) {
        // 签到 --- 要考虑线程安全--放在主线程发送
        [[TcpClientService getInstance] sendOrderMethod:[GroupPackage8583 signIn]
                                                     IP:Current_IP
                                                   PORT:Current_Port
                                               Delegate:self
                                                 method:@"tcpsignin"];
        if (![self.activitor isAnimating]) {
            [self.activitor startAnimating];
        }
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请连接设备" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        // 打开设备
//        [delegatte.device open];        // 在后台打开的
    }
}


#pragma mask : -------------  DeviceManagerDelegate
// 设备管理器读到终端号变更后的回调--更新列表
- (void)deviceManager:(DeviceManager *)deviceManager updatedTerminalArray:(NSArray *)terminalArray {
    if (terminalArray != nil) {
        self.terminalNums = terminalArray;
        // 更新终端号列表后就刷新列表
        [self.tableView reloadData];
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
        
//        AppDelegate* delegatte    = (AppDelegate*)[UIApplication sharedApplication].delegate;
        // 写工作密钥 ----- 到了这里就可以直接写了
        NSString* workStr = [[NSUserDefaults standardUserDefaults] objectForKey:WorkKey];
        NSLog(@"工作密钥: [%@]", workStr);
        [[DeviceManager sharedInstance] WriteWorkKey:57 :workStr];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.activitor isAnimating]) {
                [self.activitor stopAnimating];
            }
            [self alertForMessage:@"连接设备失败:签到报文解析失败"];
        });
    }
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
