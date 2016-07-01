//
//  JLPayDevice_TY01.m
//  JLPay
//
//  Created by jielian on 15/9/8.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "JLPayDevice_TY01.h"


#define KeyDataPathNodeDataPath         @"KeyDataPathNodeDataPath"      // 设备dataPath
#define KeyDataPathNodeIdentifier       @"KeyDataPathNodeIdentifier"    // 设备ID
#define KeyDataPathNodeSNVersion        @"KeyDataPathNodeSNVersion"     // 设备SN号

#define TYDeviceName                    @"JLpay"                        // 蓝牙设备名字



@interface JLPayDevice_TY01()
<TYJieLianDelegate>
{
    BOOL cardSwipedSuccess;
}

@end



@implementation JLPayDevice_TY01
@synthesize connectedIdentifier = _connectedIdentifier;


#pragma mask 1 PUBLIC INTERFACE

// -- 1. 连接设备
- (void) connectWithId:(NSString*)identifier
           onConnected:(void (^) (NSString* SNVersion))connectedBlock
               onError:(void (^) (NSError* error))errorBlock
{
    _connectedIdentifier = identifier;
    self.connectedBlock = connectedBlock;
    self.errorBlock = errorBlock;
    // 扫描
    [self.deviceManager StartScanning];
}
// -- 2. 断开连接
- (void) disconnectOnFinished:(void (^) (void))finished {
    self.finishDisconnected = finished;
    [self.deviceManager disConnectDevice];
}

// -- 3. 判断连接状态
- (BOOL) isConnected {
    BOOL connected = NO;
    for (CBPeripheral* peripheral in self.deviceList) {
        if ([_connectedIdentifier isEqualToString:peripheral.identifier.UUIDString]) {
            if (peripheral.state == CBPeripheralStateConnected) {
                connected = YES;
            }
        }
    }
    return connected;
}


// -- pragma mask : 初始化,创建设备入口
- (instancetype)init {
    self = [super init];
    if (self) {
        self.deviceManager.delegate = self;
    }
    return self;
}
- (void)dealloc {
    [self.deviceManager setDelegate:nil];
    self.deviceManager = nil;
}





#pragma mask 2 TYJieLianDelegate

// -- pragma mask : 扫描到设备的回调
- (void)discoverPeripheralSuccess:(CBPeripheral *)peripheral {
    if (![peripheral.name hasPrefix:MPOSDeviceNamePreTY]) { //  TYDeviceName
        return;
    }
    if (![self.deviceList containsObject:peripheral]) {
        
        // add device into list
        [self.deviceList addObject:peripheral];
        
        // connect if equal connectedIdentifier
        if ([peripheral.identifier.UUIDString isEqualToString:self.connectedIdentifier]) {
            [self.deviceManager connectDevice:peripheral];
        }
    }
}

// -- pragma mask : 连接设备的回调
- (void)didConnectPeripheral:(CBPeripheral *)peripheral {
    [self.deviceManager GetSnVersion];    
}

// -- pragma mask : 设备丢失的回调
- (void)didDisconnectPeripheral:(CBPeripheral *)peripheral{
    JLPrint(@"丢失设备[%@]",peripheral.name);
    if (self.finishDisconnected) {
        self.finishDisconnected();
    }
}

