//
//  TLVC_mDetailMpos.h
//  JLPay
//
//  Created by jielian on 2017/1/13.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* TLVC_TXNNUM_CONSUME = @"消费";


@interface TLVC_mDetailMpos : NSObject <NSCopying>

+ (instancetype) detailWidthNode:(NSDictionary*)node;


/* 交易结果: yes(成功), no(失败) */
@property (nonatomic, assign) BOOL respCode;
/* 交易日期: YYYYMMDD */
@property (nonatomic, copy) NSString* instDate;
/* 交易时间: hhmmss */
@property (nonatomic, copy) NSString* instTime;
/* 交易卡号 */
@property (nonatomic, copy) NSString* pan;
/* 交易金额: 单位:分 */
@property (nonatomic, copy) NSString* amtTrans;
/* 商户编号 */
@property (nonatomic, copy) NSString* cardAccpId;
/* 终端编号 */
@property (nonatomic, copy) NSString* cardAccpTermId;
/* 商户名称 */
@property (nonatomic, copy) NSString* cardAccpName;
/* 系统流水号 */
@property (nonatomic, copy) NSString* sysSeqNum;
/* 订单编号 */
@property (nonatomic, copy) NSString* retrivlRef;
/* 交易类型 */
@property (nonatomic, copy) NSString* txnNum;
/* 批次号 */
@property (nonatomic, copy) NSString* fldReserved;
/* 冲正标志: 1(已冲正), 0(未冲正) */
@property (nonatomic, assign) NSInteger revsal_flag;
/* 受理行编号 */
@property (nonatomic, copy) NSString* acqInstIdCode;
/* 撤销标志: 1(已撤销), 0(未撤销) */
@property (nonatomic, assign) NSInteger cancelFlag;


/* 结算方式:
    00: T+1;
    01: D+1(商户出手续费);
    02: D+1(代理商出手续费);
    20: T+0;
    21: D+0;
    22: D+0秒到；
    23: D+0钱包；
    26: T+6;
    27: T+15
    28: T+30
 */
@property (nonatomic, assign) NSInteger clearType;
/* 结算拒绝原因 */
@property (nonatomic, copy) NSString* refuseReason;
/* 结算金额: 单位 分 ? 元 */
@property (nonatomic, copy) NSString* settleMoney;
/* 结算标志: 0已结算; 1正在结算; 2拒绝; 3:冻结; */
@property (nonatomic, assign) NSInteger settleFlag;



@end
