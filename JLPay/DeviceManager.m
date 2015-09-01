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

/*
 *  厂商设备添加流程:
 *  1.interface属性中添加
 *  2.init中添加新设备操作类的初始化
 */

@interface DeviceManager()
< /* delegate */
JHLDevice_M60_Delegate
>

//@property (nonatomic, strong) JHLDevice*        JHL_A60_manager;    // 音频设备管理器 锦宏霖
//@property (nonatomic, strong) JHLDevice_M60*    JHL_M60_manager;    // 蓝牙设备管理器 锦宏霖

@property (nonatomic, strong) NSString*         deviceType;
@property (nonatomic, retain) id                device;
@end


@implementation DeviceManager
@synthesize deviceType = _deviceType;
@synthesize device;
@synthesize delegate;


static DeviceManager* _sharedDeviceManager = nil;

#pragma mask --------------------------[Public Interface]--------------------------

#pragma mask : 创建或获取设备操作入口:单例
+(DeviceManager*) sharedInstance {
    static dispatch_once_t desp;
    dispatch_once(&desp, ^{
        _sharedDeviceManager = [[DeviceManager alloc] init];
    });
    
    NSString* type = [[NSUserDefaults standardUserDefaults] valueForKey:DeviceType];
    if (!type) {
        return _sharedDeviceManager;
    }
    // 设备类型属性跟配置不一致就重置，并置空设备入口
    if (![type isEqualToString:_sharedDeviceManager.deviceType]) {
        _sharedDeviceManager.deviceType = type;
        _sharedDeviceManager.device = nil;
    }
    
    // 厂商设备入口创建   
    if (!_sharedDeviceManager.device) {
        if ([type isEqualToString:DeviceType_JHL_M60]) {
            NSLog(@"创建M60设备入口");
            _sharedDeviceManager.device = [[JHLDevice_M60 alloc] initWithDelegate:_sharedDeviceManager];
            
        } else if ([type isEqualToString:DeviceType_RF_BB01]) {
//            _sharedDeviceManager.device = [[RFDevice_BB01 alloc] init];
        } else if ([type isEqualToString:DeviceType_JHL_A60]) {
            
        }
    }
    return _sharedDeviceManager;
}

#pragma mask : 设置自动标记:是否自动打开设备
- (void) setOpenAutomaticaly:(BOOL)yesOrNo {
//    NSString* ideviceType = [[NSUserDefaults standardUserDefaults] valueForKey:DeviceType];
//    if ([self.deviceType isEqualToString:DeviceType_JHL_A60]) {          // 锦宏霖音频设备
//        
//    }
//    else if ([self.deviceType isEqualToString:DeviceType_JHL_M60]) {     // 锦宏霖蓝牙设备
////        [self.JHL_M60_manager setOpenAutomaticaly:yesOrNo];
//    }
}

#pragma mask : 开始扫描设备
- (void) startScanningDevices {
    [self.device startScanningDevices];
//    if ([self.deviceType isEqualToString:DeviceType_JHL_A60]) {          // 锦宏霖音频设备
//        
//    }
//    else if ([self.deviceType isEqualToString:DeviceType_JHL_M60]) {     // 锦宏霖蓝牙设备
////        [self.JHL_M60_manager startScanningDevices];
//    }
    
}

#pragma mask : 停止扫描设备
- (void) stopScanningDevices {
    [self.device stopScanningDevices];
//    if ([self.deviceType isEqualToString:DeviceType_JHL_A60]) {          // 锦宏霖音频设备
//        
//    }
//    else if ([self.deviceType isEqualToString:DeviceType_JHL_M60]) {     // 锦宏霖蓝牙设备
////        [self.JHL_M60_manager stopScanningDevices];
//    }
    
}
#pragma mask : 打开所有设备
- (void) openAllDevices{
    NSLog(@"打开所有设备");
    [self.device openAllDevices];
//    if ([self.deviceType isEqualToString:DeviceType_JHL_A60]) {          // 锦宏霖音频设备
//        
//    }
//    else if ([self.deviceType isEqualToString:DeviceType_JHL_M60]) {     // 锦宏霖蓝牙设备
////        [self.JHL_M60_manager openAllDevices];
//    }
}
#pragma mask : 关闭所有设备
- (void) closeAllDevices {
//    if ([self.deviceType isEqualToString:DeviceType_JHL_A60]) {          // 锦宏霖音频设备
//        
//    }
//    else if ([self.deviceType isEqualToString:DeviceType_JHL_M60]) {     // 锦宏霖蓝牙设备
////        [self.JHL_M60_manager closeAllDevices];
//    }
    [self.device closeAllDevices];

}
#pragma mask : 清空设备入口
- (void) clearAndCloseAllDevices {
    self.delegate = nil;
    [self.device setDelegate:nil];
    [self.device stopScanningDevices];
    [self.device closeAllDevices];
    self.device = nil;
    
}