// -- pragma mask : 设备返回数据
- (void)onReceive:(NSData *)data {
    Byte* bytesData = (Byte*)[data bytes];
    int result = (int)bytesData[1];
    switch (bytesData[0]) {
        case GETSNVERSION:
        {
            if (!result) {
                int len = (int)bytesData[2];
                NSMutableString* SNString = [[NSMutableString alloc] init];
                for (int i = 0; i < len; i++) {
                    [SNString appendFormat:@"%02x", bytesData[i + 3] & 0xff];
                }
                if (self.connectedBlock) {
                    self.connectedBlock(SNString);
                }
            } else {
                self.errorBlock([NSError errorWithDomain:nil code:DeviceManagerErrorTypeConnectFail localizedDescription:@"读取SN失败"]);
            }
        }
            break;
        case MAINKEY_CMD:
            if (!result) {
            } else {
            }
            break;
        case WORKKEY_CMD:
            if (!result) {
            } else {
            }
            break;
        case GETTRACKDATA_CMD:
            if (!result) {
                cardSwipedSuccess = YES;
            } else {
                cardSwipedSuccess = NO;
            }
            break;
        case GETMAC_CMD:
            if (!result) {
                NSString* dataString = [PublicInformation stringWithHexBytes2:data];
                NSString* macPin = [dataString substringWithRange:NSMakeRange(4, 16)];
                JLPrint(@"mac设备的计算结果:[%@]",macPin);
            } else {
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
                if ([[value substringFromIndex:value.length - 1] isEqualToString:@"F"]) {
                    value = [value substringToIndex:value.length - 1];
                }
                [cardInfo setValue:value forKey:@"35"];
            }
            // 三磁道
            else if ([key isEqualToString:@"encTrack3Ex"]) {
                if ([[value substringFromIndex:value.length - 1] isEqualToString:@"F"]) {
                    value = [value substringToIndex:value.length - 1];
                }
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
                if ([[value substringFromIndex:value.length - 1] isEqualToString:@"F"]) {
                    value = [value substringToIndex:value.length - 1];
                }
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

}




#pragma mask 3 PRIVATE INTERFACE



// -- 开启扫描
- (void) startDeviceScanning {
    [self.deviceList removeAllObjects];
    [self.deviceManager StartScanning];
}
// -- 关闭扫描
- (void) stopDeviceScanning {
    [self.deviceList removeAllObjects];
    [self.deviceManager stopScanning];
}
// -- 连接设备
- (void) connectingDevice:(CBPeripheral*)device {
    [self.deviceManager connectDevice:device];
}
// -- 断开设备连接
- (void) disConnectingDevice {
//    [self setConnectedIdentifier:nil];
    [self.deviceManager disConnectDevice];
}

#pragma mask 3 model: 工作密钥
- (NSString*) newWorkKeyFromSourceWorkKey:(NSString*)sourceWorkKey {
    NSString* newWorkKey = nil;
    NSString* pinKey = [sourceWorkKey substringToIndex:40];
    NSString* macKey = [sourceWorkKey substringFromIndex:40];
    NSString* newMacKey = [NSString stringWithFormat:@"%@%@%@",
                           [macKey substringToIndex:16],
                           [macKey substringToIndex:16],
                           [macKey substringFromIndex:macKey.length - 8]];
    newWorkKey = [NSString stringWithFormat:@"%@%@%@",pinKey,newMacKey,pinKey];
    return newWorkKey;
}

#pragma mask 3 model: 设备列表
// -- 设备节点: 指定ID
- (NSMutableDictionary* ) deviceNodeOnIdentifier:(NSString*)identifier {
    NSMutableDictionary* deviceNode = nil;
    for (NSMutableDictionary* dic in self.deviceList) {
        if (identifier && [identifier isEqualToString:[dic objectForKey:KeyDataPathNodeIdentifier]]) {
            deviceNode = dic;
            break;
        }
    }
    return deviceNode;
}
// -- 设备节点: 指定SN
- (NSMutableDictionary* ) deviceNodeOnSNVersion:(NSString*)SNVersion {
    NSMutableDictionary* deviceNode = nil;
    for (NSMutableDictionary* dic in self.deviceList) {
        if (SNVersion && [SNVersion isEqualToString:[dic objectForKey:KeyDataPathNodeSNVersion]]) {
            deviceNode = dic;
            break;
        }
    }
    return deviceNode;
}

// -- 设备入口: 指定ID
- (CBPeripheral* ) deviceOnIdentifier:(NSString*)identifier {
    CBPeripheral* device = nil;
    NSDictionary* deviceNode = [self deviceNodeOnIdentifier:identifier];
    if (deviceNode) {
        device = [deviceNode objectForKey:KeyDataPathNodeDataPath];
    }
    return device;
}
// -- 设备入口: 指定SN
- (CBPeripheral* ) deviceOnSNVersion:(NSString*)SNVersion {
    CBPeripheral* device = nil;
    NSDictionary* deviceNode = [self deviceNodeOnSNVersion:SNVersion];
    if (deviceNode) {
        device = [deviceNode objectForKey:KeyDataPathNodeDataPath];
    }
    return device;
}

// -- 添加SN到设备列表
- (void) addSNVersion:(NSString*)SNVersion onDeviceIdentifier:(NSString*)identifier {
    NSMutableDictionary* deviceNode = [self deviceNodeOnIdentifier:identifier];
    if (deviceNode) {
        [deviceNode setObject:SNVersion forKey:KeyDataPathNodeSNVersion];
    }
}
// -- 从设备列表移除SN
- (void) removeSNVersionOnDeviceIdentifier:(NSString*)identifier {
    NSMutableDictionary* deviceNode = [self deviceNodeOnIdentifier:identifier];
    if (deviceNode) {
        [self.deviceList removeObject:deviceNode];
    }
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
