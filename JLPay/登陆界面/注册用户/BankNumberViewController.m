//
//  BankNumberViewController.m
//  JLPay
//
//  Created by jielian on 15/10/19.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "BankNumberViewController.h"
#import "DynamicPickerView.h"
#import "PublicInformation.h"
#import "ASIFormDataRequest.h"
#import "UserRegisterViewController.h"
#import "JLActivitor.h"

@interface BankNumberViewController()<DynamicPickerViewDelegate, ASIHTTPRequestDelegate, UITextFieldDelegate>
{
    CGRect actiFrame;
}
@property (nonatomic, strong) UITextField* bankNameField;
@property (nonatomic, strong) UITextField* branchNameField;
@property (nonatomic, strong) UILabel* bankNameSearchedLabel;
@property (nonatomic, strong) UIButton* searchButton;
@property (nonatomic, strong) DynamicPickerView* pickerView;
@property (nonatomic, strong) ASIFormDataRequest* httpRequest;

@property (nonatomic, strong) NSArray* bankInfos;
@property (nonatomic, assign) int selectedIndex;
@end

@implementation BankNumberViewController


#pragma mask ------ UITextFieldDelegate 
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL enabel = YES;
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        enabel = NO;
    }
    return enabel;
}

#pragma mask ------ 按钮事件组
- (IBAction) touchDown:(UIButton*)sender {
    sender.transform = CGAffineTransformMakeScale(0.95, 0.95);
}
- (IBAction) touchOut:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
}
- (IBAction) touchToSearch:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    // 检查输入
    if (self.bankNameField.text.length == 0) {
        [self alertForMessage:@"未输入银行名"];
        return;
    }
    if (self.branchNameField.text.length == 0) {
        [self alertForMessage:@"未输入分支行关键字"];
        return;
    }
    // HTTP请求
    [self startActivitor];
    [self requestBankInfoWithBankName:self.bankNameField.text andBranchName:self.branchNameField.text];
}

#pragma mask ------ HTTP事件
- (void) requestBankInfoWithBankName:(NSString*)bankName andBranchName:(NSString*)branchName {
    [self.httpRequest addPostValue:bankName forKey:@"bankName"];
    [self.httpRequest addPostValue:branchName forKey:@"branchName"];
    [self.httpRequest startAsynchronous];
}



#pragma mask ------ DynamicPickerViewDelegate
- (void)pickerView:(DynamicPickerView *)pickerView didPickedRow:(NSInteger)row atComponent:(NSInteger)component {
    self.selectedIndex = row;
    NSDictionary* bankInfo = [self.bankInfos objectAtIndex:row];
    [self.searchButton setTitle:[bankInfo valueForKey:@"openstlNo"] forState:UIControlStateNormal];
}
#pragma mask ------ ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    [request clearDelegatesAndCancel];
    [self stopActivitor];
    NSData* data = [request responseData];
    NSError* error;
    NSDictionary* responseInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    self.httpRequest = nil;
    self.bankInfos = [responseInfo objectForKey:@"bankList"];
    NSMutableArray* bankNums = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in self.bankInfos) {
        [bankNums addObject:[dict valueForKey:@"bankName"]];
    }
    if (bankNums.count == 0) {
        [self alertForMessage:@"查询到的银行列表为空,请重新输入并查询"];
    } else {
        CGRect frame = CGRectMake(0,//self.searchButton.frame.origin.x,
                                  self.searchButton.frame.origin.y + self.searchButton.frame.size.height + 10,
                                  self.view.frame.size.width,
                                  40+180);
        [self loadPickerViewInFrame:frame withDatas:bankNums];
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request {
    [request clearDelegatesAndCancel];
    [self stopActivitor];
    self.httpRequest = nil;
    [self alertForMessage:@"查询联行号失败:网络异常"];
}


#pragma mask ------ 加载pickerView
- (void) loadPickerViewInFrame:(CGRect)frame withDatas:(NSArray*)datas {
    [self.pickerView clearDatas];
    [self.pickerView setFontSize:10];
    [self.pickerView setDatas:datas atComponent:0];
    [self.pickerView setFrame:frame];
    [self.pickerView show];
}


#pragma mask ------ 确定并回退场景
- (void) popVCWithSearchedBankNum {
    // 检查输入
    if (self.selectedIndex < 0) {
        [self alertForMessage:@"未选择开户行联行号,请先选择!"];
        return;
    }
    // 跳转界面
    NSDictionary* bankInfo = [self.bankInfos objectAtIndex:self.selectedIndex];
    [self.navigationController popViewControllerAnimated:YES];
    UserRegisterViewController* registerVC = (UserRegisterViewController*)[self.navigationController topViewController];
    [registerVC setBankNum:[bankInfo valueForKey:@"openstlNo"] forBankName:[bankInfo valueForKey:@"bankName"]];
}

#pragma mask ------ 界面声明周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.bankNameField];
    [self.view addSubview:self.branchNameField];
    [self.view addSubview:self.searchButton];
    [self.view addSubview:self.pickerView];
    
    self.selectedIndex = -1;
    
    UIBarButtonItem* doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(popVCWithSearchedBankNum)];
    self.navigationItem.rightBarButtonItem = doneItem;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat insetHorizantal = 15;
    CGFloat insetVertical = 10;
    CGFloat mustInputWidth = 8;
    CGFloat fieldWidth = self.view.frame.size.width - insetHorizantal*2 - mustInputWidth;
    CGFloat viewHeight = 40;
    CGFloat statesNaviHeight = [PublicInformation returnStatusHeight] + self.navigationController.navigationBar.frame.size.height;
    
    actiFrame = CGRectMake(0, statesNaviHeight, self.view.frame.size.width, self.view.frame.size.height - statesNaviHeight);
    CGRect frame = CGRectMake(insetHorizantal, statesNaviHeight + insetVertical, mustInputWidth, viewHeight);
    [self.view addSubview:[self mustInputLabelInFrame:frame]];
    
    frame.origin.x += frame.size.width;
    frame.size.width = fieldWidth;
    [self.bankNameField setFrame:frame];
    
    frame.origin.x = insetHorizantal;
    frame.origin.y += frame.size.height + insetVertical;
    frame.size.width = mustInputWidth;
    [self.view addSubview:[self mustInputLabelInFrame:frame]];
    
    frame.origin.x += frame.size.width;
    frame.size.width = fieldWidth;
    [self.branchNameField setFrame:frame];

    frame.origin.x = insetHorizantal;
    frame.origin.y += frame.size.height + insetVertical*2;
    frame.size.width = self.view.frame.size.width - insetHorizantal*2;
    [self.searchButton setFrame:frame];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.httpRequest clearDelegatesAndCancel ];
    self.httpRequest = nil;
}
- (UILabel*) mustInputLabelInFrame:(CGRect)frame {
    UILabel* mustInputLabel = [[UILabel alloc] initWithFrame:frame];
    mustInputLabel.text = @"*";
    mustInputLabel.textColor = [PublicInformation returnCommonAppColor:@"red"];
    mustInputLabel.textAlignment = NSTextAlignmentLeft;
    return mustInputLabel;
}

