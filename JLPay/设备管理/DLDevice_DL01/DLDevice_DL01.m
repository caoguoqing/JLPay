//
//  DLDevice_DL01.m
//  JLPay
//
//  Created by jielian on 16/1/20.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DLDevice_DL01.h"
#import <DCSwiperAPI/DCSwiperAPI.h>
#import "Define_Header.h"

static NSString* const kDCDeviceInfoName = @"Name";
static NSString* const kDCDeviceInfoIdentifier = @"identifier";
static NSString* const kDCDeviceInfoKSN = @"SNversion";

static NSString* const kDCDeviceInfoPinKey = @"PINKey";
static NSString* const kDCDeviceInfoMacKey = @"MacKey";

static NSString* const kDCDeviceNamePrefix = @"DL01";

@interface DLDevice_DL01()
<DCSwiperAPIDelegate>
@property (nonatomic, strong) DCSwiperAPI* device;

@property (nonatomic, strong) NSMutableArray* deviceList;
@property (nonatomic, strong) NSString* connectedIdentifier;
@property (nonatomic, assign) BOOL connectEnable;

@property (nonatomic, assign) id<DLDevice_DL01Delegate> delegate;

@end

@implementation DLDevice_DL01

- (instancetype)initWithDelegate:(id<DLDevice_DL01Delegate>)deviceDelegate {
    self = [super init];
    if (self) {
        self.connectEnable = NO;
        self.deviceList = [[NSMutableArray alloc] init];
        [self setDelegate:deviceDelegate];
        self.device = [DCSwiperAPI shareInstance];
        [self.device setDelegate:self];
    }
    return self;
}
- (void)dealloc {
    [self setDelegate:nil];
}



# pragma mask : 打开指定 identifier 号的设备
- (void) openDeviceWithIdentifier:(NSString*)identifier {
    JLPrint(@"正在打开设备,查看设备列表:{%@}",self.deviceList);
    // 动联设备创建设备后就已经开始扫描了;所以这里不用
    if (!identifier) {
        if (!self.connectedIdentifier) {
            // do nothing
        } else {
            [self connectDeviceOnId:self.connectedIdentifier];
        }
    } else {
        [self setConnectedIdentifier:identifier];
        if ([self deviceInfoOnId:identifier]) {
            [self connectDeviceOnId:identifier];
        }
    }
    [self setConnectEnable:YES]; // 允许连接设备
    [self scanningDevice];
}

# pragma mask : 关闭所有蓝牙设备
- (void) clearAndCloseAllDevices {
    [self setDelegate:nil];
    [self.device setDelegate:nil];
    [self stopScanningDevice];
    [self disConnectDevice];
    [self setConnectEnable:NO];
}

# pragma mask : 设备ID:通过SN查找
- (NSString*) deviceIdentifierOnSN:(NSString*)SNVersion {
    return [self identifierOnSN:SNVersion];
}


# pragma mask : 判断指定SN号的设备是否已连接
- (BOOL) isConnectedOnSNVersionNum:(NSString*)SNVersion {
    BOOL isConnected = NO;
    if ([self isScannedDevice] && [self isConnectedDevice]) {
        if ([SNVersion isEqualToString:[self SNOfDeviceInfo]]) {
            isConnected = YES;
        }
    }
    return isConnected;
}

# pragma mask : 判断指定设备ID的设备是否已连接
- (BOOL) isConnectedOnIdentifier:(NSString*)identifier {
    BOOL isConnected = NO;
    if ([self isScannedDevice] && [self isConnectedDevice]) {
        if ([identifier isEqualToString:self.connectedIdentifier]) {
            isConnected = YES;
        }
    }
    return isConnected;
}

# pragma mask : 设置主密钥
- (void) writeMainKey:(NSString*)mainKey onSNVersion:(NSString*)SNVersion {
    if ([SNVersion isEqualToString:[self SNOfDeviceInfo]]) {
        [self writeMainKey:mainKey];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteMainKeyResult:onErrMsg:)]) {
            [self.delegate didWroteMainKeyResult:NO onErrMsg:@"设备未连接!"];
        }
    }
}

# pragma mask : 设置工作密钥
- (void) writeWorkKey:(NSString*)workKey onSNVersion:(NSString*)SNVersion {
    if ([SNVersion isEqualToString:[self SNOfDeviceInfo]]) {
        [self writeWorkKey:workKey];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteWorkKeyResult:onErrMsg:)]) {
            [self.delegate didWroteWorkKeyResult:NO onErrMsg:@"设备未连接!"];
        }
    }
}

