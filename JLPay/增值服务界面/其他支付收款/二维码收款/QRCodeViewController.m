//
//  QRCodeViewController.m
//  JLPay
//
//  Created by jielian on 15/10/30.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "QRCodeViewController.h"
#import "ViewModelTCP.h"
#import "OtherPayCollectViewController.h"
#import "PublicInformation.h"
#import "ViewModelTCP.h"
#import "MBProgressHUD.h"
#import "ViewModelQRImageMaker.h"
#import "ViewModelTCPEnquiry.h"


// alert标签
typedef enum {
    TagAlertError,
    TagAlertPayDone
} TagAlert;


@interface QRCodeViewController()<ViewModelTCPDelegate, MBProgressHUDDelegate, ViewModelTCPEnquiryDelegate>
{
    NSString* orderCode; // 订单号
    NSString* QRCode; // 二维码
//    BOOL payIsDone; // 收款完成标记
}
@property (nonatomic, strong) UILabel* labelMoneyDisplay;
@property (nonatomic, strong) UILabel* labelPayType;
@property (nonatomic, strong) UILabel* labelLog;
@property (nonatomic, strong) UIImageView* imageViewQRCode;

@property (nonatomic, retain) ViewModelTCP* tcpQRCode;
@property (nonatomic, retain) ViewModelTCPEnquiry* tcpEnquiry;
@property (nonatomic, retain) MBProgressHUD* progressHUD;

@end





@implementation QRCodeViewController


#pragma mask ---- ViewModelTCPDelegate
- (void)TCPResponse:(ViewModelTCP *)tcp withState:(BOOL)state andData:(NSDictionary *)responseData {
    [self.progressHUD hide:YES];
    if (state) { // 成功
        /*
         * 1.拆出订单号、应答信息、二维码信息
         * 2.显示二维码
         * 3.根据订单号查询交易结果(轮询)
         */
        // 解析拆包的63域:订单号、应答信息、二维码信息
        [self responseMessageInF63:[responseData valueForKey:KeyResponseDataRetData]];
        // 更新二维码图片
        [self.imageViewQRCode setImage:[ViewModelQRImageMaker imageForQRCode:QRCode]];
        // 开始轮询交易结果
        [self startTCPEnquiry];
    } else { // 失败
        [self alertWithMessage:[responseData valueForKey:KeyResponseDataMessage] andTag:TagAlertError];
    }
}

#pragma mask ---- ViewModelTCPEnquiryDelegate
/* 收款结果查询回调 */
- (void)TCPEnquiryResult:(BOOL)result withMessage:(NSString *)message {
    if (result) {
        [self.labelLog setText:message];
        [self alertWithMessage:message andTag:TagAlertPayDone];
    } else {
        self.labelLog.text = nil;
        [self alertWithMessage:message andTag:TagAlertError];
    }
}

#pragma mask ---- MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
    [hud removeFromSuperview];
    hud = nil;
//    self.progressHUD = nil;
}



#pragma mask ---- 界面生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码";
    [self.view addSubview:self.labelMoneyDisplay];
    [self.view addSubview:self.labelPayType];
    [self.view addSubview:self.imageViewQRCode];
    [self.view addSubview:self.labelLog];
    
    // TCP请求订单号
    [self startTCPRequest];
    [self hudShowWithMessage:@"二维码加载中..."];
    
    // 收款完成标记
//    payIsDone = NO;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CGFloat inset = 20;
    CGFloat labelHeight = 35;
    CGFloat imageViewHeight = 260;
    CGFloat imageViewWidth = imageViewHeight;
    
    CGRect frame = CGRectMake(0,
                              [PublicInformation heightOfNavigationAndStatusInVC:self],
                              self.view.frame.size.width,
                              labelHeight);
    [self.labelMoneyDisplay setFrame:frame];
    
    frame.origin.y += frame.size.height + inset;
    [self.labelPayType setFrame:frame];
    
    frame.origin.x = (self.view.frame.size.width - imageViewWidth)/2.0;
    frame.origin.y += frame.size.height + inset/2.0;
    frame.size.width = imageViewWidth;
    frame.size.height = imageViewHeight;
    [self.imageViewQRCode setFrame:frame];
    
    frame.origin.x = 0;
    frame.origin.y += frame.size.height + inset/2.0;
    frame.size.width = self.view.frame.size.width;
    frame.size.height = labelHeight;
    [self.labelLog setFrame:frame];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tcpQRCode TCPClear];
    
    
}

