//
//  TerminalParamSetViewController.m
//  JLPay
//
//  Created by jielian on 15/4/1.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "TerminalParamSetViewController.h"

/*
 * --------- 设置终端号、商户号
 */

//static const char *PosLib_GetStr(NSString *str)
//{
//    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//    NSData *data=[str dataUsingEncoding: enc];
//    return (const char *)[data bytes];
//}

@interface TerminalParamSetViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic)  UILabel*     businessNumLabel;
@property (strong, nonatomic)  UILabel*     terminalNumLabel;
@property (strong, nonatomic)  UITextField *bussinessNumTextField;
@property (strong, nonatomic)  UITextField *terminalNumTextField;
@property (strong, nonatomic)  UIButton*    btnSetBussinessNum;
@property (strong, nonatomic)  UIButton*    btnSetTerminalNum;
@property (nonatomic, strong)  UITableView* devicesTableView;
@property (nonatomic, strong)  NSMutableArray* deviceArray;
@end

@implementation TerminalParamSetViewController
@synthesize bussinessNumTextField = _bussinessNumTextField;
@synthesize terminalNumTextField = _terminalNumTextField;
@synthesize btnSetTerminalNum = _btnSetTerminalNum;
@synthesize btnSetBussinessNum = _btnSetBussinessNum;
@synthesize devicesTableView = _devicesTableView;
@synthesize businessNumLabel = _businessNumLabel;
@synthesize terminalNumLabel = _terminalNumLabel;
@synthesize deviceArray = _deviceArray;



// section 个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
// rows in section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.deviceArray.count == 0) {
        return 1;
    }
    return self.deviceArray.count;
}
// 加载表格单元
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"deviceSN_Cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"设备%d", (int)indexPath.row + 1];
    if (self.deviceArray.count == 0) {
        cell.detailTextLabel.text = @"无";
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"SN:%@", [self.deviceArray objectAtIndex:indexPath.row]];
    }
    return cell;
}
// 点击了表格 - 连接设备
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}






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


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设备参数设置";
    [self.view addSubview:self.businessNumLabel];
    [self.view addSubview:self.terminalNumLabel];
    [self.view addSubview:self.bussinessNumTextField];
    [self.view addSubview:self.terminalNumTextField];
    [self.view addSubview:self.btnSetBussinessNum];
    [self.view addSubview:self.btnSetTerminalNum];
    [self.view addSubview:self.devicesTableView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self hideTabBar];
    // 重置子视图的frame
    CGFloat inset = 10.0;
    CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.origin.y = self.navigationController.navigationBar.bounds.size.height +
                     [[UIApplication sharedApplication] statusBarFrame].size.height + inset;
    frame.size.width = self.view.bounds.size.width / 4.0;
    frame.size.height = 30;
    
    self.businessNumLabel.frame = frame;
    frame.origin.x += frame.size.width;
    frame.size.width *= 2.0;
    
    self.bussinessNumTextField.frame = frame;
    frame.origin.x += frame.size.width + inset;
    frame.size.width = self.view.bounds.size.width - frame.origin.x - inset;
    
    self.btnSetBussinessNum.frame = frame;
    frame.origin.x = 0;
    frame.origin.y += frame.size.height + inset;
    frame.size.width = self.view.bounds.size.width / 4.0;
    
    self.terminalNumLabel.frame = frame;
    frame.origin.x += frame.size.width;
    frame.size.width *= 2.0;

    self.terminalNumTextField.frame = frame;
    frame.origin.x += frame.size.width + inset;
    frame.size.width = self.view.bounds.size.width - frame.origin.x - inset;

    self.btnSetTerminalNum.frame = frame;
    frame.origin.x = 0;
    frame.origin.y += frame.size.height + inset * 2.0;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = self.view.bounds.size.height - frame.origin.y - 50/* bottomInset */;
    
    self.devicesTableView.frame = frame;
    
    
}

// 设置各个事件
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.tabBarController.tabBar.hidden = NO;
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
        _bussinessNumTextField.layer.cornerRadius = 8.0;
        _bussinessNumTextField.layer.masksToBounds = YES;
    }
    return _bussinessNumTextField;
}
// 终端号文本框
- (UITextField *)terminalNumTextField {
    if (_terminalNumTextField == nil) {
        _terminalNumTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _terminalNumTextField.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _terminalNumTextField.layer.borderWidth = 0.5;
        _terminalNumTextField.layer.cornerRadius = 8.0;
        _terminalNumTextField.layer.masksToBounds = YES;
    }
    return _terminalNumTextField;
}
// 设置商户号的按钮
- (UIButton *)btnSetBussinessNum {
    if (_btnSetBussinessNum == nil) {
        _btnSetBussinessNum = [[UIButton alloc] initWithFrame:CGRectZero];
        _btnSetBussinessNum.layer.cornerRadius = 8.0;
        _btnSetBussinessNum.layer.masksToBounds = YES;
        [_btnSetBussinessNum setTitle:@"设置" forState:UIControlStateNormal];
        _btnSetBussinessNum.backgroundColor = [UIColor greenColor];
    }
    return _btnSetBussinessNum;
}
// 设置终端号的按钮
- (UIButton *)btnSetTerminalNum {
    if (_btnSetTerminalNum == nil) {
        _btnSetTerminalNum = [[UIButton alloc] initWithFrame:CGRectZero];
        _btnSetTerminalNum.layer.cornerRadius = 8.0;
        _btnSetTerminalNum.layer.masksToBounds = YES;
        [_btnSetTerminalNum setTitle:@"设置" forState:UIControlStateNormal];
        _btnSetTerminalNum.backgroundColor = [UIColor greenColor];
    }
    return _btnSetTerminalNum;

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
- (NSMutableArray *)deviceArray {
    if (_deviceArray == nil) {
        _deviceArray = [[NSMutableArray alloc] init];
    }
    return _deviceArray;
}

@end
