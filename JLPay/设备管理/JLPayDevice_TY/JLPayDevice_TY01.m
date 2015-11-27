//
//  JLPayDevice_TY01.m
//  JLPay
//
//  Created by jielian on 15/9/8.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "JLPayDevice_TY01.h"
#import "JieLianService.h"
#import "Define_Header.h"

@interface JLPayDevice_TY01()
<
TYJieLianDelegate
>
{
    BOOL cardSwipedSuccess;
}

@property (nonatomic, retain) JieLianService* deviceManager;
@property (nonatomic, strong) NSMutableArray* deviceList;
@property (nonatomic, strong) CBPeripheral* connectedPeripheral;
@end



@implementation JLPayDevice_TY01
@synthesize deviceManager = _deviceManager;
@synthesize deviceList = _deviceList;
@synthesize connectedPeripheral;


#define KeyDataPathNodeDataPath         @"KeyDataPathNodeDataPath"      // 设备dataPath
#define KeyDataPathNodeIdentifier       @"KeyDataPathNodeIdentifier"    // 设备ID
#define KeyDataPathNodeSNVersion        @"KeyDataPathNodeSNVersion"     // 设备SN号

#define TYDeviceName                    @"JLpay"                        // 蓝牙设备名字






#pragma mask -------------------------------------------------------- PUBLIC INTERFACE

- (void)openAllDevices{}


#pragma mask : 初始化,创建设备入口
- (instancetype)initWithDelegate:(id<JLPayDevice_TY01_Delegate>)deviceDelegate {
    self = [super init];
    if (self) {
        self.delegate = deviceDelegate;
        [self.deviceManager setDelegate: self];
    }
    return self;
}
- (void)dealloc {
    [self setDelegate:nil];
    [self.deviceManager setDelegate:nil];
    self.deviceManager = nil;
}

#pragma mask : 扫描设备
- (void)startScanningDevices {
    [self.deviceManager stopScanning];
    [self.deviceList removeAllObjects];
    [self.deviceManager StartScanning];
}

#pragma mask : 扫描停止
- (void)stopScanningDevices {
    [self.deviceManager stopScanning];
}

#pragma mask : 断开设备
- (void)closeAllDevices{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.deviceManager disConnectDevice];
    });
}


- (void)readSNVersions {}
- (void)closeDevice:(NSString *)SNVersion{}
- (void)openDevice:(NSString *)SNVersion{}


#pragma mask : 判断设备连接:SN
- (int)isConnectedOnSNVersionNum:(NSString *)SNVersion {
    int connected = -1;
    for (NSDictionary* dict in self.deviceList) {
        
        if ([SNVersion isEqualToString:[dict valueForKey:KeyDataPathNodeSNVersion]]) {
            CBPeripheral* peripheral = [dict objectForKey:KeyDataPathNodeDataPath];
            if (peripheral.state == CBPeripheralStateConnected) {
                connected = 1;
            } else if (peripheral.state == CBPeripheralStateConnecting) {
                connected = 0;
            } else {
                connected = -1;
            }
            break;
        }
    }
    return connected;
}
#pragma mask : 判断设备连接:SN
- (int)isConnectedOnIdentifier:(NSString *)identifier {
    int connected = -1;
    for (NSDictionary* dict in self.deviceList) {
        if ([identifier isEqualToString:[dict valueForKey:KeyDataPathNodeIdentifier]]) {
            CBPeripheral* peripheral = [dict objectForKey:KeyDataPathNodeDataPath];
            if (peripheral.state == CBPeripheralStateConnected) {
                connected = 1; // 连接
            } else if (peripheral.state == CBPeripheralStateConnecting) {
                connected = 0;  // 正在连接
            } else {
                connected = -1; // 未连接
            }
            break;
        }
    }
    return connected;
}

#pragma mask : 设备ID获取:on SN
- (NSString *)identifierOnDeviceSN:(NSString *)SNVersion {
    NSString* identifier = nil;
    for (NSDictionary* dict in self.deviceList) {
        if ([[dict valueForKey:KeyDataPathNodeSNVersion] isEqualToString:SNVersion]) {
            identifier = [dict valueForKey:KeyDataPathNodeIdentifier];
        }
    }
    return identifier;
}

#pragma mask : 连接设备
- (void)openDeviceWithIdentifier:(NSString *)identifier {
    for (NSDictionary* dict in self.deviceList) {
        if ([identifier isEqualToString:[dict valueForKey:KeyDataPathNodeIdentifier]]) {
            CBPeripheral* peripheral = [dict objectForKey:KeyDataPathNodeDataPath];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.deviceManager connectDevice:peripheral];
            });
            break;
        }
    }
}

#pragma mask : 写主密钥
- (void)writeMainKey:(NSString *)mainKey onSNVersion:(NSString *)SNVersion {
    CBPeripheral* peripheral = [self peripheralOnSNVersion:SNVersion];
    if (peripheral) {
        [self.deviceManager WriteMainKey:16 :mainKey];
    }
}
#pragma mask : 写工作密钥
- (void)writeWorkKey:(NSString *)workKey onSNVersion:(NSString *)SNVersion {
    CBPeripheral* peripheral = [self peripheralOnSNVersion:SNVersion];
    if (peripheral) {
        [self.deviceManager WriteWorkKey:60 :workKey];
    }
}

