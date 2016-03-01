//
//  LDDevice_M18.m
//  JLPay
//
//  Created by jielian on 16/2/24.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "LDDevice_M18.h"
#import "LandiMPOS.h"
#import "Define_Header.h"
#import "ThreeDesUtil.h"
#import "EncodeString.h"
#import "Unpacking8583.h"

static NSString* const kLDDeviceInfoBasicInfo = @"BasicInfo";
static NSString* const kLDDeviceInfoDeviceSN =  @"DeviceSN";

static NSString* const kLDDeviceNamePre = @"M18";

static NSString* const kKey3DESMainKey = @"0000000000000000";


@interface LDDevice_M18()

@property (nonatomic, assign) id<LDDevice_M18Delegate>delegate;
@property (nonatomic, strong) LandiMPOS* device;

@property (nonatomic, strong) NSString* connectedIdentifier;
@property (nonatomic, strong) NSMutableArray* bleDevices;

@end

@implementation LDDevice_M18

#pragma mask 1 public interface
# pragma mask : 初始化
- (instancetype)initWithDelegate:(id<LDDevice_M18Delegate>)deviceDelegate  {
    self = [super init];
    if (self) {
        [self setDelegate:deviceDelegate];
        [self setDevice:[LandiMPOS getInstance]];
        self.bleDevices = [NSMutableArray array];
    }
    return self;
}
- (void)dealloc {
    JLPrint(@"m18设备入口被销毁了");
}

# pragma mask : 打开指定 identifier 号的设备
- (void) openDeviceWithIdentifier:(NSString*)identifier {
    /*
     * 为空就连接第一个扫描到的设备
     * 不为空就连接指定的设备
     * 1.打开扫描
     * 2.连接设备
     */
//    [self stopDeviceScanning];
    [self setConnectedIdentifier:identifier];
    [self startDeviceScanning];
}

# pragma mask : 关闭所有蓝牙设备
- (void) clearAndCloseAllDevices {
    [self setDelegate:nil];
    [self stopDeviceScanning];
    [self closeDevice];
}
# pragma mask : 判断指定SN号的设备是否已连接
- (BOOL) isConnectedOnSNVersionNum:(NSString*)SNVersion {
    BOOL isConnected = NO;
    NSString* identifier = [self getIdentifierOnSN:SNVersion];
    if ([self.device isConnectToDevice] && identifier && [identifier isEqualToString:self.connectedIdentifier]) {
        isConnected = YES;
    }
    return isConnected;
}
# pragma mask : 判断指定设备ID的设备是否已连接
- (BOOL) isConnectedOnIdentifier:(NSString*)identifier {
    BOOL isConnected = NO;
    if ([self.device isConnectToDevice] && [identifier isEqualToString:self.connectedIdentifier]) {
        isConnected = YES;
    }
    return isConnected;
}
# pragma mask : 设备ID:通过SN查找
- (NSString*) deviceIdentifierOnSN:(NSString*)SNVersion {
    return [self getIdentifierOnSN:SNVersion];
}


