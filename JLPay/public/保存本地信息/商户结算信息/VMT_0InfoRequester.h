//
//  VMT_0InfoRequester.h
//  JLPay
//
//  Created by jielian on 16/3/21.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMT_0InfoRequester : NSObject

/* 公共入口 */
+ (instancetype) sharedInstance;


// -- 获取T+0结算信息
- (void) requestT_0InformationWithBusinessNumbser:(NSString*)businessNumber
                                       onSucBlocK:(void (^) (void))sucBlock
                                     onErrorBlock:(void (^) (NSError* error))errBlock;

/* 终止 */
- (void) requestTerminate;


// -- 是否允许T+0
- (BOOL) enableT_0;
// -- 当日限额
- (NSString*) amountLimit;
// -- 剩余可刷
- (NSString*) amountAvilable;
// -- 单笔最小可刷
- (NSString*) amountMinCust;
// -- 增加的费率
- (NSString*) T_0MoreRate;
// -- 额外手续费
- (NSString*) T_0ExtraFee;
// -- 比较金额
- (NSString*) compareMoney;


@end
