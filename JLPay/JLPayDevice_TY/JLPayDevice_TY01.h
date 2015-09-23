//
//  JLPayDevice_TY01.h
//  JLPay
//
//  Created by jielian on 15/9/8.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JLPayDevice_TY01;

@protocol JLPayDevice_TY01_Delegate <NSObject>
@optional

# pragma mask : ID号扫描成功
- (void) didDiscoverDeviceOnID:(NSString*)identifier;
# pragma mask : 连接设备de结果回调
- (void) didOpenDeviceSucOrFail:(BOOL)yesOrNo withError:(NSString*)error;
# pragma mask : SN号读取成功
- (void) didReadSNVersion:(NSString*)SNVersion sucOrFail:(BOOL)yesOrNo withError:(NSString*)error;
# pragma mask : 设备丢失:SN
- (void) deviceDisconnectOnSNVersion:(NSString*)SNVersion;
# pragma mask : 写主密钥结果回调
- (void) didWriteMainKeySucOrFail:(BOOL)yesOrNo withError:(NSString*)error;
# pragma mask : 写工作密钥结果回调
- (void) didWriteWorkKeySucOrFail:(BOOL)yesOrNo withError:(NSString*)error;
# pragma mask : 刷卡结果回调
//- (void) didCardSwipedSucOrFail:(BOOL)yesOrNo withError:(NSString*)error;
- (void) didCardSwipedSucOrFail:(BOOL)yesOrNo withError:(NSString*)error andCardInfo:(NSDictionary*)cardInfo;

# pragma mask : 设备超时
- (void) deviceTimeOut;


@end



@interface JLPayDevice_TY01 : NSObject

@property (assign) id<JLPayDevice_TY01_Delegate> delegate;

# pragma mask : 初始化
- (instancetype)initWithDelegate:(id<JLPayDevice_TY01_Delegate>)deviceDelegate ;

# pragma mask : 开始扫描设备
- (void) startScanningDevices;
# pragma mask : 停止扫描设备
- (void) stopScanningDevices;


# pragma mask : 打开所有蓝牙设备
- (void) openAllDevices;
# pragma mask : 关闭所有蓝牙设备
- (void) closeAllDevices;
# pragma mask : SN号读取:所有设备
- (void) readSNVersions;
# pragma mask : ID设备获取:根据SN号获取对应设备
- (NSString*) identifierOnDeviceSN:(NSString*)SNVersion;

# pragma mask : 打开指定 SNVersion 号的设备
- (void) openDevice:(NSString*)SNVersion;
# pragma mask : 打开指定 identifier 号的设备
- (void) openDeviceWithIdentifier:(NSString*)identifier;
# pragma mask : 关闭指定 SNVersion 号的设备
- (void) closeDevice:(NSString*)SNVersion;


# pragma mask : 判断指定SN号的设备是否已连接
- (int) isConnectedOnSNVersionNum:(NSString*)SNVersion;
# pragma mask : 判断指定设备ID的设备是否已连接
- (int) isConnectedOnIdentifier:(NSString*)identifier ;

# pragma mask : 设置主密钥
- (void) writeMainKey:(NSString*)mainKey onSNVersion:(NSString*)SNVersion;
# pragma mask : 设置工作密钥
- (void) writeWorkKey:(NSString*)workKey onSNVersion:(NSString*)SNVersion;

# pragma mask : 刷卡: 有金额+无密码, 无金额+无密码,
- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onSNVersion:(NSString*)SNVersion;

#pragma mask : PIN加密
- (void) pinEncryptBySource:(NSString*)source withPan:(NSString*)pan onSNVersion:(NSString*)SNVersion;


@end