# pragma mask : 设置主密钥 : 写入的数据 = mainKey + checkValue; checkValue = 3des[mainkey + key(16个0)].subString(0-8)
- (void) writeMainKey:(NSString*)mainKey onSNVersion:(NSString*)SNVersion{
    if (![self isConnectedOnSNVersionNum:SNVersion]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteMainKeyResult:onErrMsg:)]) {
            [self.delegate didWroteMainKeyResult:NO onErrMsg:@"设备未连接"];
        }
        return;
    }
    __block typeof(self) wSelf = self;
    [self.device loadKey:[self newMainKeyOnSouce:mainKey] successBlock:^{
        if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didWroteMainKeyResult:onErrMsg:)]) {
            [wSelf.delegate didWroteMainKeyResult:YES onErrMsg:nil];
        }
    } failedBlock:^(NSString *errCode, NSString *errInfo) {
        if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didWroteMainKeyResult:onErrMsg:)]) {
            [wSelf.delegate didWroteMainKeyResult:NO onErrMsg:errInfo];
        }
    }];
}
# pragma mask : 设置工作密钥
- (void) writeWorkKey:(NSString*)workKey onSNVersion:(NSString*)SNVersion{
    if (![self isConnectedOnSNVersionNum:SNVersion]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteWorkKeyResult:onErrMsg:)]) {
            [self.delegate didWroteWorkKeyResult:NO onErrMsg:@"设备未连接"];
        }
        return;
    }
    __block typeof(self) wSelf = self;
    __block NSString* weadWorkKey = workKey;
    [self.device loadKey:[self pinKeyInSourceWorkKey:workKey] successBlock:^{
        [self.device loadKey:[wSelf macKeyInSourceWorkKey:weadWorkKey] successBlock:^{
            if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didWroteWorkKeyResult:onErrMsg:)]) {
                [wSelf.delegate didWroteWorkKeyResult:YES onErrMsg:nil];
            }
        } failedBlock:^(NSString *errCode, NSString *errInfo) {
            if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didWroteWorkKeyResult:onErrMsg:)]) {
                [wSelf.delegate didWroteWorkKeyResult:NO onErrMsg:@"写MAC KEY失败"];
            }
        }];
    } failedBlock:^(NSString *errCode, NSString *errInfo) {
        if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didWroteWorkKeyResult:onErrMsg:)]) {
            [wSelf.delegate didWroteWorkKeyResult:NO onErrMsg:@"写PIN KEY失败"];
        }
    }];
}
# pragma mask : 刷卡: 有金额+无密码, 无金额+无密码; 无小数点格式金额
- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onSNVersion:(NSString*)SNVersion {
    if (![self isConnectedOnSNVersionNum:SNVersion]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteWorkKeyResult:onErrMsg:)]) {
            [self.delegate didWroteWorkKeyResult:NO onErrMsg:@"设备未连接"];
        }
        return;
    }

    __block typeof(self) wSelf = self;
    [self.device waitingCard:nil timeOut:20 CheckCardTp:SUPPORTCARDTYPE_MAG_IC_RF moneyNum:[PublicInformation dotMoneyFromNoDotMoney:money] successBlock:^(LDE_CardType cardtype) {
        if (cardtype == CARDTYPE_MAGNETIC) {
            [wSelf MGCardInfoReadingOnSuccess:^(NSDictionary * cardInfo) {
                if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didCardSwipedResult:onSucCardInfo:onErrMsg:)]) {
                    [wSelf.delegate didCardSwipedResult:YES onSucCardInfo:cardInfo onErrMsg:nil];
                }
            } orErrorBlock:^(NSString *errCode, NSString *errInfo) {
                if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didCardSwipedResult:onSucCardInfo:onErrMsg:)]) {
                    [wSelf.delegate didCardSwipedResult:NO onSucCardInfo:nil onErrMsg:errInfo];
                }
            }];
        }
        else if (cardtype == CARDTYPE_ICC) {
            [wSelf ICCardInfoReadingOnSuccess:^(NSDictionary *cardInfo) {
                if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didCardSwipedResult:onSucCardInfo:onErrMsg:)]) {
                    [wSelf.delegate didCardSwipedResult:YES onSucCardInfo:cardInfo onErrMsg:nil];
                }
            } orErrorBlock:^(NSString *errCode, NSString *errInfo) {
                if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didCardSwipedResult:onSucCardInfo:onErrMsg:)]) {
                    [wSelf.delegate didCardSwipedResult:NO onSucCardInfo:nil onErrMsg:errInfo];
                }
            }];
        }
    } failedBlock:^(NSString *errCode, NSString *errInfo) {
        if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didCardSwipedResult:onSucCardInfo:onErrMsg:)]) {
            [wSelf.delegate didCardSwipedResult:NO onSucCardInfo:nil onErrMsg:errInfo];
        }
    }];
}
#pragma mask : PIN加密
- (void) pinEncryptBySource:(NSString*)source withPan:(NSString*)pan onSNVersion:(NSString*)SNVersion {
    if (![self isConnectedOnSNVersionNum:SNVersion]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteWorkKeyResult:onErrMsg:)]) {
            [self.delegate didWroteWorkKeyResult:NO onErrMsg:@"设备未连接"];
        }
        return;
    }
    
    __block typeof(self) wSelf = self;
    [self.device encClearPIN:source withPan:pan successBlock:^(NSString *stringCB) {
        if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didPinEncryptResult:onSucPin:onErrMsg:)]) {
            [wSelf.delegate didPinEncryptResult:YES onSucPin:stringCB onErrMsg:nil];
        }
    } failedBlock:^(NSString *errCode, NSString *errInfo) {
        if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didPinEncryptResult:onSucPin:onErrMsg:)]) {
            [wSelf.delegate didPinEncryptResult:NO onSucPin:nil onErrMsg:errInfo];
        }
    }];
}
# pragma mask : MAC加密
- (void) macEncryptBySource:(NSString*)source onSNVersion:(NSString*)SNVersion {
    if (![self isConnectedOnSNVersionNum:SNVersion]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteWorkKeyResult:onErrMsg:)]) {
            [self.delegate didWroteWorkKeyResult:NO onErrMsg:@"设备未连接"];
        }
        return;
    }
    
    JLPrint(@"开始进行mac加密");
    __block typeof(self) wSelf = self;
    [self.device calculateMac:source successBlock:^(NSString *stringCB) {
        if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didMacEncryptResult:onSucMacPin:onErrMsg:)]) {
            [wSelf.delegate didMacEncryptResult:YES onSucMacPin:stringCB onErrMsg:nil];
        }
    } failedBlock:^(NSString *errCode, NSString *errInfo) {
        if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didMacEncryptResult:onSucMacPin:onErrMsg:)]) {
            [wSelf.delegate didMacEncryptResult:NO onSucMacPin:nil onErrMsg:errInfo];
        }
    }];
}



