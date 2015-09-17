//
//  GroupPackage8583.h
//  PosN38Universal
//
//  Created by work on 14-8-8.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupPackage8583 : NSObject

#pragma mask ---- 重写8583报文打包函数
+ (NSString*) stringPacking8583;


//签到
+(NSString *)signIn;

// 商户登陆
+(NSString *)loadIn;

//公钥下发
+(NSString *)downloadPublicKey;

//主密钥下发
+(NSString *)downloadMainKey;

//消费
+(NSString *)consume:(NSString *)pin;

//消费冲正(交易异常)
+(NSString *)consumeReturn;

//消费撤销
+(NSString *)consumeRepeal:(NSString *)pin liushui:(NSString *)liushuiStr money:(NSString *)moneyStr;

//余额查询
+(NSString *)balanceSearch:(NSString *)pin;

+(NSString *)deviceRefreshData:(NSString *)serialStr;

//回响测试//(终端号：99999986，商户号：999999999999999)
+(NSString *)returnTest;


@end
