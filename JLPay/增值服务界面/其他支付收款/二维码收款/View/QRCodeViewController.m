//
//  QRCodeViewController.m
//  JLPay
//
//  Created by jielian on 15/10/30.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "QRCodeViewController.h"

@implementation QRCodeViewController

#pragma mask 0 界面生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    if ([[VMOtherPayType sharedInstance] curPayType] == OtherPayTypeAlipay) {
        self.title = @"支付宝二维码";
    } else {
        self.title = @"微信二维码";
    }
    [self addSubviews];
    [self layoutSubviews];
    [self addKVOs];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.wechatQRCodePayer.state = VMWechatQRCodeRequesting;

}

- (void) addSubviews {
    [self.view addSubview:self.labelLog];
    [self.view addSubview:self.labelGoodsName];
    [self.view addSubview:self.labelMoneyDisplay];
    [self.view addSubview:self.imageViewQRCode];
    [self.view addSubview:self.imageViewPlatform];
    [self.view addSubview:self.activitor];
    [self.view addSubview:self.doneButton];
}

- (void) layoutSubviews {
    CGFloat heightLabel = 35;
    CGFloat heightBigImgView = self.view.frame.size.width * 0.618;
    CGFloat heightLitImgView = 30;
    CGFloat heightButton = self.view.frame.size.height * 1/15.f;
    
    NameWeakSelf(wself);
    [self.imageViewQRCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.view.mas_centerX);
        make.centerY.equalTo(wself.view.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(heightBigImgView, heightBigImgView));
    }];
    
    [self.labelGoodsName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.bottom.equalTo(wself.imageViewQRCode.mas_top).offset(- 25);
        make.height.mas_equalTo(heightLabel);
        wself.labelGoodsName.font = [UIFont systemFontOfSize:[@"test" resizeFontAtHeight:heightLabel scale:0.58]];
    }];
    [self.labelMoneyDisplay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.bottom.equalTo(wself.labelGoodsName.mas_top).offset(0);
        make.height.mas_equalTo(heightLabel);
        wself.labelMoneyDisplay.font = [UIFont boldSystemFontOfSize:[@"test" resizeFontAtHeight:heightLabel scale:0.9]];
    }];
    
    [self.labelLog mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.top.equalTo(wself.imageViewQRCode.mas_bottom).offset(15);
        make.height.mas_equalTo(heightLabel);
        wself.labelLog.font = [UIFont boldSystemFontOfSize:[@"test" resizeFontAtHeight:heightLabel scale:0.618]];
    }];
    [self.activitor mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.labelLog.mas_bottom);
        make.centerX.equalTo(wself.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(heightLabel, heightLabel));
    }];
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.activitor.mas_bottom).offset(8);
        make.left.equalTo(wself.view.mas_left).offset(heightLitImgView);
        make.right.equalTo(wself.view.mas_right).offset(- heightLitImgView);
        make.height.mas_equalTo(heightButton);
        wself.doneButton.layer.cornerRadius = heightButton * 0.5;
    }];
    
    [self.imageViewPlatform mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.view.mas_centerX);
        make.bottom.equalTo(wself.view.mas_bottom).offset(- 10);
        make.size.mas_equalTo(CGSizeMake(heightLitImgView, heightLitImgView));
    }];
}

