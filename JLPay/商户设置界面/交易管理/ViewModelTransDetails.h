//
//  ViewModelTransDetails.h
//  JLPay
//
//  Created by jielian on 15/11/12.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mask --- -------- 准备废弃 ---------

@class ViewModelTransDetails;

@protocol ViewModelTransDetailsDelegate <NSObject>

@required
/* 
 * 数据申请的结果回调 
 * 成功: controller就可以使用数据源了
 * 失败: controller要做错误处理
 */
- (void) viewModel:(ViewModelTransDetails*)viewModel
  didRequestResult:(BOOL)result
       withMessage:(NSString*)message;

@end


@interface ViewModelTransDetails : NSObject

/* 申请明细: 指定类型 */
- (void) requestDetailsWithPlatform:(NSString*)platform
                        andDelegate:(id<ViewModelTransDetailsDelegate>)delegate
                          beginTime:(NSString*)beginTime
                            endTime:(NSString*)endTime
                           terminal:(NSString*)terminal
                          bussiness:(NSString*)bussiness;
/* 终止请求 */
- (void) terminateRequesting;


/* 清空数据 */
- (void) clearDetails;

/* 过滤: 输入为金额或卡号后4位; 返回过滤结果*/
- (BOOL) filterDetailsByInput:(NSString*)input;

/* 总笔数 */
- (NSInteger) totalCountOfTrans;
/* 消费笔数 */
- (NSInteger) countOfNormalTrans;
/* 撤销笔数 */
- (NSInteger) countofCancelTrans;
/* 总金额 */
- (double) totalAmountOfTrans;


/* 卡号: 指定序号 */
- (NSString*) cardNumAtIndex:(NSInteger)index;

/* 金额: 指定序号 */
- (NSString*) moneyAtIndex:(NSInteger)index;

/* 交易类型: 指定序号 */
- (NSString*) transTypeAtIndex:(NSInteger)index;

/* 交易时间8位: 指定序号 */
- (NSString*) transTimeAtIndex:(NSInteger)index;

/* 交易日期8位: 指定序号 */
- (NSString*) transDateAtIndex:(NSInteger)index;

/* 交易详情节点: 指定序号 */
- (NSDictionary*) nodeDetailAtIndex:(NSInteger)index;

@end
