//
//  DeviceManager_JLpay.h
//  JLPay
//
//  Created by jielian on 16/4/20.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSError+Custom.h"
#import "JieLianService.h"
#import "PublicInformation.h"



static NSString* const MPOSDeviceNamePreTY = @"JLpay";

static int const iStateConnceting = 5;

@interface DeviceManager_JLpay : NSObject
<TYJieLianDelegate>

@property (nonatomic, strong) JieLianService* deviceManager;                            // 设备控制器
@property (nonatomic, assign) int deviceConnected;                                      // 监控设备的连接状态
@property (nonatomic, copy) NSString* connectedIdentifier;                              // 要绑定的设备ID

@property (nonatomic, copy) void (^ connectedDeviceSN) (NSString* SNVersion);           // 连接到设备的回调
@property (nonatomic, copy) void (^ disconnectedDevice) (void);                         // 断开连接的回调
@property (nonatomic, copy) void (^ finishedMainKeyWriting) (void);                     // 主密钥下载完毕
@property (nonatomic, copy) void (^ finishedWorkKeyWriting) (void);                     // 工作密钥下载完毕
@property (nonatomic, copy) void (^ finishedCardInfoReading) (NSDictionary* cardInfo);  // 刷卡完毕
@property (nonatomic, copy) void (^ encryptedMac) (NSString* mac);                      // mac加密

@property (nonatomic, copy) void (^ errorBlock) (NSError* error);                       // 设备操作失败的回调

// -- 1. 连接设备
- (void) connectWithId:(NSString*)identifier
           onConnected:(void (^) (NSString* SNVersion))connectedBlock
               onError:(void (^) (NSError* error))errorBlock;

// -- 2. 断开连接
- (void) disconnectOnFinished:(void (^) (void))finished;

// -- 3. 判断连接状态
- (BOOL) isConnected;

// -- 4. 写主密钥
- (void) writeMainKey:(NSString*)mainKey
           onFinished:(void (^) (void))finished
              onError:(void (^) (NSError* error))errorBlock;

// -- 5. 写工作密钥
- (void) writeWorkKey:(NSString*)workKey
           onFinished:(void (^) (void))finished
              onError:(void (^) (NSError* error))errorBlock;

// -- 6. 刷卡
- (void) swipeCardWithMoney:(NSString*)money
           onCardInfoReaded:(void (^) (NSDictionary* cardInfo))cardInfoReaded
                    onError:(void (^) (NSError* error))errorBlock;

// -- 8. mac加密
- (void) encryptMacSource:(NSString*)macSource
              onEncrypted:(void (^) (NSString* mac))macEncrypted
                  onError:(void (^) (NSError* error))errorBlock;


@end