#pragma mask : 刷卡
- (void)cardSwipeWithMoney:(NSString *)money yesOrNot:(BOOL)yesOrNot onSNVersion:(NSString *)SNVersion {
    CBPeripheral* peripheral = [self peripheralOnSNVersion:SNVersion];
    if (peripheral) {
        [self.deviceManager MagnAmountPasswordCardAmount:money TimeOut:20];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedSucOrFail:withError:andCardInfo:)]) {
            [self.delegate didCardSwipedSucOrFail:NO withError:@"设备未连接" andCardInfo:nil];
        }
    }
}

#pragma mask : 密文密码获取
- (void)pinEncryptBySource:(NSString *)source withPan:(NSString *)pan onSNVersion:(NSString *)SNVersion {}






#pragma mask ------------------------------------------------------------- TYJieLianDelegate

#pragma mask : 扫描到设备的回调
- (void)discoverPeripheralSuccess:(CBPeripheral *)peripheral {
    if (![peripheral.name hasPrefix:TYDeviceName]) {
        return;
    }
    
    BOOL isExist = NO;
    // 检查设备是否已存在
    for (NSDictionary* dict in self.deviceList) {
        CBPeripheral* iperipheral = [dict objectForKey:KeyDataPathNodeDataPath];
        if ([iperipheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
            isExist = YES;
            break;
        }
    }
    if (!isExist) {
        // 设备列表追加
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setObject:peripheral forKey:KeyDataPathNodeDataPath];
        [dict setValue:peripheral.identifier.UUIDString forKey:KeyDataPathNodeIdentifier];
        [self.deviceList addObject:dict];
        // 扫描到一个设备就关闭扫描
        [self.deviceManager stopScanning];
        // 引发回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDiscoverDeviceOnID:)]) {
            [self.delegate didDiscoverDeviceOnID:peripheral.identifier.UUIDString];
        }
    }
}


#pragma mask : 连接设备的回调
- (void)didConnectPeripheral:(CBPeripheral *)peripheral {
    self.connectedPeripheral = peripheral;
    for (NSDictionary* dict in self.deviceList) {
        CBPeripheral* iperipheral = [dict objectForKey:KeyDataPathNodeDataPath];
        if ([peripheral.identifier.UUIDString isEqualToString:iperipheral.identifier.UUIDString]) {
            // 读取SN
            [self.deviceManager GetSnVersion];
            break;
        }
    }
}

#pragma mask : 设备丢失的回调
- (void)didDisconnectPeripheral:(CBPeripheral *)peripheral{
    self.connectedPeripheral = nil;
    for (NSDictionary* dict in self.deviceList) {
        if ([[dict valueForKey:KeyDataPathNodeIdentifier] isEqualToString:peripheral.identifier.UUIDString]) {
        }
    }
}

#pragma mask : 设备返回数据
- (void)onReceive:(NSData *)data {
    Byte* bytesData = (Byte*)[data bytes];
    int result = (int)bytesData[1];
    CBPeripheral* onRececeivePeripheral = nil;
    for (NSDictionary* dict in self.deviceList) {
        if ([[dict objectForKey:KeyDataPathNodeIdentifier] isEqualToString:self.connectedPeripheral.identifier.UUIDString]) {
            onRececeivePeripheral = [dict objectForKey:KeyDataPathNodeDataPath];
        }
    }
    switch (bytesData[0]) {
        case GETSNVERSION:
        {
            if (!result) {
                int len = (int)bytesData[2];
                NSMutableString* SNString = [[NSMutableString alloc] init];
                for (int i = 0; i < len; i++) {
                    [SNString appendFormat:@"%02x", bytesData[i + 3] & 0xff];
                }
                // 更新SN到设备池
                for (NSDictionary* dict in self.deviceList) {
                    if ([[dict valueForKey:KeyDataPathNodeIdentifier] isEqualToString:self.connectedPeripheral.identifier.UUIDString]) {
                        [dict setValue:SNString forKey:KeyDataPathNodeSNVersion];
                    }
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(didReadSNVersion:sucOrFail:withError:)]) {
                    [self.delegate didReadSNVersion:SNString sucOrFail:YES withError:nil];
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didReadSNVersion:sucOrFail:withError:)]) {
                    [self.delegate didReadSNVersion:nil sucOrFail:NO withError:@"读取SN号失败"];
                }
            }
        }
            break;
        case MAINKEY_CMD:
            if (!result) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteMainKeySucOrFail:withError:)]) {
                    [self.delegate didWriteMainKeySucOrFail:YES withError:nil];
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteMainKeySucOrFail:withError:)]) {
                    [self.delegate didWriteMainKeySucOrFail:NO withError:@"下载主密钥失败"];
                }
            }
            break;
        case WORKKEY_CMD:
            if (!result) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteWorkKeySucOrFail:withError:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate didWriteWorkKeySucOrFail:YES withError:nil];
                    });
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteWorkKeySucOrFail:withError:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate didWriteWorkKeySucOrFail:NO withError:@"下载工作密钥失败"];
                    });
                }
            }
            break;
        case GETTRACKDATA_CMD:
            if (!result) {
                cardSwipedSuccess = YES;
            } else {
                cardSwipedSuccess = NO;
                if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedSucOrFail:withError:andCardInfo:)]) {
                    [self.delegate didCardSwipedSucOrFail:NO withError:@"刷卡失败" andCardInfo:nil];
                }
            }
            break;
        default:
            break;
    }
}


