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
    BOOL enable = YES;
    return enable;
}
/* 重置金额的显示 */
- (void)textFieldDidEndEditing:(UITextField *)textField {
//    NSInteger lengthOfDots = textField.text.length - ([textField.text rangeOfString:@"."].location + 1);
//    if (![textField.text containsString:@"."] || (lengthOfDots < 2)) {
//        
//    }
    CGFloat floatManey = [textField.text floatValue];
    textField.text = [NSString stringWithFormat:@"%.02lf",floatManey];
}


#pragma mask ---- QRCodeButtonViewDelegate
- (void)didSelectedView:(QRCodeButtonView *)QRCodeView {
    NSLog(@"点击了视图:[%@]",QRCodeView.title);
}



#pragma mask ---- PRIVATE INTERFACE
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




#pragma mask ---- 界面生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    QRCodeName = @"QRCodeImage";
    barCodeName = @"BarCodeImage";
    [self setTitle:self.payCollectType];
    [self.view addSubview:self.fieldMoneyInput];
    [self.view addSubview:self.btnViewRQCodeDisplay];
    [self.view addSubview:self.btnViewRQCodeScan];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat labelWidth = self.view.frame.size.width;
    CGFloat labelHeight = 40;
    CGFloat btnHeight = 130;
    CGFloat btnWidth = self.view.frame.size.width / 2.0;
    CGFloat inset = 30;
    
    CGRect frame = CGRectMake(0, [PublicInformation heightOfNavigationAndStatusInVC:self] + inset, labelWidth, labelHeight);
    [self.fieldMoneyInput setFrame:frame];
    [self.fieldMoneyInput setLeftView:[self leftViewLabelInFrame:frame]];
    [self.fieldMoneyInput setLeftViewMode:UITextFieldViewModeAlways];
    
    
    frame.origin.y += frame.size.height + inset;
    frame.size.width = btnWidth;
    frame.size.height = btnHeight;
    [self.btnViewRQCodeDisplay setFrame:frame];
    
    frame.origin.x += frame.size.width;
    [self.btnViewRQCodeScan setFrame:frame];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}



#pragma mask ---- getter
- (UITextField *)fieldMoneyInput {
    if (_fieldMoneyInput == nil) {
        _fieldMoneyInput = [[UITextField alloc] initWithFrame:CGRectZero];
        _fieldMoneyInput.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:0.5].CGColor;
        _fieldMoneyInput.layer.borderWidth = 0.28;
        [_fieldMoneyInput setPlaceholder:@"请输入收款金额"];
        [_fieldMoneyInput setDelegate:self];
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