# pragma mask : 刷卡: 有金额+无密码, 无金额+无密码,
- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onSNVersion:(NSString*)SNVersion {
    if (![SNVersion isEqualToString:[self SNOfDeviceInfo]]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedResult:onSucCardInfo:onErrMsg:)]) {
            [self.delegate didCardSwipedResult:NO onSucCardInfo:nil onErrMsg:@"设备未连接"];
        }
        return;
    }
    double dMoney = 0;
    if (yesOrNot) {
        dMoney = [money doubleValue];
    } else {
        dMoney = 100;
    }
    [self swipeCardOnMoney:dMoney];
}

#pragma mask : PIN加密
- (void) pinEncryptBySource:(NSString*)source withPan:(NSString*)pan onSNVersion:(NSString*)SNVersion {
    if (![SNVersion isEqualToString:[self SNOfDeviceInfo]]) {
        return;
    }
    [self encriptSourcePin:source];
}

# pragma mask : MAC加密
- (void) macEncryptBySource:(NSString*)source onSNVersion:(NSString*)SNVersion {
    if (![SNVersion isEqualToString:[self SNOfDeviceInfo]]) {
        return;
    }
    [self encriptSourceMac:source];
}




#pragma mask 2 -------------- DCSwiperAPIDelegate
//扫描设备结果
-(void)onFindBlueDevice:(NSDictionary *)dic {
    if (![[dic objectForKey:kDCDeviceInfoName] hasPrefix:kDCDeviceNamePrefix]) {
        return;
    }
    NSString* curDeviceIdentifier = [dic objectForKey:kDCDeviceInfoIdentifier];
    JLPrint(@"扫描到设备(%@):[%@]", [dic objectForKey:kDCDeviceInfoName], curDeviceIdentifier);
    // add device if it not exists; else return
    BOOL exists = NO;
    for (NSDictionary* device in self.deviceList) {
        if ([device[kDCDeviceInfoIdentifier] isEqualToString:curDeviceIdentifier]) {
            exists = YES;
            break;
        }
    }
    if (exists) {
        return;
    }
    [self.deviceList addObject:[NSMutableDictionary dictionaryWithDictionary:dic]];
    
    // connect device on connectedIdentifier,if equal to curIdentifier;
    //         or set curIdentifier to connectedIdentifier,and connect it
    if (![self isConnectedDevice]) {
        if (self.connectedIdentifier) {
            if ([self.connectedIdentifier isEqualToString:curDeviceIdentifier]) {
                if (self.connectEnable) {
                    [self connectDeviceOnId:self.connectedIdentifier];
                }
            }
        } else {
            [self setConnectedIdentifier:curDeviceIdentifier];
            if (self.connectEnable) {
                [self connectDeviceOnId:curDeviceIdentifier];
            }
        }
    }
}

//连接设备结果
-(void)onDidConnectBlueDevice:(NSDictionary *)dic {
    [self readDeviceSN];
}


//失去连接到设备
-(void)onDisconnectBlueDevice:(NSDictionary *)dic {
    JLPrint(@"丢失设备:[%@]",dic);
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDisconnectDeviceOnSN:)]) {
        [self.delegate didDisconnectDeviceOnSN:[self SNOfDeviceInfo]];
    }
}


//读取ksn结果
-(void)onDidGetDeviceKsn:(NSDictionary *)dic {
    JLPrint(@"读取到的设备ksn信息:[%@]", dic);
    NSString* SNVersion = [dic objectForKey:@"6"];
    [self deviceInfoAddSN:SNVersion]; // 添加SN到设备信息
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectedDeviceResult:onSucSN:onErrMsg:)]) {
        [self.delegate didConnectedDeviceResult:YES onSucSN:SNVersion onErrMsg:nil];
    }
}

//更新主密钥回调
-(void)onDidUpdateMasterKey:(int)retCode {
    if (retCode == ERROR_OK) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteMainKeyResult:onErrMsg:)]) {
            [self.delegate didWroteMainKeyResult:YES onErrMsg:nil];
        }
    }
}

//更新工作密钥回调
-(void)onDidUpdateKey:(int)retCode {
    if (retCode == ERROR_OK) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteWorkKeyResult:onErrMsg:)]) {
            [self.delegate didWroteWorkKeyResult:YES onErrMsg:nil];
        }
    }
}

