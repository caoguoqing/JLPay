//
//  ISControlManager.m
//   深圳锦弘霖蓝牙模块
//
//  Created by  gjh 2015/03/10.
//
//


#import "ISControlManager.h"
#import "ISMFiDataPath.h"
#import "ISBLEDataPath.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ILAlertView.h"
#import "UUID.h"

@interface ISControlManager()<CBCentralManagerDelegate,ISDataPathDelegate> {
    NSMutableArray *_connectedAccessory;
    NSArray *MFi_SPP_Protocol;
    CBCentralManager *manager;
    NSMutableArray *devices;
}
@end
@implementation ISControlManager
@synthesize connectedAccessory = _connectedAccessory;
__strong static id _sharedObject = nil;
+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

+ (id)allocWithZone:(NSZone *)zone {
    if (_sharedObject) {
        return _sharedObject;
    }
    else {
        return [super allocWithZone:zone];
    }
}

- (id)init {
    if (_sharedObject) {
        return _sharedObject;
    }
    else {
        self = [super init];
        if (self) {
            _connect = NO;
            _connectedAccessory = [[NSMutableArray alloc] init];
            MFi_SPP_Protocol = @[@"com.issc.datapath", @"com.issc.datapath2", @"com.issc.datapath3", @"com.issc.datapath4", @"com.issc.datapath5", @"com.issc.datapath6", @"com.issc.datapath7"];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
            //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
            [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
            // 开始搜索已连接或未连接状态的所有蓝牙设备
            [self checkConnectedAccessories];
            manager = [CBCentralManager alloc];
            if ([manager respondsToSelector:@selector(initWithDelegate:queue:options:)]) {
                manager = [manager initWithDelegate:self queue:nil options:@{CBCentralManagerOptionRestoreIdentifierKey: ISSC_RestoreIdentifierKey}];
            }
            else {
                manager = [manager initWithDelegate:self queue:nil];
            }
            devices = [[NSMutableArray alloc] init];
        }
        return self;
    }
}

- (void)checkConnectedAccessories {
    EAAccessory *accessory = nil;
    NSArray *accessories_array = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
    // 所有外设入口
    for (EAAccessory *obj in accessories_array) {
        BOOL haveAccessory = NO;
        // 从已连接的设备列表中检索是否有当前外设- 最开始有可能有蓝牙配对
        for (ISDataPath *dataPath in _connectedAccessory) {
            if ([dataPath isKindOfClass:[ISMFiDataPath class]]) {
                ISMFiDataPath *mDataPath = (ISMFiDataPath *)dataPath;
                if ([[accessory protocolStrings] containsObject:mDataPath.protocolString]) {
                    [mDataPath setProtocolString:mDataPath.protocolString withAccessory:accessory];
                    haveAccessory = YES;
                    break;
                }
            }
        }
        // 如果上一步检索有，就跳到下一个循环
        if (haveAccessory) {
            continue;
        }
        // 没有就检查这个外设是不是需要的，是得话就插入到已连接设备列表
        for (NSString *protocol in MFi_SPP_Protocol) {
//            NSLog(@"[obtainAccessoryForProtocol]111 protocolStr: %@", [obj protocolStrings]);
            if ([[obj protocolStrings] containsObject:protocol]) {
                accessory = obj;
//                NSLog(@"[obtainAccessoryForProtocol] protocolStr: %@", [obj protocolStrings]);
                ISMFiDataPath *dataPath = [[ISMFiDataPath alloc] init];
                dataPath.delegate = self;
                [dataPath setProtocolString:protocol withAccessory:obj];
                [_connectedAccessory addObject:dataPath];
                break;
            }
        }
    }
}
- (BOOL)isConnect {
    return _connect;
}

- (void)scanDeviceList:(ISControlManagerType)type {
    switch (type) {
        case ISControlManagerTypeEA: {
            [[EAAccessoryManager sharedAccessoryManager] showBluetoothAccessoryPickerWithNameFilter:nil completion:^(NSError *error) {
                if (error) {
                    NSLog(@"%@",[error description]);
                }
            }];
            break;
        }
        case ISControlManagerTypeCB: {
            [devices removeAllObjects];
            for (ISDataPath *dataPath in _connectedAccessory) {
                if ([dataPath isKindOfClass:[ISBLEDataPath class]]) {
                    [devices addObject:dataPath];
                }
            }
            [manager scanForPeripheralsWithServices:nil options:nil];
            break;
        }
        default:
            break;
    }
}

- (void)connectDevice:(ISDataPath *)device {
    if ([device isKindOfClass:[ISBLEDataPath class]]) {
        ISBLEDataPath *mDataPath = (ISBLEDataPath *)device;
        /*if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            if ([mDataPath.peripheral state] == CBPeripheralStateDisconnected) {
                [manager connectPeripheral:mDataPath.peripheral options:nil];
            }
        }
        else {
            if (![mDataPath.peripheral isConnected]) {
                [manager connectPeripheral:mDataPath.peripheral options:nil];
            }
        }*/
        if ([mDataPath state] == CBPeripheralStateDisconnected) {
            mDataPath.connecting = YES;
            [manager connectPeripheral:mDataPath.peripheral options:nil];
        }
     }
}

- (void)disconnectDevice:(ISDataPath *)device {
    if ([device isKindOfClass:[ISBLEDataPath class]]) {
        ISBLEDataPath *mDataPath = (ISBLEDataPath *)device;
        /*if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            if ([mDataPath.peripheral state] != CBPeripheralStateDisconnected) {
                [manager cancelPeripheralConnection:mDataPath.peripheral];
            };
        }
        else {
            if ([mDataPath.peripheral isConnected]) {
                [manager cancelPeripheralConnection:mDataPath.peripheral];
            }
        }*/
        if ([mDataPath state] != CBPeripheralStateDisconnected) {
            mDataPath.canSendData = NO;
            [mDataPath cancelWriteData];
            if ([mDataPath.transmit canDisconnect]) {
                [manager cancelPeripheralConnection: mDataPath.peripheral];
            }
            else {
                // 如果设备不能立即断开连接，要先等待数据交互完成或等待10s后断开
                dispatch_async(dispatch_queue_create("temp", NULL), ^{
                    NSLog(@"[CBController] disconnectDevice : Wait for data clear");
                    int timer_count = 0;
                    while (![mDataPath.transmit canDisconnect]) {
                        //[NSThread sleepForTimeInterval:0.1];
                        sleep(1);
                        timer_count++;
                        if (timer_count > 10) {
                            break;
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [manager cancelPeripheralConnection: mDataPath.peripheral];
                    });
                });
            }
        }
    }
}

- (void)disconnectAllDevices {
    for (ISDataPath *dataPath in _connectedAccessory) {
        if ([dataPath isKindOfClass:[ISBLEDataPath class]]) {
            /*ISBLEDataPath *mDataPath = (ISBLEDataPath *)dataPath;
             [manager cancelPeripheralConnection:mDataPath.peripheral];*/
            [self disconnectDevice:dataPath];
        }
    }
    [_connectedAccessory removeAllObjects];
}

- (void)stopScaning {
    [manager stopScan];
}

- (void)writeData:(NSData *)data {
    [_connectedAccessory makeObjectsPerformSelector:@selector(writeData:) withObject:data];
}

- (void)writeData:(NSData *)data withAccessory:(ISDataPath *)accessory {
    [accessory writeData:data];
}

- (void)cancelWriteData {
    [_connectedAccessory makeObjectsPerformSelector:@selector(cancelWriteData) withObject:nil];
}

/*
 Uses CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. An alert is raised if Bluetooth LE is not enabled or is not supported.
 */
- (BOOL) isLECapableHardware
{
    NSString * state = nil;
    
    switch ([manager state])
    {
        case CBCentralManagerStateUnsupported:
//            state = @"蓝牙设备电量过低,请先充电.";
//            break;
        case CBCentralManagerStateUnauthorized:
            state = @"蓝牙设备电量过低,请先充电.";
//            state = @"The app is not authorized to use Bluetooth Low Energy.";

            break;
        case CBCentralManagerStatePoweredOff:
            state = @"手机蓝牙未打开,请先打开手机蓝牙.";
            break;
        case CBCentralManagerStatePoweredOn:
//            NSLog(@"手机蓝牙已开启");
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;
            
    }
    
//    NSLog(@"Central manager state: %@", state);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"蓝牙提示"  message:state delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
    return FALSE;
}

- (void)addDiscoverPeripheral:(CBPeripheral *)aPeripheral advName:(NSString *)advName{
    BOOL find = NO;
    for (ISDataPath *dataPath in devices) {
        if ([dataPath isKindOfClass:[ISBLEDataPath class]]) {
            ISBLEDataPath *mDataPath = (ISBLEDataPath *)dataPath;
            if (aPeripheral == mDataPath.peripheral) {
                // 如果已在已识别列表，则更新 advName
                [mDataPath setPeripheral:aPeripheral withAdvName:advName];
                find = YES;
                break;
            }
        }
    }
    // 只有新识别的没在已识别列表中得设备才会进入已识别列表
    if (!find) {
        ISBLEDataPath *dataPath = [[ISBLEDataPath alloc] init];
        [dataPath setPeripheral:aPeripheral withAdvName:advName];
        [devices addObject:dataPath];
//        if (aPeripheral.isConnected) {
        if ([aPeripheral state] == CBPeripheralStateConnected) {
            [_connectedAccessory addObject:dataPath];
            dataPath.delegate = self;
            _connect = YES;
        }
        if (_deviceList) {
            // 调用者的回调:::获取完了各个设备列表后的处理
            [_deviceList didGetDeviceList:devices andConnected:_connectedAccessory];
        }
        NSLog(@"deviceList = %@",[devices description]);
    }
}

#pragma mark - EAAccessory Notifications

- (void)accessoryDidConnect:(NSNotification *)notification {
    NSLog(@"[MFiDataPath] accessoryDidConnect");
    NSLog(@"%@",[[notification userInfo] description]);
    EAAccessory *accessory = [[notification userInfo] objectForKey:@"EAAccessoryKey"];
    if (accessory) {
         BOOL haveAccessory = NO;
        // 先检查当前“已连接设备列表”中是否有符合当前 外设数据交互入口协议 的蓝牙设备-- 有就退出
        for (ISDataPath *dataPath in _connectedAccessory) {
            if ([dataPath isKindOfClass:[ISMFiDataPath class]]) {
                ISMFiDataPath *mDataPath = (ISMFiDataPath *)dataPath;
                if ([[accessory protocolStrings] containsObject:mDataPath.protocolString]) {
                    [mDataPath setProtocolString:mDataPath.protocolString withAccessory:accessory];
                    haveAccessory = YES;
                    break;
                }
            }
        }
        if (haveAccessory) {
            return;
        }
        // 没有就将它添加到“已连接设备列表中”
        for (NSString *protocol in MFi_SPP_Protocol) {
            if ([[accessory protocolStrings] containsObject:protocol]) {
                ISMFiDataPath *dataPath = [[ISMFiDataPath alloc] init];
                dataPath.delegate = self;
                [dataPath setProtocolString:protocol withAccessory:accessory];
                [_connectedAccessory addObject:dataPath];
                break;
            }
        }
    }
}

#pragma mark - CBCentralManager delegate methods
/*
 Invoked whenever the central manager's state is updated.
 */
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self isLECapableHardware];
}

