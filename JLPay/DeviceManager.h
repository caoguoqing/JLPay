//
//  DeviceManager.h
//  JLPay
//
//  Created by jielian on 15/6/1.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol DeviceManagerDelegate <NSObject>

@optional
// 刷卡成功: 读出卡号
- (void)didSuccessSwiping;

@end



@interface DeviceManager : NSObject

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
