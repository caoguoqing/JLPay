//
//  CodeScannerViewController.m
//  JLPay
//
//  Created by jielian on 15/11/6.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "CodeScannerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MaskView.h"
#import "MBProgressHUD+CustomSate.h"
#import "OtherPayCollectViewController.h"
#import "BarCodeResultViewController.h"
#import "QRCodeViewController.h"
#import "WatingPayViewController.h"

#import "PublicInformation.h"
#import "ViewModelCodeScanner.h"
#import "VMOtherPayType.h"



#pragma mask ---- 对象属性
@interface CodeScannerViewController()
<
ViewModelCodeScannerDelegate,
UIAlertViewDelegate>
{
    BOOL codeScanningDone;  // 扫码结果
    BOOL isTCPEnquirying;   // 轮询标志
}
@property (nonatomic, retain) ViewModelCodeScanner* codeScanner;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* videoLayer;   // 视频显示层
@property (nonatomic, strong) MaskView* maskView; // 遮罩视图: 带扫描框

@property (nonatomic, strong) MBProgressHUD* progressHUD;

@property (nonatomic, strong) NSTimer* timeOutForTCPEnquiry;
@property (nonatomic, strong) UIButton* QRCodeBtn;

@property (nonatomic, strong) UILabel* moneyLabel;

@end



@implementation CodeScannerViewController

#pragma mask ---- ViewModelCodeScannerDelegate
- (void)codeScanner:(ViewModelCodeScanner *)codeScanner
      resultScanned:(BOOL)result
        codeScanned:(NSString *)code
       errorMessage:(NSString *)message
{
    [self.codeScanner stopScanning];
    [self.maskView stopImageAnimation];
    if (result) {
        [[VMOtherPayType sharedInstance] setPayCode:code];
        codeScanningDone = YES;
        NameWeakSelf(wself);
        [self.progressHUD showSuccessWithText:@"扫码成功" andDetailText:nil onCompletion:^{
            [wself.navigationController pushViewController:[[WatingPayViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
        }];
    } else {
        [self alertForMessage:message];
    }
}



#pragma mask ---- 初始化界面视图
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    codeScanningDone = NO;
    isTCPEnquirying = NO;
    // 创建背景框视图
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.QRCodeBtn];
    [self.view addSubview:self.moneyLabel];
    [self.view addSubview:self.progressHUD];
    [self.view.layer insertSublayer:self.videoLayer atIndex:0];
    // 启动摄像头扫描
    [self.codeScanner startScanning];
    
    OtherPayType payType = [[VMOtherPayType sharedInstance] curPayType];
    if (payType == OtherPayTypeAlipay) {
        self.title = @"扫描支付宝条码";
    } else {
        self.title = @"扫描微信条码";
    }
    
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.tabBarController.tabBar.hidden = YES;
    if (!codeScanningDone) {
        [self.codeScanner startScanning];
        if (![self.maskView isImageAnimating]) {
            [self.maskView startImageAnimation];
        }
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    // 如果还在扫码，关闭扫码
    if (!codeScanningDone) {
        [self.codeScanner stopScanning];
    }
    // 关闭扫码动效
    [self.maskView stopImageAnimation];
}

# pragma mask 1 IBAction
- (IBAction) clickPushToQRCodeVC:(UIButton*)sender {
    QRCodeViewController* QRCodeVC = [[QRCodeViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:QRCodeVC animated:YES];
}

#pragma mask ---- PRIVATE INTERFACE
/* 摄入框的焦点rect: CGRect(y,x,h,w) */
- (CGRect) rectOfInterest {
    CGRect rect = CGRectMake(0, 0, 0, 0);
    CGSize size = [self.maskView sizeOfScannerView];
    CGFloat screenW = self.view.frame.size.width;
    CGFloat screenH = self.view.frame.size.height;
    rect.origin.y = (screenW - size.width)/2.0 / screenW;
    rect.origin.x = (screenH - size.height)/2.0 / screenH;
    rect.size.width = size.height / screenH;
    rect.size.height = size.width / screenW;
    return rect;
}


#pragma mask ---- UIAlertView & UIAlertViewDelegate
/* 创建弹窗 */
- (void) alertForMessage:(NSString*)message {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}
/* 创建弹窗: +其他选项按钮 */
- (void) alertForMessage:(NSString*)message andOtherChoice:(NSString*)otherChoice {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:otherChoice, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}
/* UIAlertViewDelegate */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mask ---- getter 
- (MaskView *)maskView {
    if (_maskView == nil) {
        CGFloat heightStates = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGFloat heightNavi = self.navigationController.navigationBar.frame.size.height;

        _maskView = [[MaskView alloc] initWithFrame:CGRectMake(0, heightNavi + heightStates, self.view.frame.size.width, self.view.frame.size.height - heightStates - heightNavi /*- heightTabBar*/)];
    }
    return _maskView;
}
- (AVCaptureVideoPreviewLayer *)videoLayer {
    if (_videoLayer == nil) {
        _videoLayer = [self.codeScanner newPreviewLayerVideoCapture];
        [_videoLayer setFrame:self.view.bounds];
    }
    return _videoLayer;
}
- (MBProgressHUD *)progressHUD {
    if (_progressHUD == nil) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _progressHUD;
}
- (ViewModelCodeScanner *)codeScanner {
    if (_codeScanner == nil) {
        _codeScanner = [[ViewModelCodeScanner alloc] init];
        [_codeScanner setDelegate: self];
        [_codeScanner setInterestRect:[self rectOfInterest]];
    }
    return _codeScanner;
}
- (UIButton *)QRCodeBtn {
    if (!_QRCodeBtn) {
        _QRCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height * 0.5 + 32 + 100 + 20 + 15 + 20,
                                                                self.view.frame.size.width, 40)];
        [_QRCodeBtn setTitle:@"二维码收款" forState:UIControlStateNormal];
        [_QRCodeBtn setTitleColor:[UIColor colorWithHex:HexColorTypeGreen alpha:1] forState:UIControlStateNormal];
        [_QRCodeBtn addTarget:self action:@selector(clickPushToQRCodeVC:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _QRCodeBtn;
}

- (UILabel *)moneyLabel {
    if (!_moneyLabel ) {
        CGFloat height = 30;
        _moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height * 0.5 - 32 - 100) * 0.5 + 64 - height * 0.5, self.view.frame.size.width, height)];
        _moneyLabel.textColor = [UIColor whiteColor];
        _moneyLabel.textAlignment = NSTextAlignmentCenter;
        _moneyLabel.text = [@"￥" stringByAppendingString: [VMOtherPayType sharedInstance].payAmount];
        _moneyLabel.font = [UIFont boldSystemFontOfSize:24];
    }
    return _moneyLabel;
}

@end
