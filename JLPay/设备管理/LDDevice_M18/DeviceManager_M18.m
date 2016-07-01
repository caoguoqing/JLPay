//
//  DeviceManager_M18.m
//  JLPay
//
//  Created by 冯金龙 on 16/4/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DeviceManager_M18.h"

@implementation DeviceManager_M18


# pragma mask : 初始化
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setDevice:[LandiMPOS getInstance]];
    }
    return self;
}
- (void)dealloc {
    JLPrint(@"-=-=-=-=-=-= dealloc:: DeviceManager_M18 =-=-=-=-=-=-");
    [self.device stopSearchDev];
    if ([self.device isConnectToDevice]) {
        [self.device closeDevice];
    }
    self.device = nil;
}


// -- 1. 连接设备
- (void) connectWithId:(NSString*)identifier
           onConnected:(void (^) (NSString* SNVersion))connectedBlock
               onError:(void (^) (NSError* error))errorBlock
{
    // 扫描 -> 连接 -> 关闭扫描 -> 读取SN -> 回调
    NameWeakSelf(wself);
    [self.device startSearchDev:1000 searchOneDeviceBlcok:^(LDC_DEVICEBASEINFO *deviceInfo) {
        
        if ([identifier isEqualToString:deviceInfo.deviceIndentifier]) {
            // 链接
            [wself.device openDevice:identifier channel:CHANNEL_BLUETOOTH mode:COMMUNICATIONMODE_DUPLEX successBlock:^{
                [wself.device stopSearchDev];
                
                // 链接成功,读取SN
                [wself.device getDeviceInfo:^(LDC_DeviceInfo *deviceInfo) {
                    connectedBlock(deviceInfo.productSN);
                } failedBlock:^(NSString *errCode, NSString *errInfo) {
                    // 读取SN失败
                    errorBlock([NSError errorWithDomain:nil code:DeviceManagerErrorTypeConnectFail localizedDescription:errInfo]);
                }];
                
            } failedBlock:^(NSString *errCode, NSString *errInfo) {
                // 链接失败
                errorBlock([NSError errorWithDomain:nil code:DeviceManagerErrorTypeConnectFail localizedDescription:errInfo]);
            }];
            
        }
    } completeBlock:^(NSMutableArray *deviceArray) {
    }];
}
// -- 2. 断开连接
- (void) disconnectOnFinished:(void (^) (void))finished {
    [self.device closeDevice];
    
    while ([self.device isConnectToDevice]) {
        sleep(0.3);
        NSLog(@"等待LD设备断开中...");
    }
    NSLog(@"LD设备已断开");
    finished();
}

// -- 3. 判断连接状态
- (BOOL) isConnected {
    if (self.device) {
        return [self.device isConnectToDevice];
    } else {
        return NO;
    }
}

// -- 4. 写主密钥
- (void) writeMainKey:(NSString*)mainKey
           onFinished:(void (^) (void))finished
              onError:(void (^) (NSError* error))errorBlock
{
    [self.device loadKey:[self newMainKeyOnSouce:mainKey] successBlock:^{
        finished();
    } failedBlock:^(NSString *errCode, NSString *errInfo) {
        errorBlock([NSError errorWithDomain:@"" code:errCode.integerValue localizedDescription:errInfo]);
    }];
}

// -- 5. 写工作密钥
- (void) writeWorkKey:(NSString*)workKey
           onFinished:(void (^) (void))finished
              onError:(void (^) (NSError* error))errorBlock
{
    NameWeakSelf(wself);
    [self.device loadKey:[self pinKeyInSourceWorkKey:workKey] successBlock:^{
        [wself.device loadKey:[wself macKeyInSourceWorkKey:workKey] successBlock:^{
            finished();
        } failedBlock:^(NSString *errCode, NSString *errInfo) {
            errorBlock([NSError errorWithDomain:@"" code:errCode.integerValue localizedDescription:errInfo]);
        }];
    } failedBlock:^(NSString *errCode, NSString *errInfo) {
        errorBlock([NSError errorWithDomain:@"" code:errCode.integerValue localizedDescription:errInfo]);
    }];
}


