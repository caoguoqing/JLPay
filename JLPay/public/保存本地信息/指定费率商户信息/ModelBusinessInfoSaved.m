//
//  ModelBusinessInfoSaved.m
//  JLPay
//
//  Created by jielian on 16/3/8.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "ModelBusinessInfoSaved.h"

static NSString* const kMBusinessInfoNodeName       = @"kMBusinessInfoNodeName";    // 数据节点名-字典类型

static NSString* const kMBusinessInfoRateType       = @"rateType";              // 费率类型
static NSString* const kMBusinessInfoProvinceName   = @"provinceName";          // 省名
static NSString* const kMBusinessInfoProvinceCode   = @"provinceCode";          // 省代码
static NSString* const kMBusinessInfoCityName       = @"cityName";              // 市名
static NSString* const kMBusinessInfoCityCode       = @"cityCode";              // 市代码
static NSString* const kMBusinessInfoBusinessName   = @"businessName";          // 商户名
static NSString* const kMBusinessInfoBusinessCode   = @"businessCode";          // 商户号
static NSString* const kMBusinessInfoTerminalCode   = @"terminalCode";          // 终端号




@implementation ModelBusinessInfoSaved

#pragma mask : WRITE FUNC

// -- 保存
+ (void) savingBusinessInfoWithRateType:(NSString*)rateType
                           provinceName:(NSString*)provinceName
                           provinceCode:(NSString*)provinceCode
                               cityName:(NSString*)cityName
                               cityCode:(NSString*)cityCode
                           businessName:(NSString*)businessName
                           businessCode:(NSString*)businessCode
                           terminalCode:(NSString*)terminalCode
{
    NSMutableDictionary* businessInfo = [NSMutableDictionary dictionary];
    [businessInfo setObject:rateType forKey:kMBusinessInfoRateType];
    [businessInfo setObject:provinceName forKey:kMBusinessInfoProvinceName];
    [businessInfo setObject:provinceCode forKey:kMBusinessInfoProvinceCode];
    [businessInfo setObject:cityName forKey:kMBusinessInfoCityName];
    [businessInfo setObject:cityCode forKey:kMBusinessInfoCityCode];
    [businessInfo setObject:businessName forKey:kMBusinessInfoBusinessName];
    [businessInfo setObject:businessCode forKey:kMBusinessInfoBusinessCode];
    [businessInfo setObject:terminalCode forKey:kMBusinessInfoTerminalCode];
    [self savingRateInfoNodeIntoLocalByNode:businessInfo];
}
// -- 清空
+ (void) clearSaved
{
    [self removeRateInfoNodeFromLocal];
}


#pragma mask : READ FUNC

// -- 是否保存了商户信息
+ (BOOL) beenSaved {
    BOOL saved = NO;
    NSDictionary* businessInfo = [self businessInfoNodeSavedInLocal];
    if (businessInfo) {
        saved = YES;
    }
    return saved;
}

// -- 所有的索引类型
+ (NSArray*) allRateTypes {
    return [[self rateTypesDictionary] allKeys];
}

// -- 已选择的费率
+ (NSString*) rateTypeSelected {
    return [[self businessInfoNodeSavedInLocal] objectForKey:kMBusinessInfoRateType];
}

// -- 费率值:指定费率类型
+ (NSString*) rateValueOnRateType:(NSString*)rateType {
    return [[self rateTypesDictionary] objectForKey:rateType];
}

// -- 省名
+ (NSString*) provinceName {
    return [[self businessInfoNodeSavedInLocal] objectForKey:kMBusinessInfoProvinceName];
}
// -- 省代码
+ (NSString*) provinceCode {
    return [[self businessInfoNodeSavedInLocal] objectForKey:kMBusinessInfoProvinceCode];
}
// -- 城市名
+ (NSString*) cityName {
    return [[self businessInfoNodeSavedInLocal] objectForKey:kMBusinessInfoCityName];
}
// -- 城市代码
+ (NSString*) cityCode {
    return [[self businessInfoNodeSavedInLocal] objectForKey:kMBusinessInfoCityCode];
}
// -- 商户名
+ (NSString*) businessName {
    return [[self businessInfoNodeSavedInLocal] objectForKey:kMBusinessInfoBusinessName];
}
// -- 商户代码
+ (NSString*) businessCode {
    return [[self businessInfoNodeSavedInLocal] objectForKey:kMBusinessInfoBusinessCode];
}
// -- 终端号
+ (NSString*) terminalCode {
    return [[self businessInfoNodeSavedInLocal] objectForKey:kMBusinessInfoTerminalCode];
}



#pragma mask 2 private interface
// -- 保存节点到本地
+ (void) savingRateInfoNodeIntoLocalByNode:(NSDictionary*)node {
    NSUserDefaults* userD = [NSUserDefaults standardUserDefaults];
    [userD setObject:node forKey:kMBusinessInfoNodeName];
    [userD synchronize];
}
// -- 从本地删除节点
+ (void) removeRateInfoNodeFromLocal {
    NSUserDefaults* userD = [NSUserDefaults standardUserDefaults];
    [userD removeObjectForKey:kMBusinessInfoNodeName];
    [userD synchronize];
}
// -- 从本地查出节点
+ (NSDictionary*) businessInfoNodeSavedInLocal {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kMBusinessInfoNodeName];
}

#pragma mask 3 model:
// -- 费率组字典
+ (NSDictionary*) rateTypesDictionary {
    return @{@"0.38民生类":@"11",@"0.78一般类":@"12",/*@"0.78批发类":@"13",*/@"1.25餐饮类":@"14"};
}



@end