/* 简化代码 */
- (void) alertForMessage:(NSString*)msg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}
- (void) startActivitor {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[JLActivitor sharedInstance] startAnimatingInFrame:actiFrame];
    });
}
- (void) stopActivitor {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[JLActivitor sharedInstance] stopAnimating];
    });
}

#pragma mask ---- getter
- (UITextField *)bankNameField {
    if (_bankNameField == nil) {
        _bankNameField = [[UITextField alloc] initWithFrame:CGRectZero];
        _bankNameField.placeholder = @"请输入开户行银行名称(非全称)";
        [_bankNameField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)]];
        [_bankNameField setLeftViewMode:UITextFieldViewModeAlways];
        [_bankNameField setClearButtonMode:UITextFieldViewModeWhileEditing];
        _bankNameField.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _bankNameField.layer.borderWidth = 1.0;
        [_bankNameField setDelegate:self];
    }
    return _bankNameField;
}
- (UITextField *)branchNameField {
    if (_branchNameField == nil) {
        _branchNameField = [[UITextField alloc] initWithFrame:CGRectZero];
        _branchNameField.placeholder = @"请输入分支行关键字";
        [_branchNameField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)]];
        [_branchNameField setLeftViewMode:UITextFieldViewModeAlways];
        [_branchNameField setClearButtonMode:UITextFieldViewModeWhileEditing];
        _branchNameField.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _branchNameField.layer.borderWidth = 1.0;
        [_branchNameField setDelegate:self];
    }
    return _branchNameField;
}
- (UIButton *)searchButton {
    if (_searchButton == nil) {
        _searchButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _searchButton.backgroundColor = [PublicInformation returnCommonAppColor:@"red"];
        [_searchButton setTitle:@"查询联行号" forState:UIControlStateNormal];
        [_searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _searchButton.layer.cornerRadius = 5.0;
        
        [_searchButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_searchButton addTarget:self action:@selector(touchOut:) forControlEvents:UIControlEventTouchUpOutside];
        [_searchButton addTarget:self action:@selector(touchToSearch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}
- (DynamicPickerView *)pickerView {
    if (_pickerView == nil) {
        _pickerView = [[DynamicPickerView alloc] initWithFrame:CGRectZero];
        [_pickerView setDelegate:self];
    }
    return _pickerView;
}
- (ASIFormDataRequest *)httpRequest {
    if (_httpRequest == nil) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/getOpenBankNo",[PublicInformation getDataSourceIP],[PublicInformation getDataSourcePort]];
        _httpRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
        [_httpRequest setDelegate:self];
    }
    return _httpRequest;
}
@end
