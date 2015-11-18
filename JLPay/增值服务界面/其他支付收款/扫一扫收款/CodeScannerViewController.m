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
#import "MBProgressHUD.h"
#import "ViewModelTCP.h"
#import "ViewModelTCPEnquiry.h"
#import "OtherPayCollectViewController.h"
#import "BarCodeResultViewController.h"
#import "PublicInformation.h"
#import "ViewModelCodeScanner.h"


#pragma mask ---- 对象属性
@interface CodeScannerViewController()
<
ViewModelCodeScannerDelegate,
UIAlertViewDelegate,
ViewModelTCPDelegate, ViewModelTCPEnquiryDelegate>
{
    BOOL codeScanningDone;  // 扫码结果
    BOOL payIsDone;         // 收款结果
    BOOL isTCPEnquirying;   // 轮询标志
}
@property (nonatomic, retain) ViewModelCodeScanner* codeScanner;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* videoLayer;   // 视频显示层
@property (nonatomic, strong) MaskView* maskView; // 遮罩视图: 带扫描框

@property (nonatomic, strong) MBProgressHUD* progressHUD;
@property (nonatomic, strong) ViewModelTCP* tcpHolder;
@property (nonatomic, strong) ViewModelTCPEnquiry* tcpEnquiry;

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
        [self startTCPTransWithOrderCode:code];
    } else {
        [self alertForMessage:message];
    }
}


#pragma mask ---- ViewModelTCPDelegate
- (void)TCPResponse:(ViewModelTCP *)tcp withState:(BOOL)state andData:(NSDictionary *)responseData
{
    [tcp TCPClear];
    // 交易成功
    if (state) {
        payIsDone = YES;
        [self.progressHUD hide:YES];
        [self pushToBarCodeResultVCWithResult:state];
    }
    // 交易失败,继续查询结果
    else {
        NSString* f63 = [responseData valueForKey:KeyResponseDataRetData];
        if (f63 && f63.length > 0) {
            NSString* orderCode = nil;
            // 订单号
            orderCode = [f63 substringToIndex:64*2];
            orderCode = [PublicInformation stringFromHexString:orderCode];
            
            // 发起结果查询轮询定时器
            [self startTCPEnquiryWithOrderCode:orderCode];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startTimerForTCPEnquiry];
            });
        }
    }
}

#pragma mask ---- NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:KEYPATH_PAYISDONE_CHANGED] && object == self.tcpEnquiry) {
        NSNumber* value = [self.tcpEnquiry valueForKey:KEYPATH_PAYISDONE_CHANGED];
        if (value.boolValue) { // 监控的值变为成功了
            [self.tcpEnquiry cleanForEnquiryDone];
        }
    }
}


#pragma mask ---- ViewModelTCPEnquiryDelegate
- (void)TCPEnquiryResult:(BOOL)result withMessage:(NSString *)message {
    payIsDone = YES;
    isTCPEnquirying = NO;
    [self.progressHUD hide:YES];
    [self pushToBarCodeResultVCWithResult:result];
}


#pragma mask ---- TCP
/* TCP扫码收款交易请求 */
- (void) startTCPTransWithOrderCode:(NSString*)orderCode {
    NSString* transType = nil;
    if ([self.payCollectType isEqualToString:PayCollectTypeAlipay]) {
        transType = TranType_BarCode_Trans_Alipay;
    }
    else if ([self.payCollectType isEqualToString:PayCollectTypeWeChatPay]) {
        transType = TranType_BarCode_Trans_WeChat;
    }
    if (transType) {
        [self.tcpHolder TCPRequestWithTransType:transType andMoney:self.money andOrderCode:orderCode andDelegate:self];
    }
}

/* TCP扫码收款结果查询 */
- (void) startTCPEnquiryWithOrderCode:(NSString*)orderCode {
    NSString* transType = nil;
    if ([self.payCollectType isEqualToString:PayCollectTypeAlipay]) {
        transType = TranType_BarCode_Review_Alipay;
    }
    else if ([self.payCollectType isEqualToString:PayCollectTypeWeChatPay]) {
        transType = TranType_BarCode_Review_WeChat;
    }
    if (transType) {
        [self.tcpEnquiry TCPStartTransEnquiryWithTransType:transType andOrderCode:orderCode andMoney:self.money];
    }
    isTCPEnquirying = YES;
}
/* 关闭交易结果轮询TCP */
- (void) stopTCPEnquiry {
    // 终止并清除轮询TCP队列
    [self.tcpEnquiry terminateTCPEnquiry];
    isTCPEnquirying = NO;
    
    [self.progressHUD hide:YES];
    // 跳转到交易结果显示界面
    [self pushToBarCodeResultVCWithResult:NO];
}


#pragma mask ---- 交易结果轮询超时定时器
- (void) startTimerForTCPEnquiry {
    self.timeOutForTCPEnquiry = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(stopTCPEnquiry) userInfo:nil repeats:NO];
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
    // 注册KVO: 轮询结果更新
    [self.tcpEnquiry addObserver:self forKeyPath:KEYPATH_PAYISDONE_CHANGED options:NSKeyValueObservingOptionNew context:nil];
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
    
    // 如果交易未成功: 先判断并关闭条码支付TCP，然后判断并关闭TCP结果轮询
    if (!payIsDone) {
        if ([self.tcpHolder isConnected]) {
            [self.tcpHolder TCPClear];
        }
        if (isTCPEnquirying) {
            [self.tcpEnquiry terminateTCPEnquiry];
        }
    }
    
    [self.progressHUD hide:YES];
    
    // 注销KVO
    [self.tcpEnquiry removeObserver:self forKeyPath:KEYPATH_PAYISDONE_CHANGED];

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
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BarCodeResultViewController* resultVC = [storyBoard instantiateViewControllerWithIdentifier:@"barPayCollectionVC"];
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
//        CGFloat heightTabBar = self.tabBarController.tabBar.frame.size.height;

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
- (ViewModelTCP *)tcpHolder {
    if (_tcpHolder == nil) {
        _tcpHolder = [[ViewModelTCP alloc] init];
    }
    return _tcpHolder;
}
- (ViewModelTCPEnquiry *)tcpEnquiry {
    if (_tcpEnquiry == nil) {
        _tcpEnquiry = [[ViewModelTCPEnquiry alloc] init];
        [_tcpEnquiry setDelegate:self];
    }
    return _tcpEnquiry;
}
- (ViewModelCodeScanner *)codeScanner {
    if (_codeScanner == nil) {
        _codeScanner = [[ViewModelCodeScanner alloc] init];
        [_codeScanner setDelegate: self];
        [_codeScanner setInterestRect:[self rectOfInterest]];
    }
    return _codeScanner;
}

@end