#pragma mask ---- TCP报文请求
/* 二维码请求 */
- (void) startTCPRequest {
    NSString* transType = nil;
    if ([self.payCollectType isEqualToString:PayCollectTypeAlipay]) {
        transType = TranType_QRCode_Request_Alipay;
    }
    else if ([self.payCollectType isEqualToString:PayCollectTypeWeChatPay]) {
        transType = TranType_QRCode_Request_WeChat;
    }
    [self.tcpQRCode TCPRequestWithTransType:transType
                                   andMoney:self.money
                               andOrderCode:nil
                                andDelegate:self];
}
/* 收款结果查询 */
- (void) startTCPEnquiry {
    NSString* transType = nil;
    if ([self.payCollectType isEqualToString:PayCollectTypeAlipay]) {
        transType = TranType_QRCode_Review_Alipay;
    }
    else if ([self.payCollectType isEqualToString:PayCollectTypeWeChatPay]) {
        transType = TranType_QRCode_Review_WeChat;
    }
    [self.tcpEnquiry TCPStartTransEnquiryWithTransType:transType andOrderCode:orderCode andMoney:self.money];
    [self.labelLog setText:@"收款结果确认中..."];
}


#pragma mask ---- PRIVATE INTERFACE
/* 支付类型 */
- (NSString*) payTypeDisplay {
    NSMutableString* display = [[NSMutableString alloc] initWithString:@"请扫描二维码进行"];
    if ([self.payCollectType isEqualToString:PayCollectTypeAlipay]) {
        [display appendString:@"支付宝"];
    } else if ([self.payCollectType isEqualToString:PayCollectTypeWeChatPay]) {
        [display appendString:@"微信"];
    }
    [display appendString:@"支付"];
    return display;
}

/* alert */
- (void) alertWithMessage:(NSString*)message andTag:(TagAlert)tagAlert {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert setTag:tagAlert];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

/* processHUD show */
- (void) hudShowWithMessage:(NSString*)message {
    [self.view addSubview:self.progressHUD];
    [self.progressHUD setLabelText:message];
    [self.progressHUD show:YES];
}

/* 拆分63域响应值:订单号+应答信息+二维码 */
- (NSString*) responseMessageInF63:(NSString*)f63 {
    NSString* responseMessage = nil;
    // 订单号
    orderCode = [f63 substringToIndex:64*2];
    orderCode = [PublicInformation stringFromHexString:orderCode];
    // 响应信息
    responseMessage = [f63 substringWithRange:NSMakeRange(64*2, 64*2)];
    // 二维码
    QRCode = [f63 substringFromIndex:64*2+64*2];
    QRCode = [PublicInformation stringFromHexString:QRCode];

    return responseMessage;
}


#pragma mask ---- getter
- (UILabel *)labelMoneyDisplay {
    if (_labelMoneyDisplay == nil) {
        _labelMoneyDisplay = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelMoneyDisplay.text = [NSString stringWithFormat:@"   金额: %@元",self.money];
        _labelMoneyDisplay.textAlignment = NSTextAlignmentLeft;
    }
    return _labelMoneyDisplay;
}
- (UILabel *)labelPayType {
    if (_labelPayType == nil) {
        _labelPayType = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelPayType.text = [self payTypeDisplay];
        _labelPayType.textAlignment = NSTextAlignmentCenter;
        _labelPayType.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    }
    return _labelPayType;
}
- (UILabel *)labelLog {
    if (_labelLog == nil) {
        _labelLog = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelLog.textAlignment = NSTextAlignmentLeft;
        _labelLog.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    }
    return _labelLog;
}
- (UIImageView *)imageViewQRCode {
    if (_imageViewQRCode == nil) {
        _imageViewQRCode = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageViewQRCode.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        _imageViewQRCode.image = [UIImage imageNamed:@"QRCodeImage"];
    }
    return _imageViewQRCode;
}
- (ViewModelTCP *)tcpQRCode {
    if (_tcpQRCode == nil) {
        _tcpQRCode = [[ViewModelTCP alloc] init];
    }
    return _tcpQRCode;
}
- (ViewModelTCPEnquiry *)tcpEnquiry {
    if (_tcpEnquiry == nil) {
        _tcpEnquiry = [[ViewModelTCPEnquiry alloc] init];
        [_tcpEnquiry setDelegate:self];
    }
    return _tcpEnquiry;
}
- (MBProgressHUD *)progressHUD {
    if (_progressHUD == nil) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        _progressHUD.dimBackground = YES;
        [_progressHUD setDelegate:self];
    }
    return _progressHUD;
}
@end
