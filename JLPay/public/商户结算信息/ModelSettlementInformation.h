//
//  ModelSettlementInformation.h
//  JLPay
//
//  Created by jielian on 15/12/11.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    SETTLEMENTTYPE_T_1 = 1 << 0, // T+1
    SETTLEMENTTYPE_T_0 = 1 << 1  // T+0
} SETTLEMENTTYPE;


@interface ModelSettlementInformation : NSObject

+ (instancetype) sharedInstance;
/* 结算方式名: 指定结算方式 */
+ (NSString*) nameOfSettlementType:(SETTLEMENTTYPE)settlementType;


/* 当前结算方式 */
- (SETTLEMENTTYPE) curSettlementType;
/* 切换结算方式 */
- (SETTLEMENTTYPE) settlementTypeSwitched;

/* 更新结算方式 */
- (void) updateSettlementType:(SETTLEMENTTYPE)settlementType;

/* 保存结算信息 */
- (void) saveSettlementInfo:(NSDictionary*)settlementInfo;



#pragma mask ---- 结算信息
/* 是否允许T+0 */
- (BOOL) T_0EnableOrNot;

/* T+0日结算限额 */
- (NSString*) T_0DaySettlementAmountLimit;

/* T+0日可刷金额 */
- (NSString*) T_0DaySettlementAmountAvailable;

/* T+0最低消费金额 */
- (NSString*) T_0MinSettlementAmount;

/* T+0增加费率 */
- (NSString*) T_0SettlementFeeRate;

/* T+0比较金额 */
- (NSString*) T_0CompareMoney;
/* T+0额外手续费 */
- (NSString*) T_0CompareExtraFee;

@end
