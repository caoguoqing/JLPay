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
#import "QRCodeViewController.h"
#import "CodeScannerViewController.h"
#import "MBProgressHUD+CustomSate.h"
#import "VMOtherPayType.h"
#import "Masonry.h"


@interface OtherPayCollectViewController()<UITextFieldDelegate, QRCodeButtonViewDelegate>

@property (nonatomic, strong) UIImageView* moneyImageView;
@property (nonatomic, strong) UIImageView* goodsImageView;
@property (nonatomic, strong) UILabel* moneyLabel;
@property (nonatomic, strong) UITextField* goodsTextField;

@property (nonatomic, strong) QRCodeButtonView* btnViewRQCodeDisplay;
@property (nonatomic, strong) QRCodeButtonView* btnViewRQCodeScan;

@end



@implementation OtherPayCollectViewController

#pragma mask ---- UITextFieldDelegate
/* 检测并控制金额输入 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
        if ([string isEqualToString:@"\n"]) { // 回车键:隐藏键盘
            [textField resignFirstResponder];
        }
        return YES;
}


#pragma mask ---- QRCodeButtonViewDelegate
/* 点击了二维码/条码按钮 */
- (void)didSelectedView:(QRCodeButtonView *)QRCodeView {
    // 检查输入
    if (!self.goodsTextField.text || self.goodsTextField.text.length == 0) {
        [MBProgressHUD showWarnWithText:@"请输入商品名称!" andDetailText:nil onCompletion:nil];
        return;
    }
    
    if ([QRCodeView.title isEqualToString:@"二维码"]) {
        // --- 先屏蔽掉二维码
        [MBProgressHUD showWarnWithText:@"新功能开发中,敬请期待!" andDetailText:nil onCompletion:nil];
        return;
        // 跳转到二维码生成界面去生成二维码
    }
    else if ([QRCodeView.title isEqualToString:@"扫一扫"]) {
        // 跳转到条码扫描界面
        [[VMOtherPayType sharedInstance] setGoodsName:self.goodsTextField.text];
        [self.navigationController pushViewController:[[CodeScannerViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
    }
}


#pragma mask ---- 界面生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    OtherPayType payType = [[VMOtherPayType sharedInstance] curPayType];
    if (payType == OtherPayTypeAlipay) {
        self.title = @"支付宝收款";
    } else {
        self.title = @"微信收款";
    }
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    [self addSubviews];
    [self relayoutSubviews];
    
    [self.goodsTextField becomeFirstResponder];
    
}

- (void) addSubviews {
    [self.view addSubview:self.moneyImageView];
    [self.view addSubview:self.goodsImageView];
    [self.view addSubview:self.moneyLabel];
    [self.view addSubview:self.goodsTextField];
    
    [self.view addSubview:self.btnViewRQCodeDisplay];
    [self.view addSubview:self.btnViewRQCodeScan];
}
- (void) relayoutSubviews {
    
    CGFloat labelHeight = 40;
    CGFloat btnHeight = 130;
    CGFloat inset = 10;
    
    NameWeakSelf(wself);
    [self.moneyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left).offset(inset * 2);
        make.centerY.equalTo(wself.view.mas_top).offset(64 + inset * 2 + labelHeight * 0.5);
        make.width.mas_equalTo(labelHeight * 0.88);
        make.height.mas_equalTo(labelHeight * 0.88);
    }];
    
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.moneyImageView.mas_right).offset(inset);
        make.right.equalTo(wself.view.mas_right).offset(-inset * 2);
        make.centerY.equalTo(wself.moneyImageView.mas_centerY);
        make.height.mas_equalTo(labelHeight);
        wself.moneyLabel.layer.cornerRadius = labelHeight * 0.5;
    }];
    
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.moneyImageView.mas_centerX);
        make.centerY.equalTo(wself.moneyImageView.mas_bottom).offset(inset + labelHeight * 0.5);
        make.width.equalTo(wself.moneyImageView.mas_width);
        make.height.equalTo(wself.moneyImageView.mas_height);
    }];
    
    [self.goodsTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.moneyLabel.mas_centerX);
        make.centerY.equalTo(wself.goodsImageView.mas_centerY);
        make.width.equalTo(wself.moneyLabel.mas_width);
        make.height.equalTo(wself.moneyLabel.mas_height);
        wself.goodsTextField.layer.cornerRadius = labelHeight * 0.5;
        wself.goodsTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelHeight * 0.5, inset)];
    }];
    
    [self.btnViewRQCodeDisplay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_centerX);
        make.top.equalTo(wself.goodsImageView.mas_bottom).offset(inset * 3);
        make.height.mas_equalTo(btnHeight);
    }];
    [self.btnViewRQCodeScan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.btnViewRQCodeDisplay.mas_right);
        make.right.equalTo(wself.view.mas_right);
        make.top.equalTo(wself.btnViewRQCodeDisplay.mas_top);
        make.bottom.equalTo(wself.btnViewRQCodeDisplay.mas_bottom);
    }];
}