// -- 6. 刷卡
- (void) swipeCardWithMoney:(NSString*)money
           onCardInfoReaded:(void (^) (NSDictionary* cardInfo))cardInfoReaded
                    onError:(void (^) (NSError* error))errorBlock
{
//    NSMutableDictionary* cardInfo = [NSMutableDictionary dictionary];
    NameWeakSelf(wself);
    [self.device waitingCard:@"" timeOut:30 CheckCardTp:SUPPORTCARDTYPE_MAG_IC
                    moneyNum:[PublicInformation dotMoneyFromNoDotMoney:money] successBlock:^(LDE_CardType cardtype) {
        
        if (cardtype == SUPPORTCARDTYPE_MAG) {
            [wself MGCardInfoReadingOnSuccess:^(NSDictionary *cardInfo) {
                if (cardInfoReaded) cardInfoReaded(cardInfo);
            } orErrorBlock:^(NSString *errCode, NSString *errInfo) {
                if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:errCode.integerValue localizedDescription:[NSString stringWithFormat:@"读取磁卡数据失败(%@)",errInfo]]);
            }];
//            // get pan
//            [wself.device getPAN:PANDATATYPE_PLAIN successCB:^(NSString *stringCB) {
//                JLPrint(@"读取了卡号[%@]",stringCB);
//                [cardInfo setObject:stringCB forKey:@"2"];
//                // get track
//                [wself.device getTrackData:TRACKTYPE_PLAIN successCB:^(LDC_TrackDataInfo *trackData) {
//                    JLPrint(@"读到的磁道数据:[%@]",trackData);
//                    if (trackData.expDate && trackData.expDate.length > 0) {
//                        [cardInfo setObject:[trackData.expDate substringToIndex:4] forKey:@"14"];
//                    }
//                    [cardInfo setObject:trackData.track2 forKey:@"35"];
//                    if (trackData.track3 && trackData.track3.length > 0) {
//                        [cardInfo setObject:trackData.track3 forKey:@"36"];
//                    }
//                    [cardInfo setObject:@"0200" forKey:@"22"];
//                    // 回调
//                    if (cardInfoReaded) cardInfoReaded(cardInfo);
//                } failedBlock:^(NSString *errCode, NSString *errInfo) {
//                    if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:errCode.integerValue localizedDescription:[NSString stringWithFormat:@"读取磁卡数据失败(%@)",errInfo]]);
//                }];
//            } failedBlock:^(NSString *errCode, NSString *errInfo) {
//                if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:errCode.integerValue localizedDescription:[NSString stringWithFormat:@"获取卡号失败(%@)",errInfo]]);
//            }];
        }
        
        else if (cardtype == SUPPORTCARDTYPE_IC) {
            [wself ICCardInfoReadingOnSuccess:^(NSDictionary *cardInfo) {
                if (cardInfoReaded) cardInfoReaded(cardInfo);
            } orErrorBlock:^(NSString *errCode, NSString *errInfo) {
                if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:errCode.integerValue localizedDescription:[NSString stringWithFormat:@"读取磁卡数据失败(%@)",errInfo]]);
            }];
            
//            LFC_EMVTradeInfo* tradeInfo = [[LFC_EMVTradeInfo alloc] init];
//            tradeInfo.flag = FORCEONLINE_NO;
//            NSString* curDate = [PublicInformation currentDateAndTime];
//            tradeInfo.date = [curDate substringWithRange:NSMakeRange(2, 6)];
//            tradeInfo.time = [curDate substringWithRange:NSMakeRange(8, 6)];
//            tradeInfo.type = TRADETYPE_PURCHASE;
//            [wself.device startPBOC:tradeInfo trackInfoSuccess:^(LFC_EMVProgress *emvProgress) {
//                
//            } failedBlock:^(NSString *errCode, NSString *errInfo) {
//                if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:errCode.integerValue localizedDescription:[NSString stringWithFormat:@"读取IC卡数据失败(%@)",errInfo]]);
//            }];
        }
    } failedBlock:^(NSString *errCode, NSString *errInfo) {
        if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:errCode.integerValue localizedDescription:errInfo]);
    }];
}

