//
//  DeviceManager.h
//  JLPay
//
//  Created by jielian on 15/6/1.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "NSError+Custom.h"
#import "Define_Header.h"
#import "ModelDeviceBindedInformation.h"

#import "DeviceManager_M18.h"
#import "DeviceManager_JLpay.h"
#import "DeviceManager_DL01.h"
#import "DeviceManager_SMIT.h"


typedef enum {
    DeviceManagerErrorTypeNullDevice,   // 创建失败: 设备入口
    DeviceManagerErrorTypeConnectFail,  // 连接失败
    DeviceManagerErrorTypeBindFail      // 绑定失败
} DeviceManagerErrorType;




@interface DeviceManager : NSObject
<CBCentralManagerDelegate>


# pragma mask -> 属性定义区

@property (nonatomic, assign) BOOL connected;                                       // 连接状态
@property (nonatomic, assign) BOOL hasNumbersButton;                                // 设备是否有数字按键




# pragma mask -> 方法定义区

// -- 0. 设备管理器公共入口
+(DeviceManager*) sharedInstance;

// -- 1. 开启扫描 (绑定设备时才用)
- (void) startScanningOnDiscovered:(void (^) (CBPeripheral* peripheral))discoveredPeripheral;

// -- 2. 关闭扫描
- (void) stopScanning;

// -- 3. 连接设备
- (void) connectPeripheral:(CBPeripheral* )peripheral
               onConnected:(void (^) (NSString* SNVersion))connectedBlock
                   onError:(void (^) (NSError* error))errorBlock;

// -- 4. 断开设备:并释放设备入口
- (void) disconnectOnFinished:(void (^) (void))finished;

// -- 5. 写主密钥
- (void) writeMainKey:(NSString*)mainKey
           onFinished:(void (^) (void))finished
              onError:(void (^) (NSError* error))errorBlock;

// -- 6. 写工作密钥
- (void) writeWorkKey:(NSString*)workKey
           onFinished:(void (^) (void))finished
              onError:(void (^) (NSError* error))errorBlock;

// -- 7. 刷卡  money:单位'分'
- (void) swipeCardWithMoney:(NSString*)money onCardInfoReaded:(void (^) (NSDictionary* cardInfo))cardInfoReaded onError:(void (^) (NSError* error))errorBlock;

// -- 8. pin加密
- (void) encryptPinSource:(NSString*)pinSource
              onEncrypted:(void (^) (NSString* pin))pinEncrypted
                  onError:(void (^) (NSError* error))errorBlock;

// -- 9. mac加密
- (void) encryptMacSource:(NSString*)macSource
              onEncrypted:(void (^) (NSString* mac))macEncrypted
                  onError:(void (^) (NSError* error))errorBlock;



# pragma mask : private properties

@property (nonatomic, strong) CBCentralManager* blueManager;                        // 蓝牙管理器:用来扫描设备
@property (nonatomic, strong) NSArray* deviceNamePreListSupported;                  // 列表:设备名前缀(所有厂商)
@property (nonatomic, strong) id device;                                            // 设备入口
// -- block
@property (nonatomic, copy) void (^ discoveredBlock) (CBPeripheral* peripheral);    // 发现蓝牙设备


@end
