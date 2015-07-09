//
//  TerminalParamSetViewController.m
//  JLPay
//
//  Created by jielian on 15/4/1.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "TerminalParamSetViewController.h"
#import "DeviceManager.h"
#import "Define_Header.h"
#import "TCP/TcpClientService.h"
#import "GroupPackage8583.h"
#import "Unpacking8583.h"
#import "Toast+UIView.h"

/*
 * --------- 设置终端号、商户号
 */

//static const char *PosLib_GetStr(NSString *str)
//{
//    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//    NSData *data=[str dataUsingEncoding: enc];
//    return (const char *)[data bytes];
//}

@interface TerminalParamSetViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,DeviceManagerDelegate,UIActionSheetDelegate, wallDelegate,managerToCard>

@property (strong, nonatomic)  UILabel*     businessNumLabel;
@property (strong, nonatomic)  UILabel*     terminalNumLabel;
@property (strong, nonatomic)  UITextField *bussinessNumTextField;
@property (strong, nonatomic)  UITextField *terminalNumTextField;
//@property (strong, nonatomic)  UIButton*    btnSetBussinessNum;
@property (strong, nonatomic)  UIButton*    btnSetTerminalNum;
@property (strong, nonatomic)  UIButton*    btnSetMainKey;
@property (nonatomic, strong)  UITableView* devicesTableView;
@property (nonatomic, strong)  NSMutableArray* SNVersionArray;
@property (nonatomic, strong)  NSString*    selectedSNVersion;
@property (nonatomic, strong)  UITableViewCell* lastSelectedCell;
@property (nonatomic, strong)  NSArray*     deviceNameArray;
@end

@implementation TerminalParamSetViewController
@synthesize bussinessNumTextField = _bussinessNumTextField;
@synthesize terminalNumTextField = _terminalNumTextField;
@synthesize btnSetTerminalNum = _btnSetTerminalNum;
//@synthesize btnSetBussinessNum = _btnSetBussinessNum;
@synthesize btnSetMainKey = _btnSetMainKey;
@synthesize devicesTableView = _devicesTableView;
@synthesize businessNumLabel = _businessNumLabel;
@synthesize terminalNumLabel = _terminalNumLabel;
@synthesize SNVersionArray = _SNVersionArray;
@synthesize selectedSNVersion;
@synthesize lastSelectedCell;



// section 个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
// rows in section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 检查设备sn号列表中是否有已选择的sn号,没有就置空
    BOOL hasSelectedSN = NO;
    for (NSString* sn in self.SNVersionArray) {
        if ([sn isEqualToString:self.selectedSNVersion]) {
            hasSelectedSN = YES;
        }
    }
    if (!hasSelectedSN) {
        self.selectedSNVersion = nil;
    }
    if (self.SNVersionArray.count == 0) {
        return 1;
    }
    return self.SNVersionArray.count;
}
// 加载表格单元
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* identifier = @"deviceSN_Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"设备%d SN:", (int)indexPath.row + 1];
    if (self.SNVersionArray.count == 0) {
        cell.detailTextLabel.text = @"无";
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.detailTextLabel.text = [self.SNVersionArray objectAtIndex:indexPath.row];
        if ([cell.detailTextLabel.text isEqualToString:self.selectedSNVersion]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}
// 点击了表格 - 连接设备
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"点击了cell[%d]",indexPath.row);
    if (![cell.detailTextLabel.text isEqualToString:@"无"]) {
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else { // == UITableViewCellAccessoryCheckmark
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (self.lastSelectedCell != nil) {
            self.lastSelectedCell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            self.selectedSNVersion = cell.detailTextLabel.text;
            self.lastSelectedCell = cell;
        } else {
            self.selectedSNVersion = nil;
            self.lastSelectedCell = nil;
        }

    } 
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
// 显示section header
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"设备列表";
    }
    return nil;
}


// uiactionSheet 的选项点击回调
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"点击了actionSheet的按钮[%d]:[%@]", buttonIndex,[actionSheet buttonTitleAtIndex:buttonIndex]);
    NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"取消"]) { // M60
        
    } else if ([buttonTitle isEqualToString:DeviceType_JHL_M60]) { // M60
        [[NSUserDefaults standardUserDefaults] setObject:DeviceType_JHL_M60 forKey:DeviceType];
        [[DeviceManager sharedInstance] openAllDevices];
        [DeviceManager sharedInstance].delegate = self;
    }
}

