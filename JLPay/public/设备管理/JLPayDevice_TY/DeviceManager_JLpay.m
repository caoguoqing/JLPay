//
//  DeviceManager_JLpay.m
//  JLPay
//
//  Created by jielian on 16/4/20.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DeviceManager_JLpay.h"

@implementation DeviceManager_JLpay

- (instancetype)init {
    self = [super init];
    if (self) {
        self.deviceConnected = NO;
    }
    return self;
}
- (void)dealloc {
    JLPrint(@"-=-=-=-=-=-= dealloc:: DeviceManager_JLPay =-=-=-=-=-=-");
    self.deviceManager.delegate = nil;
    [self.deviceManager stopScanning];
    [self.deviceManager disConnectDevice];
    self.deviceConnected = NO;
}

// -- 1. 连接设备
- (void) connectWithId:(NSString*)identifier
           onConnected:(void (^) (NSString* SNVersion))connectedBlock
               onError:(void (^) (NSError* error))errorBlock
{
    self.connectedIdentifier = identifier;
    self.connectedDeviceSN = connectedBlock;
    self.errorBlock = errorBlock;
    [self.deviceManager StartScanning];
}

// -- 2. 断开连接
- (void) disconnectOnFinished:(void (^) (void))finished {
    self.disconnectedDevice = finished;
    [self.deviceManager disConnectDevice];
}

// -- 3. 判断连接状态
- (BOOL) isConnected {
    if (self.deviceConnected == YES) {
        return YES;
    } else {
        return NO;
    }
}

// -- 4. 写主密钥
- (void) writeMainKey:(NSString*)mainKey
           onFinished:(void (^) (void))finished
              onError:(void (^) (NSError* error))errorBlock
{
    self.finishedMainKeyWriting = finished;
    self.errorBlock = errorBlock;
    [self.deviceManager WriteMainKey:(int)[mainKey length] * 0.5 :mainKey];
}

// -- 5. 写工作密钥
- (void) writeWorkKey:(NSString*)workKey
           onFinished:(void (^) (void))finished
              onError:(void (^) (NSError* error))errorBlock
{
    self.finishedWorkKeyWriting = finished;
    self.errorBlock = errorBlock;
    
    // newWorkKey[120] = workKey[0-40] +  workKey[40-80] + workKey[0-40]/(trakKey)
    NSString* pinKey = [workKey substringToIndex:40];
    NSString* macKey = [workKey substringFromIndex:40];
    NSString* newMacKey = [NSString stringWithFormat:@"%@%@%@",
                           [macKey substringToIndex:16],
                           [macKey substringToIndex:16], // 替换掉 56 - 80 位的0
                           [macKey substringFromIndex:macKey.length - 8]];
    NSString* newWorkKey = [NSString stringWithFormat:@"%@%@%@",pinKey,newMacKey,pinKey];

    [self.deviceManager WriteWorkKey:(int)[newWorkKey length] * 0.5 :newWorkKey];
}

// -- 6. 刷卡
- (void)swipeCardWithMoney:(NSString *)money
          onCardInfoReaded:(void (^)(NSDictionary *))cardInfoReaded
                   onError:(void (^)(NSError *))errorBlock
{
    self.finishedCardInfoReading = cardInfoReaded;
    self.errorBlock = errorBlock;
    [self.deviceManager MagnAmountPasswordCardAmount:money TimeOut:20];
}

// -- 8. mac加密
- (void) encryptMacSource:(NSString*)macSource
              onEncrypted:(void (^) (NSString* mac))macEncrypted
                  onError:(void (^) (NSError* error))errorBlock
{
    self.encryptedMac = macEncrypted;
    self.errorBlock = errorBlock;
    [self.deviceManager GetMac:macSource.length * 0.5 :macSource];
}



# pragma mask 2 TYJieLianDelegate

// -- delegate: discovered
- (void)discoverPeripheralSuccess:(CBPeripheral *)peripheral {
    if ([peripheral.identifier.UUIDString isEqualToString:self.connectedIdentifier]) {
        if (peripheral.state == CBPeripheralStateDisconnected) {
            if (self.deviceConnected != iStateConnceting) { // 未处在状态:正在连接
                [self.deviceManager connectDevice:peripheral];
                self.deviceConnected = iStateConnceting;
            }
        }
    }
}

