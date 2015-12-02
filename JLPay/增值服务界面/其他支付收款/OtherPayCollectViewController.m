//
//  OtherPayCollectViewController.m
//  JLPay
//
//  Created by jielian on 15/10/30.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "OtherPayCollectViewController.h"
#import "QRCodeButtonView.h"
#import "PublicInformation.h"
#import "Packing8583.h"
#import "TcpClientService.h"
#import "EncodeString.h"
#import "Define_Header.h"
#import "QRCodeViewController.h"
#import "CodeScannerViewController.h"

@interface OtherPayCollectViewController()<UITextFieldDelegate, QRCodeButtonViewDelegate>
{
    NSString* QRCodeName;
    NSString* barCodeName;
}

@property (nonatomic, strong) UITextField* fieldMoneyInput;
@property (nonatomic, strong) QRCodeButtonView* btnViewRQCodeDisplay;
@property (nonatomic, strong) QRCodeButtonView* btnViewRQCodeScan;

@end



@implementation OtherPayCollectViewController

#pragma mask ---- UITextFieldDelegate
/* 检测并控制金额输入 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL enable = NO;
    if ([string isEqualToString:@"\n"]) { // 回车键:隐藏键盘
        [textField resignFirstResponder];
        enable = NO;
    }
    else if ([string length] == 0) { // 删除键:
        enable = YES;
    }
    else if ([self isValidOfNumberString:string]) { // 检查是否为金额有效键
        NSRange dotRange = [textField.text rangeOfString:@"."];
        if (dotRange.length > 0) { // 已经有小数点
            // 只有当前输入为纯数字且未满2位小数时,有效
            if (![string isEqualToString:@"."] && (textField.text.length - dotRange.location - dotRange.length < 2)) {
                enable = YES;
            }
        } else { // 无小数点
            enable = YES;
        }
    }
    return enable;
}
/* 重置金额的显示 */
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length > 0) {
        CGFloat floatManey = [textField.text floatValue];
        textField.text = [NSString stringWithFormat:@"%.02lf",floatManey];
    }
}




#pragma mask ---- QRCodeButtonViewDelegate
/* 点击了二维码/条码按钮 */
- (void)didSelectedView:(QRCodeButtonView *)QRCodeView {
    // 检查输入
    if (self.fieldMoneyInput.text.length == 0 || self.fieldMoneyInput.text.floatValue == 0.0) {
        [self alertWithMessage:@"请输入金额!"];
        return;
    }
    if ([QRCodeView.title isEqualToString:@"二维码"]) {
        // 跳转到二维码生成界面去生成二维码
        [self pushToVCQRCode];
    }
    else if ([QRCodeView.title isEqualToString:@"扫一扫"]) {
        // 跳转到条码扫描界面
        [self pushToVCBarCode];
    }
}
/* 跳转到二维码显示界面 */
- (void) pushToVCQRCode {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QRCodeViewController* vc = [storyBoard instantiateViewControllerWithIdentifier:@"QRCodeVC"];
    vc.payCollectType = self.payCollectType;
    vc.money = [NSString stringWithFormat:@"%.02lf", [self.fieldMoneyInput.text floatValue]];
    [self.navigationController pushViewController:vc animated:YES];
}
/* 跳转到扫一扫条码界面 */
- (void) pushToVCBarCode {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CodeScannerViewController* vc = [storyBoard instantiateViewControllerWithIdentifier:@"codeScannerVC"];
    vc.payCollectType = self.payCollectType;
    vc.money = [NSString stringWithFormat:@"%.02lf", [self.fieldMoneyInput.text floatValue]];
    [self.navigationController pushViewController:vc animated:YES];
}







#pragma mask ---- PRIVATE INTERFACE
/* 左视图: 金额输入框 */
- (UILabel*) leftViewLabelInFrame:(CGRect)frame {
    CGRect inFrame = frame;
    inFrame.size.width /= 3.0;
    inFrame.origin.x = 0;
    inFrame.origin.y = 0;
    UILabel* label = [[UILabel alloc] initWithFrame:inFrame];
    label.text = @"收款金额:";
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}
/* 检查是否全有效的金额输入键值 */
- (BOOL) isValidOfNumberString:(NSString*)string {
    BOOL isValid = YES;
    NSRange range = NSMakeRange(0, 1);
    NSArray* numberArray = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"."];
    for (int i = 0; i < string.length; i++) {
        range.location = i;
        if (![numberArray containsObject:[string substringWithRange:range]]) {
            isValid = NO;
            break;
        }
    }
    return isValid;
}


