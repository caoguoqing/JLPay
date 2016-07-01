//
//  DLDevice_DL01.h
//  JLPay
//
//  Created by jielian on 16/1/20.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DCSwiperAPI/DCSwiperAPI.h>
#import "Define_Header.h"



static NSString* const kDCDeviceInfoName = @"Name";
static NSString* const kDCDeviceInfoIdentifier = @"identifier";
static NSString* const kDCDeviceInfoKSN = @"SNversion";

static NSString* const kDCDeviceInfoPinKey = @"PINKey";
static NSString* const kDCDeviceInfoMacKey = @"MacKey";



@class DLDevice_DL01;
@protocol DLDevice_DL01Delegate <NSObject>

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


@interface DLDevice_DL01 : NSObject


# pragma mask : 初始化
- (instancetype)initWithDelegate:(id<DLDevice_DL01Delegate>)deviceDelegate ;

# pragma mask : 打开指定 identifier 号的设备
- (void) openDeviceWithIdentifier:(NSString*)identifier;
# pragma mask : 关闭所有蓝牙设备
- (void) clearAndCloseAllDevices;
# pragma mask : 判断指定SN号的设备是否已连接
- (BOOL) isConnectedOnSNVersionNum:(NSString*)SNVersion;
# pragma mask : 判断指定设备ID的设备是否已连接
- (BOOL) isConnectedOnIdentifier:(NSString*)identifier ;
# pragma mask : 设备ID:通过SN查找
- (NSString*) deviceIdentifierOnSN:(NSString*)SNVersion;


# pragma mask : 设置主密钥
- (void) writeMainKey:(NSString*)mainKey onSNVersion:(NSString*)SNVersion;
# pragma mask : 设置工作密钥
- (void) writeWorkKey:(NSString*)workKey onSNVersion:(NSString*)SNVersion;
# pragma mask : 刷卡: 有金额+无密码, 无金额+无密码,
- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onSNVersion:(NSString*)SNVersion;
#pragma mask : PIN加密
- (void) pinEncryptBySource:(NSString*)source withPan:(NSString*)pan onSNVersion:(NSString*)SNVersion;
# pragma mask : MAC加密
- (void) macEncryptBySource:(NSString*)source onSNVersion:(NSString*)SNVersion;

@end