#pragma mask : 刷卡的回调
- (void)accessoryDidReadData:(NSDictionary *)data {
    if (!cardSwipedSuccess) {
        return;
    }
    NSMutableString* f22 = [NSMutableString stringWithString:@"0000"];
    if ([[data valueForKey:@"cardType"] isEqualToString:@"01"]) {
        [f22 replaceCharactersInRange:NSMakeRange(1, 1) withString:@"5"];
    } else {
        [f22 replaceCharactersInRange:NSMakeRange(1, 1) withString:@"2"];
    }
    
    // 回调带回的卡数据信息字典
    NSMutableDictionary* cardInfo = [[NSMutableDictionary alloc] init];
    
    for (NSString* key in data.allKeys) {
        NSString* value = [data valueForKey:key];
        if (!value || value.length == 0) {
            continue;
        }
        if ([f22 hasPrefix:@"02"]) {    // 磁条卡
            // 卡号
            if ([key isEqualToString:@"cardNumber"]) {
                [cardInfo setValue:value forKey:@"2"];
            }
            // 二磁道
            else if ([key isEqualToString:@"encTrack2Ex"]) {
                [cardInfo setValue:value forKey:@"35"];
            }
            // 三磁道
            else if ([key isEqualToString:@"encTrack3Ex"]) {
                [cardInfo setValue:value forKey:@"36"];
            }
            // 密文密码
            else if ([key isEqualToString:@"pinBlock"]) {
                [cardInfo setValue:value forKey:@"52"];
            }
            // 有效期
            else if ([key isEqualToString:@"cardValidDate"]) {
                [cardInfo setValue:value forKey:@"14"];
            }
        } else {                // IC卡
            // 卡号
            if ([key isEqualToString:@"cardNumber"]) {
                [cardInfo setValue:value forKey:@"2"];
            }
            // 二磁道
            else if ([key isEqualToString:@"track2Data"]) {
                [cardInfo setValue:value forKey:@"35"];
            }
            // 密文密码
            else if ([key isEqualToString:@"pinBlock"]) {
                [cardInfo setValue:value forKey:@"52"];
            }
            // 卡有效期
            else if ([key isEqualToString:@"cardValidDate"]) {
                [cardInfo setValue:value forKey:@"14"];
            }
            // 卡序列号
            else if ([key isEqualToString:@"masterSN"]) {
                while (value.length < 4) {
                    value = [@"0" stringByAppendingString:value];
                }
                [cardInfo setValue:value forKey:@"23"];
            }
            // IC卡数据
            else if ([key isEqualToString:@"ic_authData"]) {
                [cardInfo setValue:value forKey:@"55"];
            }
        }
    }
    
    NSString* pin = [data valueForKey:@"pinBlock"];
    if (pin && pin.length == 16) {
        [f22 replaceCharactersInRange:NSMakeRange(2, 1) withString:@"1"];
        [cardInfo setValue:@"2600000000000000" forKey:@"53"];
    } else {
        [cardInfo setValue:@"0600000000000000" forKey:@"53"];
    }
    [cardInfo setValue:f22 forKey:@"22"];

    if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedSucOrFail:withError:andCardInfo:)]) {
        [self.delegate didCardSwipedSucOrFail:YES withError:nil andCardInfo:cardInfo];
    }
}









#pragma mask ------------------------------------ PRIVATE INTERFACE

#pragma mask : 根据SN获取设备入口
- (CBPeripheral*) peripheralOnSNVersion:(NSString*)SNVersion {
    CBPeripheral* peripheral = nil;
    for (NSDictionary* dict in self.deviceList) {
        if ([[dict valueForKey:KeyDataPathNodeSNVersion] isEqualToString:SNVersion]) {
            peripheral = [dict objectForKey:KeyDataPathNodeDataPath];
        }
    }
    return peripheral;
}

#pragma mask : 根据ID获取设备入口
- (CBPeripheral*) peripheralOnIdentifier:(NSString*)identifier {
    CBPeripheral* peripheral = nil;
    for (NSDictionary* dict in self.deviceList) {
        if ([[dict valueForKey:KeyDataPathNodeIdentifier] isEqualToString:identifier]) {
            peripheral = [dict objectForKey:KeyDataPathNodeDataPath];
        }
    }
    return peripheral;
}







#pragma mask : getter 
- (JieLianService *)deviceManager {
    if (_deviceManager == nil) {
        _deviceManager = [[JieLianService alloc] init];
    }
    return _deviceManager;
}
- (NSMutableArray *)deviceList {
    if (_deviceList == nil) {
        _deviceList = [[NSMutableArray alloc] init];
    }
    return _deviceList;
}


@end
