//
//  ModelRateInfoSaved.m
//  JLPay
//
//  Created by jielian on 16/3/4.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "ModelRateInfoSaved.h"


static NSString* const kMRateInfoNodeName       = @"kMRateInfoNodeName";    // 数据节点名-字典类型

static NSString* const kMRateInfoRateType       = @"rateType";              // 费率类型
static NSString* const kMRateInfoProvinceName   = @"provinceName";          // 省名
static NSString* const kMRateInfoProvinceCode   = @"provinceCode";          // 省代码
static NSString* const kMRateInfoCityName       = @"cityName";              // 市名
static NSString* const kMRateInfoCityCode       = @"cityCode";              // 市代码



@implementation ModelRateInfoSaved

#pragma mask : WRITE FUNC

// -- 保存
+ (void) savingRateInfoWithRateType:(NSString*)rateType
                       provinceName:(NSString*)provinceName
                       provinceCode:(NSString*)provinceCode
                           cityName:(NSString*)cityName
                           cityCode:(NSString*)cityCode
{
    NSMutableDictionary* rateInfoNode = [NSMutableDictionary dictionary];
    [rateInfoNode setObject:rateType forKey:kMRateInfoRateType];
    [rateInfoNode setObject:provinceName forKey:kMRateInfoProvinceName];
    [rateInfoNode setObject:provinceCode forKey:kMRateInfoProvinceCode];
    [rateInfoNode setObject:cityName forKey:kMRateInfoCityName];
    [rateInfoNode setObject:cityCode forKey:kMRateInfoCityCode];
    [self savingRateInfoNodeIntoLocalByNode:rateInfoNode];
}
// -- 清空
+ (void) clearSaved {
    [self removeRateInfoNodeFromLocal];
}


#pragma mask : READ FUNC

// -- 是否保存了费率信息
+ (BOOL) beenSaved {
    NSDictionary* rateInfo = [self rateInfoNodeSavedInLocal];
    if (rateInfo) {
        return YES;
    } else {
        return NO;
    }
}

// -- 所有的索引类型
+ (NSArray*) allRateTypes {
    return [[self rateTypesDictionary] allKeys];
}

// -- 费率值:指定费率类型
+ (NSString*) rateValueOnRateType:(NSString*)rateType {
    return [[self rateTypesDictionary] objectForKey:rateType];
}

// -- 已选择的费率
+ (NSString*) rateTypeSelected {
    return [[self rateInfoNodeSavedInLocal] objectForKey:kMRateInfoRateType];
}
// -- 省名
+ (NSString*) provinceName {
    return [[self rateInfoNodeSavedInLocal] objectForKey:kMRateInfoProvinceName];
}
// -- 省代码
+ (NSString*) provinceCode {
    return [[self rateInfoNodeSavedInLocal] objectForKey:kMRateInfoProvinceCode];
}
// -- 城市名
+ (NSString*) cityName {
    return [[self rateInfoNodeSavedInLocal] objectForKey:kMRateInfoCityName];
}
// -- 城市代码
+ (NSString*) cityCode {
    return [[self rateInfoNodeSavedInLocal] objectForKey:kMRateInfoCityCode];
}

#pragma mask 2 private interface
// -- 保存节点到本地
+ (void) savingRateInfoNodeIntoLocalByNode:(NSDictionary*)node {
    NSUserDefaults* userD = [NSUserDefaults standardUserDefaults];
    [userD setObject:node forKey:kMRateInfoNodeName];
    [userD synchronize];
}
// -- 从本地删除节点
+ (void) removeRateInfoNodeFromLocal {
    NSUserDefaults* userD = [NSUserDefaults standardUserDefaults];
    [userD removeObjectForKey:kMRateInfoNodeName];
    [userD synchronize];
}
// -- 从本地查出节点
+ (NSDictionary*) rateInfoNodeSavedInLocal {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kMRateInfoNodeName];
}

#pragma mask 3 model: 
// -- 费率组字典
+ (NSDictionary*) rateTypesDictionary {
    return @{@"0.38民生类":@"11",@"0.78一般类":@"12",/*@"0.78批发类":@"13",*/@"1.25餐饮类":@"14"};
}

@end
