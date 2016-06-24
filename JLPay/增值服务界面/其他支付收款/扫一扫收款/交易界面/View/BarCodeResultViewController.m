//
//  BarCodeResultViewController.m
//  JLPay
//
//  Created by jielian on 15/11/9.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "BarCodeResultViewController.h"


@implementation BarCodeResultViewController

#pragma mask ---- 按钮事件
- (IBAction) clickToBackVC:(UIButton*)sender {
    self.tabBarController.tabBar.hidden = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction) clickToRevoke:(UIButton*)sender {
    NameWeakSelf(wself);
    [JCAlertView showTwoButtonsWithTitle:@"是否确认撤销?" Message:[NSString stringWithFormat:@"撤销金额: ￥%.02lf",[[VMOtherPayType sharedInstance] payAmount].floatValue] ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"取消" Click:nil ButtonType:JCAlertViewButtonTypeWarn ButtonTitle:@"撤销" Click:^{
        // 执行撤销 ...
        [wself.progressHud showNormalWithText:@"正在撤销交易..." andDetailText:nil];
        [wself.httpTransaction startRevokeOnFinished:^{
            [wself.progressHud showSuccessWithText:@"撤销成功" andDetailText:nil onCompletion:nil];
        } onError:^(NSError *error) {
            [wself.progressHud showFailWithText:@"撤销失败" andDetailText:[error localizedDescription] onCompletion:nil];
        }];
    }];
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
    colorLabelPre = [UIColor colorWithWhite:0.2 alpha:0.95];
    colorLabelDetail = [UIColor colorWithWhite:0.2 alpha:1];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setHidesBackButton:YES];
    
    [self addSubveiws];
    [self viewOnKVOs];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self layoutSubviewsAll];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NameWeakSelf(wself);
    [self.progressHud showNormalWithText:@"交易处理中..." andDetailText:nil];
    [self.httpTransaction startPayingOnFinished:^{
        [wself.progressHud showSuccessWithText:@"交易成功" andDetailText:nil onCompletion:nil];
    } onError:^(NSError *error) {
        [wself.progressHud showFailWithText:@"交易失败" andDetailText:[error localizedDescription] onCompletion:nil];
    }];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}
- (void)dealloc {
    [self.httpTransaction stopTrans];
}


// -- 绑定ViewModel
- (void) viewOnKVOs {
    if ([[VMOtherPayType sharedInstance] curPayType] == OtherPayTypeAlipay) {
        VMHttpAlipay* httpAlipay = (VMHttpAlipay*)self.httpTransaction;
        
        /*  */
        RAC(self.labelResult,text) = [RACObserve(httpAlipay, stateMessage) deliverOnMainThread];
        
        RAC(self.labelResult,textColor) = [[RACObserve(httpAlipay, state) map:^UIColor* (NSNumber* state) {
            if (state.integerValue == -1 || state.integerValue == 2 || state.integerValue == -2) {
                return [UIColor redColor];
            } else {
                return [PublicInformation returnCommonAppColor:@"green"];
            }
        }] deliverOn:[RACScheduler mainThreadScheduler]];
        
        RAC(self.labelOrderNo, text) = [[RACObserve(httpAlipay, orderNumber) deliverOn:[RACScheduler mainThreadScheduler]] map:^NSString* (NSString* source) {
            return [NSString stringWithFormat:@"%@****%@", [source substringToIndex:6], [source substringFromIndex:source.length - 4]];
        }];
//        RAC(self.labelBuyerId,text) = [RACObserve(httpAlipay, buyerId) deliverOnMainThread];
        
//        RAC(self.labelPayOrder,text) = [[RACObserve(httpAlipay, paidOrderNumber) deliverOnMainThread] map:^id(NSString* source) {
//            if (source && source.length > 10) {
//                return [NSString stringWithFormat:@"%@****%@", [source substringToIndex:6], [source substringFromIndex:source.length - 4]];
//            } else {
//                return nil;
//            }
//        }];
        
//        RAC(self.labelPayTime,text) = [RACObserve(httpAlipay, transTime) deliverOnMainThread];

        
        RAC(self.buttonDone, enabled) = [[RACObserve(httpAlipay, state) map:^NSNumber* (NSNumber* state) {
            if (state.integerValue == 0) {
                return @(NO);
            } else {
                return @(YES);
            }
        }] deliverOnMainThread];
        
        RAC(self.buttonDone,backgroundColor) = [[RACObserve(httpAlipay, state) map:^UIColor* (NSNumber* state) {
            if (state.integerValue == 1 || state.integerValue == 0) {
                return [PublicInformation returnCommonAppColor:@"green"];
            } else {
                return [PublicInformation returnCommonAppColor:@"red"];
            }
        }] deliverOnMainThread];

        RAC(self.buttonRevoke, hidden) = [[RACObserve(httpAlipay, state) map:^NSNumber* (NSNumber* state) {
            if (state.integerValue == 1 || state.integerValue == -2) {
                return @(NO);
            } else {
                return @(YES);
            }
        }] deliverOnMainThread];
        
        RAC(self.imageView, image) = [[RACObserve(httpAlipay, state) map:^UIImage* (NSNumber* state) {
            if (state.integerValue == 0) {
                return [UIImage imageNamed:@"hourGlass"];
            }
            else if (state.integerValue == 1 || state.integerValue == 2) {
                return [UIImage imageNamed:@"checkRight_green"];
            }
            else {
                return [UIImage imageNamed:@"checkWrong_red"]; //checkRight_green
            }
        }] deliverOnMainThread];
        
    }
}




