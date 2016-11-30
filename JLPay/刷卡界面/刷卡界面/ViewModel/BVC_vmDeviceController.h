//
//  BVC_vmDeviceController.h
//  JLPay
//
//  Created by jielian on 2016/11/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACCommand;

@interface BVC_vmDeviceController : NSObject

/* 状态信息 */
@property (nonatomic, strong) NSString* stateMessage;

/* mpos是否带键盘 */
@property (nonatomic, assign) BOOL mposHasKeyboard;

/* 需加密的原始串 */
@property (nonatomic, copy) NSString* pinSource;
@property (nonatomic, copy) NSString* pinEncrypted;

/* 需计算的mac原始串 */
@property (nonatomic, copy) NSString* macSource;
@property (nonatomic, copy) NSString* macCalculated;

/* 交易金额 */
@property (nonatomic, copy) NSString* money;

/* 读到的卡数据 */
@property (nonatomic, copy) NSDictionary* cardInfo;



/* cmd: 设备连接 */
@property (nonatomic, strong) RACCommand* cmd_deviceConnecting;

/* cmd: 读卡 */
@property (nonatomic, strong) RACCommand* cmd_cardReading;

/* cmd: pin加密 */
@property (nonatomic, strong) RACCommand* cmd_pinEncrypting;

/* cmd: mac计算 */
@property (nonatomic, strong) RACCommand* cmd_macCalculating;

/* cmd: 断开连接 */
@property (nonatomic, strong) RACCommand* cmd_deviceDisconnecting;

@end
