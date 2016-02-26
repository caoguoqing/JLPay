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

static NSString* const kLDDeviceInfoBasicInfo = @"BasicInfo";
static NSString* const kLDDeviceInfoDeviceSN =  @"DeviceSN";

static NSString* const kLDDeviceNamePre = @"M18";


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


# pragma mask : 设置主密钥
- (void) writeMainKey:(NSString*)mainKey onSNVersion:(NSString*)SNVersion{}
# pragma mask : 设置工作密钥
- (void) writeWorkKey:(NSString*)workKey onSNVersion:(NSString*)SNVersion{}
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
    [self.device startSearchDev:8000 searchOneDeviceBlcok:^(LDC_DEVICEBASEINFO *deviceInfo) {
        JLPrint(@"扫描到设备:[%@]",deviceInfo);
        if (![deviceInfo.deviceName hasPrefix:kLDDeviceNamePre]) return ;
        NSString* curIdentifier = deviceInfo.deviceIndentifier;
        JLPrint(@"扫描到设备ID:[%@]",curIdentifier);
        if ([self isDeviceListContainsDeviceIdentifier:curIdentifier]) return ;
        [self deviceListAddedDevice:deviceInfo];
        if ([self.device isConnectToDevice]) return;
        BOOL needConnectDevice = NO;
        if (self.connectedIdentifier) {
            if ([curIdentifier isEqualToString:self.connectedIdentifier]) {
                needConnectDevice = YES;
            }
        } else {
            [self setConnectedIdentifier:curIdentifier];
            needConnectDevice = YES;
        }
        if (needConnectDevice) {
            [self.device openDevice:curIdentifier channel:CHANNEL_BLUETOOTH mode:COMMUNICATIONMODE_DUPLEX successBlock:^{
                [self.device getProductSN:^(NSString *stringCB) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectedDeviceResult:onSucSN:onErrMsg:)]) {
                        [self.delegate didConnectedDeviceResult:YES onSucSN:stringCB onErrMsg:nil];
                    }
                } failedBlock:^(NSString *errCode, NSString *errInfo) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectedDeviceResult:onSucSN:onErrMsg:)]) {
                        [self.delegate didConnectedDeviceResult:NO onSucSN:nil onErrMsg:errInfo];
                    }
                }];
            } failedBlock:^(NSString *errCode, NSString *errInfo) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectedDeviceResult:onSucSN:onErrMsg:)]) {
                    [self.delegate didConnectedDeviceResult:NO onSucSN:nil onErrMsg:errInfo];
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