#pragma mask ---- getter
- (UIImageView *)moneyImageView {
    if (!_moneyImageView) {
        _moneyImageView = [UIImageView new];
        _moneyImageView.image = [UIImage imageNamed:@"RMB_blueBlack"];
    }
    return _moneyImageView;
}

- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [UIImageView new];
        _goodsImageView.image = [UIImage imageNamed:@"goods_03"];
    }
    return _goodsImageView;
}

- (UILabel *)moneyLabel {
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _moneyLabel.backgroundColor = [PublicInformation returnCommonAppColor:@"blueBlack"];
        _moneyLabel.textColor = [UIColor whiteColor];
        _moneyLabel.textAlignment = NSTextAlignmentLeft;
        _moneyLabel.text = [NSString stringWithFormat:@"    %@",[VMOtherPayType sharedInstance].payAmount];
        _moneyLabel.layer.masksToBounds = YES;
    }
    return _moneyLabel;
}
- (UITextField *)goodsTextField {
    if (!_goodsTextField) {
        _goodsTextField = [UITextField new];
        _goodsTextField.backgroundColor = [PublicInformation returnCommonAppColor:@"blueBlack"];
        _goodsTextField.delegate = self;
        _goodsTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入商品名称" attributes:[NSDictionary dictionaryWithObject:[UIColor colorWithWhite:0.68 alpha:0.78] forKey:NSForegroundColorAttributeName]];
        _goodsTextField.textColor = [UIColor whiteColor];
        _goodsTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _goodsTextField.keyboardType = UIKeyboardTypeDefault;
        _goodsTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _goodsTextField;
}

- (QRCodeButtonView *)btnViewRQCodeDisplay {
    if (_btnViewRQCodeDisplay == nil) {
        _btnViewRQCodeDisplay = [[QRCodeButtonView alloc] initWithFrame:CGRectZero];
        [_btnViewRQCodeDisplay setBackgroundColor:[PublicInformation returnCommonAppColor:@"blueBlack"]];
        [_btnViewRQCodeDisplay setDelegate:self];
        [_btnViewRQCodeDisplay setTitle:@"二维码"];
        [_btnViewRQCodeDisplay setImage:[UIImage imageNamed:@"QRCodeImage"]];
    }
    return _btnViewRQCodeDisplay;
}
- (QRCodeButtonView *)btnViewRQCodeScan {
    if (_btnViewRQCodeScan == nil) {
        _btnViewRQCodeScan = [[QRCodeButtonView alloc] initWithFrame:CGRectZero];
        [_btnViewRQCodeScan setBackgroundColor:[PublicInformation returnCommonAppColor:@"blueBlack"]];
        [_btnViewRQCodeScan setDelegate:self];
        [_btnViewRQCodeScan setTitle:@"扫一扫"];
        [_btnViewRQCodeScan setImage:[UIImage imageNamed:@"BarCodeImage"]];
    }
    return _btnViewRQCodeScan;
}

@end
