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
#import "PublicInformation.h"
#import "ViewModelCodeScanner.h"

#import "VMHttpAlipay.h"


#pragma mask ---- 对象属性
@interface CodeScannerViewController()
<
ViewModelCodeScannerDelegate,
UIAlertViewDelegate>
{
    BOOL codeScanningDone;  // 扫码结果
    BOOL payIsDone;         // 收款结果
    BOOL isTCPEnquirying;   // 轮询标志
}
@property (nonatomic, retain) ViewModelCodeScanner* codeScanner;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* videoLayer;   // 视频显示层
@property (nonatomic, strong) MaskView* maskView; // 遮罩视图: 带扫描框

@property (nonatomic, strong) MBProgressHUD* progressHUD;

@property (nonatomic, strong) VMHttpAlipay* http;

@property (nonatomic, strong) NSTimer* timeOutForTCPEnquiry;
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
        codeScanningDone = YES;
        self.progressHUD.labelText = @"交易处理中...";
        [self.progressHUD show:YES];
        [self startHttpTransWithPayCode:code andFloatMoney:self.money];
    } else {
        [self alertForMessage:message];
    }
}

#pragma mask ---- HTTP
- (void) startHttpTransWithPayCode:(NSString*)payCode andFloatMoney:(NSString*)floatMoney {
    self.http.payCode = payCode;
    self.http.payAmount = [PublicInformation intMoneyFromDotMoney:floatMoney];
    [self.progressHUD showNormalWithText:@"交易处理中..." andDetailText:nil];
    NameWeakSelf(wself);
    [self.http startAlipayTransOnFinished:^{
        [wself.progressHUD showSuccessWithText:@"交易成功" andDetailText:nil onCompletion:^{
            
        }];
    } onError:^(NSError *error) {
        [wself.progressHUD showFailWithText:@"交易失败" andDetailText:[error localizedDescription] onCompletion:^{
            
        }];
    }];
}


#pragma mask ---- 初始化界面视图
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    codeScanningDone = NO;
    payIsDone = NO;
    isTCPEnquirying = NO;
    // 创建背景框视图
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.progressHUD];
    [self.view.layer insertSublayer:self.videoLayer atIndex:0];
    // 启动摄像头扫描
    [self.codeScanner startScanning];
    
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

/* 跳转界面 */
- (void) pushToBarCodeResultVCWithResult:(BOOL)result {
    BarCodeResultViewController* resultVC = [[BarCodeResultViewController alloc] initWithNibName:nil bundle:nil];
    [resultVC setPayCollectType:self.payCollectType];
    [resultVC setMoney:self.money];
    [resultVC setResult:result];
    [self.navigationController pushViewController:resultVC animated:YES];
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
- (VMHttpAlipay *)http {
    if (!_http) {
        _http = [VMHttpAlipay new];
    }
    return _http;
}

@end
