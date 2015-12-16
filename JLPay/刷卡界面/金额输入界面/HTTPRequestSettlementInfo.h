//
//  HTTPRequestSettlementInfo.h
//  JLPay
//
//  Created by jielian on 15/12/7.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

/* keys of settlementInfo */
static NSString* const kSettleInfoNameT_0_Enable = @"kSettleInfoNameT_0_Enable"; // 是否允许T+0
static NSString* const kSettleInfoNameAmountLimit = @"kSettleInfoNameAmountLimit"; // 当日限额
static NSString* const kSettleInfoNameAmountAvilable = @"kSettleInfoNameAmountAvilabel"; // 当日可用限额
static NSString* const kSettleInfoNameMinCustAmount = @"kSettleInfoNameMinCustAmount"; // T+0最小消费金额
static NSString* const kSettleInfoNameT_0_Fee = @"kSettleInfoNameT_0_Fee"; // T+0费率
static NSString* const kSettleInfoNameCompareMoney = @"kSettleInfoNameCompareMoney"; // T+0比较金额
static NSString* const kSettleInfoNameExtraFee = @"kSettleInfoNameExtraFee"; // 额外手续费


@class HTTPRequestSettlementInfo;
@protocol HTTPRequestSettlementInfoDelegate <NSObject>

/* 成功 */
- (void) didRequestedSuccessWithSettlementInfo:(NSDictionary*)settlementInfo;
/* 失败 */
- (void) didRequestedFailedWithErrorMessage:(NSString*)errorMessage;


@end


@interface HTTPRequestSettlementInfo : NSObject

/* 公共入口 */
+ (instancetype) sharedInstance;

/* 申请结算信息，指定: 商户号、终端号 */
- (void) requestSettlementInfoWithBusinessNumber:(NSString*)businessNumber
                                        delegate:(id<HTTPRequestSettlementInfoDelegate>)delegate;

/* 终止 */
- (void) requestTerminate;

@end