#pragma mask -------------------------- DeviceManager 的回调
- (void)deviceManager:(DeviceManager *)deviceManager updatedSNVersionArray:(NSArray *)SNVersionArray {
    [self.SNVersionArray removeAllObjects];
    if (SNVersionArray.count > 0) {
        [self.SNVersionArray addObjectsFromArray:SNVersionArray];
    }
    NSLog(@"回调:更新了sn列表:[%@]", self.SNVersionArray);
    [self.devicesTableView reloadData];
}
// 设置终端号+商户号的回调
- (void)deviceManager:(DeviceManager *)deviceManager didWriteTerminalSuccessOrNot:(BOOL)yesOrNot withMessage:(NSString *)msg {
    if (yesOrNot) {
        [self alertForMessage:@"终端号+商户号设置成功!"];
        // 成功就将终端号+商户号设置到本地
        [[NSUserDefaults standardUserDefaults] setValue:self.bussinessNumTextField.text forKey:Business_Number];
        [[NSUserDefaults standardUserDefaults] setValue:self.terminalNumTextField.text forKey:Terminal_Number];
    } else {
        [self alertForMessage:msg];
    }
}
// 设置主密钥的回调
- (void)deviceManager:(DeviceManager *)deviceManager didWriteMainKeySuccessOrNot:(BOOL)yesOrNot withMessage:(NSString *)msg {
    if (yesOrNot) {
        [self alertForMessage:@"主密钥设置成功"];
    } else {
        [self alertForMessage:msg];
    }
}


#pragma mask --------------------- 分界线

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// 取消键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.bussinessNumTextField resignFirstResponder];
    [self.terminalNumTextField resignFirstResponder];
}
// 开始编辑文本框
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}
// 编辑文本框结束
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    self.view.frame = frame;
}
- (void)keyboardHide:(NSNotification *)notf
{
    NSLog(@"1111");

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==self.bussinessNumTextField) {
        [self.bussinessNumTextField resignFirstResponder];
        [self.terminalNumTextField becomeFirstResponder];
    } else if(textField==self.terminalNumTextField) {
        [self.terminalNumTextField resignFirstResponder];
    }
    return YES;
}

// 完成按钮的点击事件
- (IBAction)goSave:(id)sender
{
    [self.bussinessNumTextField resignFirstResponder];
    [self.terminalNumTextField resignFirstResponder];
    
    if ([self.bussinessNumTextField.text length] > 15) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的商户号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([self.terminalNumTextField.text length] > 8) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入正确的终端号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardShow:(NSNotification *)notf
{
    NSDictionary *userInfo = notf.userInfo;
    
    CGRect keyboardFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];
    
    CGRect textFrame = self.bussinessNumTextField.frame;
    
    if (CGRectGetMaxY(textFrame) >= CGRectGetMinY(keyboardFrame)) {
        
        CGFloat y = CGRectGetMinY(keyboardFrame) - CGRectGetMaxY(textFrame);
        CGRect frame = self.view.frame;
        frame.origin.y = y;
        
        self.view.frame = frame;
    }
}

- (void)hideTabBar {
    if (self.tabBarController.tabBar.hidden == YES) {
        return;
    }
    UIView *contentView;
    if ( [[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    else
        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    contentView.frame = CGRectMake(contentView.bounds.origin.x,  contentView.bounds.origin.y,  contentView.bounds.size.width, contentView.bounds.size.height + self.tabBarController.tabBar.frame.size.height);
    self.tabBarController.tabBar.hidden = YES;
    
}

#pragma mask ----------------------- 按钮点击事件

// 点击开始设置终端号
- (IBAction) btnOnSettingTerminalNum:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformIdentity;
    button.highlighted = NO;
    if (self.selectedSNVersion == nil) {
        [self alertForMessage:@"请选择设备"];
        return;
    }
    if (![[DeviceManager sharedInstance] isConnectedOnSNVersionNum:self.selectedSNVersion]) {
        [self alertForMessage:@"请先连接设备"];
        return;
    }
    if (self.bussinessNumTextField.text == nil || [self.bussinessNumTextField.text length] == 0) {
        [self alertForMessage:@"请输入商户号"];
        return;
    }
    if (self.terminalNumTextField.text == nil || [self.terminalNumTextField.text length] == 0) {
        [self alertForMessage:@"请输入终端号"];
        return;
    }
    if ([self.terminalNumTextField.text length] != 8) {
        [self alertForMessage:@"终端号位数不为8!"];
        return;
    }
    if ([self.bussinessNumTextField.text length] != 15) {
        [self alertForMessage:@"商户号位数不为15!"];
    }
    // 开始写终端号
    NSString* terminalNumAndBusinessNum = [self.terminalNumTextField.text stringByAppendingString:self.bussinessNumTextField.text];
    NSLog(@"开始写终端号+商户号:[%@]",terminalNumAndBusinessNum);
    [[DeviceManager sharedInstance] writeTerminalNum:terminalNumAndBusinessNum onSNVersion:self.selectedSNVersion];
}


// 点击开始设置主密钥
- (IBAction) btnOnSettingMainKey:(id)sender {
    NSLog(@"开始设置主密钥...");
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformIdentity;
    button.highlighted = NO;
    if (self.selectedSNVersion == nil) {
        [self alertForMessage:@"请选择设备"];
        return;
    }
    if (![[DeviceManager sharedInstance] isConnectedOnSNVersionNum:self.selectedSNVersion]) {
        [self alertForMessage:@"请先连接设备"];
        return;
    }

    
    [[TcpClientService getInstance] sendOrderMethod:[GroupPackage8583 downloadMainKey] IP:Current_IP PORT:Current_Port Delegate:self method:@"downloadMainKey"];

}

- (IBAction) btnDown:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformMakeScale(0.98, 0.98);
    button.highlighted = YES;
}
- (IBAction) btnUpOutSide:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformIdentity;
    button.highlighted = NO;
}

