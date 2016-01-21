//
//  DeviceManager.m
//  JLPay
//
//  Created by jielian on 15/6/1.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "DeviceManager.h"
#import "Define_Header.h"
#import "JHLDevice.h"
#import "JHL_M60/ISControlManager.h"
#import "JHL_M60/JHLDevice_M60.h"
#import "RF_BB01/RFDevice_BB01.h"
#import "JLPayDevice_TY01.h"
#import "ModelDeviceBindedInformation.h"
#import "DLDevice_DL01.h"

/*
 *  厂商设备添加流程:
 *  1.interface属性中添加
 *  2.init中添加新设备操作类的初始化
 */

@interface DeviceManager()
< /* delegate */
JHLDevice_M60_Delegate,
RFDevice_BB01Delegate,
JLPayDevice_TY01_Delegate,
DLDevice_DL01Delegate
>
@property (nonatomic, retain) id                device;
@end


@implementation DeviceManager
@synthesize deviceType = _deviceType;
@synthesize device;
@synthesize delegate;


//static DeviceManager* _sharedDeviceManager = nil;

#pragma mask --------------------------[Public Interface]--------------------------

#pragma mask : 创建或获取设备操作入口:单例
+(DeviceManager*) sharedInstance {
    static DeviceManager* _sharedDeviceManager = nil;

    static dispatch_once_t desp;
    dispatch_once(&desp, ^{
        _sharedDeviceManager = [[DeviceManager alloc] init];
    });
//    [_sharedDeviceManager makeDeviceIfNeeded];
    JLPrint(@"====STMD 来获取设备入口了");
    return _sharedDeviceManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        // 如果已经选择过设备就直接创建设备入口
        [self makeDeviceIfNeeded];
//        if (_sharedDeviceManager.device == nil && _sharedDeviceManager.deviceType != nil) {
//            [_sharedDeviceManager makeDeviceEntryWithType:_sharedDeviceManager.deviceType];
//        }
    }
    return self;
}

#pragma mask : 开始扫描设备
- (void) startScanningDevices {
    JLPrint(@"%s 设备:[%@]",__func__, self.device);
    [self.device startScanningDevices];
}

#pragma mask : 停止扫描设备
- (void) stopScanningDevices {
    [self.device stopScanningDevices];
}
#pragma mask : 打开所有设备
- (void) openAllDevices{
    [self.device openAllDevices];
}
#pragma mask : 关闭所有设备
- (void) closeAllDevices {
    [self.device closeAllDevices];

}
#pragma mask : 清空设备入口
- (void) clearAndCloseAllDevices {
    self.delegate = nil;
    [self.device setDelegate:nil];
    [self.device stopScanningDevices];
    [self.device closeAllDevices];
    self.deviceType = nil;
    self.device = nil;
    
}

#pragma mask : 打开设备,用SN打开
- (void) openDevice:(NSString*)SNVersion {
    [self.device openDevice:SNVersion];
}
#pragma mask : 打开设备,用UUID打开
- (void) openDeviceWithIdentifier:(NSString*)identifier {
    [self.device openDeviceWithIdentifier:identifier];
}
#pragma mask : 关闭设备:用SN号关闭
- (void) closeDevice:(NSString*)SNVersion {
    [self.device closeDevice:SNVersion];
}
#pragma mask : SN号读取
- (void) readSNVersions{
    [self.device readSNVersions];
}

#pragma mask : ID读取
- (NSString*) identifierOnDeviceSN:(NSString*)SNVersion {
    if ([self.device respondsToSelector:@selector(identifierOnDeviceSN:)]) {
        return [self.device identifierOnDeviceSN:SNVersion];
    } else {
        return nil;
    }
}

#pragma mask : 设备是否连接,用SN判断  *  0:已打开，未连接  1:已连接  -1:未打开
- (int) isConnectedOnSNVersionNum:(NSString*)SNVersion {
    return [self.device isConnectedOnSNVersionNum:SNVersion];
}

#pragma mask : 判断指定设备ID的设备是否已连接
- (int)isConnectedOnIdentifier:(NSString*)identifier {
    return  [self.device isConnectedOnIdentifier:identifier];
}

#pragma mask : 设置设备主密钥(指定设备的SN号)
- (void) writeMainKey:(NSString*)mainKey onSNVersion:(NSString*)SNVersion {
    [self.device writeMainKey:mainKey onSNVersion:SNVersion];
}

#pragma mask : 设置设备工作密钥(指定设备的SN号)
- (void) writeWorkKey:(NSString*)workKey onSNVersion:(NSString*)SNVersion {
    [self.device writeWorkKey:workKey onSNVersion:SNVersion];
}

#pragma mask : 刷卡: 有金额+无密码, 无金额+无密码,
- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onSNVersion:(NSString*)SNVersion {
    [self.device cardSwipeWithMoney:money yesOrNot:yesOrNot onSNVersion:SNVersion];
}
#pragma mask : PIN加密
- (void) pinEncryptBySource:(NSString*)source withPan:(NSString*)pan onSNVersion:(NSString*)SNVersion {
    if ([self.device respondsToSelector:@selector(pinEncryptBySource:withPan:onSNVersion:)]) {
        [self.device pinEncryptBySource:source withPan:pan onSNVersion:SNVersion];
    }
}

