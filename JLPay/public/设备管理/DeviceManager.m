//
//  DeviceManager.m
//  JLPay
//
//  Created by jielian on 15/6/1.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "DeviceManager.h"



@implementation DeviceManager
@synthesize connected = _connected;


# pragma mask : 0 public interface

// -- 0. 创建或获取设备操作入口:单例
+(DeviceManager*) sharedInstance {
    static DeviceManager* _sharedDeviceManager = nil;
    static dispatch_once_t desp;
    dispatch_once(&desp, ^{
        _sharedDeviceManager = [[DeviceManager alloc] init];
    });
    return _sharedDeviceManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.connected = NO;
    }
    return self;
}

// -- 1. 开启扫描 (绑定设备时才用)
- (void) startScanningOnDiscovered:(void (^) (CBPeripheral* peripheral))discoveredPeripheral {
    self.discoveredBlock = discoveredPeripheral;
    /* waiting for CoreBlueToothCentralManager powered ON */
    while (self.blueManager.state != CBCentralManagerStatePoweredOn) {
        sleep(0.3);
    }
    [self.blueManager scanForPeripheralsWithServices:nil options:nil];
}

// -- 2. 关闭扫描
- (void) stopScanning {
    [self.blueManager stopScan];
}


// -- 3. 连接设备
- (void)connectPeripheral:(CBPeripheral *)peripheral
              onConnected:(void (^)(NSString * SNVersion))connectedBlock
                  onError:(void (^)(NSError *error))errorBlock
{
    [self stopScanning];
    
    NameWeakSelf(wself);
    if (self.device && [self.device isConnected]) {
        [self.device disconnectOnFinished:^{
            [wself makeDeviceAndConnectPeripheral:peripheral onConnected:^(NSString *SNVersion) {
                if (connectedBlock) connectedBlock([SNVersion copy]);
            } onError:^(NSError *error) {
                if (errorBlock) errorBlock([error copy]);
            }];
        }];
    } else {
        [wself makeDeviceAndConnectPeripheral:peripheral onConnected:^(NSString *SNVersion) {
            if (connectedBlock) connectedBlock([SNVersion copy]);
        } onError:^(NSError *error) {
            if (errorBlock) errorBlock([error copy]);
        }];
    }
}


// -- 4. 断开设备
- (void) disconnectOnFinished:(void (^) (void))finished {
    if ([self.device isConnected]) {
        NameWeakSelf(wself);
        [wself.device disconnectOnFinished:^{
            wself.device = nil;
            if (finished) finished();
            wself.connected = NO;
        }];
    } else {
        self.device = nil;
        if (finished) finished();
        self.connected = NO;
    }
}

// -- 5. 写主密钥
- (void) writeMainKey:(NSString*)mainKey
           onFinished:(void (^) (void))finished
              onError:(void (^) (NSError* error))errorBlock
{
    if ([self.device isConnected]) {
        [self.device writeMainKey:mainKey onFinished:^{
            if (finished) finished();
        } onError:^(NSError *error) {
            if (errorBlock) errorBlock([error copy]);
        }];
    } else {
        if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:9 localizedDescription:@"蓝牙设备未连接"]);
    }
}

// -- 6. 写工作密钥
- (void) writeWorkKey:(NSString*)workKey
           onFinished:(void (^) (void))finished
              onError:(void (^) (NSError* error))errorBlock
{
    if ([self.device isConnected]) {
        [self.device writeWorkKey:workKey onFinished:^{
            if (finished) finished();
        } onError:^(NSError *error) {
            if (errorBlock) errorBlock([error copy]);
        }];
    } else {
        if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:9 localizedDescription:@"蓝牙设备未连接"]);
    }
}

// -- 7. 刷卡
- (void)swipeCardWithMoney:(NSString *)money onCardInfoReaded:(void (^)(NSDictionary *))cardInfoReaded onError:(void (^)(NSError *))errorBlock
{
    if ([self.device isConnected]) {
        [self.device swipeCardWithMoney:money onCardInfoReaded:^(NSDictionary *cardInfo) {
            if (cardInfoReaded) cardInfoReaded([cardInfo copy]);
        } onError:^(NSError *error) {
            if (errorBlock) errorBlock([error copy]);
        }];
    } else {
        if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:9 localizedDescription:@"蓝牙设备未连接"]);
    }
}

// -- 8. pin加密
- (void) encryptPinSource:(NSString*)pinSource
              onEncrypted:(void (^) (NSString* pin))pinEncrypted
                  onError:(void (^) (NSError* error))errorBlock
{
    if ([self.device isConnected]) {
        [self.device encryptPinSource:pinSource onEncrypted:^(NSString *pin) {
            if (pinEncrypted) pinEncrypted([pin copy]);
        } onError:^(NSError *error) {
            if (errorBlock) errorBlock([error copy]);
        }];
    } else {
        if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:9 localizedDescription:@"蓝牙设备未连接"]);
    }
}

