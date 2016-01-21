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
static NSString* const kDCDeviceKSN = @"SNversion";

static NSString* const kDCDeviceInfoPinKey = @"PINKey";
static NSString* const kDCDeviceInfoMacKey = @"MacKey";

static NSString* const kDCDeviceNamePrefix = @"DL01";

@interface DLDevice_DL01()
<DCSwiperAPIDelegate>
@property (nonatomic, strong) DCSwiperAPI* device;
@property (nonatomic, strong) NSMutableDictionary* deviceInfoDiscovered;

@end

@implementation DLDevice_DL01

- (instancetype)initWithDelegate:(id<DLDevice_DL01Delegate>)deviceDelegate {
    self = [super init];
    if (self) {
        [self setDelegate:deviceDelegate];
        self.device = [DCSwiperAPI shareInstance];
        [self.device setDelegate:self];
    }
    return self;
}
- (void)dealloc {
    [self setDelegate:nil];
    
}


# pragma mask : 开始扫描设备
- (void) startScanningDevices {
    // 停止扫描
    [self stopScanningDevice];
    // 关闭已连接的设备
    if ([self isConnectedDevice]) {
        [self disConnectDevice];
    }
    // 启动扫描
    [self scanningDevice];
}
# pragma mask : 停止扫描设备
- (void) stopScanningDevices {
    [self stopScanningDevice];
}


# pragma mask : 打开所有蓝牙设备
- (void) openAllDevices{}
# pragma mask : 关闭所有蓝牙设备
- (void) closeAllDevices {
    [self disConnectDevice];
}
# pragma mask : SN号读取:所有设备
- (void) readSNVersions{}
# pragma mask : ID设备获取:根据SN号获取对应设备
- (NSString*) identifierOnDeviceSN:(NSString*)SNVersion{return  nil;}

# pragma mask : 打开指定 SNVersion 号的设备
- (void) openDevice:(NSString*)SNVersion{}
# pragma mask : 打开指定 identifier 号的设备
- (void) openDeviceWithIdentifier:(NSString*)identifier {
    if ([identifier isEqualToString:[self deviceIdentifier]]) {
        if (![self isConnectedDevice]) {
            [self connectDevice];
        }
    }
}
# pragma mask : 关闭指定 SNVersion 号的设备
- (void) closeDevice:(NSString*)SNVersion {
    [self disConnectDevice];
    [self setDeviceInfoDiscovered:nil];
}

# pragma mask : 判断指定SN号的设备是否已连接
- (int) isConnectedOnSNVersionNum:(NSString*)SNVersion {
    int isConnected = -1;
    if ([self isScannedDevice] && [self isConnectedDevice]) {
        if ([SNVersion isEqualToString:[self SNOfDeviceInfo]]) {
            isConnected = 1;
        }
    }
    return isConnected;
}

# pragma mask : 判断指定设备ID的设备是否已连接
// 1:已连接; 0:正在连接; -1:未连接;
- (int) isConnectedOnIdentifier:(NSString*)identifier {
    int isConnected = -1;
    if ([self isScannedDevice] && [self isConnectedDevice]) {
        if ([identifier isEqualToString:[self deviceIdentifier]]) {
            isConnected = 1;
        }
    }
    return isConnected;
}

# pragma mask : 设置主密钥
- (void) writeMainKey:(NSString*)mainKey onSNVersion:(NSString*)SNVersion {
    if ([SNVersion isEqualToString:[self SNOfDeviceInfo]]) {
        [self writeMainKey:mainKey];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteMainKeySucOrFail:withError:)]) {
            [self.delegate didWriteMainKeySucOrFail:NO withError:@"下载主密钥失败:设备未连接!"];
        }
    }
}
# pragma mask : 设置工作密钥
- (void) writeWorkKey:(NSString*)workKey onSNVersion:(NSString*)SNVersion {
    if ([SNVersion isEqualToString:[self SNOfDeviceInfo]]) {
        [self writeWorkKey:workKey];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteWorkKeySucOrFail:withError:)]) {
            [self.delegate didWriteWorkKeySucOrFail:NO withError:@"下载工作密钥失败:设备未连接!"];
        }
    }
}

# pragma mask : 刷卡: 有金额+无密码, 无金额+无密码,
- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onSNVersion:(NSString*)SNVersion {
    
}

#pragma mask : PIN加密
- (void) pinEncryptBySource:(NSString*)source withPan:(NSString*)pan onSNVersion:(NSString*)SNVersion {
    
}




#pragma mask 2 DCSwiperAPIDelegate
//扫描设备结果
-(void)onFindBlueDevice:(NSDictionary *)dic {
    JLPrint(@"扫描到设备:[%@]", [dic objectForKey:kDCDeviceInfoName]);
    if (![[dic objectForKey:kDCDeviceInfoName] hasPrefix:kDCDeviceNamePrefix]) {
        return;
    }
    if ([self isScannedDevice]) {
        JLPrint(@"已扫描到设备,关闭了扫描");
        [self stopScanningDevice];
        return;
    }
    [self setDeviceInfoDiscovered:[NSMutableDictionary dictionaryWithDictionary:dic]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDiscoverDeviceOnID:)]) {
        JLPrint(@"DLDevice扫描到了设备");
        [self.delegate didDiscoverDeviceOnID:[self deviceIdentifier]];
    }
}

//连接设备结果
-(void)onDidConnectBlueDevice:(NSDictionary *)dic {
    [self readDeviceSN];
}


//失去连接到设备
-(void)onDisconnectBlueDevice:(NSDictionary *)dic {
}


