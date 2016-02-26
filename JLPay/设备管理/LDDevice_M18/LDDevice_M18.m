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

static NSString* const kLDDeviceInfoBasicInfo = @"BasicInfo";
static NSString* const kLDDeviceInfoDeviceSN =  @"DeviceSN";

static NSString* const kLDDeviceNamePre = @"M18";

static NSString* const kKey3DESMainKey = @"3030303030303030";

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
        JLPrint(@"开始创建联迪设备入口");
        [self setDevice:[LandiMPOS getInstance]];
        JLPrint(@"固件版本信息:[%@]", [self.device getLibVersion]);
        JLPrint(@"完成创建联迪设备入口");
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
    JLPrint(@"已设置的绑定id:[%@]",self.connectedIdentifier);
    BOOL isConnected = NO;
    NSString* identifier = [self getIdentifierOnSN:SNVersion];
    if ([self.device isConnectToDevice] && identifier && [identifier isEqualToString:self.connectedIdentifier]) {
        isConnected = YES;
    }
    return isConnected;
}
# pragma mask : 判断指定设备ID的设备是否已连接
- (BOOL) isConnectedOnIdentifier:(NSString*)identifier {
    JLPrint(@"已设置的绑定id:[%@]",self.connectedIdentifier);
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
        JLPrint(@"写主密钥成功");
        if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didWroteMainKeyResult:onErrMsg:)]) {
            [wSelf.delegate didWroteMainKeyResult:YES onErrMsg:nil];
        }
    } failedBlock:^(NSString *errCode, NSString *errInfo) {
        JLPrint(@"写主密钥失败:%@",errInfo);
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
            JLPrint(@"写工作密钥成功");
            if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didWroteWorkKeyResult:onErrMsg:)]) {
                [wSelf.delegate didWroteWorkKeyResult:YES onErrMsg:nil];
            }
        } failedBlock:^(NSString *errCode, NSString *errInfo) {
            JLPrint(@"写工作密钥失败:%@",errInfo);
            if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didWroteWorkKeyResult:onErrMsg:)]) {
                [wSelf.delegate didWroteWorkKeyResult:NO onErrMsg:@"写MAC KEY失败"];
            }
        }];
    } failedBlock:^(NSString *errCode, NSString *errInfo) {
        JLPrint(@"写工作密钥失败:%@",errInfo);
        if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(didWroteWorkKeyResult:onErrMsg:)]) {
            [wSelf.delegate didWroteWorkKeyResult:NO onErrMsg:@"写PIN KEY失败"];
        }
    }];
}
# pragma mask : 刷卡: 有金额+无密码, 无金额+无密码,
- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onSNVersion:(NSString*)SNVersion {}
#pragma mask : PIN加密
- (void) pinEncryptBySource:(NSString*)source withPan:(NSString*)pan onSNVersion:(NSString*)SNVersion{}
# pragma mask : MAC加密
- (void) macEncryptBySource:(NSString*)source onSNVersion:(NSString*)SNVersion {}



#pragma mask 2 private interface 
// -- 开启扫描
- (void) startDeviceScanning {
    JLPrint(@"开始扫描");
    __block typeof(self) wself = self;
    [self.device startSearchDev:8000 searchOneDeviceBlcok:^(LDC_DEVICEBASEINFO *deviceInfo) {
        if (![deviceInfo.deviceName hasPrefix:kLDDeviceNamePre]) return ;
        NSString* curIdentifier = deviceInfo.deviceIndentifier;
        JLPrint(@"扫描到设备[%@]ID:[%@]",deviceInfo.deviceName,curIdentifier);
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
        JLPrint(@"扫描完毕,扫描到设备组:[%@]",deviceArray);
    }];
}
// -- 关闭扫描
- (void) stopDeviceScanning {
    JLPrint(@"关闭扫描");
    [self.device stopSearchDev];
    [self cleanDeivceList];
}

// -- 关闭设备
- (void) closeDevice {
    [self.device closeDevice];
}


#pragma mask 2 model: 密钥相关
// -- 主密钥生成
- (LFC_LoadKey*) newMainKeyOnSouce:(NSString*)mainKey {
    mainKey = @"8AA431C8BA205B34EFCEA7C4314CD53E";
    LFC_LoadKey* newMainKey = [[LFC_LoadKey alloc] init];
    newMainKey.keyType = KEYTYPE_MKEY;
    NSString* encryptedMainKey = [ThreeDesUtil encryptUse3DES:[EncodeString encodeASC:mainKey] key:kKey3DESMainKey];
    NSString* newMainKeyData = [mainKey stringByAppendingString:[encryptedMainKey substringToIndex:8]];
    JLPrint(@"\n3des加密前的主密钥:[%@]\n加密后的密钥:[%@]\n合成后的新主密钥:[%@]",mainKey, encryptedMainKey,newMainKeyData);
    newMainKey.keyData = newMainKeyData;
    return newMainKey;
}
// -- 工作密钥拆分: pin key
- (LFC_LoadKey*) pinKeyInSourceWorkKey:(NSString*)source {
    LFC_LoadKey* pinKey = [[LFC_LoadKey alloc] init];
    pinKey.keyType = KEYTYPE_PIN;
    pinKey.keyData = [source substringToIndex:40];
    JLPrint(@"pinkey = [%@]",pinKey.keyData);
    return pinKey;
}
// -- 工作密钥拆分: mac key
- (LFC_LoadKey*) macKeyInSourceWorkKey:(NSString*)source {
    LFC_LoadKey* macKey = [[LFC_LoadKey alloc] init];
    macKey.keyType = KEYTYPE_MAC;
    macKey.keyData = [source substringFromIndex:source.length - 40];
    JLPrint(@"macKey = [%@]",macKey.keyData);
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