/* 封装alert */
- (void) alertWithMessage:(NSString*)message {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}


#pragma mask ---- 界面生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    QRCodeName = @"QRCodeImage";
    barCodeName = @"BarCodeImage";
    [self setTitle:self.payCollectType];
    [self.view addSubview:self.fieldMoneyInput];
    [self.view addSubview:self.btnViewRQCodeDisplay];
    [self.view addSubview:self.btnViewRQCodeScan];
    [self.fieldMoneyInput becomeFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat labelWidth = self.view.frame.size.width;
    CGFloat labelHeight = 40;
    CGFloat btnHeight = 130;
    CGFloat btnWidth = self.view.frame.size.width / 2.0;
    CGFloat inset = 20;
    
    CGRect frame = CGRectMake(0, [PublicInformation heightOfNavigationAndStatusInVC:self] + inset*2, labelWidth, labelHeight);
    [self.fieldMoneyInput setFrame:frame];
    [self.fieldMoneyInput setLeftView:[self leftViewLabelInFrame:frame]];
    [self.fieldMoneyInput setLeftViewMode:UITextFieldViewModeAlways];
    
    frame.origin.y += frame.size.height + inset;
    frame.size.width = btnWidth;
    frame.size.height = btnHeight;
    [self.btnViewRQCodeDisplay setFrame:frame];
    
    frame.origin.x += frame.size.width;
    [self.btnViewRQCodeScan setFrame:frame];
    
    UIBarButtonItem* backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(backToLastViewController)];
    [self.navigationItem setBackBarButtonItem:backBarButton];

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.fieldMoneyInput isFirstResponder]) {
        [self.fieldMoneyInput resignFirstResponder];
    }
}
- (void) backToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mask ---- getter
- (UITextField *)fieldMoneyInput {
    if (_fieldMoneyInput == nil) {
        _fieldMoneyInput = [[UITextField alloc] initWithFrame:CGRectZero];
        _fieldMoneyInput.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:0.5].CGColor;
        _fieldMoneyInput.layer.borderWidth = 0.28;
        [_fieldMoneyInput setPlaceholder:@"请输入收款金额"];
        _fieldMoneyInput.textColor = [UIColor blueColor];
        [_fieldMoneyInput setDelegate:self];
        [_fieldMoneyInput setClearButtonMode:UITextFieldViewModeWhileEditing];
        _fieldMoneyInput.keyboardType = UIKeyboardTypeDecimalPad;
    }
    return _fieldMoneyInput;
}
- (QRCodeButtonView *)btnViewRQCodeDisplay {
    if (_btnViewRQCodeDisplay == nil) {
        _btnViewRQCodeDisplay = [[QRCodeButtonView alloc] initWithFrame:CGRectZero];
        [_btnViewRQCodeDisplay setBackgroundColor:[UIColor colorWithRed:47.0/255.0 green:53.0/255.0 blue:61.0/255.0 alpha:1]];
        [_btnViewRQCodeDisplay setDelegate:self];
        [_btnViewRQCodeDisplay setTitle:@"二维码"];
        [_btnViewRQCodeDisplay setImage:[UIImage imageNamed:QRCodeName]];
    }
    return _btnViewRQCodeDisplay;
}
- (QRCodeButtonView *)btnViewRQCodeScan {
    if (_btnViewRQCodeScan == nil) {
        _btnViewRQCodeScan = [[QRCodeButtonView alloc] initWithFrame:CGRectZero];
        [_btnViewRQCodeScan setBackgroundColor:[UIColor colorWithRed:47.0/255.0 green:53.0/255.0 blue:61.0/255.0 alpha:1]];
        [_btnViewRQCodeScan setDelegate:self];
        [_btnViewRQCodeScan setTitle:@"扫一扫"];
        [_btnViewRQCodeScan setImage:[UIImage imageNamed:barCodeName]];
    }
    return _btnViewRQCodeScan;
}

#pragma mask ---- setter
- (void)setPayCollectType:(NSString *)payCollectType {
    _payCollectType = payCollectType;
    self.title = _payCollectType;
}
@end
