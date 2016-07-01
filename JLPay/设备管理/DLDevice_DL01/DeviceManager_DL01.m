//
//  DeviceManager_DL01.m
//  JLPay
//
//  Created by jielian on 16/4/20.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DeviceManager_DL01.h"

@implementation DeviceManager_DL01


- (instancetype)init {
    self = [super init];
    if (self) {
        self.deviceManager = [DCSwiperAPI shareInstance];
        self.deviceManager.delegate = self;
    }
    return self;
}
- (void)dealloc {
    JLPrint(@"-=-=-=-=-=-= dealloc:: DeviceManager_DL01 =-=-=-=-=-=-");
    [self.deviceManager stopScanBlueDevice];
    if ([self.deviceManager isConnectBlue]) {
        [self.deviceManager disConnect];
    }
}

// -- 1. 连接设备
- (void) connectWithId:(NSString*)identifier
           onConnected:(void (^) (NSString* SNVersion))connectedBlock
               onError:(void (^) (NSError* error))errorBlock
{
    self.connectedDeviceSN = connectedBlock;
    self.errorBlock = errorBlock;
    self.connectedIdentifier = identifier;
    NameWeakSelf(wself);
    self.deviceManager.delegate = self;
    [wself.deviceManager scanBlueDevice];
}

// -- 2. 断开连接
- (void) disconnectOnFinished:(void (^) (void))finished {
    self.disconnectedDevice = finished;
    if (self.deviceManager.isConnectBlue) {
        [self.deviceManager cancelCard];
    } else {
        self.deviceManager.delegate = nil;
        if (finished) finished();
    }
//    [self.deviceManager disConnect];
}

// -- 3. 判断连接状态
- (BOOL) isConnected {
    if (self.deviceManager) {
        return [self.deviceManager isConnectBlue];
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
    [self.deviceManager updateMasterKey:mainKey];
}

// -- 5. 写工作密钥
- (void) writeWorkKey:(NSString*)workKey
           onFinished:(void (^) (void))finished
              onError:(void (^) (NSError* error))errorBlock
{
    self.finishedWorkKeyWriting = finished;
    self.errorBlock = errorBlock;
    NSString* pinKey = [workKey substringToIndex:40];
    NSString* macKey = [workKey substringFromIndex:40];
    NSString*  newMacKey = [NSString stringWithFormat:@"%@%@",[macKey substringToIndex:16],[macKey substringFromIndex:macKey.length - 8]]; // 16 + 8
    [self.deviceManager updateKey:[NSDictionary dictionaryWithObjects:@[pinKey,newMacKey] forKeys:@[kDLDeviceInfoPinKey,kDLDeviceInfoMacKey]]];
}

// -- 6. 刷卡
- (void)swipeCardWithMoney:(NSString *)money
          onCardInfoReaded:(void (^)(NSDictionary *))cardInfoReaded
                   onError:(void (^)(NSError *))errorBlock
{
    self.finishedCardInfoReading = cardInfoReaded;
    self.errorBlock = errorBlock;
    [self.deviceManager readCard:2 money:money.integerValue];
}

// -- 7. pin加密
- (void) encryptPinSource:(NSString*)pinSource
              onEncrypted:(void (^) (NSString* pin))pinEncrypted
                  onError:(void (^) (NSError* error))errorBlock
{
    self.encryptedPin = pinEncrypted;
    self.errorBlock = errorBlock;
    int curLen = pinSource.length;
    pinSource = [NSString stringWithFormat:@"%02d%@",curLen,pinSource];
    for ( ; curLen < 16; curLen = pinSource.length) {
        pinSource = [pinSource stringByAppendingString:@"F"];
    }
    [self.deviceManager encryptPin:pinSource];
}

// -- 8. mac加密
- (void) encryptMacSource:(NSString*)macSource
              onEncrypted:(void (^) (NSString* mac))macEncrypted
                  onError:(void (^) (NSError* error))errorBlock
{
    self.encryptedMac = macEncrypted;
    self.errorBlock = errorBlock;
    [self.deviceManager getMacValue:macSource];
}


# pragma mask 3 DCSwiperAPIDelegate
//扫描设备结果
-(void)onFindBlueDevice:(NSDictionary *)dic {
    if ([[dic objectForKey:kDLDeviceInfoIdentifier] isEqualToString:self.connectedIdentifier]) {
        if (![self.deviceManager isConnectBlue]) {
            [self.deviceManager connectBlueDevice:dic];
        }
    }
}

//连接设备结果
-(void)onDidConnectBlueDevice:(NSDictionary *)dic {
    if ([[dic objectForKey:kDLDeviceInfoIdentifier] isEqualToString:self.connectedIdentifier]) {
        [self.deviceManager stopScanBlueDevice];
        NameWeakSelf(wself);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [wself.deviceManager getDeviceKsn];
        });
    }
}

//取消交易
-(void)onDidCancelCard {
    [self.deviceManager disConnect];
}

//失去连接到设备
-(void)onDisconnectBlueDevice:(NSDictionary *)dic {
    self.deviceManager.delegate = nil;
    if (self.disconnectedDevice) {
        self.disconnectedDevice();
    } else if (self.errorBlock) {
        self.errorBlock([NSError errorWithDomain:@"" code:9 localizedDescription:@"设备丢失!"]);
    }
}