#pragma mask ----------------------- wallDelegate
// 接收主密钥的返回报文
- (void)receiveGetData:(NSString *)data method:(NSString *)str {
    if ([str isEqualToString:@"downloadMainKey"]) {
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
        } else {
            [self alertForMessage:@"获取主密钥数据失败"];
        }
    }
}
// 主密钥下载响应失败
-(void)falseReceiveGetDataMethod:(NSString *)str {
    [self alertForMessage:@"网络异常,下载主密钥失败"];
}


#pragma mask ----------------------- managedToCard 拆包的回调
- (void)managerToCardState:(NSString *)type isSuccess:(BOOL)state method:(NSString *)metStr {
    if ([metStr isEqualToString:@"downloadMainKey"]) {
        if (state) {
            NSString* mainKey = [PublicInformation signinPin];
            [[app_delegate window] makeToast:[NSString stringWithFormat:@"获取主密钥[%@]成功", mainKey]];
            // 可以向设备中写了
            [[DeviceManager sharedInstance] writeMainKey:mainKey onSNVersion:self.selectedSNVersion];
        } else {
            [self alertForMessage:@"获取主密钥数据失败"];
        }
    }
}


#pragma mask ----------------------- 界面生命周期的处理
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"参数设置";
    self.selectedSNVersion = nil;
    self.lastSelectedCell = nil;
    self.deviceNameArray = [[NSArray alloc] initWithObjects:DeviceType_JHL_M60, nil];
    self.devicesTableView.dataSource = self;
    self.devicesTableView.delegate = self;
    // 加载子视图
    [self.view addSubview:self.businessNumLabel];
    [self.view addSubview:self.terminalNumLabel];
    [self.view addSubview:self.bussinessNumTextField];
    [self.view addSubview:self.terminalNumTextField];
    [self.view addSubview:self.btnSetMainKey];
    [self.view addSubview:self.btnSetTerminalNum];
    [self.view addSubview:self.devicesTableView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self hideTabBar];
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
    }

    // 重置子视图的frame
    // 商户号标签
    CGFloat inset = 10.0;
    CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.origin.y = self.navigationController.navigationBar.bounds.size.height +
                     [[UIApplication sharedApplication] statusBarFrame].size.height + inset;
    frame.size.width = self.view.bounds.size.width / 4.0;
    frame.size.height = 30;
    self.businessNumLabel.frame = frame;
    
    // 商户号输入框
    frame.origin.x += frame.size.width;
    frame.size.width = self.view.bounds.size.width/4.0 * 3.0 - inset;
    self.bussinessNumTextField.frame = frame;
    
    // 终端号标签
    frame.origin.x = 0;
    frame.origin.y += frame.size.height + inset;
    frame.size.width = self.view.bounds.size.width / 4.0;
    self.terminalNumLabel.frame = frame;
    
    // 终端号输入框
    frame.origin.x += frame.size.width;
    frame.size.width = self.view.bounds.size.width/4.0 * 3.0 - inset;
    self.terminalNumTextField.frame = frame;

    // 设备列表视图
    frame.origin.x = 0;
    frame.origin.y += frame.size.height + inset * 2.0;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = self.view.bounds.size.height/2.5/* bottomInset */;
    self.devicesTableView.frame = frame;
    
    // 设置终端号+商户号按钮
    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset;
    frame.size.width = self.view.bounds.size.width - inset * 2;
    frame.size.height = 50;
    self.btnSetTerminalNum.frame = frame;
    
    // 设置主密钥按钮
    frame.origin.y += frame.size.height + inset;
    self.btnSetMainKey.frame = frame;
}

