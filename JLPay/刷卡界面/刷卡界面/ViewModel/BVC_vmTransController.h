//
//  BVC_vmTransController.h
//  JLPay
//
//  Created by jielian on 2016/11/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACCommand;

@interface BVC_vmTransController : NSObject

/* 状态信息 */
@property (nonatomic, strong) NSString* stateMessage;

/* 交易类型 */
@property (nonatomic, copy) NSString* transType;

/* 交易报文 */
@property (nonatomic, copy) NSString* transMessage;

/* 交易结果数据 */
@property (nonatomic, copy) NSDictionary* responseInfo;


/* cmd: 上送交易 */
@property (nonatomic, strong) RACCommand* cmd_transSending;

/* cmd: 上送签名 */
@property (nonatomic, strong) RACCommand* cmd_elecSignSending;

/* cmd: 停止交易上传 */
@property (nonatomic, strong) RACCommand* cmd_stopSending;


@end
