//
//  IC_GroupPackage8583.h
//  PosN38Universal
//
//  Created by work on 14-10-21.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IC_GroupPackage8583 : NSObject

//IC卡计算解密key
+(NSString *)returenKey;


+(NSString *)return55Info:(NSString *)string;

//参数更新ic

+(NSString *)blue_deviceRefreshData:(NSString *)terminalStr;


//pos状态上送_公钥下载/参数下载ic
//1,公钥下载；2，参数下载

+(NSString *)blue_StatusSend:(int)type;

//pos参数传递_公钥下载/参数下载ic
+(NSString *)blue_ParameterSend:(int)type;

//pos公钥下载结束/参数下载结束ic
+(NSString *)blue_GongyaoDownload:(int)type;

//签到
+(NSString *)blue_signin_IC;

//消费
+(NSString *)blue_consumer_IC:(NSString *)pin;

//余额查询
+(NSString *)blue_searchMoney_IC:(NSString *)pin;

//消费撤销
+(NSString *)blue_consumeRepeal:(NSString *)pin liushui:(NSString *)liushuiStr money:(NSString *)moneyStr;

//消费冲正(交易异常)
+(NSString *)blue_consumeReturn;




@end
