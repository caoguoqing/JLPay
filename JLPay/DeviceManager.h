//
//  DeviceManager.h
//  JLPay
//
//  Created by jielian on 15/6/1.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DeviceManagerDelegate;


@interface DeviceManager : NSObject
@property (assign) id<DeviceManagerDelegate> delegate;
+(DeviceManager*) sharedInstance;

#pragma mask : 打开设备探测;
- (void) detecting;
#pragma mask : 打开设备;
- (void) open;
#pragma mask : 关闭设备;
- (void) close;
#pragma mask : 检测设备是否连接;
- (BOOL) isConnected;
#pragma mask : 刷卡
- (int) cardSwipe;
#pragma mask : 刷磁消费
-(int)TRANS_Sale:(long)timeout nAmount:(long)nAmount nPasswordlen:(int)nPasswordlen bPassKey:(NSString*)bPassKey;
#pragma mask : 主密钥下载
- (int) mainKeyDownload;
#pragma mask : 工作密钥设置
-(int)WriteWorkKey:(int)len :(NSString*)DataWorkkey;
#pragma mask : 参数下载
- (int) parameterDownload;
#pragma mask : IC卡公钥下载
- (int) ICPublicKeyDownload;
#pragma mask : EMV参数下载
- (int) EMVDownload;

@end


#pragma mask ================================ 设备管理器的总回调协议
@protocol DeviceManagerDelegate <NSObject>

@optional
/*
 * 刷磁或读芯片成功/失败:
 *      deviceType: DeviceType_A60, DeviceType_M60 ...
 *      在回调中，如果成功，要判断是不是M60设备，如果是，不用在手机中输入密码
 */
- (void) deviceManager:(DeviceManager*)deviceManager didSwipingSuccessOrNot:(BOOL)yesOrNot onDeviceType:(NSString*)deviceType;

/*
 * 校验密码成功/失败的回调
 */
- (void) deviceManager:(DeviceManager*)deviceManager didReadingTrackSuccessOrNot:(BOOL)yesOrNot;


/*
 * 写主密钥成功/失败的回调
 */
- (void) deviceManager:(DeviceManager*)deviceManager didWritingMainKeySuccessOrNot:(BOOL)yesOrNot;

/*
 * 写工作密钥成功/失败的回调
 */
- (void) deviceManager:(DeviceManager*)deviceManager didWritingWorkKeySuccessOrNot:(BOOL)yesOrNot;



@end