- (void) addSubveiws {
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.labelResult];
    [self.view addSubview:self.labelMoney];
    [self.view addSubview:self.labelGoodsName];
    
    [self.view addSubview:self.labelOrderNoPre];
    [self.view addSubview:self.labelOrderNo];
    [self.view addSubview:self.labelBuyerIdPre];
    [self.view addSubview:self.labelBuyerId];
    [self.view addSubview:self.labelPayOrderPre];
    [self.view addSubview:self.labelPayOrder];
    [self.view addSubview:self.labelPayTimePre];
    [self.view addSubview:self.labelPayTime];

    [self.view addSubview:self.buttonDone];
    [self.view addSubview:self.buttonRevoke];
    [self.view addSubview:self.progressHud];
}

- (void) layoutSubviewsAll {
    CGRect frame = self.view.bounds;
    CGFloat widthImageView = frame.size.width * 0.2;
    CGFloat heightButton = 50;
    CGFloat heightLabel = 30;
    CGFloat widthLabelPre = frame.size.width * 0.33;
    CGFloat insetMin = 10;
    CGFloat insetBig = 30;
    
    CGFloat topAvilableHeight = frame.size.height * 0.5 - 64;
    
    CGFloat scaleTextPre = 0.6;
    CGFloat scaleText = 0.8;
    
    
    NameWeakSelf(wself);
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(widthImageView);
        make.height.mas_equalTo(widthImageView);
        make.centerX.equalTo(wself.view.mas_centerX);
        make.top.equalTo(wself.view.mas_top).offset(64 + (topAvilableHeight - widthImageView - heightLabel*3 - insetMin*2) * 0.5);
    }];
    
    [self.labelResult mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.height.mas_equalTo(heightLabel);
        make.top.equalTo(wself.imageView.mas_bottom).offset(insetMin);
        wself.labelResult.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:0.85]];
    }];
    
    [self.labelMoney mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.height.mas_equalTo(heightLabel);
        make.top.equalTo(wself.labelResult.mas_bottom).offset(insetMin);
        wself.labelMoney.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:1.1]];
    }];
    [self.labelGoodsName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.view.mas_centerX);
        make.top.equalTo(wself.labelMoney.mas_bottom);
        make.width.equalTo(wself.labelMoney.mas_width);
        make.height.equalTo(wself.labelMoney.mas_height);
        wself.labelGoodsName.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:0.8]];
    }];
    
    [self.labelOrderNoPre mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.width.mas_equalTo(widthLabelPre);
        make.height.mas_equalTo(heightLabel);
        make.top.equalTo(wself.view.mas_centerY);
        wself.labelOrderNoPre.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:scaleTextPre]];
    }];
    
    [self.labelOrderNo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.labelOrderNoPre.mas_right).offset(insetMin);
        make.right.equalTo(wself.view.mas_right);
        make.height.mas_equalTo(heightLabel);
        make.top.equalTo(wself.labelOrderNoPre.mas_top);
        wself.labelOrderNo.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:scaleText]];
    }];
    
    [self.labelBuyerIdPre mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.labelOrderNoPre.mas_left);
        make.right.equalTo(wself.labelOrderNoPre.mas_right);
        make.top.equalTo(wself.labelOrderNoPre.mas_bottom);
        make.height.equalTo(wself.labelOrderNoPre.mas_height);
        wself.labelBuyerIdPre.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:scaleTextPre]];
    }];
    [self.labelBuyerId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.labelOrderNo.mas_left).offset(0);
        make.right.equalTo(wself.labelOrderNo.mas_right);
        make.top.equalTo(wself.labelOrderNo.mas_bottom);
        make.height.equalTo(wself.labelOrderNo.mas_height);
        wself.labelBuyerId.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:scaleText]];
    }];
    
    [self.labelPayOrderPre mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.labelBuyerIdPre.mas_left);
        make.right.equalTo(wself.labelBuyerIdPre.mas_right);
        make.top.equalTo(wself.labelBuyerIdPre.mas_bottom);
        make.height.equalTo(wself.labelBuyerIdPre.mas_height);
        wself.labelPayOrderPre.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:scaleTextPre]];
    }];
    [self.labelPayOrder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.labelBuyerId.mas_left).offset(0);
        make.right.equalTo(wself.labelBuyerId.mas_right);
        make.top.equalTo(wself.labelBuyerId.mas_bottom);
        make.height.equalTo(wself.labelBuyerId.mas_height);
        wself.labelPayOrder.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:scaleText]];
    }];
    
    [self.labelPayTimePre mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.labelPayOrderPre.mas_left);
        make.right.equalTo(wself.labelPayOrderPre.mas_right);
        make.top.equalTo(wself.labelPayOrderPre.mas_bottom);
        make.height.equalTo(wself.labelPayOrderPre.mas_height);
        wself.labelPayTimePre.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:scaleTextPre]];
    }];
    [self.labelPayTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.labelPayOrder.mas_left).offset(0);
        make.right.equalTo(wself.labelPayOrder.mas_right);
        make.top.equalTo(wself.labelPayOrder.mas_bottom);
        make.height.equalTo(wself.labelPayOrder.mas_height);
        wself.labelPayTime.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:scaleText]];
    }];
    
    [self.buttonRevoke mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(wself.view.mas_bottom).offset(-insetMin);
        make.left.equalTo(wself.view.mas_left).offset(insetBig * 0.5);
        make.right.equalTo(wself.view.mas_right).offset(-insetBig * 0.5);
        make.height.mas_equalTo(heightButton);
    }];
    
    [self.buttonDone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(wself.buttonRevoke.mas_top);
        make.left.equalTo(wself.buttonRevoke.mas_left);
        make.right.equalTo(wself.buttonRevoke.mas_right);
        make.height.equalTo(wself.buttonRevoke.mas_height);
        wself.buttonDone.layer.cornerRadius = heightButton * 0.5;
    }];
    
}

