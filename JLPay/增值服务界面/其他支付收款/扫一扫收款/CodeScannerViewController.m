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


const NSString* kScanQRCodeQueueName = @"kScanQRCodeQueueName__";
static CGFloat fScanViewHeight = 200; // 条码摄取框的高度
static CGFloat fInset = 20; // 条码摄取框的水平边界间隔



#pragma mask ---- 对象属性
@interface CodeScannerViewController()<AVCaptureMetadataOutputObjectsDelegate>
{
    NSArray* metadataTypes;
}
@property (nonatomic, strong) AVCaptureSession* captureSession;         // 媒体管理器
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* videoLayer;   // 视频显示层
@property (nonatomic, strong) MaskView* maskView;

@end



@implementation CodeScannerViewController


#pragma mask ---- AVCaptureMetadataOutputObjectsDelegate
/* 流媒体数据的数据获取回调 */
- (void)     captureOutput:(AVCaptureOutput *)captureOutput
  didOutputMetadataObjects:(NSArray *)metadataObjects
            fromConnection:(AVCaptureConnection *)connection
{
    
}



#pragma mask ---- 初始化界面视图
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    // 条码类型:
    metadataTypes = @[AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code];
    // 创建背景框视图
    [self.view addSubview:self.maskView];
    [self.view.layer insertSublayer:self.videoLayer atIndex:0];
    // 初始化摄像头
    if ([self initBarCodeScanning]) {
        [self startBarCodeScanning];
    } else {
        [self alertForMessage:@"摄像头打开失败!"];
    }
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
    [self.captureSession startRunning];
}
/* 停止扫码 */
- (void) stopBarCodeScanning {
    [self.captureSession stopRunning];
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
/* 创建弹窗 */
- (void) alertForMessage:(NSString*)message {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
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

@end
