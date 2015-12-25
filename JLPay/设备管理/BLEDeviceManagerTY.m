//
//  BLEDeviceManagerTY.m
//  JLPay
//
//  Created by jielian on 15/12/25.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "BLEDeviceManagerTY.h"
#import "JieLianService.h"


static NSString* const BlueToothDeviceNameTY = @"JLpay";

static NSString* const kDeviceInfoIdentifierNeedConnect = @"kDeviceInfoIdentifierNeedConnect__"; // 需要连接的设备ID:只有绑定过的才占用这个字段
static NSString* const kDeviceInfoPeripheral = @"kDeviceInfoPeripheral__"; // 已识别的设备
static NSString* const kDeviceInfoSNVersion = @"kDeviceInfoSNVersion__"; // 已连接的设备SN


@interface BLEDeviceManagerTY()
<TYJieLianDelegate>
@property (nonatomic, retain) JieLianService* deviceManager;

@property (nonatomic, strong) NSMutableDictionary* deviceInfo; // 设备信息:

@end

@implementation BLEDeviceManagerTY

+ (instancetype)sharedInstance {
    static BLEDeviceManagerTY* deviceTY = nil;
    static dispatch_once_t dispatchOnceT;
    
    dispatch_once(&dispatchOnceT, ^{
        deviceTY = [[BLEDeviceManagerTY alloc] init];
    });
    return deviceTY;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.deviceManager = [[JieLianService alloc] init];
        [self.deviceManager setDelegate:self];
        self.deviceInfo = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void)dealloc {
    [self setDelegate:nil];
}

/* 检查设备是否连接 */
- (BOOL) isConnected {
    BOOL connected = NO;
    if ([self savedDevice]) {
        connected = ([self peripheralSaved].state == CBPeripheralStateConnected)?(YES):(NO);
    }
    return connected;
}


/* 连接、断开所有设备 */
- (void) connectAllDevices {
    [self.deviceManager StartScanning];
}
- (void) disConnectAllDevices {
    
}

/* 连接、断开设备: 指定SN */
- (void) connectDeviceOnIdentifier:(NSString*)identifier {

}
- (void) disConnectDeviceOnSN:(NSString*)SNVersion {
    
}

/* 写主密钥: 指定SN */
- (void) writeMainKey:(NSString*)mainKey onSN:(NSString*)SNVersion {
    
}
/* 写工作密钥: 指定SN */
- (void) writeWorkKey:(NSString *)workKey onSN:(NSString *)SNVersion {
    
}

/* 刷卡: 指定SN */
- (void) swipeCardOnSN:(NSString*)SNVersion {
    
}

#pragma mask ---- TYJieLianDelegate
/* 设备回调: 读取了卡数据 */
- (void)accessoryDidReadData:(NSDictionary *)data {
    NSLog(@"读到的卡数据:{%@}",data);
}

/* 设备回调: 设备操作结果 */
- (void)onReceive:(NSData *)data {
    Byte* resDatas = (Byte*)[data bytes];
    int command = (int)*(resDatas++);
    int state = (int)*(resDatas++); // 0:成功; 1:失败;
    
    switch (command) {
        case GETSNVERSION:
        {
            if (state == 0) {
                int leng = (int)*(resDatas++);
                NSMutableString* SNVersion = [[NSMutableString alloc] init];
                for (int i = 0; i < leng; i++) {
                    [SNVersion appendFormat:@"%02x", *(resDatas++) & 0xff];
                }
                [self savingDeviceSN:SNVersion];
                if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectedDeviceSucOnSN:identifier:)]) {
                    [self.delegate didConnectedDeviceSucOnSN:SNVersion identifier:[self peripheralSaved].identifier.UUIDString];
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectedDeviceFail:OnSN:)]) {
                    
                }
            }
        }
            break;
        case MAINKEY_CMD:
            
            break;
        case WORKKEY_CMD:
            
            break;
        case GETTRACKDATA_CMD:
            
            break;
        default:
            break;
    }
    
}

