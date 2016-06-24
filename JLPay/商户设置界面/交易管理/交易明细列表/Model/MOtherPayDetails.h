//
//  MOtherPayDetails.h
//  JLPay
//
//  Created by jielian on 16/5/16.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ReactiveCocoa.h>
#import "Define_Header.h"

static NSString* const  kMOtherPayNodeTradeMoney   	= @"tradeMoney"	;
static NSString* const  kMOtherPayNodeMchtNo		= @"mchtNo"		;
static NSString* const  kMOtherPayNodeRevokeStatus  = @"revokeStatus";
static NSString* const  kMOtherPayNodeOrderNo   	= @"orderNo"		;
static NSString* const  kMOtherPayNodeRefundStatus  = @"refundStatus";
static NSString* const  kMOtherPayNodeOrderType   	= @"orderType"		;
static NSString* const  kMOtherPayNodePayStatus   	= @"payStatus"		;
static NSString* const  kMOtherPayNodeTradeTime   	= @"tradeTime"		;
static NSString* const  kMOtherPayNodePayTime   	= @"payTime"		;
static NSString* const  kMOtherPayNodeReverseStatus = @"reverseStatus";
static NSString* const  kMOtherPayNodeGoodsName   	= @"goodsName"	;



@interface MOtherPayDetails : NSObject

+ (instancetype) sharedOtherPayDetails;

/* 明细数组 */
@property (nonatomic, copy) NSArray* originDetails;

/* 过滤后的数组 */
@property (nonatomic, strong) NSMutableArray* siftedDetails;

/* 分组后的明细: 按日期分组;并排序 */
@property (nonatomic, copy) NSArray* separatedDetailsOnDates;

/* 总金额 */
@property (nonatomic, assign) CGFloat totalMoney;

@property (nonatomic, copy) NSIndexPath* selectedIndexPath;

// -- 日期
- (NSString*) dateAtDateIndex:(NSInteger)dateIndex ;

// -- 金额(浮点型): 指定日期序号、内部序号
- (NSString*) moneyAtDateIndex:(NSInteger)dateIndex andInnerIndex:(NSInteger)innerIndex;

// -- 交易类型: 后缀加上撤销、冲正、支付中
- (NSString*) transTypeAtDateIndex:(NSInteger)dateIndex andInnerIndex:(NSInteger)innerIndex;

// -- 订单编号: 用星号截取
- (NSString*) orderNoAtDateIndex:(NSInteger)dateIndex andInnerIndex:(NSInteger)innerIndex;

// -- 交易时间: HH:mm:ss
- (NSString*) transTimeAtDateIndex:(NSInteger)dateIndex andInnerIndex:(NSInteger)innerIndex;

/*****  供筛选用:  *****/
@property (nonatomic, strong) NSArray* mainSiftTitles;
@property (nonatomic, strong) NSArray* allDaysInOriginList;
@property (nonatomic, strong) NSArray* allOrderNosInOriginList;
@property (nonatomic, strong) NSArray* allTransTypesInOriginList;
@property (nonatomic, strong) NSArray* allMoneysInOriginList;

// -- 执行过滤: 指定条件序号
- (void) doSiftingOnSelectedIndexs:(NSArray<NSArray<NSNumber*>*>*)selectedIndexs ;

@end