# pragma mask 1 KVOs
- (void) addKVOs {
    RAC(self.wechatQRCodePayer, payMoney) = RACObserve([VMOtherPayType sharedInstance], payAmount);
    RAC(self.wechatQRCodePayer, payGoodsName) = RACObserve([VMOtherPayType sharedInstance], goodsName);
    
    RAC(self.labelLog, text) = [RACObserve(self.wechatQRCodePayer, stateMessage) deliverOnMainThread];
    RAC(self.imageViewQRCode, image) = [RACObserve(self.wechatQRCodePayer, QRCodeImage) deliverOnMainThread];
    
    RAC(self.doneButton, enabled) = [[RACObserve(self.wechatQRCodePayer, state) map:^NSNumber* (NSNumber* state) {
        if (state.integerValue == VMWechatPayStateSuc ||
            state.integerValue == VMWechatQRCodeRequestedFail ||
            state.integerValue == VMWechatPayStateFail)
        {
            return @(YES);
        } else {
            return @(NO);
        }
    }] deliverOnMainThread];
    
    RAC(self.doneButton, backgroundColor) = [[RACObserve(self.wechatQRCodePayer, state) map:^UIColor* (NSNumber* state) {
        if (state.integerValue == VMWechatPayStateSuc) {
            return [UIColor colorWithHex:HexColorTypeGreen alpha:1];
        } else {
            return [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        }
    }] deliverOnMainThread];
    
    @weakify(self);
    // 流程控制
    [RACObserve(self.wechatQRCodePayer, state) subscribeNext:^(NSNumber* state) {
        @strongify(self);
        switch (state.integerValue) {
            case VMWechatQRCodeRequesting:          // 发起请求
                [MBProgressHUD showNormalWithText:self.wechatQRCodePayer.stateMessage andDetailText:nil];
                break;
            case VMWechatQRCodeRequestedSuc: {      // 请求二维码成功
                [MBProgressHUD hideCurNormalHud];
            }
                break;
            case VMWechatPayStateEnquiring:         // 正在轮询交易结果
                [self.activitor startAnimating];
                break;
            case VMWechatPayStateSuc:               // 交易成功
            {
                self.labelLog.textColor = [UIColor colorWithHex:HexColorTypeGreen alpha:1];
                [self.activitor stopAnimating];
                [MBProgressHUD showSuccessWithText:@"微信收款成功" andDetailText:nil onCompletion:^{
                }];
            }
                break;
            case VMWechatQRCodeRequestedFail: {     // 请求二维码失败
                self.labelLog.textColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
                [MBProgressHUD showFailWithText:@"生成二维码失败"
                                     andDetailText:[self.wechatQRCodePayer.error localizedDescription]
                                      onCompletion:^{
                                      }];
            }
                break;
            case VMWechatPayStateFail:              // 交易失败
            {
                self.labelLog.textColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
                [self.activitor stopAnimating];
                [MBProgressHUD showFailWithText:@"微信收款失败"
                                     andDetailText:[self.wechatQRCodePayer.error localizedDescription]
                                      onCompletion:^{
                                      }];
            }
                break;
            default:
                break;
        }
    }];
}


# pragma mask 1 IBAction 
- (IBAction) clickToPopRootVC:(UIButton*)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

# pragma mask 4 getter
- (UILabel *)labelMoneyDisplay {
    if (_labelMoneyDisplay == nil) {
        _labelMoneyDisplay = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelMoneyDisplay.textAlignment = NSTextAlignmentCenter;
        _labelMoneyDisplay.text = [NSString stringWithFormat:@"￥%.02lf",[[[VMOtherPayType sharedInstance] payAmount] floatValue]];
        _labelMoneyDisplay.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
    }
    return _labelMoneyDisplay;
}
- (UILabel *)labelLog {
    if (_labelLog == nil) {
        _labelLog = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelLog.textAlignment = NSTextAlignmentCenter;
        _labelLog.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
    }
    return _labelLog;
}
- (UILabel *)labelGoodsName {
    if (!_labelGoodsName) {
        _labelGoodsName = [UILabel new];
        _labelGoodsName.textAlignment = NSTextAlignmentCenter;
        _labelGoodsName.text = [NSString stringWithFormat:@"[%@]",[[VMOtherPayType sharedInstance] goodsName]];
        _labelGoodsName.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
    }
    return _labelGoodsName;
}
- (UIImageView *)imageViewQRCode {
    if (_imageViewQRCode == nil) {
        _imageViewQRCode = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageViewQRCode.layer.cornerRadius = 8.f;
        _imageViewQRCode.layer.shadowColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1].CGColor;
        _imageViewQRCode.layer.shadowOffset = CGSizeMake(-5, 5);
        _imageViewQRCode.layer.shadowRadius = 5;
        _imageViewQRCode.layer.shadowOpacity = 1;
        
    }
    return _imageViewQRCode;
}
- (UIImageView *)imageViewPlatform {
    if (!_imageViewPlatform) {
        _imageViewPlatform = [[UIImageView alloc] init];
        if ([[VMOtherPayType sharedInstance] curPayType] == OtherPayTypeAlipay) {
            _imageViewPlatform.image = [UIImage imageNamed:@"alipay_lightGray"];
        } else {
            _imageViewPlatform.image = [UIImage imageNamed:@"wechatPay_lightGray"];
        }
    }
    return _imageViewPlatform;
}
- (UIActivityIndicatorView *)activitor {
    if (!_activitor) {
        _activitor = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activitor;
}
- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton new];
        [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateHighlighted];
        [_doneButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateDisabled];
        _doneButton.enabled = NO;
        [_doneButton addTarget:self action:@selector(clickToPopRootVC:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}


- (VMWechatQRCodePay *)wechatQRCodePayer {
    if (!_wechatQRCodePayer) {
        _wechatQRCodePayer = [[VMWechatQRCodePay alloc] init];
    }
    return _wechatQRCodePayer;
}

@end
