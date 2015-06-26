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


@interface ChooseDeviceTabelViewController()<wallDelegate,managerToCard>
@property (nonatomic, strong) NSArray* terminalNums;
@end


@implementation ChooseDeviceTabelViewController
@synthesize terminalNums = _terminalNums;

#pragma mask ::: 主视图加载
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绑定机具";
    NSString* terminalCount = [[NSUserDefaults standardUserDefaults] objectForKey:Terminal_Count];
    
    if ([terminalCount intValue] > 1) {
        self.terminalNums = [[NSUserDefaults standardUserDefaults] objectForKey:Terminal_Numbers];
    } else {
        self.terminalNums = [NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:Terminal_Number], nil];
    }
    
    // 注册写工作密钥的结果通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(workKeyWritingSuccNote:) name:Noti_WorkKeyWriting_Success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(workKeyWritingFailNote:) name:Noti_WorkKeyWriting_Fail object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate* delegatte = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegatte.device open];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString* terminalCount = [[NSUserDefaults standardUserDefaults] objectForKey:Terminal_Count];
    return [terminalCount intValue];
}

#pragma mask ::: 装载终端编号单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"terminalNoCell"];
    cell.textLabel.text = @"终端编号";
    cell.detailTextLabel.text = [self.terminalNums objectAtIndex:indexPath.row];
    return cell;
}

#pragma mask ::: 点击终端编号对应的单元格: 进行签到、写工作密钥
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    [[NSUserDefaults standardUserDefaults] setValue:cell.detailTextLabel.text forKey:Terminal_Number];
    
    // 怎样判断是哪种设备--- 打开方式不同
    
    AppDelegate* delegatte    = (AppDelegate*)[UIApplication sharedApplication].delegate;
    // 先判断设备是否连接
    if ([delegatte.device isConnected]) {
        // 签到 --- 要考虑线程安全--放在主线程发送
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [[TcpClientService getInstance] sendOrderMethod:[GroupPackage8583 signIn]
                                                         IP:Current_IP
                                                       PORT:Current_Port
                                                   Delegate:self
                                                     method:@"tcpsignin"];
//        });
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请连接设备" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        // 打开设备
        [delegatte.device open];        // 在后台打开的
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
            [self alertForMessage:@"绑定失败:签到报文返回空"];
        });
    }
}
// 接收数据失败
- (void)falseReceiveGetDataMethod:(NSString *)str {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self alertForMessage:@"连接设备失败:签到失败"];
    });
}
// 拆包结果的处理方法
- (void)managerToCardState:(NSString *)type isSuccess:(BOOL)state method:(NSString *)metStr {
    if (![metStr isEqualToString:@"tcpsignin"]) return;
    NSLog(@"state=[%hhd], message=[%@]", state, type);
    if (state) {    // 签到成功
        NSLog(@"拆包成功");
        // 更新批次号 returnSignSort -> Get_Sort_Number
        NSString* signSort = [PublicInformation returnSignSort];
        int intSignSort = [signSort intValue] + 1;
        if (intSignSort > 999999) {
            intSignSort = 1;
        }
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%06d", intSignSort] forKey:Get_Sort_Number];
        
        AppDelegate* delegatte    = (AppDelegate*)[UIApplication sharedApplication].delegate;
        // 写工作密钥 ----- 到了这里就可以直接写了
        NSString* workStr = [[NSUserDefaults standardUserDefaults] objectForKey:WorkKey];
        NSLog(@"工作密钥: [%@]", workStr);
        [delegatte.device WriteWorkKey:57 :workStr];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertForMessage:@"连接设备失败:签到报文解析失败"];
        });
    }
}

#pragma mask ::: 写工作密钥结果的通知处理
- (void) workKeyWritingSuccNote: (NSNotification*)noti {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self alertForMessage:@"绑定设备成功"];
    });
    // 保存设备签到标志到本地;供刷卡时读取
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DeviceBeingSignedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void) workKeyWritingFailNote: (NSNotification*)noti {
    dispatch_async(dispatch_get_main_queue(), ^{
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


@end
