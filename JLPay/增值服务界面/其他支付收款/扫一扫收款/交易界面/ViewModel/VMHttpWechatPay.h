//
//  VMHttpWechatPay.h
//  JLPay
//
//  Created by jielian on 16/4/15.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPInstance.h"
#import "PublicInformation.h"
#import "MD5Util.h"
#import "EncodeString.h"
#import "VMOtherPayType.h"
#import <ReactiveCocoa.h>


typedef enum {
    VMHttpWechatPayStatePrePaying,      // 交易未开始
    VMHttpWechatPayStatePaying,         // 正在交易...
    VMHttpWechatPayStatePaySuc,         // 交易成功
    VMHttpWechatPayStatePayFail,        // 交易失败
    VMHttpWechatPayStateEnquiring,      // 正在轮询...(KVO)
    VMHttpWechatPayStateTerminate       // 交易终止
}VMHttpWechatPayState;

typedef enum {
    VMHttpWechatPayTypePay,
    VMHttpWechatPayTypeRevoke
}VMHttpWechatPayType;



@interface VMHttpWechatPay : NSObject
<UITableViewDataSource>

@property (nonatomic, assign) VMHttpWechatPayType payType;     // 支付/撤销

@property (nonatomic, strong) HTTPInstance* httpPays;
@property (nonatomic, strong) NSMutableArray* httpEnquireArray; // 轮询队列
@property (nonatomic, strong) NSTimer* circleEnquireTimer;

@property (nonatomic, copy) NSError* payError;

@property (nonatomic, strong) NSArray* keyPayList;
@property (nonatomic, strong) NSArray* keyRevokeList;
@property (nonatomic, strong) NSArray* keyEnquireList;

@property (nonatomic, strong) NSMutableDictionary* columnsDic;
@property (nonatomic, strong) NSMutableArray* displayColumnsName;

// --  follow 5 properties displaid(outside) on KVO
@property (nonatomic, assign) VMHttpWechatPayState state;
@property (nonatomic, copy) NSString* stateMessage;         // 交易状态语句: 简单的状态，详细的在 errorBlock 返回;
@property (nonatomic, copy) NSString* payCode;              // 付款码
@property (nonatomic, copy) NSString* payAmount;            // 金额
@property (nonatomic, copy) NSString* goodsName;            // 商品名称




@end
