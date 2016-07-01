//
//  JLPayDevice_TY01.h
//  JLPay
//
//  Created by jielian on 15/9/8.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JieLianService.h"
#import "Define_Header.h"
#import "DeviceManager.h"
#import "NSError+Custom.h"

//static NSString* const MPOSDeviceNamePreTY = @"JLpay";



@interface JLPayDevice_TY01 : NSObject


@property (nonatomic, retain) JieLianService* deviceManager;                    // 设备控制器
@property (nonatomic, strong) NSMutableArray* deviceList;

@property (nonatomic, strong, readonly) NSString* connectedIdentifier;          // 设备ID:需要连接的

@property (nonatomic, copy) void (^ connectedBlock) (NSString* SNVersion);      // 连接成功的回调
@property (nonatomic, copy) void (^ finishDisconnected) (void);                 // 完成:断开连接

@property (nonatomic, copy) void (^ errorBlock) (NSError* error);               // 操作失败的回调



// -- 1. 连接设备
- (void) connectWithId:(NSString*)identifier
           onConnected:(void (^) (NSString* SNVersion))connectedBlock
               onError:(void (^) (NSError* error))errorBlock;
// -- 2. 断开连接
- (void) disconnectOnFinished:(void (^) (void))finished;

// -- 3. 判断连接状态
- (BOOL) isConnected;



@end