#pragma mask 2 private interface 
// -- 开启扫描
- (void) startDeviceScanning {
    __block typeof(self) wself = self;
    [self.device startSearchDev:8000 searchOneDeviceBlcok:^(LDC_DEVICEBASEINFO *deviceInfo) {
        if (![deviceInfo.deviceName hasPrefix:kLDDeviceNamePre]) return ;
        NSString* curIdentifier = deviceInfo.deviceIndentifier;
        if ([wself isDeviceListContainsDeviceIdentifier:curIdentifier]) return ;
        [wself deviceListAddedDevice:deviceInfo];
        if ([wself.device isConnectToDevice]) return;
        BOOL needConnectDevice = NO;
        if (wself.connectedIdentifier) {
            if ([curIdentifier isEqualToString:wself.connectedIdentifier]) {
                needConnectDevice = YES;
            }
        } else {
            [wself setConnectedIdentifier:curIdentifier];
            needConnectDevice = YES;
        }
        if (needConnectDevice) {
            [wself.device openDevice:curIdentifier channel:CHANNEL_BLUETOOTH mode:COMMUNICATIONMODE_MASTER successBlock:^{
                [wself.device getDeviceInfo:^(LDC_DeviceInfo *deviceInfo) {
                    JLPrint(@"读取到设备信息:productSN[%@]",deviceInfo.productSN);
                    [wself addSN:deviceInfo.productSN toDeviceIdentifier:curIdentifier];
                    if (wself.delegate && [wself.delegate respondsToSelector:@selector(didConnectedDeviceResult:onSucSN:onErrMsg:)]) {
                        [wself.delegate didConnectedDeviceResult:YES onSucSN:deviceInfo.productSN onErrMsg:nil];
                    }
                } failedBlock:^(NSString *errCode, NSString *errInfo) {
                    if (wself.delegate && [wself.delegate respondsToSelector:@selector(didConnectedDeviceResult:onSucSN:onErrMsg:)]) {
                        [wself.delegate didConnectedDeviceResult:NO onSucSN:nil onErrMsg:errInfo];
                    }
                }];
            } failedBlock:^(NSString *errCode, NSString *errInfo) {
                if (wself.delegate && [wself.delegate respondsToSelector:@selector(didConnectedDeviceResult:onSucSN:onErrMsg:)]) {
                    [wself.delegate didConnectedDeviceResult:NO onSucSN:nil onErrMsg:errInfo];
                }
            }];
        }
    } completeBlock:^(NSMutableArray *deviceArray) {
    }];
}
// -- 关闭扫描
- (void) stopDeviceScanning {
    [self.device stopSearchDev];
    [self cleanDeivceList];
}

// -- 关闭设备
- (void) closeDevice {
    [self.device closeDevice];
}

// -- 读卡数据,并封装; 磁条卡
- (void) MGCardInfoReadingOnSuccess:(void (^) (NSDictionary*))successCB orErrorBlock:(onErrorCB)errorCB {
    __block NSMutableDictionary* cardInfo = [NSMutableDictionary dictionary];
    __block typeof(self) wSelf = self;
    __block onErrorCB errorBlock = errorCB;
    // 先读卡号
    [self.device getPAN:PANDATATYPE_PLAIN successCB:^(NSString *stringCB) {
        [cardInfo setObject:stringCB forKey:@"2"];
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
            errorBlock(errCode, errInfo);
        }];
    } failedBlock:^(NSString *errCode, NSString *errInfo) {
        errorBlock(errCode, errInfo);
    }];
}


