//
//  DeviceManager_SMIT.m
//  JLPay
//
//  Created by jielian on 2016/11/2.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DeviceManager_SMIT.h"
#import <sdk/Common.h>
#import "Define_Header.h"


@interface DeviceManager_GW()

@property (nonatomic, strong) NSMutableDictionary* cardInfo;
@property (nonatomic, copy) NSString* deviceSN;

@end

@implementation DeviceManager_GW

- (instancetype)init {
    self = [super init];
    if (self) {
        _deviceManager = [[Smit alloc] initWithEncryptMode:SMIT_ENCRYPT_MODE_PLAIN key:@""];
//        _deviceManager = [[Smit alloc] initWithEncryptMode:SMIT_ENCRYPT_MODE_PLAIN
//                                                       key:@""
//                                                  workMode:SMIT_WORK_MODE_3RD
//                                                  authType:SMIT_AUTH_TYPE_AUTO];
        [_deviceManager setDeviceType:SMIT_DEVICE_TYPE_NEW];
        [_deviceManager setWriteGap:0.10155];
        _deviceManager.delegate = self;
        _cardInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"-----------DeviceManager_0011 dealloc -----");
    self.deviceManager.delegate = nil;
    [self cancelCommand];
    [self.deviceManager stopScan];
    [self.deviceManager disconnect];
}


// -- 1. 连接设备
- (void) connectWithId:(NSString*)identifier
           onConnected:(void (^) (NSString* SNVersion))connectedBlock
               onError:(void (^) (NSError* error))errorBlock
{
    self.connectedDeviceSN = connectedBlock;
    self.errorBlock = errorBlock;
    self.connectedIdentifier = identifier;
    NSLog(@"1--------启动SMit的扫描");
    NameWeakSelf(wself);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wself.deviceManager scan];
    });
}

// -- 2. 断开连接
- (void) disconnectOnFinished:(void (^) (void))finished
{
    if (![self.deviceManager isBTConnect]) {
        if (finished) finished();
        return;
    }
    
    self.disconnectedDevice = finished;
    NSLog(@"2--------正在断开设备...");
    [self.deviceManager stopScan];
    [self.deviceManager disconnect];
    // 因sdk的bug，需要断2次才能断开....
    [self.deviceManager performSelector:@selector(disconnect) withObject:nil afterDelay:0.5];
}

// -- 3. 判断连接状态
- (BOOL) isConnected {
    NSLog(@"3--------设备是否连接:[%@]", [self.deviceManager isBTConnect] ? @"是":@"否");
    return [self.deviceManager isBTConnect];
}

// -- 4. 写主密钥
- (void) writeMainKey:(NSString*)mainKey
           onFinished:(void (^) (void))finished
              onError:(void (^) (NSError* error))errorBlock
{
    if (![self.deviceManager isBTConnect]) {
        if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"设备未连接"]);
        return;
    }
    
    self.finishedMainKeyWriting = finished;
    self.errorBlock = errorBlock;
    
    NSMutableString* paramStr = [NSMutableString string];

    [paramStr appendFormat:@"{\"index\":0,"];
    [paramStr appendFormat:@"\"mainKey\":\"%@\"}", mainKey];
    [self.deviceManager exec:SMIT_MSG_TYPE_UPDATE_MAIN_KEY params:paramStr];
}

// -- 5. 写工作密钥
- (void) writeWorkKey:(NSString*)workKey
           onFinished:(void (^) (void))finished
              onError:(void (^) (NSError* error))errorBlock
{
    if (![self.deviceManager isBTConnect]) {
        if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"设备未连接"]);
        return;
    }

    self.finishedWorkKeyWriting = finished;
    self.errorBlock = errorBlock;
    
    [self.deviceManager exec:SMIT_MSG_TYPE_SYNC_WKEY_FROM_SERVER params:[self smitWorkKeyTransformedWithSourceKey:workKey]];
}

// -- 6. 刷卡
- (void) swipeCardWithMoney:(NSString*)money
           onCardInfoReaded:(void (^) (NSDictionary* cardInfo))cardInfoReaded
                    onError:(void (^) (NSError* error))errorBlock
{
    if (![self.deviceManager isBTConnect]) {
        if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"设备未连接"]);
        return;
    }

    self.finishedCardInfoReading = cardInfoReaded;
    self.errorBlock = errorBlock;
    
    long long trade_time=[[NSDate date] timeIntervalSince1970];
    double amount=100;//300.30;//3.24;
    long long trade_type=0x01;
    int timeout = 200;
    
    NSString* params=[NSString stringWithFormat:@"{\"trade_id\":0,\"trade_time\":%lld,\"timeout\":%d,\"trade_type\":%lld,\"amount\":%lf}", trade_time, timeout, trade_type,amount];
    NSLog(@"%@",params);
    [self.deviceManager exec:SMIT_MSG_TYPE_READ_ALL_CARD params:params];
}

