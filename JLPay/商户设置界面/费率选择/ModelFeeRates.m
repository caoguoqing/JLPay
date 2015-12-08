//
//  ModelFeeRates.m
//  JLPay
//
//  Created by jielian on 15/12/8.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ModelFeeRates.h"

static NSString* const kFeeRateNameSaved = @"kFeeRateNameSaved__"; // 键名: 保存
//static NSString* const vFee


//@interface ModelFeeRates()
//
//@property (nonatomic, strong) NSArray* keysOfFeeRates; // 键数组
//@property (nonatomic, strong) NSDictionary* keyAndValuesOfFeeRates; // 键值对字典
//@property (nonatomic, strong) NSString* valueOfFeeRateSaved; // 保存的键值
//
//@end


//static ModelFeeRates* modelFeeRates = nil;

@implementation ModelFeeRates

//+ (instancetype) getInstance {
//    @synchronized(self) {
//        modelFeeRates = [[ModelFeeRates alloc] init];
//    }
//    return modelFeeRates;
//}
//
//
//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        self.valueOfFeeRateSaved = nil;
//    }
//    return self;
//}


#pragma mask --- PUBLIC INTERFACE
/* 获取键名组 */
+ (NSArray*) arrayOfFeeRates {
    return @[kFeeNameNormal,
             kFeeNameGeneral,
             kFeeNameWholesale,
             kFeeNameFoodservice];
}

/* 获取费率值: 指定键名 */
+ (NSString*) valueOfFeeRateName:(NSString*)feeRateName {
    return [[self dictionaryOfFeeRateNamesAndValues] objectForKey:feeRateName];
}

/* 保存费率值: 指定键名 */
+ (void) savingFeeRateName:(NSString*)feeRateName {
    if (!feeRateName) {
        return;
    }
    if (![self valueOfFeeRateName:feeRateName]) {
        return;
    }
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:feeRateName forKey:kFeeRateNameSaved];
//    [userDefault setObject:[self valueOfFeeRateName:feeRateName] forKey:kFeeRateNameSaved];

    [userDefault synchronize];
}

/* 清空保存 */
+ (void) cleanSavingFeeRate {
    if ([self isSavedFeeRate]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFeeRateNameSaved];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


/* 是否保存了费率 */
+ (BOOL) isSavedFeeRate {
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:kFeeRateNameSaved]) {
        return YES;
    } else {
        return NO;
    }
}

/* 获取保存的费率键名 */
+ (NSString*) feeRateNameSaved {
    NSString* feeRateName = nil;
    if ([self isSavedFeeRate]) {
        feeRateName = [[NSUserDefaults standardUserDefaults] objectForKey:kFeeRateNameSaved];
    }
    return feeRateName;
}

#pragma mask ---- PRIVATE INTERFACE
/* 创建费率键值对字典 */
+ (NSDictionary*) dictionaryOfFeeRateNamesAndValues {
    return @{kFeeNameNormal:@"0",
             kFeeNameGeneral:@"1",
             kFeeNameWholesale:@"2",
             kFeeNameFoodservice:@"3",};
}


@end
