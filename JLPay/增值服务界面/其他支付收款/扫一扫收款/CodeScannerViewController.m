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
#import "OtherPayCollectViewController.h"
#import "BarCodeResultViewController.h"


//const NSString* kScanQRCodeQueueName = @"kScanQRCodeQueueName__";
//static CGFloat fScanViewHeight = 200; // 条码摄取框的高度
//static CGFloat fInset = 20; // 条码摄取框的水平边界间隔



#pragma mask ---- 对象属性
@interface CodeScannerViewController()<AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate,ViewModelTCPDelegate>
{
    NSArray* metadataTypes; // 扫码的类型组
    BOOL enableImageAnimating; // 扫描框动效的开关
}
@property (nonatomic, strong) AVCaptureSession* captureSession;         // 媒体管理器
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* videoLayer;   // 视频显示层
@property (nonatomic, strong) MaskView* maskView; // 遮罩视图: 带扫描框

@property (nonatomic, strong) MBProgressHUD* progressHUD;
@property (nonatomic, retain) ViewModelTCP* tcpHolder;
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
        NSString* qureTitle = [NSString stringWithFormat:@"条形码:%@",orderCode];
        NSLog(@"%@",qureTitle);
//        NSString* otherTitle = @"重新扫描";
//        [self alertForMessage:qureTitle andOtherChoice:otherTitle];
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
    [self.progressHUD hide:YES];
    [tcp TCPClear];
    BOOL result = NO;
    if (state) {
//        [self alertForMessage:@"收款成功"];
        result = YES;
    }
    else {
//        NSString* message = [responseData valueForKey:KeyResponseDataMessage];
//        [self alertForMessage:[NSString stringWithFormat:@"收款失败:%@",message]];
    }
    // barPayCollectionVC
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
//        _progressHUD = [MBProgressHUD HUDForView:self.view];
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
//        _progressHUD.mode = MBProgressHUDModeCustomView;
//        _progressHUD.animationType = MBProgressHUDAnimationZoom;
//        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
//        imageView.image = [UIImage imageNamed:@"wx"];
//        _progressHUD.customView = imageView;
    }
    return _progressHUD;
}
- (ViewModelTCP *)tcpHolder {
    if (_tcpHolder == nil) {
        _tcpHolder = [[ViewModelTCP alloc] init];
    }
    return _tcpHolder;
}

@end