// -- delegate: connected
- (void)didConnectPeripheral:(CBPeripheral *)peripheral {
    if ([peripheral.identifier.UUIDString isEqualToString:self.connectedIdentifier]) {
        [self.deviceManager stopScanning];
        [self.deviceManager GetSnVersion];
    }
}

// -- delegate: disconnected
- (void)didDisconnectPeripheral:(CBPeripheral *)peripheral {
    self.deviceConnected = NO;
    if (self.disconnectedDevice) {
        self.disconnectedDevice();
    } else if (self.errorBlock) {
        self.errorBlock([NSError errorWithDomain:@"" code:9 localizedDescription:@"设备丢失!"]);
    }
}

// -- delegate: card info readed
- (void)accessoryDidReadData:(NSDictionary *)data {
    JLPrint(@"读取到的卡数据:[%@]",data);
    if (data && data.count > 0) {
        
        NSMutableString* f22 = [NSMutableString stringWithString:@"0000"];
        if ([[data valueForKey:@"cardType"] isEqualToString:@"01"]) {
            [f22 replaceCharactersInRange:NSMakeRange(1, 1) withString:@"5"];
        } else {
            [f22 replaceCharactersInRange:NSMakeRange(1, 1) withString:@"2"];
        }
        
        // 回调带回的卡数据信息字典
        NSMutableDictionary* cardInfo = [[NSMutableDictionary alloc] init];
        [cardInfo setValue:@"0600000000000000" forKey:@"53"];
        
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
                    [f22 replaceCharactersInRange:NSMakeRange(2, 1) withString:@"1"];
                    [cardInfo setValue:@"2600000000000000" forKey:@"53"];
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
                    [f22 replaceCharactersInRange:NSMakeRange(2, 1) withString:@"1"];
                    [cardInfo setValue:@"2600000000000000" forKey:@"53"];
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
        [cardInfo setValue:f22 forKey:@"22"];
        // -- 回调
        if (self.finishedCardInfoReading) self.finishedCardInfoReading(cardInfo);
    }
}



// -- delegate: device handle result
- (void)onReceive:(NSData *)data {
    Byte* dataBytes = (Byte*)[data bytes];
    int handleType = (int)dataBytes[0];
    int hendleResult = (int)dataBytes[1];
    JLPrint(@"操作类型:[0x%02x],结果:[0x%02x]",handleType,hendleResult);
    NSMutableString* hendleDatas = [NSMutableString string];
    for (int i = 2; i < [data length]; i++) {
        [hendleDatas appendFormat:@"%02x", dataBytes[i] & 0xff ];
    }
    JLPrint(@"操作设备获取的数据:[%@]",hendleDatas);

    if (handleType == GETSNVERSION) {
        if (!hendleResult) {
            self.deviceConnected = YES;
            if (self.connectedDeviceSN) self.connectedDeviceSN(hendleDatas);
        } else {
            self.deviceConnected = NO;
            if (self.errorBlock) self.errorBlock([NSError errorWithDomain:@"" code:9 localizedDescription:@"读取SN失败"]);
        }
    }
    else if (handleType == MAINKEY_CMD) {
        if (!hendleResult) {
            if (self.finishedMainKeyWriting) self.finishedMainKeyWriting();
        } else {
            if (self.errorBlock) self.errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"写主密钥失败"]);
        }
    }
    else if (handleType == WORKKEY_CMD) {
        if (!hendleResult) {
            if (self.finishedWorkKeyWriting) self.finishedWorkKeyWriting();
        } else {
            if (self.errorBlock) self.errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"写工作密钥失败"]);
        }
    }
    else if (handleType == GETMAC_CMD) {
        if (!hendleResult) {
            if (self.encryptedMac) self.encryptedMac([[PublicInformation stringWithHexBytes2:data] substringWithRange:NSMakeRange(4, 16)]);
        } else {
            if (self.errorBlock) self.errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"MAC加密失败"]);
        }
    }
    else if (handleType == GETTRACKDATA_CMD) {
        if (hendleResult) {
            if (self.errorBlock) self.errorBlock([NSError errorWithDomain:@"" code:6 localizedDescription:@"读卡数据失败"]);
        }
    }
}



# pragma mask 4 getter
- (JieLianService *)deviceManager {
    if (!_deviceManager) {
        _deviceManager = [[JieLianService alloc] init];
        _deviceManager.delegate = self;
    }
    return _deviceManager;
}



@end