# pragma mask : MAC加密
- (void) macEncryptBySource:(NSString*)source onSNVersion:(NSString*)SNVersion {
    if ([self.device respondsToSelector:@selector(macEncryptBySource:onSNVersion:)]) {
        [self.device macEncryptBySource:source onSNVersion:SNVersion];
    }
}






#pragma mask ------------------------------------------------------------- JHLDevice_M60_Delegate & RFDevice_BB01Delegate

#pragma mask : ID号扫描成功
- (void) didDiscoverDeviceOnID:(NSString*)identifier {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDiscoverDeviceOnID:)]) {
        [self.delegate didDiscoverDeviceOnID:identifier];
    }
}


#pragma mask : 连接设备结果的回调
- (void)didOpenDeviceSucOrFail:(BOOL)yesOrNo withError:(NSString *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deviceManager:didOpenSuccessOrNot:withMessage:)]) {
        [self.delegate deviceManager:self didOpenSuccessOrNot:yesOrNo withMessage:error];
    }
}

#pragma mask : SN号读取成功
- (void) didReadSNVersion:(NSString*)SNVersion sucOrFail:(BOOL)yesOrNo withError:(NSString*)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReadSNVersion:sucOrFail:withError:)]) {
        [self.delegate didReadSNVersion:SNVersion sucOrFail:yesOrNo withError:error];
    }
}
#pragma mask : 设备丢失:SN
- (void)deviceDisconnectOnSNVersion:(NSString *)SNVersion {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deviceDisconnectOnSNVersion:)]) {
        [self.delegate deviceDisconnectOnSNVersion:SNVersion];
    }
}
#pragma mask : 设置主密钥的回调
- (void)didWriteMainKeySucOrFail:(BOOL)yesOrNo withError:(NSString *)error {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(deviceManager:didWriteMainKeySuccessOrNot:withMessage:)]) {
        [self.delegate deviceManager:self didWriteMainKeySuccessOrNot:yesOrNo withMessage:error];
    }
}
#pragma mask : 设置工作密钥的回调
- (void)didWriteWorkKeySucOrFail:(BOOL)yesOrNo withError:(NSString *)error {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(deviceManager:didWriteWorkKeySuccessOrNot:)]) {
        [self.delegate deviceManager:self didWriteWorkKeySuccessOrNot:yesOrNo];
    }
}
#pragma mask : 刷卡的回调
- (void)didCardSwipedSucOrFail:(BOOL)yesOrNo withError:(NSString *)error andCardInfo:(NSDictionary *)cardInfo {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deviceManager:didSwipeSuccessOrNot:withMessage:andCardInfo:)]) {
        [self.delegate deviceManager:self didSwipeSuccessOrNot:yesOrNo withMessage:error andCardInfo:cardInfo];
    }
}





#pragma mask ------------------------------------------------------------- RFDevice_BB01Delegate

# pragma mask : PIN加密回调
- (void) didEncryptPinSucOrFail:(BOOL)yesOrNo pin:(NSString*)pin withError:(NSString*)error {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didEncryptPinSucOrFail:pin:withError:)]) {
        [self.delegate didEncryptPinSucOrFail:yesOrNo pin:pin withError:error];
    }
}

#pragma mask ------------------------------------------------------------- DLDevice_DL01Delegate

# pragma mask : MAC加密回调
- (void) didEncryptMacSucOrFail:(BOOL)yesOrNo macPin:(NSString*)macPin withError:(NSString*)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didEncryptMacSucOrFail:macPin:withError:)]) {
        [self.delegate didEncryptMacSucOrFail:yesOrNo macPin:macPin withError:error];
    }
}

#pragma mask --------------------------[Private Interface]--------------------------



#pragma mask : 设置并创建指定的设备入口
- (void) makeDeviceEntry{ //WithType:(NSString*)devitype {
   // self.deviceType //= devitype;
    if (self.device) {
        self.device = nil;
    }
    if ([self.deviceType isEqualToString:DeviceType_JHL_M60]) {
        self.device = [[JHLDevice_M60 alloc] initWithDelegate:self];
    }
    else if ([self.deviceType isEqualToString:DeviceType_RF_BB01]) {
        self.device = [[RFDevice_BB01 alloc] initWithDelegate:self];
    }
    else if ([self.deviceType isEqualToString:DeviceType_JLpay_TY01]) {
        self.device = [[JLPayDevice_TY01 alloc] initWithDelegate:self];
    }
    else if ([self.deviceType isEqualToString:DeviceType_DL01]) {
        self.device = [[DLDevice_DL01 alloc] initWithDelegate:self];
    }

}

- (void) makeDeviceIfNeeded {
    JLPrint(@"设备类型:[%@]",self.deviceType);
    if (!self.device && self.deviceType) {
//        [self makeDeviceEntryWithType:self.deviceType];
        [self makeDeviceEntry];
    }
}


#pragma mask --------------------------[GETTER & SETTER]--------------------------

#pragma mask : 获取配置中的设备类型
- (NSString *)deviceType {
    if (_deviceType == nil) {
        _deviceType = [ModelDeviceBindedInformation deviceTypeBinded];
    }
    return _deviceType;
}


@end
