//
//  ViewModelOtherPayDetails.h
//  JLPay
//
//  Created by jielian on 15/12/18.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPInstance.h"

@class ViewModelOtherPayDetails;
@protocol ViewModelOtherPayDetailsDelegate <NSObject>

- (void) didRequestingSuccessful;
- (void) didRequestingFailWithCode:(HTTPErrorCode)errorCode andMessage:(NSString*)message;

@end

@interface ViewModelOtherPayDetails : NSObject


/* 申请明细: 指定类型 */
- (void) requestDetailsWithDelegate:(id<ViewModelOtherPayDetailsDelegate>)delegate
                          beginTime:(NSString*)beginTime
                            endTime:(NSString*)endTime;
/* 终止请求 */
- (void) terminateRequesting;

/* 清空数据 */
- (void) clearDetails;




#pragma mask ---- selector
/* 准备好获取数据源: 有过滤器的过滤出条件值 */
- (void) prepareSelector;

/* 总笔数 */
- (NSInteger) totalCountOfTrans;
/* 消费笔数 */
- (NSInteger) countOfNormalTrans;
/* 撤销笔数 */
- (NSInteger) countofCancelTrans;
/* 总金额: int */
- (NSString*) totalAmountOfTrans;

/* ----- 原始值 ----- */

/* 交易详情节点: 指定序号 */
- (NSDictionary*) nodeDetailAtIndex:(NSInteger)index;

/* 金额: int 指定序号 */
- (NSString*) moneyAtIndex:(NSInteger)index;

/* 交易类型: 指定序号 */
- (NSString*) transTypeAtIndex:(NSInteger)index;



/* ----- 格式化值 ----- */
/* 交易时间: 指定序号 hh:mm:ss */
- (NSString*) formatTimeAtIndex:(NSInteger)index;
/* 交易日期: 指定序号 YYYY/MM/DD */
- (NSString*) formatDateAtIndex:(NSInteger)index;

/* 显示字段名数组: 交易详情 */
+ (NSArray*) titlesNeedDisplayedForNode:(NSDictionary*)detailNode;
/* 显示字段名对应的值 */
+ (NSString*) valueForTitleNeedDisplayed:(NSString*)title ofNode:(NSDictionary*)detailNode;


@end
