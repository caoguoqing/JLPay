//
//  MTransMoneyCache.h
//  JLPay
//
//  Created by jielian on 16/10/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MTransMoneyCache : NSObject

+ (instancetype) sharedMoney;


/* 最大金额限制 */
@property (nonatomic, assign) CGFloat maxMoneyLimit;

/* 当前金额: 单位元 */
@property (nonatomic, assign) CGFloat curMoneyUniteYuan;

/* 当前金额: 单位分 */
@property (nonatomic, assign) NSInteger curMoneyUniteMinute;

/* 追加尾数: (0-9) */
- (void) appendLastBitNumber:(NSInteger)bitNumber;

/* 单位去尾 */
- (void) removeLastBitNumber;

/* 重置为零 */
- (void) resetMoneyToZero;

@end