// -- 7. pin加密
- (void) encryptPinSource:(NSString*)pinSource
              onEncrypted:(void (^) (NSString* pin))pinEncrypted
                  onError:(void (^) (NSError* error))errorBlock
{
    if (![self.deviceManager isBTConnect]) {
        if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"设备未连接"]);
        return;
    }
    
    self.encryptedPin = pinEncrypted;
    self.errorBlock = errorBlock;
    
    NSString* pan = [self.cardInfo objectForKey:@"2"];
    NSLog(@"------------------准备加密:pan[%@] ,source=[%@]", pan, pinSource);
    NSString* params = [NSString stringWithFormat:@"{\"PAN\":\"%@\",\"pin\":\"%@\"}", pan, pinSource];
    [self.deviceManager exec:SMIT_MSG_TYPE_EX_ENCRYPT_PIN_WITH_PAN params:params];
    
}

// -- 8. mac加密
- (void) encryptMacSource:(NSString*)macSource
              onEncrypted:(void (^) (NSString* mac))macEncrypted
                  onError:(void (^) (NSError* error))errorBlock
{
    if (![self.deviceManager isBTConnect]) {
        if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"设备未连接"]);
        return;
    }
    
    self.encryptedMac = macEncrypted;
    self.errorBlock = errorBlock;

    /*
     " key_index": 密钥索引（传0x10即可）
     " key_system": 秘钥系统（传0即可）
     " mac_mode":  MAC模式：0：最后块3DES模式；1：所有块3DES模式；2：最后块DES模式 ；3：所有块DES模式
     " block_flag": 块标志：0：第一块；1：下一块；2：最后块；3：唯一一块；
     " block_data": "待MAC的数据（长度0-1023）"
     */
    
    NSUInteger key_index = 0x10;
    int key_system = 0;
    int mac_mode = 2;
    int block_flag = 3;
    
    NSString* params=[NSString stringWithFormat:@"{\"key_index\": %lu,\"key_system\": %d,\"mac_mode\": %d,\"block_flag\": %d,\"block_data\": \"%@\"}",(unsigned long)key_index,key_system,mac_mode,block_flag,macSource];
    [self.deviceManager exec:SMIT_MSG_TYPE_EX_PW_CALCULATE_MAC params:params];

}



# pragma mask 2 SmitDelegate

/* 扫描到设备 */
-(void)onFoundDevice:(NSDictionary*)device all:(NSArray*)devices {
    CBPeripheral* cbPeripheral = [device objectForKey:@"Peripheral"];
    if ([cbPeripheral.identifier.UUIDString isEqualToString:self.connectedIdentifier]) {
        [self.deviceManager connect:device];
    }

}

/* 扫描完毕 */
-(void)onScanFinished:(NSArray*)devices {
    NSLog(@"-------SMIT::扫描结束，设备组:[%@]", devices);
}

/* 设备连接了 */
-(void)onDeviceConnected {
    NSLog(@"-------SMIT::连接了设备");
    [self readDeviceInfo];
    
}

/* 设备断开连接了 */
-(void)onDeviceDisconnected {
    NSLog(@"-------SMIT::设备已断开连接");
    if (self.disconnectedDevice) {
        self.disconnectedDevice();
    }
}

