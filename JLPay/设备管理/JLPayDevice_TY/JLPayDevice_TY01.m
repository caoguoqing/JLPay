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
#import "PublicInformation.h"

@interface JLPayDevice_TY01()
<TYJieLianDelegate>
{
    BOOL cardSwipedSuccess;
}
@property (assign) id<JLPayDevice_TY01_Delegate> delegate;

@property (nonatomic, retain) JieLianService* deviceManager;
@property (nonatomic, strong) NSMutableArray* deviceList;

@property (nonatomic, strong) NSString* connectedIdentifier;
@end



@implementation JLPayDevice_TY01
@synthesize deviceManager = _deviceManager;
@synthesize deviceList = _deviceList;


#define KeyDataPathNodeDataPath         @"KeyDataPathNodeDataPath"      // 设备dataPath
#define KeyDataPathNodeIdentifier       @"KeyDataPathNodeIdentifier"    // 设备ID
#define KeyDataPathNodeSNVersion        @"KeyDataPathNodeSNVersion"     // 设备SN号

#define TYDeviceName                    @"JLpay"                        // 蓝牙设备名字




#pragma mask 1 PUBLIC INTERFACE


// -- pragma mask : 初始化,创建设备入口
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

// -- pragma mask : 连接设备
- (void)openDeviceWithIdentifier:(NSString *)identifier {
    // 0.设置已连接设备的id
    [self setConnectedIdentifier:identifier];
    // 1.开启扫描
    [self startDeviceScanning];
}

// -- pragma mask : 关闭所有蓝牙设备
- (void) clearAndCloseAllDevices {
    [self setDelegate:nil];
    [self.deviceManager setDelegate:nil];
    [self stopDeviceScanning];
    [self disConnectingDevice];
}


// -- pragma mask : 判断设备连接:SN
- (BOOL)isConnectedOnSNVersionNum:(NSString *)SNVersion {
    BOOL connected = NO;
    NSDictionary* deviceNode = [self deviceNodeOnSNVersion:SNVersion];
    if (deviceNode && [[deviceNode objectForKey:KeyDataPathNodeIdentifier] isEqualToString:self.connectedIdentifier]) {
        connected = YES;
    }
    return connected;
}
// -- pragma mask : 判断设备连接:SN
- (BOOL)isConnectedOnIdentifier:(NSString *)identifier {
    BOOL connected = NO;
    NSDictionary* deviceNode = [self deviceNodeOnIdentifier:identifier];
    if (deviceNode && [identifier isEqualToString:self.connectedIdentifier]) {
        connected = YES;
    }
    return connected;
}

// -- pragma mask : ID设备获取:根据SN号获取对应设备
- (NSString*) deviceIdentifierOnSN:(NSString*)SNVersion {
    NSString* identifier = nil;
    NSDictionary* deviceNode = [self deviceNodeOnSNVersion:SNVersion];
    if (deviceNode) {
        identifier = [deviceNode objectForKey:KeyDataPathNodeIdentifier];
    }
    return identifier;
}

// -- pragma mask : 写主密钥
- (void)writeMainKey:(NSString *)mainKey onSNVersion:(NSString *)SNVersion {
    if (![self isConnectedOnSNVersionNum:SNVersion]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteMainKeyResult:onErrMsg:)]) {
            [self.delegate didWroteMainKeyResult:NO onErrMsg:@"设备未连接"];
        }
        return;
    }
    [self.deviceManager WriteMainKey:16 :mainKey];
}
// -- pragma mask : 写工作密钥
- (void)writeWorkKey:(NSString *)workKey onSNVersion:(NSString *)SNVersion {
    if (![self isConnectedOnSNVersionNum:SNVersion]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteWorkKeyResult:onErrMsg:)]) {
            [self.delegate didWroteWorkKeyResult:NO onErrMsg:@"设备未连接"];
        }
        return;
    }
    // 因为不用 TRK_KEY 了,将 PIN_KEY 当 TRK_KEY 用;
    [self.deviceManager WriteWorkKey:60 :[self newWorkKeyFromSourceWorkKey:workKey]];
}

// -- pragma mask : 刷卡
- (void)cardSwipeWithMoney:(NSString *)money yesOrNot:(BOOL)yesOrNot onSNVersion:(NSString *)SNVersion {
    if (![self isConnectedOnSNVersionNum:SNVersion]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedResult:onSucCardInfo:onErrMsg:)]) {
            [self.delegate didCardSwipedResult:NO onSucCardInfo:nil onErrMsg:@"设备未连接"];
        }
        return;
    }
    [self.deviceManager MagnAmountPasswordCardAmount:money TimeOut:20];
}


// -- pragma mask : MAC加密
- (void) macEncryptBySource:(NSString*)source onSNVersion:(NSString*)SNVersion {
    if (![self isConnectedOnSNVersionNum:SNVersion]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didMacEncryptResult:onSucMacPin:onErrMsg:)]) {
            [self.delegate didMacEncryptResult:NO onSucMacPin:nil onErrMsg:@"设备未连接"];
        }
    }
    [self.deviceManager GetMac:(int)source.length/2 :source];
}





