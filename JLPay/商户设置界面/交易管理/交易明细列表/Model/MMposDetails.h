//
//  MMposDetails.h
//  JLPay
//
//  Created by jielian on 16/5/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ReactiveCocoa.h>
#import "Define_Header.h"

static NSString* const kMMposNodeCardNo = @"pan";
static NSString* const kMMposNodeMoney = @"amtTrans";
static NSString* const kMMposNodeTxnType = @"txnNum";
static NSString* const kMMposNodeDate = @"instDate";
static NSString* const kMMposNodeTime = @"instTime";
static NSString* const kMMposNodeSysSeqNum = @"sysSeqNum";
static NSString* const kMMposNodeCardAccpId = @"cardAccpId";
static NSString* const kMMposNodeCardAccpName = @"cardAccpName";
static NSString* const kMMposNodeCardAccpTermId = @"cardAccpTermId";
static NSString* const kMMposNodeRetrivlRef = @"retrivlRef";
static NSString* const kMMposNodeAcqInstIdCode = @"acqInstIdCode";
static NSString* const kMMposNodeCancelFlag = @"cancelFlag";
static NSString* const kMMposNodeRevsal_flag = @"revsal_flag";
static NSString* const kMMposNodeRespCode = @"respCode";
static NSString* const kMMposNodeFldReserved = @"fldReserved";
static NSString* const kMMposNodeClearType = @"clearType";
static NSString* const kMMposNodeSettleFlag = @"settleFlag";
static NSString* const kMMposNodeSettleMoney = @"settleMoney";
static NSString* const kMMposNodeRefuseReason = @"refuseReason";


@interface MMposDetails : NSObject

+ (instancetype) sharedMposDetails;

/* 原始明细数组 */
@property (nonatomic, copy) NSArray* originDetails;

/* 过滤后的数组 */
@property (nonatomic, strong) NSMutableArray* siftedDetails;


/* 分组后的明细: 按日期分组;并排序 */
@property (nonatomic, strong) NSArray* separatedDetailsOnDates;


/* cell选定的序号 */
@property (nonatomic, copy) NSIndexPath* selectedIndexPath;



/*****  供显示字段用(从separatedDetailsOnDates读取):  *****/

/* 总金额 */
@property (nonatomic, assign) CGFloat totalMoney;

// -- 日期: yyyyMMddHHmmss
- (NSString*) dateAtDateIndex:(NSInteger)dateIndex ;

// -- 金额(浮点型): 指定日期序号、内部序号
- (NSString*) moneyAtDateIndex:(NSInteger)dateIndex andInnerIndex:(NSInteger)innerIndex;

// -- 交易类型: 后缀加上撤销、冲正、退货
- (NSString*) transTypeAtDateIndex:(NSInteger)dateIndex andInnerIndex:(NSInteger)innerIndex;

// -- 卡号: 用星号截取
- (NSString*) cardNoAtDateIndex:(NSInteger)dateIndex andInnerIndex:(NSInteger)innerIndex;

// -- 交易时间: HH:mm:ss
- (NSString*) transTimeAtDateIndex:(NSInteger)dateIndex andInnerIndex:(NSInteger)innerIndex;



/*****  供筛选用:  *****/
@property (nonatomic, strong) NSArray* mainSiftTitles;
@property (nonatomic, strong) NSArray* allDaysInOriginList;
@property (nonatomic, strong) NSArray* allCardNosInOriginList;
@property (nonatomic, strong) NSArray* allTransTypesInOriginList;
@property (nonatomic, strong) NSArray* allMoneysInOriginList;


// -- 执行过滤: 指定条件序号
- (void) doSiftingOnSelectedIndexs:(NSArray<NSArray<NSNumber*>*>*)selectedIndexs ;

@end
