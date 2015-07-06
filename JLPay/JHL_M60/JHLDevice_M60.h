//
//  JHLDevice_M60.h
//  JLPay
//
//  Created by jielian on 15/7/4.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JHLDevice_M60_Delegate<NSObject>
@optional
// 读取终端号成功
- (void) didReadingTerminalNo:(NSString*)terminalNo;

@end



@interface JHLDevice_M60 : NSObject
@property (assign) id<JHLDevice_M60_Delegate> delegate;
/* 打开所有蓝牙设备 */
- (void) openAllDevices;
/*
 * 函  数: readTerminalNo
 * 功  能: 读取已识别列表中得设备号;
 *        一次尝试打开一批；
 * 参  数: 无
 * 返  回: 无
 */
- (BOOL) readTerminalNo;


#pragma mask : 打开设备探测;
- (void) detecting;

#pragma mask : 打开设备;
- (void) open;

#pragma mask : 关闭设备;
- (void) close;

#pragma mask : 刷卡
- (int) cardSwipeInTime: (long)timeOut mount: (long)nMount mode: (long)brushMode;

#pragma mask : 刷磁消费
-(int)TRANS_Sale:(long)timeout :(long)nAmount :(int)nPasswordlen :(NSString*)bPassKey;

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