//读取ksn结果
-(void)onDidGetDeviceKsn:(NSDictionary *)dic {
    JLPrint(@"读取到的设备ksn信息:[%@]", dic);
    NSString* SNVersion = [dic objectForKey:@"6"];
    [self deviceInfoAddSN:SNVersion]; // 添加SN到设备信息
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReadSNVersion:sucOrFail:withError:)]) {
        [self.delegate didReadSNVersion:SNVersion sucOrFail:YES withError:nil];
    }
    
}

//更新主密钥回调
-(void)onDidUpdateMasterKey:(int)retCode {
    if (retCode == ERROR_OK) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteMainKeySucOrFail:withError:)]) {
            [self.delegate didWriteMainKeySucOrFail:YES withError:nil];
        } else {
            [self.delegate didWriteMainKeySucOrFail:NO withError:@"主密钥下载失败!"];
        }
    }
}

//更新工作密钥回调
-(void)onDidUpdateKey:(int)retCode {
    if (retCode == ERROR_OK) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteWorkKeySucOrFail:withError:)]) {
            [self.delegate didWriteWorkKeySucOrFail:YES withError:nil];
        } else {
            [self.delegate didWriteWorkKeySucOrFail:NO withError:@"工作密钥下载失败!"];
        }
    }
}

//读取卡信息结果
-(void)onDidReadCardInfo:(NSDictionary *)dic {
    
}

//加密Pin结果
-(void)onEncryptPinBlock:(NSString *)encPINblock {
    
}

//mac计算结果
-(void)onDidGetMac:(NSString *)strmac {
    
}

//取消交易
-(void)onDidCancelCard {
    
}

// -- 操作结果
-(void)onResponse:(int)type :(int)status {
    JLPrint(@"%s type = [%d], status = [%d]",__func__, type, status);
    switch (type) {
        case ERROR_FAIL_CONNECT_DEVICE:
            if (self.delegate && [self.delegate respondsToSelector:@selector(didOpenDeviceSucOrFail:withError:)]) {
                [self.delegate didOpenDeviceSucOrFail:NO withError:@"连接设备失败"];
            }
            break;
        case ERROR_FAIL_DATA:
        {
            JLPrint(@"设备操作失败:[ERROR_FAIL_DATA]");
        }
            break;
        case ERROR_FAIL_ENCRYPTPIN:
            if (self.delegate && [self.delegate respondsToSelector:@selector(didEncryptPinSucOrFail:pin:withError:)]) {
                [self.delegate didEncryptPinSucOrFail:NO pin:nil withError:@"密码加密失败"];
            }
            break;
        case ERROR_FAIL_GET_KSN:
            if (self.delegate && [self.delegate respondsToSelector:@selector(didReadSNVersion:sucOrFail:withError:)]) {
                [self.delegate didReadSNVersion:nil sucOrFail:NO withError:@"读取设备SN号失败"];
            }
            break;
        case ERROR_FAIL_GETMAC:
            break;
        case ERROR_FAIL_MCCARD:
            break;
        case ERROR_FAIL_NEEDIC:
            
            break;
        case ERROR_FAIL_READCARD:
            
            break;
        case ERROR_FAIL_TIMEOUT:
            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceTimeOut)]) {
                [self.delegate deviceTimeOut];
            }
            break;
        default:
            break;
    }
}

// -- 刷卡回调
-(void)onDetectCard {
    
}


#pragma mask 3 PRIVATE INTERFACE
// -- 释放设备信息
- (void) freeDevice {
    [self.device setDelegate:nil];
    [self.device stopScanBlueDevice];
    [self.device disConnect];
    [self setDeviceInfoDiscovered:nil];
}


// -- 开启扫描
- (void) scanningDevice {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.device scanBlueDevice];
    });
}
// -- 关闭扫描
- (void) stopScanningDevice {
    [self.device stopScanBlueDevice];
}
// -- 是否扫描到设备
- (BOOL) isScannedDevice {
    if (self.deviceInfoDiscovered) {
        return YES;
    } else {
        return NO;
    }
}
// -- 连接设备
- (void) connectDevice {
    [self.device connectBlueDevice:self.deviceInfoDiscovered];
}
// -- 断开设备
- (void) disConnectDevice {
    [self.device disConnect];
    [self.device stopScanBlueDevice];
    [self setDeviceInfoDiscovered:nil];
}
// -- 是否已连接设备
- (BOOL) isConnectedDevice {
    return [self.device isConnectBlue];
}
// -- 设备 identifier
- (NSString*) deviceIdentifier {
    if ([self isScannedDevice]) {
        return [self.deviceInfoDiscovered objectForKey:kDCDeviceInfoIdentifier];
    } else {
        return nil;
    }
}

// -- 读取sn
- (void) readDeviceSN {
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
    JLPrint(@"原始工作密钥:[%@]",workKey);
    NSString* pinKey = [workKey substringToIndex:40];
    NSString* macKey = [workKey substringFromIndex:40];
    macKey = [NSString stringWithFormat:@"%@%@",[macKey substringToIndex:16],[macKey substringFromIndex:macKey.length - 8]];
    NSDictionary* workKeyInfo = [NSDictionary dictionaryWithObjects:@[pinKey,macKey] forKeys:@[kDCDeviceInfoPinKey,kDCDeviceInfoMacKey]];
    JLPrint(@"打包后的工作密钥:[%@]",workKeyInfo);
    [self.device updateKey:workKeyInfo];
}

// ---- 设备信息数据源
// -- 设置SN
- (void) deviceInfoAddSN:(NSString*)sn {
    [self.deviceInfoDiscovered setObject:sn forKey:kDCDeviceKSN];
}
// -- 获取SN
- (NSString*) SNOfDeviceInfo {
    return [self.deviceInfoDiscovered objectForKey:kDCDeviceKSN];
}

#pragma mask 4 getter 


@end