// 设置各个事件
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 弹窗提示要选择设备类型
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择设备类型"
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil, nil];
    for (int i = 0; i < self.deviceNameArray.count; i++) {
        [actionSheet addButtonWithTitle:[self.deviceNameArray objectAtIndex:i]];
    }
    [actionSheet showFromToolbar:self.navigationController.toolbar];
    
    
    // 设置终端号+商户号的按钮事件
    [self.btnSetTerminalNum addTarget:self action:@selector(btnOnSettingTerminalNum:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnSetTerminalNum addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchDown];
    [self.btnSetTerminalNum addTarget:self action:@selector(btnUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
    
    // 设置主密钥设置的按钮事件
    [self.btnSetMainKey addTarget:self action:@selector(btnOnSettingMainKey:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnSetMainKey addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchDown];
    [self.btnSetMainKey addTarget:self action:@selector(btnUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.tabBarController.tabBar.hidden = NO;
    [[DeviceManager sharedInstance] setDelegate:nil];
}


// 错误弹窗
- (void) alertForMessage:(NSString*)msg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}


#pragma mask -------------- setter && getter
// 商户号
- (UILabel *)businessNumLabel {
    if (_businessNumLabel == nil) {
        _businessNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _businessNumLabel.text = @"商户号";
        _businessNumLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _businessNumLabel;
}
// 终端号
- (UILabel *)terminalNumLabel {
    if (_terminalNumLabel == nil) {
        _terminalNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _terminalNumLabel.text = @"终端号";
        _terminalNumLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _terminalNumLabel;
}
// 商户号文本框
- (UITextField *)bussinessNumTextField {
    if (_bussinessNumTextField == nil) {
        _bussinessNumTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _bussinessNumTextField.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _bussinessNumTextField.layer.borderWidth = 0.5;
        _bussinessNumTextField.layer.cornerRadius = 5.0;
        _bussinessNumTextField.layer.masksToBounds = YES;
        _bussinessNumTextField.placeholder = @"请输入15位商户号";
    }
    return _bussinessNumTextField;
}
// 终端号文本框
- (UITextField *)terminalNumTextField {
    if (_terminalNumTextField == nil) {
        _terminalNumTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _terminalNumTextField.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _terminalNumTextField.layer.borderWidth = 0.5;
        _terminalNumTextField.layer.cornerRadius = 5.0;
        _terminalNumTextField.layer.masksToBounds = YES;
        _terminalNumTextField.placeholder = @"请输入8位终端号";
    }
    return _terminalNumTextField;
}
// 设置终端号的按钮
- (UIButton *)btnSetTerminalNum {
    if (_btnSetTerminalNum == nil) {
        _btnSetTerminalNum = [[UIButton alloc] initWithFrame:CGRectZero];
        _btnSetTerminalNum.layer.cornerRadius = 8.0;
        _btnSetTerminalNum.layer.masksToBounds = YES;
        [_btnSetTerminalNum setTitle:@"设置终端号/商户号" forState:UIControlStateNormal];
        _btnSetTerminalNum.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:69.0/255.0 blue:75.0/255.0 alpha:1.0];
    }
    return _btnSetTerminalNum;

}
- (UIButton *)btnSetMainKey {
    if (_btnSetMainKey == nil) {
        _btnSetMainKey = [[UIButton alloc] initWithFrame:CGRectZero];
        _btnSetMainKey.layer.cornerRadius = 10.0;
        _btnSetMainKey.layer.masksToBounds = YES;
        [_btnSetMainKey setTitle:@"设置主密钥" forState:UIControlStateNormal];
        _btnSetMainKey.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:69.0/255.0 blue:75.0/255.0 alpha:1.0];
    }
    return _btnSetMainKey;
    
}
// 显示设备列表的表格视图
- (UITableView *)devicesTableView {
    if (_devicesTableView == nil) {
        _devicesTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _devicesTableView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.95];
        _devicesTableView.layer.borderColor = [UIColor grayColor].CGColor;
        _devicesTableView.layer.borderWidth = 0.5;
    }
    return _devicesTableView;
}
// 设备列表
- (NSMutableArray *)SNVersionArray {
    if (_SNVersionArray == nil) {
        _SNVersionArray = [[NSMutableArray alloc] init];
    }
    return _SNVersionArray;
}

@end
