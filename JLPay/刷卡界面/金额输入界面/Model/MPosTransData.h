//
//  MPosTransData.h
//  JLPay
//
//  Created by jielian on 16/7/22.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MposTransType) {
    MposTransTypeConsume,                       /* 消费 */
    MposTransTypeReversal,                      /* 冲正 */
    MposTransTypeRevoke,                        /* 撤销 */
    MposTransTypeBatchUp                        /* 批上送:IC卡交易 */
};


@interface MPosTransData : NSObject


@property (nonatomic, assign) MposTransType transType;      /* 交易类型 */

@property (nonatomic, copy) NSString* F2_cardNo;

@property (nonatomic, copy) NSString* F3_transType;

@property (nonatomic, copy) NSString* F4_intMoney;

@property (nonatomic, copy) NSString* F11_seqNo;

@property (nonatomic, copy) NSString* F14_validThru;

@property (nonatomic, copy) NSString* F22_validThru;

@property (nonatomic, copy) NSString* F23_validThru;

@property (nonatomic, copy) NSString* F25_validThru;

@property (nonatomic, copy) NSString* F42_validThru;

@property (nonatomic, copy) NSString* F44_validThru;

@property (nonatomic, copy) NSString* F52_validThru;

@property (nonatomic, copy) NSString* F53_validThru;

@property (nonatomic, copy) NSString* F55_validThru;

@property (nonatomic, copy) NSString* F60_validThru;
@property (nonatomic, copy) NSString* F62_validThru;
@property (nonatomic, copy) NSString* F63_validThru;
@property (nonatomic, copy) NSString* F64_validThru;

@end