// -- 7. pin加密
- (void) encryptPinSource:(NSString*)pinSource
              onEncrypted:(void (^) (NSString* pin))pinEncrypted
                  onError:(void (^) (NSError* error))errorBlock
{
    [self.device encClearPIN:pinSource withPan:self.cardNo successBlock:^(NSString *stringCB) {
        if (pinEncrypted) pinEncrypted(stringCB);
    } failedBlock:^(NSString *errCode, NSString *errInfo) {
        if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:errCode.integerValue localizedDescription:errInfo]);
    }];
}

// -- 8. mac加密
- (void) encryptMacSource:(NSString*)macSource
              onEncrypted:(void (^) (NSString* mac))macEncrypted
                  onError:(void (^) (NSError* error))errorBlock
{
    [self.device calculateMac:macSource successBlock:^(NSString *stringCB) {
        if (macEncrypted) macEncrypted(stringCB);
    } failedBlock:^(NSString *errCode, NSString *errInfo) {
        if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:errCode.integerValue localizedDescription:errInfo]);
    }];
}




#pragma mask 2 private interface

// -- 读卡数据,并封装; 磁条卡
- (void) MGCardInfoReadingOnSuccess:(void (^) (NSDictionary* cardInfo))successCB orErrorBlock:(onErrorCB)errorCB {
    __block NSMutableDictionary* cardInfo = [NSMutableDictionary dictionary];
    NameWeakSelf(wSelf);
    // 先读卡号
    [self.device getPAN:PANDATATYPE_PLAIN successCB:^(NSString *stringCB) {
        [cardInfo setObject:stringCB forKey:@"2"];
        wSelf.cardNo = stringCB;
        // 再读磁道、有效期等数据
        [wSelf.device getTrackData:TRACKTYPE_PLAIN successCB:^(LDC_TrackDataInfo *trackData) {
            // 35
            NSString* track2 = trackData.track2;
            NSRange equalsSymbolRange = [track2 rangeOfString:@"="];
            if (track2 && equalsSymbolRange.length > 0) {
                track2 = [track2 stringByReplacingCharactersInRange:equalsSymbolRange withString:@"D"];
            }
            if (track2 && track2.length > 0) {
                [cardInfo setObject:track2 forKey:@"35"];
            }
            // 36
            NSString* track3 = trackData.track3;
            equalsSymbolRange = NSMakeRange(0, 0);
            equalsSymbolRange = [track3 rangeOfString:@"="];
            if (track3 && equalsSymbolRange.length > 0) {
                track3 = [track3 stringByReplacingOccurrencesOfString:@"=" withString:@"D"];
            }
            if (track3 && track3.length > 0) {
                [cardInfo setObject:track3 forKey:@"36"];
            }
            // 14
            if (trackData.expDate && trackData.expDate.length > 0) {
                [cardInfo setObject:[trackData.expDate substringToIndex:4] forKey:@"14"];
            }
            // 22
            [cardInfo setObject:@"0200" forKey:@"22"];
            // 回调读到的卡数据
            successCB(cardInfo);
        } failedBlock:^(NSString *errCode, NSString *errInfo) {
            errorCB(errCode, errInfo);
        }];
    } failedBlock:^(NSString *errCode, NSString *errInfo) {
        errorCB(errCode, errInfo);
    }];
}


