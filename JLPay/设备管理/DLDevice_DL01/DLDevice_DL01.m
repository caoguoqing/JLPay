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
//@property (nonatomic, strong) NSMutableDictionary* deviceInfoDiscovered;

@property (nonatomic, strong) NSMutableArray* deviceList;
@property (nonatomic, strong) NSString* connectedIdentifier;


@end

@implementation DLDevice_DL01

- (instancetype)initWithDelegate:(id<DLDevice_DL01Delegate>)deviceDelegate {
    self = [super init];
    if (self) {
        JLPrint(@"=====TMD  什么时候被创建的");
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


# pragma mask : 开始扫描设备
- (void) startScanningDevices {
    // 停止扫描
    [self stopScanningDevice];
    // 关闭已连接的设备
    if ([self isConnectedDevice]) {
        [self disConnectDevice];
    }
    // 启动扫描
    JLPrint(@"-------什么时候开启扫描了");
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
- (NSString*) identifierOnDeviceSN:(NSString*)SNVersion {
    if (!self.connectedIdentifier) {
        return nil;
    }
    NSString* connectedSN = [[self deviceInfoOnId:self.connectedIdentifier] objectForKey:kDCDeviceInfoKSN];
    if ([connectedSN isEqualToString:SNVersion]) {
        return self.connectedIdentifier;
    } else {
        return nil;
    }
}

# pragma mask : 打开指定 SNVersion 号的设备
- (void) openDevice:(NSString*)SNVersion{
}
# pragma mask : 打开指定 identifier 号的设备
- (void) openDeviceWithIdentifier:(NSString*)identifier {
    JLPrint(@"保存的设备id[%@]，需要打开的id[%@]", self.connectedIdentifier, identifier);
    
    if (![self.connectedIdentifier isEqualToString:identifier]) {
        [self disConnectDevice];
    }
    [self connectDeviceOnId:identifier];
//    if ([identifier isEqualToString:[self deviceIdentifier]]) {
//        if (![self isConnectedDevice]) {
//            [self connectDevice];
//        }
//    }
}
# pragma mask : 关闭指定 SNVersion 号的设备
- (void) closeDevice:(NSString*)SNVersion {
    [self disConnectDevice];
//    [self setDeviceInfoDiscovered:nil];
}

# pragma mask : 判断指定SN号的设备是否已连接
- (int) isConnectedOnSNVersionNum:(NSString*)SNVersion {
    int isConnected = -1;
    if ([self isScannedDevice] && [self isConnectedDevice]) {
        JLPrint(@"。。。读取已连接的SN号:[%@]",[self SNOfDeviceInfo]);
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
        if ([identifier isEqualToString:self.connectedIdentifier]) {
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
    JLPrint(@"money = [%@]",money);
    if (![SNVersion isEqualToString:[self SNOfDeviceInfo]]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedSucOrFail:withError:andCardInfo:)]) {
            [self.delegate didCardSwipedSucOrFail:NO withError:@"刷卡失败:设备未连接" andCardInfo:nil];
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
    
}




#pragma mask 2 DCSwiperAPIDelegate
//扫描设备结果
-(void)onFindBlueDevice:(NSDictionary *)dic {
    if (![[dic objectForKey:kDCDeviceInfoName] hasPrefix:kDCDeviceNamePrefix]) {
        return;
    }
    JLPrint(@"扫描到设备:[%@]", [dic objectForKey:kDCDeviceInfoName]);
    if ([self deviceInfoOnId:[dic objectForKey:kDCDeviceInfoIdentifier]]) {
        return;
    }
    // 追加设备信息到设备列表
    JLPrint(@"====添加扫描到的设备到设备列表:[%@]",dic);
    [self.deviceList addObject:[NSMutableDictionary dictionaryWithDictionary:dic]];
    JLPrint(@"====添加后的设备列表:[%@]",self.deviceList);
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDiscoverDeviceOnID:)]) {
        [self.delegate didDiscoverDeviceOnID:[dic objectForKey:kDCDeviceInfoIdentifier]];
    }
}

//连接设备结果
-(void)onDidConnectBlueDevice:(NSDictionary *)dic {
    self.connectedIdentifier = [dic objectForKey:kDCDeviceInfoIdentifier];
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
    JLPrint(@"刷卡数据:[%@]",dic);
    NSMutableDictionary* cardInfoReaded = [[NSMutableDictionary alloc] init];
    if (self.device.currentCardType == card_mc) {
        
    }

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
//    [self setDeviceInfoDiscovered:nil];
    [self setConnectedIdentifier:nil];
    [self.deviceList removeAllObjects];
}


// -- 开启扫描
- (void) scanningDevice {
    JLPrint(@"启动扫描");
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.device scanBlueDevice];
//    });
}
// -- 关闭扫描
- (void) stopScanningDevice {
    [self.device stopScanBlueDevice];
    JLPrint(@"清空设备列表");
//    [self.deviceList removeAllObjects];
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
//    [self.device stopScanBlueDevice];
//    [self setDeviceInfoDiscovered:nil];
    [self setConnectedIdentifier:nil];
}
// -- 是否已连接设备
- (BOOL) isConnectedDevice {
    return [self.device isConnectBlue];
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

// -- 读卡
- (void) swipeCardOnMoney:(double)money {
    // 2:消费; 3:撤销; 4:查余;
    [self.device readCard:2 money:money];
}

// ---- 设备信息数据源
// -- 设置SN
- (void) deviceInfoAddSN:(NSString*)sn {
    if (!self.connectedIdentifier) {
        JLPrint(@"self.connectedIdentifier为空!!!!!");
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

#pragma mask 4 getter


@end
