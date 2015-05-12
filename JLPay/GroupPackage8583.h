//
//  GroupPackage8583.h
//  PosN38Universal
//
//  Created by work on 14-8-8.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupPackage8583 : NSObject

//支付宝
//支付宝二维码消费预下订单
+(NSString *)saomaAndOrderMoney:(NSString *)money;

//支付宝条形码消费(下订单并支付)
+(NSString *)tiaoxingmaConsumer:(NSString *)money tiaoxingmaId:(NSString *)maid;

//支付宝查询
+(NSString *)zhifubaoSearchOrderNum:(NSString *)num;

//支付宝撤销
+(NSString *)zhifubaoReplaceDingdanNum:(NSString *)num;

//支付宝退款
+(NSString *)zhifubaoRebateMoney:(NSString *)money tuikuanDingdanNum:(NSString *)num;









//签到
+(NSString *)signIn;

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



//参数更新

+(NSString *)deviceRefreshData:(NSString *)serialStr;

//回响测试//(终端号：99999986，商户号：999999999999999)
+(NSString *)returnTest;



@end
