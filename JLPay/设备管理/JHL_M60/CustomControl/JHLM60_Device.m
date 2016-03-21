//
//  JHLM60_Device.m
//  JLPay
//
//  Created by jielian on 16/3/18.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "JHLM60_Device.h"

@interface JHLM60_Device()
<ISControlManagerDelegate,ISControlManagerDeviceList>
@property (nonatomic, strong) ISControlManager* manager;
@property (nonatomic, strong) NSMutableArray* deviceList;

@property (nonatomic, copy) void (^scannedDevice) (CBPeripheral* device); // 扫描到设备
@property (nonatomic, copy) void (^connectedDevice) (CBPeripheral* device); // 连接了设备
@property (nonatomic, copy) void (^connectedFailed) ();


@end

@implementation JHLM60_Device

// -- 扫描设备;回调中刷新扫描到的设备列表
- (void) startScanningOnDeviceScanned:(void (^) (CBPeripheral* deviceScanned))scannedBlock {
    self.scannedDevice = scannedBlock;
    [self.manager scanDeviceList:ISControlManagerTypeCB];
}

// -- 关闭扫描
- (void) stopScanning {
    [self.deviceList removeAllObjects];
    [self.manager stopScaning];
}

// -- 连接设备
- (void) connectDevice:(CBPeripheral*)device
            onSucBlock:(void (^) (void))sucBlock
          onErrorBlock:(void (^) (NSError* error))errBlock
{
    
}



#pragma mask 1 ISControlManagerDeviceList
- (void)didGetDeviceList:(NSArray *)devices andConnected:(NSArray *)connectList {
    for (ISBLEDataPath* dataPath in devices) {
        if (![self existsDevice:dataPath]) {
            [self.deviceList addObject:dataPath];
            // 回调
            self.scannedDevice(dataPath.peripheral);
        }
    }
}
#pragma mask 1 ISControlManagerDelegate
- (void) accessoryDidConnect:(ISDataPath *)accessory {
    
}

#pragma mask 3 model: deviceList
// --
- (BOOL) existsDevice:(ISBLEDataPath*)device {
    BOOL exists = NO;
    for (ISBLEDataPath* dataPath in self.deviceList) {
        if ([dataPath.UUID.UUIDString isEqualToString:device.UUID.UUIDString]) {
            exists = YES;
            break;
        }
    }
    return exists;
}


#pragma mask 5 getter 
- (ISControlManager *)manager {
    if (!_manager) {
        _manager = [ISControlManager sharedInstance];
        [_manager setDelegate: self];
        [_manager setDeviceList: self];
    }
    return _manager;
}
- (NSMutableArray *)deviceList {
    if (!_deviceList) {
        _deviceList = [NSMutableArray array];
    }
    return _deviceList;
}


@end
