//
//  VMHttpAlipay.h
//  JLPay
//
//  Created by jielian on 16/4/14.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPInstance.h"
#import "PublicInformation.h"
#import "MD5Util.h"
#import "EncodeString.h"
#import "VMOtherPayType.h"



@interface VMHttpAlipay : NSObject
<UITableViewDataSource>

@property (nonatomic, strong) HTTPInstance* http;
@property (nonatomic, strong) NSArray* keyPayList;
@property (nonatomic, strong) NSArray* keyRevokeList;
@property (nonatomic, strong) NSMutableDictionary* columnsDic;
@property (nonatomic, strong) NSMutableArray* displayColumnsName;

/* follow 8 properties displaid(outside) on KVO */
@property (nonatomic, assign) NSInteger state; // 0:ing, 1:pay suc, 2:revoke suc, -1:pay fail, -2:revoke fail
@property (nonatomic, copy) NSString* stateMessage;         // 交易状态语句
@property (nonatomic, copy) NSString* payCode;              // 付款码
@property (nonatomic, copy) NSString* payAmount;            // 金额
@property (nonatomic, copy) NSString* goodsName;            // 商品名称
@property (nonatomic, copy) NSString* orderNumber;          // 订单编号

//@property (nonatomic, copy) NSString* orderDes;             // 订单描述
//@property (nonatomic, copy) NSString* buyerId;              // 买家id
//@property (nonatomic, copy) NSString* paidOrderNumber;      // 支付宝订单编号
//@property (nonatomic, copy) NSString* transTime;            // 交易时间


// 支付
- (void) startPayingOnFinished:(void (^) (void))finished onError:(void (^) (NSError* error))errorBlock;
// 撤销
- (void) startRevokeOnFinished:(void (^) (void))finished onError:(void (^) (NSError* error))errorBlock;
// 停止交易
- (void) stopTrans;

@end
