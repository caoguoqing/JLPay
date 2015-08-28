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
//@property (nonatomic, strong) NSString* deviceType;
+(DeviceManager*) sharedInstance;

#pragma mask --------------------------老接口 适用于A60
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
- (int) TRANS_Sale:(long)timeout nAmount:(long)nAmount nPasswordlen:(int)nPasswordlen bPassKey:(NSString*)bPassKey;
#pragma mask : 主密钥下载
- (int) mainKeyDownload;
#pragma mask : 工作密钥设置
- (int) WriteWorkKey:(int)len :(NSString*)DataWorkkey;
#pragma mask : 参数下载
- (int) parameterDownload;
#pragma mask : IC卡公钥下载
- (int) ICPublicKeyDownload;
#pragma mask : EMV参数下载
- (int) EMVDownload;




#pragma mask --------------------------- 新接口
// pragma mask : 设置自动标记:是否自动打开设备
- (void) setOpenAutomaticaly:(BOOL)yesOrNo;
// pragma mask : 打开所有设备
- (void) openAllDevices;
// pragma mask : 断开所有设备
- (void) closeAllDevices;
// pragma mask : 读取所有已连接设备的SN号
- (void) readSNVersions;
// 打开指定SNVersion号的设备
- (void) openDeviceWithIdentifier:(NSString*)identifier;    // 特别给蓝牙设备使用
- (void) openDevice:(NSString*)SNVersion;
- (void) closeDevice:(NSString*)SNVersion;
// pragma mask : 开始扫描设备
- (void) startScanningDevices;
// pragma mask : 停止扫描设备
- (void) stopScanningDevices;
// pragma mask : 判断指定SN号的设备是否已连接  *  0:已打开，未连接  1:已连接  -1:未打开
- (int) isConnectedOnSNVersionNum:(NSString*)SNVersion;
// pragma mask : 判断指定设备ID的设备是否已连接 *  0:已打开，未连接  1:已连接  -1:未打开
- (int) isConnectedOnIdentifier:(NSString*)identifier;
// pragma mask : 主密钥设置(指定设备的SN号)
- (void) writeMainKey:(NSString*)mainKey onSNVersion:(NSString*)SNVersion;
// pragma mask : 工作密钥设置(指定设备的SN号)
- (void) writeWorkKey:(NSString*)workKey onSNVersion:(NSString*)SNVersion;
// pragma mask : 刷卡: 有金额+无密码, 无金额+无密码,
- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onSNVersion:(NSString*)SNVersion;
// pragma mask : 设置设备的终端号+商户号(指定设备的SN号)
- (void) writeTerminalNum:(NSString*)terminalNumAndBusinessNum onSNVersion:(NSString*)SNVersion;

// pragma mask : 读取所有设备的终端号 -- useless
- (NSArray*) terminalNumArrayOfReading;
// pragma mask : 仅保留指定终端号的设备 -- useless
- (void) retainDeviceWithTerminalNum:(NSString*)terminalNum;
// pragma mask : 判断指定终端号的设备是否已连接
- (BOOL) isConnectedOnTerminalNum:(NSString*)terminalNum;
// pragma mask : 设置设备工作密钥(指定设备的终端号)
- (void) writeWorkKey:(NSString*)workKey onTerminal:(NSString*)terminalNum;
// pragma mask : 刷卡: 有金额+无密码, 无金额+无密码,
- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onTerminal:(NSString*)terminalNum;
@end


#pragma mask ================================ 设备管理器的总回调协议
@protocol DeviceManagerDelegate <NSObject>

@optional
/*
 * 刷磁或读芯片成功/失败:
 *      deviceType: DeviceType_A60, DeviceType_M60 ...
 *      在回调中，如果成功，要判断是不是M60设备，如果是，不用在手机中输入密码
 */
- (void) deviceManager:(DeviceManager*)deviceManager didSwipeSuccessOrNot:(BOOL)yesOrNot withMessage:(NSString*)msg;

/*
 * 校验密码成功/失败的回调
 */
- (void) deviceManager:(DeviceManager*)deviceManager didReadTrackSuccessOrNot:(BOOL)yesOrNot;


/*
 * 写主密钥成功/失败的回调
 */
- (void) deviceManager:(DeviceManager*)deviceManager didWriteMainKeySuccessOrNot:(BOOL)yesOrNot withMessage:(NSString*)msg;

/*
 * 写工作密钥成功/失败的回调
 */
- (void) deviceManager:(DeviceManager*)deviceManager didWriteWorkKeySuccessOrNot:(BOOL)yesOrNot;

/*
 * 写终端号成功/失败的回调
 */
- (void) deviceManager:(DeviceManager*)deviceManager didWriteTerminalSuccessOrNot:(BOOL)yesOrNot withMessage:(NSString*)msg;
/*
 * 写SN号成功/失败的回调
 */
- (void) deviceManager:(DeviceManager*)deviceManager didWriteSNVersionSuccessOrNot:(BOOL)yesOrNot;

/*
 * 打开设备成功/失败的回调
 */
- (void) deviceManager:(DeviceManager*)deviceManager didOpenSuccessOrNot:(BOOL)yesOrNot withMessage:(NSString*)msg;
/*
 * 终端号列表更新后的回调
 */
- (void) deviceManager:(DeviceManager*)deviceManager updatedTerminalArray:(NSArray*)terminalArray;
/*
 * SN号列表更新后的回调
 */
- (void) deviceManager:(DeviceManager*)deviceManager updatedSNVersionArray:(NSArray*)SNVersionArray;

/*
 * 设备操作超时的回调
 */
- (void) deviceManagerTimeOut;


@end