/* 设备操作响应 */
-(void)onResponse:(int)msgType data:(id)data code:(int)code frame:(NSString*)frame {
    NSDictionary* dataInfo = [Common jsonStringToObject:data];
    NSString* status = dataInfo[@"status"];

    switch (msgType) {
        /* 设备信息 */
        case SMIT_MSG_TYPE_DEVICE_INFO:
        {
            if ([status isEqualToString:@"00"]) {
                self.deviceSN = dataInfo[@"device_sn"];
                [self deviceAuth];
            } else {
                NSLog(@"--------状态信息:[%@]", dataInfo);
                if (self.errorBlock) {
                    self.errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"连接设备失败"]);
                }
            }
        }
            break;
        /* 设备认证 */
        case SMIT_MSG_TYPE_DEVICE_AUTH:
        {
            if ([status isEqualToString:@"00"]) {
                [self externAuth];
            } else {
                self.errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"连接设备失败"]);
            }
        }
            break;
        /* 外部认证 */
        case SMIT_MSG_TYPE_EXTERNAL_AUTH:
        {
            if ([status isEqualToString:@"00"]) {
                if (self.connectedDeviceSN) {
                    self.connectedDeviceSN(self.deviceSN);
                }
            } else {
                self.errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"连接设备失败"]);
            }
        }
            break;

        /* 写主密钥 */
        case SMIT_MSG_TYPE_UPDATE_MAIN_KEY:
        {
            if ([status isEqualToString:@"00"]) {
                if (self.finishedMainKeyWriting) {
                    self.finishedMainKeyWriting();
                }
            } else {
                NSLog(@"--------写主密钥的回调数据:[%@]", dataInfo);
                if (self.errorBlock) {
                    self.errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"更新主密钥失败"]);
                }
            }
        }
            break;
        /* 写工作密钥 */
        case SMIT_MSG_TYPE_SYNC_WKEY_FROM_SERVER:
        {
            if ([status isEqualToString:@"00"]) {
                if (self.finishedWorkKeyWriting) {
                    self.finishedWorkKeyWriting();
                }
            } else {
                NSLog(@"--------写工作密钥的回调数据:[%@]", dataInfo);
                if (self.errorBlock) {
                    self.errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"更新工作密钥失败"]);
                }
            }
        }
            break;
        /* 读卡响应结果 */
        case SMIT_MSG_TYPE_READ_ALL_CARD:
        {
            if ([status isEqualToString:@"00"]) {
                NSLog(@"-=-=-=-=-=--= 读到的卡数据:[%@]", dataInfo);
                [self cardInfoAnalyzedWithReaded:dataInfo];
                if (self.finishedCardInfoReading) {
                    self.finishedCardInfoReading(self.cardInfo);
                }
            } else {
                NSLog(@"--------读卡失败:[%@]", dataInfo);
                if (self.errorBlock) {
                    self.errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"读卡失败"]);
                }
            }
        }
            break;
        /* 密码加密结果 */
        case SMIT_MSG_TYPE_EX_ENCRYPT_PIN_WITH_PAN:
        {
            if ([status isEqualToString:@"00"]) {
                if (self.encryptedPin) {
                    NSLog(@"-------------加密回调数据:[%@]", dataInfo[@"en_pin"]);
                    self.encryptedPin([dataInfo objectForKey:@"en_pin"]);
                }
            } else {
                if (self.errorBlock) {
                    self.errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"PIN加密失败"]);
                }
            }
        }
            break;
        /* MAC计算结果 */
        case SMIT_MSG_TYPE_EX_PW_CALCULATE_MAC:
        {
            if ([status isEqualToString:@"00"]) {
                if (self.encryptedMac) {
                    self.encryptedMac([dataInfo objectForKey:@"MAC"]);
                }
            } else {
                NSLog(@"--------MAC计算回调数据:[%@]", dataInfo);
                if (self.errorBlock) {
                    self.errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:@"MAC计算失败"]);
                }
            }
        }
            break;

        default:
            break;
    }
}

/* 设备连接失败了 */
-(void)onConnectFailed {
    NSLog(@"--------连接设备失败了........");
}



# pragma mask 2 func tools

/* 取消交易 */
- (void) cancelCommand {
    [self.deviceManager exec:SMIT_MSG_TYPE_EX_TM_CANCEL_RESET params:nil];
}

/* 读取设备信息 */
- (void) readDeviceInfo {
    [self.deviceManager exec:SMIT_MSG_TYPE_DEVICE_INFO params:nil];
}


/* 设备认证 */
- (void) deviceAuth {
    NSString* params=[NSString stringWithFormat:@"{\"random_num\":8,\"device_sn\":\"%@\"}", self.deviceSN];
    [self.deviceManager  exec:SMIT_MSG_TYPE_DEVICE_AUTH params:params];

}
/* 外部认证 */
- (void) externAuth {
    [self.deviceManager exec:SMIT_MSG_TYPE_EXTERNAL_AUTH params:nil];
}

