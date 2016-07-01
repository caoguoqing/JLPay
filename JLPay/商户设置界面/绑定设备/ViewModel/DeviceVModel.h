//
//  DeviceVModel.h
//  JLPay
//
//  Created by jielian on 16/4/12.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DeviceManager.h"
#import "NSString+Formater.h"
#import "BTDeviceChooseCell.h"
#import "JCAlertView.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"


@interface DeviceVModel : NSObject
<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray* deviceList;
@property (nonatomic, strong) DeviceManager* deviceManager;
@property (nonatomic, strong) CBPeripheral* selectedPeripheral;     // 选择的要连接的设备
@property (nonatomic, assign) BOOL connected;

@property (nonatomic, assign) BOOL enableWriteKey;                  // 绑定在'绑定'按钮的enable状态

@property (nonatomic, strong) NSString* stateMessage;               // 在控制器中监控，并显示状态信息

// -- 1. 扫描设备
- (void) startScanningOnDiscovered:(void (^) (void))discoveredPeripheral;
// -- 2. 关闭扫描
- (void) stopScanning;

// -- 3. 链接设备
- (void) conntectDeviceOnConnected:(void (^) (NSString* SNVersion))connectedSNVersion
                           onError:(void (^) (NSError* error))errorBlock;
// -- 4. 断开连接
- (void) disconnectDeviceOnFinished:(void (^) (void))finished;

// -- 5. 写主密钥
- (void) writeMainKey:(NSString*)mainKey
           onFinished:(void (^) (void))finishedBlock
              onError:(void (^) (NSError* error))errorBlock;

// -- 6. 写工作密钥
- (void) writeWorkKey:(NSString*)workKey
           onFinished:(void (^) (void))finishedBlock
              onError:(void (^) (NSError* error))errorBlock;

@end
