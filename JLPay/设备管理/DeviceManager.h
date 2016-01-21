//
//  DeviceManager.h
//  JLPay
//
//  Created by jielian on 15/6/1.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


// 厂商设备类型
#define DeviceType                  @"DeviceType"
#define DeviceType_JHL_A60          @"A60音频刷卡头A"
#define DeviceType_JHL_M60          @"M60蓝牙刷卡器"
#define DeviceType_RF_BB01          @"蓝牙刷卡头"
#define DeviceType_JLpay_TY01       @"JLpay蓝牙刷卡器"
#define DeviceType_DL01             @"DL01蓝牙刷卡器"


@protocol DeviceManagerDelegate;


@interface DeviceManager : NSObject
@property (assign)            id<DeviceManagerDelegate> delegate;
@property (nonatomic, strong) NSString*         deviceType;


# pragma mask : 设备管理器公共入口获取或创建
+(DeviceManager*) sharedInstance;


# pragma mask : 设置并创建指定的设备入口
- (void) makeDeviceEntry ;

# pragma mask : 开始扫描设备
- (void) startScanningDevices;
# pragma mask : 停止扫描设备
- (void) stopScanningDevices;


# pragma mask : 打开所有设备
- (void) openAllDevices;
# pragma mask : 打开指定 identifier 号的设备
- (void) openDeviceWithIdentifier:(NSString*)identifier;
# pragma mask : 打开指定 SNVersion 号的设备
- (void) openDevice:(NSString*)SNVersion;

# pragma mask : 断开所有设备
- (void) closeAllDevices;
- (void) closeDevice:(NSString*)SNVersion;
# pragma mask : 清空设备入口以及 delegate
- (void) clearAndCloseAllDevices;

# pragma mask : 判断指定SN号的设备是否已连接  *  0:已打开，未连接  1:已连接  -1:未打开
- (int) isConnectedOnSNVersionNum:(NSString*)SNVersion;
# pragma mask : 判断指定设备ID的设备是否已连接 *  0:已打开，未连接  1:已连接  -1:未打开
- (int) isConnectedOnIdentifier:(NSString*)identifier;


# pragma mask : SN号读取:所有设备
- (void) readSNVersions;
# pragma mask : Identifier 获取:通过SN号
- (NSString*) identifierOnDeviceSN:(NSString*)SNVersion;
# pragma mask : 主密钥设置(指定设备的SN号)
- (void) writeMainKey:(NSString*)mainKey onSNVersion:(NSString*)SNVersion;
# pragma mask : 工作密钥设置(指定设备的SN号)
- (void) writeWorkKey:(NSString*)workKey onSNVersion:(NSString*)SNVersion;
# pragma mask : 刷卡: 有金额+无密码, 无金额+无密码,
- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onSNVersion:(NSString*)SNVersion;

# pragma mask : 密码加密 - 不支持输入密码的设备使用本接口加密
- (void) pinEncryptBySource:(NSString*)source withPan:(NSString*)pan onSNVersion:(NSString*)SNVersion;

# pragma mask : MAC加密
- (void) macEncryptBySource:(NSString*)source onSNVersion:(NSString*)SNVersion;


@end


# pragma mask ================================ 设备管理器的总回调协议
@protocol DeviceManagerDelegate <NSObject>

@optional

# pragma mask :  * ID号扫描成功
- (void) didDiscoverDeviceOnID:(NSString*)identifier;

# pragma mask :  * 打开设备成功/失败的回调 -- 暂时未用到
- (void) deviceManager:(DeviceManager*)deviceManager didOpenSuccessOrNot:(BOOL)yesOrNot withMessage:(NSString*)msg;

# pragma mask :  * 丢失设备连接: SN
- (void) deviceDisconnectOnSNVersion:(NSString*)SNVersion;

# pragma mask :  * SN号读取成功/失败的回调
- (void) didReadSNVersion:(NSString*)SNVersion sucOrFail:(BOOL)yesOrNo withError:(NSString*)error ;

# pragma mask :  * 设备操作超时的回调
- (void) deviceManagerTimeOut;


# pragma mask :  * 读卡数据成功/失败的回调
- (void) deviceManager:(DeviceManager*)deviceManager didReadTrackSuccessOrNot:(BOOL)yesOrNot;

# pragma mask :  * 写主密钥成功/失败的回调
- (void) deviceManager:(DeviceManager*)deviceManager didWriteMainKeySuccessOrNot:(BOOL)yesOrNot withMessage:(NSString*)msg;

# pragma mask :  * 写工作密钥成功/失败的回调
- (void) deviceManager:(DeviceManager*)deviceManager didWriteWorkKeySuccessOrNot:(BOOL)yesOrNot;

# pragma mask :  * 刷卡结果:
- (void) deviceManager:(DeviceManager*)deviceManager
  didSwipeSuccessOrNot:(BOOL)yesOrNot
           withMessage:(NSString*)msg
           andCardInfo:(NSDictionary*)cardInfo;


# pragma mask : PIN加密回调
- (void) didEncryptPinSucOrFail:(BOOL)yesOrNo pin:(NSString*)pin withError:(NSString*)error;

# pragma mask : MAC加密回调
- (void) didEncryptMacSucOrFail:(BOOL)yesOrNo macPin:(NSString*)macPin withError:(NSString*)error;


@end