#pragma mask : 打开设备,用SN打开
- (void) openDevice:(NSString*)SNVersion {
    [self.device openDevice:SNVersion];
//    if ([self.deviceType isEqualToString:DeviceType_JHL_A60]) {          // 锦宏霖音频设备
//        
//    }
//    else if ([self.deviceType isEqualToString:DeviceType_JHL_M60]) {     // 锦宏霖蓝牙设备
////        [self.JHL_M60_manager openDevice:SNVersion];
//    }

}
#pragma mask : 打开设备,用UUID打开
- (void) openDeviceWithIdentifier:(NSString*)identifier {
    [self.device openDeviceWithIdentifier:identifier];
//    [self.JHL_M60_manager openDeviceWithIdentifier:identifier];
}
#pragma mask : 关闭设备:用SN号关闭
- (void) closeDevice:(NSString*)SNVersion {
    [self.device closeDevice:SNVersion];
//    if ([self.deviceType isEqualToString:DeviceType_JHL_A60]) {          // 锦宏霖音频设备
//        
//    }
//    else if ([self.deviceType isEqualToString:DeviceType_JHL_M60]) {     // 锦宏霖蓝牙设备
////        [self.JHL_M60_manager closeDevice:SNVersion];
//    }
}
#pragma mask : SN号读取
- (void) readSNVersions{
    NSLog(@"读取所有SN号");
    [self.device readSNVersions];
//    if ([self.deviceType isEqualToString:DeviceType_JHL_A60]) {          // 锦宏霖音频设备
//        
//    }
//    else if ([self.deviceType isEqualToString:DeviceType_JHL_M60]) {     // 锦宏霖蓝牙设备
////        [self.JHL_M60_manager readSNVersions];
//    }
}

#pragma mask : ID读取
- (NSString*) identifierOnDeviceSN:(NSString*)SNVersion {
    if ([self.device respondsToSelector:@selector(identifierOnDeviceSN:)]) {
        return [self.device identifierOnDeviceSN:SNVersion];
    } else {
        return nil;
    }
}

#pragma mask : 判断指定终端号的设备是否已连接
//- (BOOL) isConnectedOnTerminalNum:(NSString*)terminalNum {
//    BOOL result = NO;
//    if ([[self deviceType] isEqualToString:DeviceType_JHL_A60]) {
//        
//    }
//    else if ([[self deviceType] isEqualToString:DeviceType_JHL_M60]) {
//        result = [self.JHL_M60_manager isConnectedOnTerminalNum:terminalNum];
//    }
//    return result;
//}


#pragma mask : 设备是否连接,用SN判断  *  0:已打开，未连接  1:已连接  -1:未打开
- (int) isConnectedOnSNVersionNum:(NSString*)SNVersion {
    int result = -1;
    result = [self.device isConnectedOnSNVersionNum:SNVersion];
//    if ([[self deviceType] isEqualToString:DeviceType_JHL_A60]) {
//        
//    }
//    else if ([[self deviceType] isEqualToString:DeviceType_JHL_M60]) {
////        result = [self.JHL_M60_manager isConnectedOnSNVersionNum:SNVersion];
//    }
    return result;
}

#pragma mask : 判断指定设备ID的设备是否已连接
- (int)isConnectedOnIdentifier:(NSString*)identifier {
    int result = -1;
    result = [self.device isConnectedOnIdentifier:identifier];
//    if ([[self deviceType] isEqualToString:DeviceType_JHL_A60]) {
//        
//    }
//    else if ([[self deviceType] isEqualToString:DeviceType_JHL_M60]) {
////        result = [self.JHL_M60_manager isConnectedOnIdentifier:identifier];
//    }
    return result;
}

