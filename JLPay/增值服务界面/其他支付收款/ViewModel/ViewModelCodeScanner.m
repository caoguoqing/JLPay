//
//  ViewModelCodeScanner.m
//  JLPay
//
//  Created by jielian on 15/11/16.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ViewModelCodeScanner.h"

@interface ViewModelCodeScanner()
<AVCaptureMetadataOutputObjectsDelegate>
{
    BOOL scanning;
    BOOL captured;
    NSArray* metadataTypes;
}
@property (nonatomic, retain) AVCaptureSession* captureSession;


@end

@implementation ViewModelCodeScanner

#pragma mask ---- PUBLIC INTERFACE

/* 生成一个视频摄入层: 使用本类的session属性 */
- (AVCaptureVideoPreviewLayer*) newPreviewLayerVideoCapture {
    AVCaptureVideoPreviewLayer* previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    return previewLayer;
}

/* 设置摄入框的焦点框 */
- (void) setInterestRect:(CGRect)rect {
    NSArray* outputs = [self.captureSession outputs];
    if (outputs.count > 0) {
        AVCaptureMetadataOutput* output = [outputs objectAtIndex:0];
        [output setRectOfInterest:rect];
    }
}

/* 是否正在扫描 */
- (BOOL) isScanning {
    return scanning;
}

/* 启动扫描 */
- (void) startScanning {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![self.captureSession isRunning]) {
            [self.captureSession startRunning];
        }
    });
    scanning = YES;
}
/* 停止扫描 */
- (void) stopScanning {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self.captureSession isRunning]) {
            [self.captureSession stopRunning];
        }
    });
    scanning = NO;
}

#pragma mask ---- AVCaptureMetadataOutputObjectsDelegate
/* 捕获到了code */
-  (void)       captureOutput:(AVCaptureOutput *)captureOutput
     didOutputMetadataObjects:(NSArray *)metadataObjects
               fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects && metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject* metadata = [metadataObjects objectAtIndex:0];
        if (!captured) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(codeScanner:resultScanned:codeScanned:errorMessage:)]) {
                [self.delegate codeScanner:self resultScanned:YES codeScanned:[metadata stringValue] errorMessage:nil];
            }
            captured = YES;
        }
    } else {
        if (!captured) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(codeScanner:resultScanned:codeScanned:errorMessage:)]) {
                [self.delegate codeScanner:self resultScanned:NO codeScanned:nil errorMessage:@"扫码失败"];
            }
        }
    }
}

#pragma mask ---- 初始化
- (instancetype)init {
    self = [super init];
    if (self) {
        captured = NO;
        self.captureSession = [[AVCaptureSession alloc] init];
        metadataTypes = @[AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code];
        [self initCaptureSession];
        
    }
    return self;
}

#pragma mask ---- PRIVATE INTERFACE
/* 初始化 captureSession */
- (void) initCaptureSession {
    AVCaptureDeviceInput* input = [self inputDevice];
    if (!input) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(codeScanner:resultScanned:codeScanned:errorMessage:)]) {
            [self.delegate codeScanner:self resultScanned:NO codeScanned:nil errorMessage:@"调用摄像头失败"];
        }
        return;
    }
    [self.captureSession addInput:input];
    AVCaptureMetadataOutput* output = [self metadataOutput];
    [self.captureSession addOutput:output];
    // 注意: metadataTypes要在output已经添加后才能设置
    [output setMetadataObjectTypes:metadataTypes];
}

/* input */
- (AVCaptureDeviceInput*) inputDevice {
    AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    return input;
}

/* output */
- (AVCaptureMetadataOutput*) metadataOutput {
    AVCaptureMetadataOutput* output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    return output;
}

@end
