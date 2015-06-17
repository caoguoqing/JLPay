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
    self.title = @"连接机具";
    NSString* terminalCount = [[NSUserDefaults standardUserDefaults] objectForKey:Terminal_Count];
    if ([terminalCount intValue] > 1) {
        self.terminalNums = [[NSUserDefaults standardUserDefaults] objectForKey:Terminal_Numbers];
    } else {
        self.terminalNums = [NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:Terminal_Number], nil];
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    
    
    // 怎样判断是哪种设备--- 打开方式不同
    
    AppDelegate* delegatte    = (AppDelegate*)[UIApplication sharedApplication].delegate;
    // 先判断设备是否连接
    if ([delegatte.device isConnected]) {
        // 签到
        [[TcpClientService getInstance] sendOrderMethod:[GroupPackage8583 signIn] IP:Current_IP PORT:Current_Port Delegate:self method:@"tcpsignin"];
    } else {
        // 打开设备
        [delegatte.device open];
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
        [[Unpacking8583 getInstance] unpackingSignin:data method:@"tcpsignin" getdelegate:self];
    } else {
        [self.view makeToast:@"签到报文返回空"];
    }
}
// 接收数据失败
- (void)falseReceiveGetDataMethod:(NSString *)str {
    [self.view makeToast:@"签到失败"];
}
// 拆包结果的处理方法
- (void)managerToCardState:(NSString *)type isSuccess:(BOOL)state method:(NSString *)metStr {
    if (![metStr isEqualToString:@"tcpsignin"]) return;
    if (state) {
        AppDelegate* delegatte    = (AppDelegate*)[UIApplication sharedApplication].delegate;
        // 写工作密钥 ----- 到了这里就可以直接写了
//        if ([delegatte.device isConnected]) {       // 设备是连接的就开始写工作密钥
            NSString* workStr = [[NSUserDefaults standardUserDefaults] objectForKey:WorkKey];
            [delegatte.device WriteWorkKey:57 :workStr];
//        } else {                                    // 未连接就打开设备并写卡
//            [delegatte.device open];
//        }
    } else {
        [self.view makeToast:@"签到报文解析失败"];
    }

}




#pragma mask ::: getter & setter 
- (NSArray *)terminalNums {
    if (_terminalNums == nil) {
//        _terminalNums = [[NSUserDefaults standardUserDefaults] objectForKey:Terminal_Numbers];
        _terminalNums = [[NSArray alloc] init];
    }
    return _terminalNums;
}


@end
