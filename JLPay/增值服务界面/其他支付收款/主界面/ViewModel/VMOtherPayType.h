//
//  VMOtherPayType.h
//  JLPay
//
//  Created by jielian on 16/4/15.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define_Header.h"

typedef enum {
    OtherPayTypeAlipay,
    OtherPayTypeWechat
} OtherPayType; // 支付类型


@interface VMOtherPayType : NSObject

+ (instancetype) sharedInstance;

@property (nonatomic, assign) OtherPayType curPayType;      // 支付类型:主界面点击切换
@property (nonatomic, copy) NSString* payCode;              // 付款码: 扫一扫界面扫码
@property (nonatomic, copy) NSString* payAmount;            // 支付金额:主界面输入
@property (nonatomic, copy) NSString* goodsName;            // 商品名称:主界面输入
@property (nonatomic, copy) NSString* orderDes;             // 订单描述:暂时默认

@end
