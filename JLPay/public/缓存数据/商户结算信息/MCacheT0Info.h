//
//  MCacheT0Info.h
//  JLPay
//
//  Created by jielian on 16/10/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MCacheT0Info : NSObject

+ (instancetype) cache;

- (void) reloadCacheWithBusinessCode:(NSString*)businessCode
                          onFinished:(void (^) (void))finishedBlock
                             onError:(void (^) (NSError* error))errorBlock;

/* 是否允许T+0 */
@property (nonatomic, assign) BOOL T_0Enable;

/* 日结算额 */
@property (nonatomic, assign) CGFloat amountLimit;

/* T+0额外手续费率 */
@property (nonatomic, assign) CGFloat T_0MoreRate;

/* 日剩余可刷 */
@property (nonatomic, assign) CGFloat amountAvilable;

/* T+0最小刷卡额 */
@property (nonatomic, assign) CGFloat amountMinCust;

/* 额外手续费 */
@property (nonatomic, assign) CGFloat T_0ExtraFee;

/* 待比较金额 */
@property (nonatomic, assign) CGFloat compareMoney;


@end
