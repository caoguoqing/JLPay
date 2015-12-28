//
//  BLEDeviceManagerTY.h
//  JLPay
//
//  Created by jielian on 15/12/25.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//


/*
 * 天喻蓝牙MPOS设备管理器
 * 只能同时连接一台设备
 */


#import <Foundation/Foundation.h>

static NSString* const BLEDeviceTypeTY = @"JLpay蓝牙刷卡器";

@class BLEDeviceManagerTY;

@protocol BLEDeviceManagerTYDelegate <NSObject>
@optional
/* 连接设备结果 */
- (void) didConnectedDeviceSucOnSN:(NSString*)SNVersion identifier:(NSString*)identifier;
- (void) didConnectedDeviceFail:(NSString*)failMessage OnSN:(NSString *)SNVersion;

/* 断开设备结果 */
- (void) didDisConnectedDeviceOnSN:(NSString*)SNVersion;

/* 写主密钥结果 */
- (void) didWroteMainKeySuccessOnSN:(NSString*)SNVersion;
- (void) didWroteMainKeyFail:(NSString*)failMessage OnSN:(NSString *)SNVersion;

/* 写工作密钥结果 */
- (void) didWroteWorkKeySuccessOnSN:(NSString *)SNVersion;
- (void) didWroteWorkKeyFail:(NSString*)failMessage OnSN:(NSString *)SNVersion;

/* 刷卡结果 */
- (void) didSwipedCardSucWithCardInfo:(NSDictionary*)cardInfo onSN:(NSString*)SNVersion;
- (void) didSwipedCardFail:(NSString*)failMessage onSN:(NSString *)SNVersion;

@end


@interface BLEDeviceManagerTY : NSObject

+ (instancetype) sharedInstance;

@property (nonatomic, assign) id<BLEDeviceManagerTYDelegate> delegate;

/* 检查设备是否连接 */
- (BOOL) isConnected;

/* 连接、断开所有设备 */
- (void) connectAllDevices;
- (void) disConnectAllDevices;

/* 连接、断开设备: 指定SN */
- (void) connectDeviceOnIdentifier:(NSString*)identifier;
- (void) disConnectDeviceOnSN:(NSString*)SNVersion;

/* 写主密钥: 指定SN */
- (void) writeMainKey:(NSString*)mainKey onSN:(NSString*)SNVersion;
/* 写工作密钥: 指定SN */
- (void) writeWorkKey:(NSString *)workKey onSN:(NSString *)SNVersion;

/* 刷卡: 指定SN */
- (void) swipeCardOnSN:(NSString*)SNVersion;


/* -- 测试接口 -- */
- (void) readSN;
@end
