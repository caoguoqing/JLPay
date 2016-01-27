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
@property (assign, nonatomic)       id<DeviceManagerDelegate> delegate;


# pragma mask : 设备管理器公共入口获取或创建
+(DeviceManager*) sharedInstance;


# pragma mask : 设置并创建指定的设备入口
- (void) makeDeviceEntryOnDeviceType:(NSString*)deviceType ;


# pragma mask : 打开指定 identifier 号的设备
- (void) openDeviceWithIdentifier:(NSString*)identifier;
# pragma mask : 判断指定SN号的设备是否已连接  *  0:已打开，未连接  1:已连接  -1:未打开
- (BOOL) isConnectedOnSNVersionNum:(NSString*)SNVersion;
# pragma mask : 判断指定设备ID的设备是否已连接 *  0:已打开，未连接  1:已连接  -1:未打开
- (BOOL) isConnectedOnIdentifier:(NSString*)identifier;
# pragma mask : 清空设备入口以及 delegate
- (void) clearAndCloseAllDevices;

# pragma mask : 设备ID:通过SN查找
- (NSString*) deviceIdentifierOnSN:(NSString*)SNVersion;


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


# pragma mask :  * 连接设备结果: 成功:返回了SN;
- (void) didConnectedDeviceResult:(BOOL)result onSucSN:(NSString*)SNVersion onErrMsg:(NSString*)errMsg;

# pragma mask :  * 丢失设备连接: SN
- (void) didDisconnectDeviceOnSN:(NSString*)SNVersion;

# pragma mask :  * 设备操作超时的回调
- (void) deviceManagerTimeOut;

# pragma mask :  * 刷卡结果
- (void) didCardSwipedResult:(BOOL)result onSucCardInfo:(NSDictionary*)cardInfo onErrMsg:(NSString*)errMsg;

# pragma mask :  * 写主密钥结果
- (void) didWroteMainKeyResult:(BOOL)result onErrMsg:(NSString*)errMsg;

# pragma mask :  * 写工作密钥结果
- (void) didWroteWorkKeyResult:(BOOL)result onErrMsg:(NSString*)errMsg;

# pragma mask :  * PIN加密结果
- (void) didPinEncryptResult:(BOOL)result onSucPin:(NSString*)pin onErrMsg:(NSString*)errMsg;

# pragma mask :  * MAC加密结果
- (void) didMacEncryptResult:(BOOL)result onSucMacPin:(NSString*)macPin onErrMsg:(NSString*)errMsg;


@end
