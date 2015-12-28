//
//  ModelFeeBusinessInformation.m
//  JLPay
//
//  Created by jielian on 15/12/23.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ModelFeeBusinessInformation.h"



static NSString* const kDictNameFeeBusinessInfoSaved = @"kDictNameFeeBusinessInfoSaved";

@implementation ModelFeeBusinessInformation

/* 保存信息:  */
+ (void) savingFeeBusinessInfo:(NSDictionary*)info {
    [self savingInfo:info];
}
/* 清空保存 */
+ (void) clearFeeBusinessInfoSaved {
    [self clearInfo];
}

/* 查询: 是否保存 */
+ (BOOL) isSaved {
    if ([self infoSaved]) {
        return YES;
    } else {
        return NO;
    }
}
/* 查询: 费率名 */
+ (NSString*) feeNameSaved {
    return [[self infoSaved] objectForKey:kFeeBusinessInfoFeeSaved];
}
/* 查询: 地区代码 */
+ (NSString*) areaCodeSaved {
    return [[self infoSaved] objectForKey:kFeeBusinessInfoAreaCode];
}
/* 查询: 商户名 */
+ (NSString*) businessNameSaved {
    return [[self infoSaved] objectForKey:kFeeBusinessInfoBusinessName];
}
/* 查询: 商户号 */
+ (NSString*) businessNumSaved {
    return [[self infoSaved] objectForKey:kFeeBusinessInfoBusinessCode];
}
/* 查询: 终端号 */
+ (NSString*) terminalNumSaved {
    return [[self infoSaved] objectForKey:kFeeBusinessInfoTerminalNum];
}

/* 查询: 费率名列表 */
+ (NSArray*) feeNamesList {
    return @[@"0.38民生类", //0
             @"0.78一般类", //1
//             @"0.78批发类",   //2
             @"1.25餐饮类"]; //3
}
/* 查询: 费率码;指定费率名 */
+ (NSString*) feeTypeOfFeeName:(NSString*)feeName {
    if ([[self feeNamesList] containsObject:feeName]) {
        return [[self feeNamesAndTypes] objectForKey:feeName];
    } else {
        return nil;
    }
}


#pragma mask ---- PRIVATE INTERFACE
/* 费率名跟类型字典 */
+ (NSDictionary*) feeNamesAndTypes {
    return @{@"0.38民生类":@"0",
             @"0.78一般类":@"1",
             @"0.78批发类":@"2",
             @"1.25餐饮类":@"3",};
}

/* 保存数据 */
+ (void) savingInfo:(NSDictionary*)info {
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    if (info) {
        [userDefault setObject:info forKey:kDictNameFeeBusinessInfoSaved];
        [userDefault synchronize];
    }
}
/* 删除数据 */
+ (void) clearInfo {
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:kDictNameFeeBusinessInfoSaved]) {
        [userDefault removeObjectForKey:kDictNameFeeBusinessInfoSaved];
        [userDefault synchronize];
    }
}
/* 获取数据 */
+ (NSDictionary*) infoSaved {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDictNameFeeBusinessInfoSaved];
}


@end
