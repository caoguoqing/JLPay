//
//  JHLDevice_M60.h
//  JLPay
//
//  Created by jielian on 15/7/4.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JHLDevice_M60_Delegate<NSObject>
@optional
// 读取终端号成功
- (void) didReadingTerminalNo:(NSString*)terminalNo;  // 无用了
// 刷新终端号列表
- (void) renewTerminalNumbers:(NSArray*)terminalNumbers;
// 刷新SN号列表
- (void) renewSNVersionNumbers:(NSArray*)SNVersionNumbers;
// 写终端号结果回调
- (void) didWriteTerminalNumSucOrFail:(BOOL)yesOrNo withError:(NSString*)error;
// 写SN号结果回调
- (void) didWriteSNVersionNumSucOrFail:(BOOL)yesOrNo withError:(NSString*)error;
// 写主密钥结果回调
- (void) didWriteMainKeySucOrFail:(BOOL)yesOrNo withError:(NSString*)error;
// 写工作密钥结果回调
- (void) didWriteWorkKeySucOrFail:(BOOL)yesOrNo withError:(NSString*)error;
// 刷卡结果回调
- (void) didCardSwipedSucOrFail:(BOOL)yesOrNo withError:(NSString*)error;

@end



@interface JHLDevice_M60 : NSObject
@property (assign) id<JHLDevice_M60_Delegate> delegate;
/* 打开所有蓝牙设备 */
- (void) openAllDevices;
// pragma mask : 判断指定终端号的设备是否已连接
- (BOOL) isConnectedOnTerminalNum:(NSString*)terminalNum;
// pragma mask : 判断指定SN号的设备是否已连接
- (BOOL) isConnectedOnSNVersionNum:(NSString*)SNVersion;
// 写终端号+商户号
- (void) writeTerminalNum:(NSString*)terminalNumAndBusinessNum onSNVersion:(NSString*)SNVersion;
// 设置主密钥
- (void) writeMainKey:(NSString*)mainKey onSNVersion:(NSString*)SNVersion;
// 设置工作密钥
- (void) writeWorkKey:(NSString*)workKey onTerminal:(NSString*)terminalNum;
// 刷卡: 有金额+无密码, 无金额+无密码,
- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onTerminal:(NSString*)terminalNum;


@end
