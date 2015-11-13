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


#pragma mask ---- 对象属性
@interface CodeScannerViewController()
<AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate,
ViewModelTCPDelegate, ViewModelTCPEnquiryDelegate>
{
    NSArray* metadataTypes; // 扫码的类型组
    BOOL enableImageAnimating; // 扫描框动效的开关
}
@property (nonatomic, strong) AVCaptureSession* captureSession;         // 媒体管理器
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* videoLayer;   // 视频显示层
@property (nonatomic, strong) MaskView* maskView; // 遮罩视图: 带扫描框

@property (nonatomic, strong) MBProgressHUD* progressHUD;
@property (nonatomic, retain) ViewModelTCP* tcpHolder;
@property (nonatomic, retain) ViewModelTCPEnquiry* tcpEnquiry;

@property (nonatomic, retain) NSTimer* timeOutForTCPEnquiry;
@end



@implementation CodeScannerViewController


#pragma mask ---- AVCaptureMetadataOutputObjectsDelegate
/* 流媒体数据的数据获取回调 */
- (void)     captureOutput:(AVCaptureOutput *)captureOutput
  didOutputMetadataObjects:(NSArray *)metadataObjects
            fromConnection:(AVCaptureConnection *)connection
{
    [self stopBarCodeScanning];
    [self.maskView stopImageAnimation];
    enableImageAnimating = YES;
    if (metadataObjects && metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject* metadataObject = [metadataObjects objectAtIndex:0];
        NSString* orderCode = [metadataObject stringValue];
        self.progressHUD.labelText = @"收款中...";
        [self.progressHUD show:YES];
        
        [self startTCPTransWithOrderCode:orderCode];
        
    } else {
        [self alertForMessage:@"扫描条形码失败!"];
    }
}


#pragma mask ---- ViewModelTCPDelegate
- (void)TCPResponse:(ViewModelTCP *)tcp withState:(BOOL)state andData:(NSDictionary *)responseData
{
    [tcp TCPClear];
    // 交易成功
    if (state) {
        [self.progressHUD hide:YES];
        [self pushToBarCodeResultVCWithResult:state];
    }
    // 交易失败,继续查询结果
    else {
        
        NSString* f63 = [responseData valueForKey:KeyResponseDataRetData];
        if (f63) {
            NSString* responseMessage = nil;
            NSString* orderCode = nil;
            // 订单号
            NSLog(@"---1:63:[%@]",f63);
            orderCode = [f63 substringToIndex:64*2];
            NSLog(@"---2");
            orderCode = [PublicInformation stringFromHexString:orderCode];
            // 响应信息
            responseMessage = [f63 substringWithRange:NSMakeRange(64*2, 64*2)];
            
            NSLog(@"交易结果失败,进行结果轮询:[%@]",orderCode);
            // 发起结果查询轮询定时器
            [self startTCPEnquiryWithOrderCode:orderCode];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startTimerForTCPEnquiry];
            });
        }
    }
    
    
//    [tcp TCPClear];
//    BOOL result = NO;
//    if (state) {
//        result = YES;
//        [self.progressHUD hide:YES];
//    }
//    [self pushToBarCodeResultVCWithResult:result];
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
}
/* 关闭交易结果轮询TCP */
- (void) stopTCPEnquiry {
//    [self.tcpHolder TCPClear];
//    [self.tcpEnquiry removeObserver:self forKeyPath:KEYPATH_PAYISDONE_CHANGED];
    [self.tcpEnquiry terminateTCPEnquiry];
    
    [self.progressHUD hide:YES];
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
    enableImageAnimating = YES;
    // 条码类型:
    metadataTypes = @[AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code];
    // 创建背景框视图
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.progressHUD];
    [self.view.layer insertSublayer:self.videoLayer atIndex:0];
    // 初始化摄像头
    if ([self initBarCodeScanning]) {
        [self startBarCodeScanning];
    } else {
        [self alertForMessage:@"摄像头打开失败!"];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (enableImageAnimating) {
        [self.maskView startImageAnimation];
        enableImageAnimating = NO;
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.maskView stopImageAnimation];
    [self stopBarCodeScanning];
    enableImageAnimating = YES;
    
    [self.tcpHolder TCPClear];
    [self.tcpEnquiry removeObserver:self forKeyPath:KEYPATH_PAYISDONE_CHANGED];
    [self.tcpEnquiry terminateTCPEnquiry];

}



#pragma mask ---- PRIVATE INTERFACE
/* 初始化摄像头扫码 */
- (BOOL) initBarCodeScanning {
    BOOL startedResult = NO;
    AVCaptureDeviceInput* input = [self inputOfVideo];
    if (input) {
        startedResult = YES;
        [self.captureSession addInput:input];
        AVCaptureMetadataOutput* output = [self outputOfMetadata];
        [self.captureSession addOutput:output];
        [output setMetadataObjectTypes:metadataTypes];
    }
    return startedResult;
}
/* 开始扫码 */
- (void) startBarCodeScanning {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![self.captureSession isRunning]) {
            [self.captureSession startRunning];
        }
    });
}
/* 停止扫码 */
- (void) stopBarCodeScanning {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self.captureSession isRunning]) {
            [self.captureSession stopRunning];
        }
    });
}

/* 视频入口 */
- (AVCaptureDeviceInput*) inputOfVideo {
    AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput* input = nil;
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    return input;
}
/* 流媒体数据出口 */
- (AVCaptureMetadataOutput*) outputOfMetadata {
    AVCaptureMetadataOutput* output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    return output;
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
    NSString* btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if (buttonIndex > 0 && [btnTitle isEqualToString:@"重新扫描"]) {
        [self startBarCodeScanning];
    }
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
        CGFloat heightTabBar = self.tabBarController.tabBar.frame.size.height;

        _maskView = [[MaskView alloc] initWithFrame:CGRectMake(0, heightNavi + heightStates, self.view.frame.size.width, self.view.frame.size.height - heightStates - heightNavi - heightTabBar)];
    }
    return _maskView;
}
- (AVCaptureSession *)captureSession {
    if (_captureSession == nil) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}
- (AVCaptureVideoPreviewLayer *)videoLayer {
    if (_videoLayer == nil) {
        _videoLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        [_videoLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
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
        [_tcpEnquiry addObserver:self forKeyPath:KEYPATH_PAYISDONE_CHANGED options:NSKeyValueObservingOptionNew context:nil];
    }
    return _tcpEnquiry;
}

@end