// -- 读卡数据,并封装; IC卡
- (void) ICCardInfoReadingOnSuccess:(void (^) (NSDictionary*))successCB orErrorBlock:(onErrorCB)errorCB {
    __block NSMutableDictionary* cardInfo = [NSMutableDictionary dictionary];
    __block typeof(self) wSelf = self;
    __block onErrorCB errorBlock = errorCB;
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
        JLPrint(@"IC卡磁道数据:[%@]",track2);
        [cardInfo setObject:track2 forKey:@"35"];
        
        // 继续读取IC芯片数据
        LFC_GETPIN* getPin = [[LFC_GETPIN alloc] init];
        getPin.panBlock = emvProgress.pan;
        getPin.moneyNum = @"0.00";
        getPin.timeout = 40;
        [wSelf.device continuePBOC:getPin successBlock:^(LFC_EMVResult *emvResult) {
            JLPrint(@"读取IC数据的结果:[%d],IC芯片数据:[%@]",emvResult.result,emvResult.dol);
            if (emvResult.dol && emvResult.dol.length > 0) {
                // 55
                [cardInfo setObject:emvResult.dol forKey:@"55"];
                // 回调读到的卡数据 -- 这里才是真正的读IC卡成功
                successCB(cardInfo);
            } else {
                errorBlock(@"EMV_ERR", @"IC卡数据读取失败");
            }
        } failedBlock:^(NSString *errCode, NSString *errInfo) {
            errorBlock(errCode, errInfo);
        }];
        
    } failedBlock:^(NSString *errCode, NSString *errInfo) {
        errorBlock(errCode, errInfo);
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
    macKey.keyData = [source substringFromIndex:source.length - 40];
    return macKey;
}


#pragma mask 2 model: bleDevices
// -- 清空设备列表
- (void) cleanDeivceList {
    [self.bleDevices removeAllObjects];
}
// -- 添加设备到列表
- (void) deviceListAddedDevice:(LDC_DEVICEBASEINFO*)device {
    NSMutableDictionary* deviceInfo = [[NSMutableDictionary alloc] init];
    [deviceInfo setObject:device forKey:kLDDeviceInfoBasicInfo];
    [self.bleDevices addObject:deviceInfo];
}
// -- 设备列表是否存在指定的设备
- (BOOL) isDeviceListContainsDeviceIdentifier:(NSString*)identifier {
    BOOL isExists = NO;
    for (NSDictionary* iDevice in self.bleDevices) {
        LDC_DEVICEBASEINFO* device = [iDevice objectForKey:kLDDeviceInfoBasicInfo];
        if ([device.deviceIndentifier isEqualToString:identifier]) {
            isExists = YES;
            break;
        }
    }
    return isExists;
}
// -- 设置SN到指定设备ID
- (void) addSN:(NSString*)SN toDeviceIdentifier:(NSString*)identifier {
    for (NSMutableDictionary* device in self.bleDevices) {
        LDC_DEVICEBASEINFO* deviceInfo = [device objectForKey:kLDDeviceInfoBasicInfo];
        if ([deviceInfo.deviceIndentifier isEqualToString:identifier]) {
            [device setObject:SN forKey:kLDDeviceInfoDeviceSN];
            break;
        }
    }
}
// -- 查询设备ID: 指定SN
- (NSString*) getIdentifierOnSN:(NSString*)SN {
    NSString* identifier = nil;
    JLPrint(@"设备列表信息:[%@]",self.bleDevices);
    for (NSMutableDictionary* device in self.bleDevices) {
        if (device[kLDDeviceInfoDeviceSN] && [SN isEqualToString:device[kLDDeviceInfoDeviceSN]]) {
            LDC_DEVICEBASEINFO* deviceInfo = [device objectForKey:kLDDeviceInfoBasicInfo];
            identifier = deviceInfo.deviceIndentifier;
            break;
        }
    }
    return identifier;
}
// -- 查询设备SN: 指定ID
- (NSString*) getSNOnIdentifier:(NSString*)identifier {
    NSString* SN = nil;
    for (NSMutableDictionary* device in self.bleDevices) {
        LDC_DEVICEBASEINFO* deviceInfo = [device objectForKey:kLDDeviceInfoBasicInfo];
        if ([identifier isEqualToString:deviceInfo.deviceIndentifier]) {
            SN = [device objectForKey:kLDDeviceInfoDeviceSN];
            break;
        }
    }
    return SN;
}

@end