#pragma mask ---- getter
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageView;
}
- (UILabel *)labelMoney {
    if (_labelMoney == nil) {
        _labelMoney = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelMoney.textColor = [UIColor blackColor];
        _labelMoney.textAlignment = NSTextAlignmentCenter;
        _labelMoney.text = [NSString stringWithFormat:@"￥%.02lf", [[VMOtherPayType sharedInstance] payAmount].floatValue];
    }
    return _labelMoney;
}
- (UILabel *)labelGoodsName {
    if (!_labelGoodsName) {
        _labelGoodsName = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelGoodsName.textColor = [PublicInformation returnCommonAppColor:@"blueBlack"];
        _labelGoodsName.textAlignment = NSTextAlignmentCenter;
        _labelGoodsName.text = [NSString stringWithFormat:@"[%@]", [[VMOtherPayType sharedInstance] goodsName]];
    }
    return _labelGoodsName;
}
- (UILabel *)labelResult {
    if (_labelResult == nil) {
        _labelResult = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelResult.textAlignment = NSTextAlignmentCenter;
    }
    return _labelResult;
}

- (UILabel *)labelOrderNoPre {
    if (!_labelOrderNoPre) {
        _labelOrderNoPre = [[UILabel alloc] init];
        _labelOrderNoPre.text = @"订单编号:";
        _labelOrderNoPre.textColor = colorLabelPre;
        _labelOrderNoPre.textAlignment = NSTextAlignmentRight;
    }
    return _labelOrderNoPre;
}
- (UILabel *)labelOrderNo {
    if (!_labelOrderNo) {
        _labelOrderNo = [[UILabel alloc] init];
        _labelOrderNo.textColor = colorLabelDetail;
        _labelOrderNo.textAlignment = NSTextAlignmentLeft;
    }
    return _labelOrderNo;
}
- (UILabel *)labelBuyerIdPre {
    if (!_labelBuyerIdPre) {
        _labelBuyerIdPre = [[UILabel alloc] init];
        _labelBuyerIdPre.text = @"买家账号:";
        _labelBuyerIdPre.textColor = colorLabelPre;
        _labelBuyerIdPre.textAlignment = NSTextAlignmentRight;
    }
    return _labelBuyerIdPre;
}
- (UILabel *)labelBuyerId {
    if (!_labelBuyerId) {
        _labelBuyerId = [[UILabel alloc] init];
        _labelBuyerId.textColor = colorLabelDetail;
        _labelBuyerId.textAlignment = NSTextAlignmentLeft;
    }
    return _labelBuyerId;
}
- (UILabel *)labelPayOrderPre {
    if (!_labelPayOrderPre) {
        _labelPayOrderPre = [[UILabel alloc] init];
        OtherPayType payType = [[VMOtherPayType sharedInstance] curPayType];
        if (payType == OtherPayTypeAlipay) {
            _labelPayOrderPre.text = @"支付宝订单号:";
        } else {
            _labelPayOrderPre.text = @"微信订单号:";
        }
        _labelPayOrderPre.textColor = colorLabelPre;
        _labelPayOrderPre.textAlignment = NSTextAlignmentRight;
    }
    return _labelPayOrderPre;
}
- (UILabel *)labelPayOrder {
    if (!_labelPayOrder) {
        _labelPayOrder = [[UILabel alloc] init];
        _labelPayOrder.textColor = colorLabelDetail;
        _labelPayOrder.textAlignment = NSTextAlignmentLeft;
    }
    return _labelPayOrder;
}
- (UILabel *)labelPayTimePre {
    if (!_labelPayTimePre) {
        _labelPayTimePre = [[UILabel alloc] init];
        _labelPayTimePre.text = @"支付时间:";
        _labelPayTimePre.textColor = colorLabelPre;
        _labelPayTimePre.textAlignment = NSTextAlignmentRight;
    }
    return _labelPayTimePre;
}
- (UILabel *)labelPayTime {
    if (!_labelPayTime) {
        _labelPayTime = [[UILabel alloc] init];
        _labelPayTime.textColor = colorLabelDetail;
        _labelPayTime.textAlignment = NSTextAlignmentLeft;
    }
    return _labelPayTime;
}