#pragma mask : 设置设备主密钥(指定设备的SN号)
- (void) writeMainKey:(NSString*)mainKey onSNVersion:(NSString*)SNVersion {
    [self.device writeMainKey:mainKey onSNVersion:SNVersion];
//    if ([[self deviceType] isEqualToString:DeviceType_JHL_A60]) {
//        
//    }
//    else if ([[self deviceType] isEqualToString:DeviceType_JHL_M60]) {
////        [self.JHL_M60_manager writeMainKey:mainKey onSNVersion:SNVersion];
//    }

}
#pragma mask : 设置设备工作密钥(指定设备的终端号)
//- (void) writeWorkKey:(NSString*)workKey onTerminal:(NSString*)terminalNum {
//    if ([[self deviceType] isEqualToString:DeviceType_JHL_A60]) {
//        
//    }
//    else if ([[self deviceType] isEqualToString:DeviceType_JHL_M60]) {
//        [self.JHL_M60_manager writeWorkKey:workKey onTerminal:terminalNum];
//    }
//
//}
#pragma mask : 设置设备工作密钥(指定设备的SN号)
- (void) writeWorkKey:(NSString*)workKey onSNVersion:(NSString*)SNVersion {
    [self.device writeWorkKey:workKey onSNVersion:SNVersion];
//    if ([[self deviceType] isEqualToString:DeviceType_JHL_A60]) {
//        
//    }
//    else if ([[self deviceType] isEqualToString:DeviceType_JHL_M60]) {
//        [self.JHL_M60_manager writeWorkKey:workKey onSNVersion:SNVersion];
//    }
    
}

#pragma mask : 刷卡: 有金额+无密码, 无金额+无密码,
//- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onTerminal:(NSString*)terminalNum {
//    if ([[self deviceType] isEqualToString:DeviceType_JHL_A60]) {
//        
//    }
//    else if ([[self deviceType] isEqualToString:DeviceType_JHL_M60]) {
//        [self.JHL_M60_manager cardSwipeWithMoney:money yesOrNot:yesOrNot onTerminal:terminalNum];
//    }
//
//}
#pragma mask : 刷卡: 有金额+无密码, 无金额+无密码,
- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onSNVersion:(NSString*)SNVersion {
    [self.device cardSwipeWithMoney:money yesOrNot:yesOrNot onSNVersion:SNVersion];
//    if ([[self deviceType] isEqualToString:DeviceType_JHL_A60]) {
//        
//    }
//    else if ([[self deviceType] isEqualToString:DeviceType_JHL_M60]) {
//        [self.JHL_M60_manager cardSwipeWithMoney:money yesOrNot:yesOrNot onSNVersion:SNVersion];
//    }
    
}
#pragma mask : PIN加密
- (NSString *)pinEncryptBySource:(NSString *)source onSNVersion:(NSString *)SNVersion {
    NSString* pin;
    return pin;
}






#pragma mask ------------------------------------------------------------- JHLDevice_M60_Delegate

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
    NSLog(@"%s,DeviceManager didReadSNVersion:%@",__func__, SNVersion);

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
- (void)didCardSwipedSucOrFail:(BOOL)yesOrNo withError:(NSString *)error {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(deviceManager:didSwipeSuccessOrNot:withMessage:)]) {
        [self.delegate deviceManager:self didSwipeSuccessOrNot:yesOrNo withMessage:error];
    }
}


#pragma mask --------------------------[Private Interface]--------------------------


#pragma mask :  初始化;
- (instancetype)init {
    self = [super init];
//    if (self) {
//        _JHL_A60_manager = nil;
//        _JHL_M60_manager = [[JHLDevice_M60 alloc] init];
//        [_JHL_M60_manager setDelegate:self];
//    }
    return self;
}



#pragma mask --------------------------[GETTER & SETTER]--------------------------

#pragma mask : 获取配置中的设备类型
- (NSString *)deviceType {
    if (_deviceType == nil) {
        _deviceType = [[NSUserDefaults standardUserDefaults] valueForKey:DeviceType];
    }
    return _deviceType;
}


@end
