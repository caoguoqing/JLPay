//
//  ModelFeeRates.h
//  JLPay
//
//  Created by jielian on 15/12/8.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString* const kFeeNameNormal = @"正常商户"; // 0
static NSString* const kFeeNameGeneral = @"一般类商户(费率0.78%)"; // 1
static NSString* const kFeeNameWholesale = @"批发类商户(34封顶)"; // 2
static NSString* const kFeeNameFoodservice = @"餐饮类商户(费率1.25%)"; // 3

@interface ModelFeeRates : NSObject

/* 获取键名组 */
+ (NSArray*) arrayOfFeeRates;

/* 获取费率值: 指定键名 */
+ (NSString*) valueOfFeeRateName:(NSString*)feeRateName;

/* 保存费率值: 指定键名 */
+ (void) savingFeeRateName:(NSString*)feeRateName;

/* 是否保存了费率 */
+ (BOOL) isSavedFeeRate;

/* 获取保存的费率键名 */
+ (NSString*) feeRateNameSaved;

/* 清空保存 */
+ (void) cleanSavingFeeRate;

@end