//读取ksn结果
-(void)onDidGetDeviceKsn:(NSDictionary *)dic {
    JLPrint(@"读取到了Sn号[%@]", dic);
    if (self.connectedDeviceSN) self.connectedDeviceSN([dic objectForKey:kDLDeviceInfoKSN]);
}

//更新主密钥回调
-(void)onDidUpdateMasterKey:(int)retCode {
    if (retCode == ERROR_OK) {
        if (self.finishedMainKeyWriting) self.finishedMainKeyWriting();
    }
}

//更新工作密钥回调
-(void)onDidUpdateKey:(int)retCode {
    if (retCode == ERROR_OK) {
        if (self.finishedWorkKeyWriting) self.finishedWorkKeyWriting();
    }
}


//读取卡信息结果
-(void)onDidReadCardInfo:(NSDictionary *)dic {
    NSMutableDictionary* cardInfoReaded = [[NSMutableDictionary alloc] init];
    // 2,14,22,23,35,36,55
    if (self.deviceManager.currentCardType == card_mc) {
        [cardInfoReaded setObject:[dic objectForKey:@"5"] forKey:@"2"]; // 2
        [cardInfoReaded setObject:[[dic objectForKey:@"6"] substringToIndex:4] forKey:@"14"]; //14
        [cardInfoReaded setObject:@"0200" forKey:@"22"]; // 22
        NSString* lenMc35 = [dic objectForKey:@"8"];
        NSString* lenMc36 = [dic objectForKey:@"9"];
        int intLen = ([lenMc35 isEqualToString:@"FF"])?(0):([PublicInformation sistenToTen:lenMc35]);
        if (intLen > 0) {
            NSString* mc35 = [[dic objectForKey:@"A"] substringToIndex:intLen];
            [cardInfoReaded setObject:mc35 forKey:@"35"]; // 35
        }
        intLen = ([lenMc36 isEqualToString:@"FF"])?(0):([PublicInformation sistenToTen:lenMc36]);
        if (intLen > 0) {
            NSString* mc36 = [[dic objectForKey:@"B"] substringToIndex:intLen];
            [cardInfoReaded setObject:mc36 forKey:@"36"]; // 36
        }
    }
    else if (self.deviceManager.currentCardType == card_ic) {
        [cardInfoReaded setObject:[dic objectForKey:@"5A"] forKey:@"2"]; // 2
        [cardInfoReaded setObject:[[dic objectForKey:@"5F24"] substringToIndex:4] forKey:@"14"]; // 14
        [cardInfoReaded setObject:@"0500" forKey:@"22"]; // 22
        NSString* icSeq = [dic objectForKey:@"5F34"];
        while (icSeq.length < 4) {
            icSeq = [@"0" stringByAppendingString:icSeq];
        }
        [cardInfoReaded setObject:icSeq forKey:@"23"]; // 23
        NSString* mc35 = [dic objectForKey:@"57"];
        if (mc35 && mc35.length > 0) {
            if ([[mc35 substringWithRange:NSMakeRange(mc35.length - 1, 1)] isEqualToString:@"F"]) {
                mc35 = [mc35 substringToIndex:mc35.length - 1];
            }
            [cardInfoReaded setObject:mc35 forKey:@"35"]; // 35
        }
        [cardInfoReaded setObject:[dic objectForKey:@"55"] forKey:@"55"]; // 55
    }
    
    if (self.finishedCardInfoReading) self.finishedCardInfoReading(cardInfoReaded);
}


//加密Pin结果
-(void)onEncryptPinBlock:(NSString *)encPINblock {
    if (self.encryptedPin) self.encryptedPin(encPINblock);
}

//mac计算结果
-(void)onDidGetMac:(NSString *)strmac {
    if (self.encryptedMac) self.encryptedMac(strmac);
}

-(void)onResponse:(int)type :(int)status {
    JLPrint(@"-- onResponse : type[%d],status[%d]",type,status);
    NSString* errorMsg = nil;
    switch (type) {
        case ERROR_FAIL_DATA:
            errorMsg = @"设备操作失败!";
            break;
        case ERROR_FAIL_GETMAC:
            errorMsg = @"MAC加密失败!";
            break;
        case ERROR_FAIL_MCCARD:
            errorMsg = @"ERROR_FAIL_MCCARD!";
            break;
        case ERROR_FAIL_NEEDIC:
            errorMsg = @"请插入IC卡!";
            break;
        case ERROR_FAIL_GET_KSN:
            errorMsg = @"读取设备SN号失败!";
            break;
        case ERROR_FAIL_TIMEOUT:
            errorMsg = @"设备操作超时!";
            break;
        case ERROR_FAIL_READCARD:
            errorMsg = @"读取卡数据失败!";
            break;
        case ERROR_FAIL_ENCRYPTPIN:
            errorMsg = @"密码加密失败!";
            break;
        default:
            errorMsg = @"设备操作失败!";
            break;
    }
    if (self.errorBlock) self.errorBlock([NSError errorWithDomain:@"" code:type localizedDescription:errorMsg]);
}





# pragma mask 4 getter

@end