//读取卡信息结果
-(void)onDidReadCardInfo:(NSDictionary *)dic {
    JLPrint(@"刷卡数据:[%@]",dic);
    NSMutableDictionary* cardInfoReaded = [[NSMutableDictionary alloc] init];
    // 2,14,22,23,35,36,55
    if (self.device.currentCardType == card_mc) {
        [cardInfoReaded setObject:[dic objectForKey:@"5"] forKey:@"2"]; // 2
        [cardInfoReaded setObject:[[dic objectForKey:@"6"] substringToIndex:4] forKey:@"14"]; //14
        [cardInfoReaded setObject:@"0200" forKey:@"22"]; // 22
        NSString* lenMc35 = [dic objectForKey:@"8"];
        NSString* lenMc36 = [dic objectForKey:@"9"];
        int intLen = ([lenMc35 isEqualToString:@"FF"])?(0):([PublicInformation sistenToTen:lenMc35]);
        JLPrint(@"35域长度:%d",intLen);
        if (intLen > 0) {
            NSString* mc35 = [[dic objectForKey:@"A"] substringToIndex:intLen];
            [cardInfoReaded setObject:mc35 forKey:@"35"]; // 35
        }
        intLen = ([lenMc36 isEqualToString:@"FF"])?(0):([PublicInformation sistenToTen:lenMc36]);
        JLPrint(@"36域长度:%d",intLen);
        if (intLen > 0) {
            NSString* mc36 = [[dic objectForKey:@"B"] substringToIndex:intLen];
            [cardInfoReaded setObject:mc36 forKey:@"36"]; // 36
            JLPrint(@"读到的卡36域:[%@]",mc36);
        }
    }
    else if (self.device.currentCardType == card_ic) {
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedResult:onSucCardInfo:onErrMsg:)]) {
        [self.delegate didCardSwipedResult:YES onSucCardInfo:cardInfoReaded onErrMsg:nil];
    }
}

//加密Pin结果
-(void)onEncryptPinBlock:(NSString *)encPINblock {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPinEncryptResult:onSucPin:onErrMsg:)]) {
        [self.delegate didPinEncryptResult:YES onSucPin:encPINblock onErrMsg:nil];
    }
}

//mac计算结果
-(void)onDidGetMac:(NSString *)strmac {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMacEncryptResult:onSucMacPin:onErrMsg:)]) {
        [self.delegate didMacEncryptResult:YES onSucMacPin:strmac onErrMsg:nil];
    }
}

//取消交易
-(void)onDidCancelCard {
    
}

// -- 操作结果
-(void)onResponse:(int)type :(int)status {
    JLPrint(@"%s type = [%d], status = [%d]",__func__, type, status);
    switch (type) {
        case ERROR_FAIL_CONNECT_DEVICE:
            if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectedDeviceResult:onSucSN:onErrMsg:)]) {
                [self.delegate didConnectedDeviceResult:NO onSucSN:nil onErrMsg:@"连接设备失败"];
            }
            break;
        case ERROR_FAIL_DATA:
        {
            JLPrint(@"设备操作失败:[ERROR_FAIL_DATA]");
        }
            break;
        case ERROR_FAIL_ENCRYPTPIN:
            if (self.delegate && [self.delegate respondsToSelector:@selector(didPinEncryptResult:onSucPin:onErrMsg:)]) {
                [self.delegate didPinEncryptResult:NO onSucPin:nil onErrMsg:@"密码加密失败"];
            }
            break;
        case ERROR_FAIL_GET_KSN:
            if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectedDeviceResult:onSucSN:onErrMsg:)]) {
                [self.delegate didConnectedDeviceResult:NO onSucSN:nil onErrMsg:@"读取SN号失败"];
            }
            break;
        case ERROR_FAIL_GETMAC:
            if (self.delegate && [self.delegate respondsToSelector:@selector(didMacEncryptResult:onSucMacPin:onErrMsg:)]) {
                [self.delegate didMacEncryptResult:NO onSucMacPin:nil onErrMsg:@"MAC加密失败"];
            }
            break;
        case ERROR_FAIL_MCCARD:
            if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedResult:onSucCardInfo:onErrMsg:)]) {
                [self.delegate didCardSwipedResult:NO onSucCardInfo:nil onErrMsg:@"刷卡失败"];
            }
            break;
        case ERROR_FAIL_NEEDIC:
            break;
        case ERROR_FAIL_READCARD:
            if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedResult:onSucCardInfo:onErrMsg:)]) {
                [self.delegate didCardSwipedResult:NO onSucCardInfo:nil onErrMsg:@"读卡失败"];
            }
            break;
        case ERROR_FAIL_TIMEOUT:
            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceManagerTimeOut)]) {
                [self.delegate deviceManagerTimeOut];
            }
            break;
        default:
            break;
    }
}

// -- 刷卡回调
-(void)onDetectCard {
    JLPrint(@"刷卡回调:");
}


#pragma mask 3 PRIVATE INTERFACE
// -- 释放设备信息
- (void) freeDevice {
    [self.device setDelegate:nil];
    [self.device stopScanBlueDevice];
    [self.device disConnect];
    [self setConnectedIdentifier:nil];
    [self.deviceList removeAllObjects];
}