- (void) centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    NSLog(@"%@",[dict description]);
    if (dict[@"kCBRestoredPeripherals"]) {
        for (CBPeripheral *peripheral in dict[@"kCBRestoredPeripherals"]) {
            [self addDiscoverPeripheral:peripheral advName:peripheral.name];
        }
    }
}

/*
 Invoked when the central discovers heart rate peripheral while scanning.
 */
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
//    NSLog(@"<---------\n[CBController] didDiscoverPeripheral, %@, count=%u, RSSI=%d , %@", aPeripheral.UUID, [advertisementData count], [RSSI intValue], [aPeripheral description]);
//    NSArray *advDataArray = [advertisementData allValues];
//    NSArray *advValueArray = [advertisementData allKeys];
//    
//    for (int i=0; i < [advertisementData count]; i++)
//    {
//        NSLog(@"adv data=%@, %@ ", [advDataArray objectAtIndex:i], [advValueArray objectAtIndex:i]);
//    }
//    NSLog(@"-------->");
    [self addDiscoverPeripheral:aPeripheral advName:[advertisementData valueForKey:CBAdvertisementDataLocalNameKey]];
}

/*
 Invoked when the central manager retrieves the list of known peripherals.
 Automatically connect to first known peripheral
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
//    NSLog(@"Retrieved peripheral: %u - %@", [peripherals count], peripherals);
    if([peripherals count] >=1)
    {
        //[self connectDevice:[peripherals objectAtIndex:0]];
    }
}

/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral
 */
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    NSLog(@"[CBController] didConnectPeripheral, uuid=%@", aPeripheral.UUID);
    for (ISDataPath *dataPath in devices) {
        if ([dataPath isKindOfClass:[ISBLEDataPath class]]) {
            ISBLEDataPath *mDataPath = (ISBLEDataPath *)dataPath;
            if (aPeripheral == mDataPath.peripheral) {
                mDataPath.delegate = self;
                [mDataPath openSession];
                mDataPath.canSendData = YES;
                [_connectedAccessory addObject:dataPath];
                if (_deviceList) {
                    [_deviceList didGetDeviceList:devices andConnected:_connectedAccessory];
                }
                break;
            }
        }
    }
}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    NSLog(@"[CBController] didDisonnectPeripheral uuid = %@, error msg:%d, %@, %@", aPeripheral.UUID, error.code ,[error localizedFailureReason], [error localizedDescription]);
    NSMutableArray *objToRemove = [NSMutableArray array];
    for (ISDataPath *dataPath in _connectedAccessory) {
        if ([dataPath isKindOfClass:[ISBLEDataPath class]]) {
            ISBLEDataPath *mDataPath = (ISBLEDataPath *)dataPath;
            if (aPeripheral == mDataPath.peripheral) {
                [objToRemove addObject:dataPath];
                mDataPath.connecting = NO;
                [dataPath closeSession];
                break;
            }
        }
    }
    [_connectedAccessory removeObjectsInArray:objToRemove];
    if (_deviceList) {
        [_deviceList didGetDeviceList:devices andConnected:_connectedAccessory];
    }
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    NSLog(@"[CBController] Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
    NSMutableArray *objToRemove = [NSMutableArray array];
    for (ISDataPath *dataPath in _connectedAccessory) {
        if ([dataPath isKindOfClass:[ISBLEDataPath class]]) {
            ISBLEDataPath *mDataPath = (ISBLEDataPath *)dataPath;
            if (aPeripheral == mDataPath.peripheral) {
                [objToRemove addObject:dataPath];
                mDataPath.connecting = NO;
                break;
            }
        }
    }
    [_connectedAccessory removeObjectsInArray:objToRemove];
    if (_deviceList) {
        [_deviceList didGetDeviceList:devices andConnected:_connectedAccessory];
    }
}

