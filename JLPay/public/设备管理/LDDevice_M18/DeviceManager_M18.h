//
//  DeviceManager_M18.h
//  JLPay
//
//  Created by 冯金龙 on 16/4/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LandiMPOS.h"
#import "Define_Header.h"
#import "ThreeDesUtil.h"
#import "EncodeString.h"
#import "DeviceManager.h"
#import "Unpacking8583.h"
#import "NSError+Custom.h"

static NSString* const MPOSDeviceNamePreLDM18 = @"M18";

static NSString* const kKey3DESMainKey = @"0000000000000000";


@interface DeviceManager_M18 : NSObject

@property (nonatomic, strong) LandiMPOS* device;
@property (nonatomic, copy) NSString* cardNo;


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
