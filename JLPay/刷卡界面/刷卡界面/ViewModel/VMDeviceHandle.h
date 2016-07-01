//
//  VMDeviceHandle.h
//  JLPay
//
//  Created by jielian on 16/4/21.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceManager.h"
#import "ModelDeviceBindedInformation.h"
#import <ReactiveCocoa.h>
#import "PublicInformation.h"


typedef enum {
    VMDeviceStateDisconnected,
    VMDeviceStateScanning,
    VMDeviceStateScanned,
    VMDeviceStateDisconnecting,
    VMDeviceStateConnecting,
    VMDeviceStateConnected
} VMDeviceState;


@interface VMDeviceHandle : NSObject


@property (nonatomic, strong) NSString* stateMessage;
@property (nonatomic, assign) BOOL hasNumbersButton;

@property (nonatomic, assign) VMDeviceState deviceState;

@property (nonatomic, strong) DeviceManager* deviceManager;


// -- 1. 直接连接: 在dealloc中断开连接
- (void) connectDeviceOnFinished:(void (^) (void)) finished
                         onError:(void (^) (NSError* error)) errorBlock;

// -- 2. 刷卡
- (void) swipeCardWithMoney:(NSString*)money
           onCardInfoReaded:(void (^) (NSDictionary* cardInfo))cardInfoReaded
                    onError:(void (^) (NSError* error)) errorBlock;

// -- 3. 加密PIN: if hasNumbersButton == NO;
- (void) encryptPinSource:(NSString*)souce
           onEncryptedPIN:(void (^) (NSString* pin))encryptedPin
                  onError:(void (^) (NSError* error))errorBlock;

// -- 4. 加密MAC
- (void) encryptMacSource:(NSString*)souce
           onEncryptedMac:(void (^) (NSString* mac))encryptedMac
                  onError:(void (^) (NSError* error))errorBlock;

// -- 5. 断开连接
- (void) disconnectOnFinished:(void (^) (void))finished;


@end