/* 设备回调: 成功扫描到设备 */
- (void)discoverPeripheralSuccess:(CBPeripheral *)peripheral {
    // 先检查是否需要保存扫描到的设备
    if (![self savedDevice]) {
        if ([self hasDesignatedDeviceIdentifier]) {
            if ([self isDesignatedPeripheral:peripheral]) {
                [self savingPeripheral:peripheral];
            }
        } else {
            [self savingPeripheral:peripheral];
        }
        
        // 保存设备入口后就可以连接设备了
        if ([self savedDevice]) {
            [self connectDevice];
        }
    }
}
/* 设备回调: 成功连接设备 */
- (void)didConnectPeripheral:(CBPeripheral *)peripheral {
    // 读取SN
    int result = [self.deviceManager GetSnVersion];
    NSLog(@"GetSnVersion的返回值:[%d]",result);
}
/* 设备回调: 设备断开连接 */
- (void)didDisconnectPeripheral:(CBPeripheral *)peripheral {
    if ([self savedDevice]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDisConnectedDeviceOnSN:)]) {
            [self.delegate didDisConnectedDeviceOnSN:[self deviceSNofSaved]];
        }
        
        // 断开设备要不要清楚数据源
        [self clearPeripheral];
        [self clearDeviceSN];
        [self clearNeedConnectIdentifier];
    }
}

#pragma mask ---- PRIVATE INTERFACE

#pragma mask ---- 设备操作
/* 连接设备 */
- (void) connectDevice {
    [self.deviceManager connectDevice:[self peripheralSaved]];
}
/* 断开设备 */
- (void) disconnectDevice {
    [self.deviceManager stopScanning];
    [self.deviceManager disConnectDevice];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDisConnectedDeviceOnSN:)]) {
        [self.delegate didDisConnectedDeviceOnSN:[self deviceSNofSaved]];
    }

    // 断开设备要不要清楚数据源
    [self clearPeripheral];
    [self clearDeviceSN];
    [self clearNeedConnectIdentifier];
}



#pragma mask ---- 数据源操作

/* 是否指定了需要连接的设备ID */
- (BOOL) hasDesignatedDeviceIdentifier {
    if (self.deviceInfo[kDeviceInfoIdentifierNeedConnect]) {
        return YES;
    } else {
        return NO;
    }
}
/* 设备是否为指定的需要连接的设备 */
- (BOOL) isDesignatedPeripheral:(CBPeripheral*)peripheral {
    return [peripheral.identifier.UUIDString isEqualToString:self.deviceInfo[kDeviceInfoIdentifierNeedConnect]];
}


/* 指定的需要连接的设备ID */
- (NSString*) deviceIdentifierNeedConnect {
    return self.deviceInfo[kDeviceInfoIdentifierNeedConnect];
}

/* 保存: ID */
- (void) savingNeedConnectIdentifier:(NSString*)identifier {
    self.deviceInfo[kDeviceInfoIdentifierNeedConnect] = identifier;
}
/* 清除保存的ID */
- (void) clearNeedConnectIdentifier {
    [self.deviceInfo removeObjectForKey:kDeviceInfoIdentifierNeedConnect];
}

/* 是否已经保存了检索到的设备 */
- (BOOL) savedDevice {
    if (self.deviceInfo[kDeviceInfoPeripheral]) {
        return YES;
    } else {
        return NO;
    }
}

/* 指定设备是否为保存的设备 */
//- (BOOL) isEqualSavedPeripheralWithPeripheral:(CBPeripheral*)peripheral {
//    return [peripheral.identifier.UUIDString isEqualToString:[self peripheralSaved].identifier.UUIDString];
//}

/* 设备是否是已保存的设备 */
- (BOOL) savedPeripheralIsPeripheral:(CBPeripheral*)peripheral {
    return [peripheral.identifier.UUIDString isEqualToString:[self peripheralSaved].identifier.UUIDString];
}

/* 设备: 已保存对的 */
- (CBPeripheral*) peripheralSaved {
    return self.deviceInfo[kDeviceInfoPeripheral];
}

/* 保存设备 */
- (void) savingPeripheral:(CBPeripheral*)peripheral {
    self.deviceInfo[kDeviceInfoPeripheral] = peripheral;
}

/* 清除设备 */
- (void) clearPeripheral {
    [self.deviceInfo removeObjectForKey:kDeviceInfoPeripheral];
}

/* SN: 保存的 */
- (NSString*) deviceSNofSaved {
    return self.deviceInfo[kDeviceInfoSNVersion];
}

/* 保存SN */
- (void) savingDeviceSN:(NSString*)SNVersion {
    self.deviceInfo[kDeviceInfoSNVersion] = SNVersion;
}

/* 清除SN */
- (void) clearDeviceSN {
    [self.deviceInfo removeObjectForKey:kDeviceInfoSNVersion];
}




@end