/* 生成SMIT专用的 work key 串 */
- (NSString*) smitWorkKeyTransformedWithSourceKey:(NSString*)sourceKey {
    NSMutableString* smitWorkKey = [NSMutableString string];
    NSString* pinKeySource = [sourceKey substringToIndex:40];
    NSString* macKeySource = [sourceKey substringFromIndex:40];

    [smitWorkKey appendString:@"{"];
    
    [smitWorkKey appendFormat:@"\"pin_key\":\"%@\",", [self keyValueWithSource:pinKeySource andKeyType:0]];
    [smitWorkKey appendFormat:@"\"pin_key_checksum\":\"%@\",", [self checkNumWithSource:pinKeySource]];
    [smitWorkKey appendFormat:@"\"mac_key\":\"%@\",", [self keyValueWithSource:macKeySource andKeyType:1]];
    [smitWorkKey appendFormat:@"\"mac_key_checksum\":\"%@\",", [self checkNumWithSource:macKeySource]];
    [smitWorkKey appendFormat:@"\"encrypt_key\":\"%@\",", [self keyValueWithSource:macKeySource andKeyType:1]];
    [smitWorkKey appendFormat:@"\"encrypt_key_checksum\":\"%@\",", [self checkNumWithSource:macKeySource]];
    [smitWorkKey appendString:@"\"tmk_index\":0,\"wk_index\":0"];
    
    [smitWorkKey appendString:@"}"];
    return smitWorkKey;
}

/* type: 0:pin, 1:mac */
- (NSString*) keyValueWithSource:(NSString*)source andKeyType:(NSInteger)type {
    NSString* key = nil;
    if (type == 0) {
        key = [source substringToIndex:32];
    } else {
        key = [source substringToIndex:16];
        key = [key stringByAppendingString:key];
    }
    return key;
}
- (NSString*) checkNumWithSource:(NSString*)source {
    return [source substringFromIndex:source.length - 8];
}


/* 解析读卡数据 */
- (void) cardInfoAnalyzedWithReaded:(NSDictionary*)cardInfoReaded {
    // 2,14,22,23,35,36,55
    [self.cardInfo removeAllObjects];
    NSNumber* cardType = [cardInfoReaded objectForKey:@"card_tag"];
    BOOL cardTypeIC = ([cardType integerValue] == 2) ? (YES) : (NO);
    NSLog(@"-=-=-=-=-=-=-=解析前的读卡数据:[%@]", cardInfoReaded);

    /* IC卡 */
    if (cardTypeIC) {
        // 2,14,22,23,35,55
        NSString* f2 = [cardInfoReaded objectForKey:@"PAN"];
        NSString* f14 = [cardInfoReaded objectForKey:@"expired_date"];
        NSString* f22 = @"0500";
        NSString* f23 = [cardInfoReaded objectForKey:@"card_seq_No"];
        f23 = [f23 substringFromIndex:4 + 2];
        if (f23.length < 4) {
            for (int i = 4 - f23.length; i > 0; i--) {
                f23 = [@"0" stringByAppendingString:f23];
            }
        }
        NSString* f35 = [cardInfoReaded objectForKey:@"track2"];
        NSString* f55 = [cardInfoReaded objectForKey:@"field_data"];
        if (f2 && f2.length > 0) [self.cardInfo setObject:f2 forKey:@"2"];
        if (f14 && f14.length > 0) [self.cardInfo setObject:f14 forKey:@"14"];
        if (f22 && f22.length > 0) [self.cardInfo setObject:f22 forKey:@"22"];
        if (f23 && f23.length > 0) [self.cardInfo setObject:f23 forKey:@"23"];
        if (f35 && f35.length > 0) [self.cardInfo setObject:f35 forKey:@"35"];
        if (f55 && f55.length > 0) [self.cardInfo setObject:f55 forKey:@"55"];

    }
    /* 磁条卡 */
    else {
        // 2,14,22,35,36
        NSString* f2 = [cardInfoReaded objectForKey:@"PAN"];
        NSString* f14 = [cardInfoReaded objectForKey:@"expired_date"];
        NSString* f22 = @"0200";
        NSString* f35 = [cardInfoReaded objectForKey:@"track2"];
        NSString* f36 = [cardInfoReaded objectForKey:@"track3"];
        if (f2 && f2.length > 0) [self.cardInfo setObject:f2 forKey:@"2"];
        if (f14 && f14.length > 0) [self.cardInfo setObject:f14 forKey:@"14"];
        if (f22 && f22.length > 0) [self.cardInfo setObject:f22 forKey:@"22"];
        if (f35 && f35.length > 0) [self.cardInfo setObject:f35 forKey:@"35"];
        if (f36 && f36.length > 0) [self.cardInfo setObject:f36 forKey:@"36"];
    }
    NSLog(@"-=-=-=-=-=-=-=解析后的读卡数据:[%@]", self.cardInfo);
}


@end