// -- 9. mac加密
- (void) encryptMacSource:(NSString*)macSource
              onEncrypted:(void (^) (NSString* mac))macEncrypted
                  onError:(void (^) (NSError* error))errorBlock
{
    if ([self.device isConnected]) {
        [self.device encryptMacSource:macSource onEncrypted:^(NSString *mac) {
            if (macEncrypted) macEncrypted([mac copy]);
        } onError:^(NSError *error) {
            if (errorBlock) errorBlock([error copy]);
        }];
    } else {
        if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:9 localizedDescription:@"蓝牙设备未连接"]);
    }
}




# pragma mask : 2 CBCentralManagerDelegate

// -- 扫描到设备
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    if ([self isDeviceNamePreListContainName:peripheral.name]) {
        if (self.discoveredBlock) self.discoveredBlock(peripheral);
    }
}

// -- 蓝牙控制器的状态监控
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    CBCentralManagerState curState = central.state;
    switch (curState) {
        case CBCentralManagerStateUnknown:
        {
            JLPrint(@"蓝牙控制器无法识别!!!");
        }
            break;
        case CBCentralManagerStatePoweredOn:
        {
            JLPrint(@"蓝牙控制器已打开!");
        }
            break;
        case CBCentralManagerStateResetting:
        {
            JLPrint(@"蓝牙控制器正在重启...");
        }
            break;
        case CBCentralManagerStatePoweredOff:
        {
            JLPrint(@"蓝牙控制器已关闭");
        }
            break;
        case CBCentralManagerStateUnsupported:
        {
            JLPrint(@"蓝牙控制器不支持");
        }
            break;
        case CBCentralManagerStateUnauthorized:
        {
            JLPrint(@"蓝牙控制器未被批准");
        }
            break;
        default:
            break;
    }
}

# pragma mask : 3 private interface

// -- 创建并连接设备
- (void) makeDeviceAndConnectPeripheral:(CBPeripheral *)peripheral
                            onConnected:(void (^)(NSString * SNVersion))connectedBlock
                                onError:(void (^)(NSError *error))errorBlock
{
    NameWeakSelf(wself);
    [self makeEntryOnDeviceName:peripheral.name];
    [self.device connectWithId:peripheral.identifier.UUIDString onConnected:^(NSString *SNVersion) {
        wself.connected = YES;
        if (connectedBlock) connectedBlock([SNVersion copy]);
    } onError:^(NSError *error) {
        wself.connected = NO;
        if (errorBlock) errorBlock([error copy]);
    }];
}

// --  创建对应 name 的设备入口
- (void) makeEntryOnDeviceName:(NSString*)deviceName {
    NSString* deviceNamePre = [self deviceNamePreOnName:deviceName];
    Class deviceClass = NSClassFromString([NSString stringWithFormat:@"DeviceManager_%@",deviceNamePre]);
    self.device = [[deviceClass alloc] init];
    self.hasNumbersButton = NO;
    if ([deviceNamePre isEqualToString:MPOSDeviceNamePreTY]) {
        self.hasNumbersButton = YES;
    }
    else if ([deviceNamePre isEqualToString:MPOSDeviceNamePreLDM18]) {
        self.hasNumbersButton = NO;
    }
    else if ([deviceNamePre isEqualToString:MPOSDeviceNamePreDongLian]) {
        self.hasNumbersButton = NO;
    }
    else if ([deviceNamePre isEqualToString:MPOSDeviceNamePreSMIT]) {
        self.hasNumbersButton = NO;
    }
}

// -- 指定的设备名是否在厂商列表中
- (BOOL) isDeviceNamePreListContainName:(NSString*)deviceName {
    BOOL contained = NO;
    for (NSString* deviceNamePre in self.deviceNamePreListSupported) {
        if ([deviceName hasPrefix:deviceNamePre]) {
            contained = YES;
            break;
        }
    }
    return contained;
}

// -- 映射厂商设备名前缀
- (NSString*) deviceNamePreOnName:(NSString*)deviceName {
    NSString* namePre = nil;
    for (NSString* deviceNamePre in self.deviceNamePreListSupported) {
        if ([deviceName hasPrefix:deviceNamePre]) {
            namePre = deviceNamePre;
            break;
        }
    }
    return namePre;
}



# pragma mask : 4 getter
- (CBCentralManager *)blueManager {
    if (!_blueManager) {
        dispatch_queue_t queueT = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _blueManager = [[CBCentralManager alloc] initWithDelegate:self queue:queueT];
    }
    return _blueManager;
}

- (NSArray *)deviceNamePreListSupported {
    if (!_deviceNamePreListSupported) {
        _deviceNamePreListSupported = @[MPOSDeviceNamePreTY,
                                        MPOSDeviceNamePreLDM18,
                                        MPOSDeviceNamePreDongLian,
                                        MPOSDeviceNamePreSMIT];
    }
    return _deviceNamePreListSupported;
}

@end