- (UIButton *)buttonDone {
    if (_buttonDone == nil) {
        _buttonDone = [[UIButton alloc] initWithFrame:CGRectZero];
        [_buttonDone setTitle:@"完成" forState:UIControlStateNormal];
        [_buttonDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_buttonDone setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateHighlighted];
        [_buttonDone setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateDisabled];
        _buttonDone.backgroundColor = [PublicInformation returnCommonAppColor:@"green"];
        [_buttonDone addTarget:self action:@selector(clickToBackVC:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonDone;
}

- (UIButton *)buttonRevoke {
    if (_buttonRevoke == nil) {
        _buttonRevoke = [[UIButton alloc] initWithFrame:CGRectZero];
        [_buttonRevoke setTitle:@"撤销" forState:UIControlStateNormal];
        [_buttonRevoke setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateNormal];
        _buttonRevoke.backgroundColor = [UIColor clearColor];
        [_buttonRevoke addTarget:self action:@selector(clickToRevoke:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonRevoke;
}
- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _progressHud;
}
- (id)httpTransaction {
    if (!_httpTransaction) {
        if ([[VMOtherPayType sharedInstance] curPayType] == OtherPayTypeAlipay) {
            _httpTransaction = [[VMHttpAlipay alloc] init];
        } else {
//            _httpTransaction = [];
        }
    }
    return _httpTransaction;
}

@end
