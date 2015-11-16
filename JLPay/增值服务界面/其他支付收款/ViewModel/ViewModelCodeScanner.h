//
//  ViewModelCodeScanner.h
//  JLPay
//
//  Created by jielian on 15/11/16.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@class ViewModelCodeScanner;


#pragma mask ---- 扫描结果协议
@protocol ViewModelCodeScannerDelegate <NSObject>
@required
/* 扫描结果的回调 */
- (void) codeScanner:(ViewModelCodeScanner*)codeScanner
       resultScanned:(BOOL)result
         codeScanned:(NSString*)code
        errorMessage:(NSString*)message;

@end



@interface ViewModelCodeScanner : NSObject

/* 代理 */
@property (nonatomic, assign) id<ViewModelCodeScannerDelegate> delegate;

/* 生成一个视频摄入层: 使用本类的session属性 */
- (AVCaptureVideoPreviewLayer*) newPreviewLayerVideoCapture;

/* 设置摄入框的焦点框 */
- (void) setInterestRect:(CGRect)rect;

/* 是否正在扫描 */
- (BOOL) isScanning;

/* 启动扫描 */
- (void) startScanning;
/* 停止扫描 */
- (void) stopScanning;

@end