#pragma mask 2 TYJieLianDelegate

// -- pragma mask : 扫描到设备的回调
- (void)discoverPeripheralSuccess:(CBPeripheral *)peripheral {
    if (![peripheral.name hasPrefix:TYDeviceName]) {
        return;
    }
    
    // 检查设备是否存在
    BOOL isExist = NO;
    NSString* deviceIdentifier = peripheral.identifier.UUIDString;
    if ([self deviceNodeOnIdentifier:deviceIdentifier]) {
        isExist = YES;
    }
    if (!isExist) {
        // 设备列表追加
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setObject:peripheral forKey:KeyDataPathNodeDataPath];
        [dict setObject:deviceIdentifier forKey:KeyDataPathNodeIdentifier];
        [self.deviceList addObject:dict];
        // 是否连接设备
        if (self.connectedIdentifier) {
            if ([self.connectedIdentifier isEqualToString:deviceIdentifier]) {
                [self connectingDevice:peripheral];
            }
        } else {
            [self setConnectedIdentifier:deviceIdentifier];
            [self connectingDevice:peripheral];
        }
    }
}


// -- pragma mask : 连接设备的回调
- (void)didConnectPeripheral:(CBPeripheral *)peripheral {
    [self.deviceManager GetSnVersion];    
}

// -- pragma mask : 设备丢失的回调
- (void)didDisconnectPeripheral:(CBPeripheral *)peripheral{
    NSString* deviceIdentifier = peripheral.identifier.UUIDString;
    NSDictionary* deviceNode = [self deviceNodeOnIdentifier:deviceIdentifier];
    if (deviceNode) {
        NSString* SNVersion = [deviceNode objectForKey:KeyDataPathNodeSNVersion];
        if (SNVersion) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didDisconnectDeviceOnSN:)]) {
                [self.delegate didDisconnectDeviceOnSN:SNVersion];
            }
            [self removeSNVersionOnDeviceIdentifier:deviceIdentifier];
        }
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
                // 更新SN到设备池
                for (NSDictionary* dict in self.deviceList) {
                    if ([[dict valueForKey:KeyDataPathNodeIdentifier] isEqualToString:self.connectedIdentifier]) {
                        [dict setValue:SNString forKey:KeyDataPathNodeSNVersion];
                    }
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectedDeviceResult:onSucSN:onErrMsg:)]) {
                    [self.delegate didConnectedDeviceResult:YES onSucSN:SNString onErrMsg:nil];
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectedDeviceResult:onSucSN:onErrMsg:)]) {
                    [self.delegate didConnectedDeviceResult:NO onSucSN:nil onErrMsg:@"设备SN号读取失败"];
                }
            }
        }
            break;
        case MAINKEY_CMD:
            if (!result) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteMainKeyResult:onErrMsg:)]) {
                    [self.delegate didWroteMainKeyResult:YES onErrMsg:nil];
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteMainKeyResult:onErrMsg:)]) {
                    [self.delegate didWroteMainKeyResult:NO onErrMsg:@"下载主密钥失败"];
                }
            }
            break;
        case WORKKEY_CMD:
            if (!result) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteWorkKeyResult:onErrMsg:)]) {
                    [self.delegate didWroteWorkKeyResult:YES onErrMsg:nil];
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteWorkKeyResult:onErrMsg:)]) {
                    [self.delegate didWroteWorkKeyResult:NO onErrMsg:@"下载工作密钥失败"];
                }
            }
            break;
        case GETTRACKDATA_CMD:
            if (!result) {
                cardSwipedSuccess = YES;
            } else {
                cardSwipedSuccess = NO;
                if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedResult:onSucCardInfo:onErrMsg:)]) {
                    [self.delegate didCardSwipedResult:NO onSucCardInfo:nil onErrMsg:@"刷卡失败"];
                }
            }
            break;
        case GETMAC_CMD:
            if (!result) {
                NSString* dataString = [PublicInformation stringWithHexBytes2:data];
                NSString* macPin = [dataString substringWithRange:NSMakeRange(4, 16)];
                JLPrint(@"mac设备的计算结果:[%@]",macPin);
                if (self.delegate && [self.delegate respondsToSelector:@selector(didMacEncryptResult:onSucMacPin:onErrMsg:)]) {
                    [self.delegate didMacEncryptResult:YES onSucMacPin:macPin onErrMsg:nil];
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didMacEncryptResult:onSucMacPin:onErrMsg:)]) {
                    [self.delegate didMacEncryptResult:NO onSucMacPin:nil onErrMsg:@"MAC加密失败"];
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

    if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedResult:onSucCardInfo:onErrMsg:)]) {
        [self.delegate didCardSwipedResult:YES onSucCardInfo:cardInfo onErrMsg:nil];
    }
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
    [self setConnectedIdentifier:nil];
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
