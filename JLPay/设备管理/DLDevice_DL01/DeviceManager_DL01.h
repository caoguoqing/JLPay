//
//  DeviceManager_DL01.h
//  JLPay
//
//  Created by jielian on 16/4/20.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DCSwiperAPI/DCSwiperAPI.h>
#import "PublicInformation.h"
#import "NSError+Custom.h"



static NSString* const MPOSDeviceNamePreDongLian = @"DL01";

static NSString* const kDLDeviceInfoName = @"Name";
static NSString* const kDLDeviceInfoIdentifier = @"identifier";
static NSString* const kDLDeviceInfoKSN = @"SNversion";

static NSString* const kDLDeviceInfoPinKey = @"PINKey";
static NSString* const kDLDeviceInfoMacKey = @"MacKey";


@interface DeviceManager_DL01 : NSObject
<DCSwiperAPIDelegate>

@property (nonatomic, strong) DCSwiperAPI* deviceManager;
@property (nonatomic, copy) NSString* connectedIdentifier;

@property (nonatomic, copy) void (^ connectedDeviceSN) (NSString* SNVersion);           // 连接到设备的回调
@property (nonatomic, copy) void (^ disconnectedDevice) (void);                         // 断开连接的回调
@property (nonatomic, copy) void (^ finishedMainKeyWriting) (void);                     // 主密钥下载完毕
@property (nonatomic, copy) void (^ finishedWorkKeyWriting) (void);                     // 工作密钥下载完毕
@property (nonatomic, copy) void (^ finishedCardInfoReading) (NSDictionary* cardInfo);  // 刷卡完毕
@property (nonatomic, copy) void (^ encryptedPin) (NSString* pin);                      // pin加密
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

// -- 7. pin加密
- (void) encryptPinSource:(NSString*)pinSource
              onEncrypted:(void (^) (NSString* pin))pinEncrypted
                  onError:(void (^) (NSError* error))errorBlock;

// -- 8. mac加密
- (void) encryptMacSource:(NSString*)macSource
              onEncrypted:(void (^) (NSString* mac))macEncrypted
                  onError:(void (^) (NSError* error))errorBlock;


@end