// -- 读卡数据,并封装; IC卡
- (void) ICCardInfoReadingOnSuccess:(void (^) (NSDictionary* cardInfo))successCB orErrorBlock:(onErrorCB)errorCB {
    __block NSMutableDictionary* cardInfo = [NSMutableDictionary dictionary];
    NameWeakSelf(wSelf);
    LFC_EMVTradeInfo* emvInfo = [[LFC_EMVTradeInfo alloc] init];
    emvInfo.flag = FORCEONLINE_NO;
    emvInfo.type = TRADETYPE_PURCHASE;
    emvInfo.moneyNum = @"0.00";
    NSString* curDateAndTime = [PublicInformation currentDateAndTime];
    emvInfo.date = [curDateAndTime substringWithRange:NSMakeRange(2, 6)];
    emvInfo.time = [curDateAndTime substringFromIndex:curDateAndTime.length - 6];
    
    [self.device startPBOC:emvInfo trackInfoSuccess:^(LFC_EMVProgress *emvProgress) {
        // 2
        [cardInfo setObject:emvProgress.pan forKey:@"2"];
        wSelf.cardNo = emvProgress.pan;
        // 14
        NSString* cardExpired = emvProgress.cardExpired;
        if (cardExpired && cardExpired.length > 0) {
            [cardInfo setObject:[cardExpired substringToIndex:4] forKey:@"14"];
        }
        // 22
        [cardInfo setObject:@"0500" forKey:@"22"];
        // 23
        NSString* icSeq = emvProgress.panSerialNO;
        while (icSeq.length < 4) {
            icSeq = [@"0" stringByAppendingString:icSeq];
        }
        [cardInfo setObject:icSeq forKey:@"23"];
        
        // 35
        NSString* track2 = emvProgress.track2data;
        if (track2 && [track2 rangeOfString:@"="].length > 0) {
            track2 = [track2 stringByReplacingOccurrencesOfString:@"=" withString:@"D"];
        }
        [cardInfo setObject:track2 forKey:@"35"];
        
        // 继续读取IC芯片数据
        LFC_GETPIN* getPin = [[LFC_GETPIN alloc] init];
        getPin.panBlock = emvProgress.pan;
        getPin.moneyNum = @"0.00";
        getPin.timeout = 40;
        [wSelf.device continuePBOC:getPin successBlock:^(LFC_EMVResult *emvResult) {
            if (emvResult.dol && emvResult.dol.length > 0) {
                // 55
                [cardInfo setObject:emvResult.dol forKey:@"55"];
                // 回调读到的卡数据 -- 这里才是真正的读IC卡成功
                successCB(cardInfo);
            } else {
                errorCB(@"EMV_ERR", @"IC卡数据读取失败");
            }
        } failedBlock:^(NSString *errCode, NSString *errInfo) {
            errorCB(errCode, errInfo);
        }];
        
    } failedBlock:^(NSString *errCode, NSString *errInfo) {
        errorCB(errCode, errInfo);
    }];
}


#pragma mask 2 model: 密钥相关
// -- 主密钥生成
- (LFC_LoadKey*) newMainKeyOnSouce:(NSString*)mainKey {
    LFC_LoadKey* newMainKey = [[LFC_LoadKey alloc] init];
    newMainKey.keyType = KEYTYPE_MKEY;
    NSString* encryptedMainKey = [ThreeDesUtil TriDESEncryptedSource:kKey3DESMainKey onKey:mainKey];
    NSString* newMainKeyData = [mainKey stringByAppendingString:[encryptedMainKey substringToIndex:8]];
    newMainKey.keyData = newMainKeyData;
    return newMainKey;
}
// -- 工作密钥拆分: pin key
- (LFC_LoadKey*) pinKeyInSourceWorkKey:(NSString*)source {
    LFC_LoadKey* pinKey = [[LFC_LoadKey alloc] init];
    pinKey.keyType = KEYTYPE_PIN;
    pinKey.keyData = [source substringToIndex:40];
    return pinKey;
}
// -- 工作密钥拆分: mac key
- (LFC_LoadKey*) macKeyInSourceWorkKey:(NSString*)source {
    LFC_LoadKey* macKey = [[LFC_LoadKey alloc] init];
    macKey.keyType = KEYTYPE_MAC;
    macKey.keyData = [source substringWithRange:NSMakeRange(40, 40)];
    return macKey;
}


@end