// -- 开启扫描
- (void) scanningDevice {
    JLPrint(@"启动扫描");
    [self.device scanBlueDevice];
}
// -- 关闭扫描
- (void) stopScanningDevice {
    JLPrint(@"关闭扫描");
    [self.device stopScanBlueDevice];
    [self.deviceList removeAllObjects];
}
// -- 是否扫描到设备
- (BOOL) isScannedDevice {
    if (self.deviceList && self.deviceList.count > 0) {
        return YES;
    } else {
        return NO;
    }
}
// -- 连接设备
- (void) connectDeviceOnId:(NSString*)identifier {
    JLPrint(@"从设备列表取出的%@的设备信息[%@]",identifier,[self deviceInfoOnId:identifier]);
    [self.device connectBlueDevice:[self deviceInfoOnId:identifier]];
}

// -- 断开设备
- (void) disConnectDevice {
    [self.device disConnect];
    [self setConnectedIdentifier:nil];
}
// -- 是否已连接设备
- (BOOL) isConnectedDevice {
    return [self.device isConnectBlue];
}

// -- 读取sn
- (void) readDeviceSN {
    JLPrint(@"读取设备SN号");
    [self.device getDeviceKsn];
}

// -- 写主密钥
- (void) writeMainKey:(NSString*)mainKey {
    JLPrint(@"写主密钥:[%@]",mainKey);
    [self.device updateMasterKey:mainKey];
}
// -- 写工作密钥
- (void) writeWorkKey:(NSString *)workKey {
    // 解析workkey到字典
    NSString* pinKey = [workKey substringToIndex:40];
    NSString* macKey = [workKey substringFromIndex:40];
    macKey = [NSString stringWithFormat:@"%@%@",[macKey substringToIndex:16],[macKey substringFromIndex:macKey.length - 8]];
    NSDictionary* workKeyInfo = [NSDictionary dictionaryWithObjects:@[pinKey,macKey] forKeys:@[kDCDeviceInfoPinKey,kDCDeviceInfoMacKey]];
    JLPrint(@"打包后的工作密钥:[%@]",workKeyInfo);
    [self.device updateKey:workKeyInfo];
}

// -- 读卡
- (void) swipeCardOnMoney:(double)money {
    // 2:消费; 3:撤销; 4:查余;
    [self.device readCard:2 money:money];
}
// -- pin加密
- (void) encriptSourcePin:(NSString*)source {
    if (!source || source.length == 0) {
        return;
    }
    NSInteger len = source.length;
    source = [NSString stringWithFormat:@"%02d%@",len,source];
    for (int i = 0; i < 16 - len; i++) {
        source = [source stringByAppendingString:@"F"];
    }
    JLPrint(@"组包后的需要加密的明文:[%@]",source);
    [self.device encryptPin:source];
}
// -- mac加密
- (void) encriptSourceMac:(NSString*)source {
    if (!source || source.length == 0) {
        return;
    }
    JLPrint(@"加密mac:[%@]",source);
    [self.device getMacValue:source];
}


// ---- 设备信息数据源
// -- 设置SN
- (void) deviceInfoAddSN:(NSString*)sn {
    if (!self.connectedIdentifier) {
        return;
    }
    NSMutableDictionary* deviceInfo = [self deviceInfoOnId:self.connectedIdentifier];
    [deviceInfo setObject:sn forKey:kDCDeviceInfoKSN];
    JLPrint(@"设置了sn后的设备列表:[%@]",self.deviceList);
}
// -- 获取SN
- (NSString*) SNOfDeviceInfo {
    if (!self.connectedIdentifier) {
        return nil;
    }
    JLPrint(@"已连接设备的信息:{%@}", [self deviceInfoOnId:self.connectedIdentifier]);
    return [[self deviceInfoOnId:self.connectedIdentifier] objectForKey:kDCDeviceInfoKSN];
}

// -- 获取已连接设备的信息节点
- (NSMutableDictionary*) deviceInfoOnId:(NSString*)identifier {
    NSMutableDictionary* deviceInfo = nil;
    for (NSMutableDictionary* dic in self.deviceList) {
        JLPrint(@"设备列表中,id[%@]",[dic objectForKey:kDCDeviceInfoIdentifier]);
        if ([[dic objectForKey:kDCDeviceInfoIdentifier] isEqualToString:identifier]) {
            deviceInfo = dic;
        }
    }
    return deviceInfo;
}
// -- id获取: 指定SN
- (NSString*) identifierOnSN:(NSString*)SNVersion {
    NSString* identifier = nil;
    for (NSDictionary* deviceInfo in self.deviceList) {
        if ([SNVersion isEqualToString:[deviceInfo objectForKey:kDCDeviceInfoKSN]]) {
            identifier = [deviceInfo objectForKey:kDCDeviceInfoIdentifier];
            break;
        }
    }
    return identifier;
}

#pragma mask 4 getter


@end
