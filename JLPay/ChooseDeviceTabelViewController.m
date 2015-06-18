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
    
    
    // 怎样判断是哪种设备--- 打开方式不同
    
    AppDelegate* delegatte    = (AppDelegate*)[UIApplication sharedApplication].delegate;
    // 先判断设备是否连接
    if ([delegatte.device isConnected]) {
        // 签到
        [[TcpClientService getInstance] sendOrderMethod:[GroupPackage8583 signIn] IP:Current_IP PORT:Current_Port Delegate:self method:@"tcpsignin"];
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
        [[app_delegate window] makeToast:@"签到报文返回空"];
    }
}
// 接收数据失败
- (void)falseReceiveGetDataMethod:(NSString *)str {
    [self.view makeToast:@"签到失败"];
}
// 拆包结果的处理方法
- (void)managerToCardState:(NSString *)type isSuccess:(BOOL)state method:(NSString *)metStr {
    if (![metStr isEqualToString:@"tcpsignin"]) return;
    NSLog(@"state=[%hhd], message=[%@]", state, type);
    if (state) {
        NSLog(@"拆包成功");
        AppDelegate* delegatte    = (AppDelegate*)[UIApplication sharedApplication].delegate;
        // 写工作密钥 ----- 到了这里就可以直接写了
        NSString* workStr = [[NSUserDefaults standardUserDefaults] objectForKey:WorkKey];
        NSLog(@"工作密钥: [%@]", workStr);
        [delegatte.device WriteWorkKey:57 :workStr];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[delegatte window] makeToast:@"签到成功"];
        });
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DeviceBeingSignedIn];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[app_delegate window] makeToast:@"连接设备失败:签到报文解析失败"];
        });
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