#pragma mark - ISDataPathDelegate

- (void)dataReceived:(ISDataPath *)dataPath {
    if ([dataPath readBytesAvailable] > 0) {
        NSData *data = [dataPath readData:[dataPath readBytesAvailable]];
        if (_delegate && [_delegate respondsToSelector:@selector(accessoryDidReadData:data:)]) {
            [_delegate accessoryDidReadData:dataPath data:data];
        }
    }
}
- (void)accessoryDidDisconnect:(ISDataPath *)dataPath {
    //[dataPath closeSession];
    [_connectedAccessory removeObject:dataPath];
    if ([_connectedAccessory count] == 0) {
        _connect = NO;
    }
//    if (_delegate && [_delegate respondsToSelector:@selector(accessoryDidDisconnect)]) {
//        [_delegate accessoryDidDisconnect];
//    }
    if (_delegate && [_delegate respondsToSelector:@selector(accessoryDidDisconnect:)]) {
        [_delegate accessoryDidDisconnect:dataPath];
    }
}

- (void)accessoryDidConnected:(ISDataPath *)dataPath {
    if ([dataPath isKindOfClass:[ISMFiDataPath class]]) {
        [dataPath openSession];
    }
    NSLog(@"%@",dataPath.name);
    _connect = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(accessoryDidConnect:)]) {
        [_delegate accessoryDidConnect:dataPath];
    }
}

- (void)accessoryDidWriteData:(ISDataPath *)accessory bytes:(int)bytes complete:(BOOL)complete {
    if (_delegate && [_delegate respondsToSelector:@selector(accessoryDidWriteData:bytes:complete:)]) {
        [_delegate accessoryDidWriteData:accessory bytes:bytes complete:complete];
    }
}

- (void)accessoryDidFailToWriteData:(ISDataPath *)accessory error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(accessoryDidFailToWriteData:error:)]) {
        [self.delegate accessoryDidFailToWriteData:accessory error:error];
    }
}

@end
