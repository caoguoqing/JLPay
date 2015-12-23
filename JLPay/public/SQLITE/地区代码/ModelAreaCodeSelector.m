//
//  ModelAreaCodeSelector.m
//  JLPay
//
//  Created by jielian on 15/12/23.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ModelAreaCodeSelector.h"
#import "MySQLiteManager.h"


static NSString* const kOwnerTypeCountry = @"COUNTRY";
static NSString* const kOwnerTypeProvince = @"PROVINCE";
static NSString* const kOwnerTypeCity = @"CITY";
static NSString* const kOwnerTypeArea = @"AREA";


@implementation ModelAreaCodeSelector

/* 查询所有省信息 */
+ (NSArray*) allProvincesSelected {
    NSMutableString* selector = [[NSMutableString alloc] initWithString:[self mainSelectionBody]];
    [selector appendString:[self firstCondition:@"156" forName:kFieldNameDescr]];
    [selector appendString:[self otherCondition:kOwnerTypeProvince forName:kFieldNameOwner]];
    [selector appendString:[self terminateSelector]];
    return [[MySQLiteManager SQLiteManagerWithDBFile:DBFILENAME_AREACODE] selectedDatasWithSQLString:selector];
}
/* 查询所有市信息: 指定省 */
+ (NSArray*) allCitiesSelectedAtProvinceCode:(NSString*)provinceCode {
    NSMutableString* selector = [[NSMutableString alloc] initWithString:[self mainSelectionBody]];
    [selector appendString:[self firstCondition:provinceCode forName:kFieldNameDescr]];
    [selector appendString:[self otherCondition:kOwnerTypeCity forName:kFieldNameOwner]];
    [selector appendString:[self terminateSelector]];
    return [[MySQLiteManager SQLiteManagerWithDBFile:DBFILENAME_AREACODE] selectedDatasWithSQLString:selector];
}
/* 查询所有县/区信息: 指定市 */
+ (NSArray*) allAreasSelectedAtCityCode:(NSString*)cityCode {
    NSMutableString* selector = [[NSMutableString alloc] initWithString:[self mainSelectionBody]];
    [selector appendString:[self firstCondition:cityCode forName:kFieldNameDescr]];
    [selector appendString:[self otherCondition:kOwnerTypeArea forName:kFieldNameOwner]];
    [selector appendString:[self terminateSelector]];
    return [[MySQLiteManager SQLiteManagerWithDBFile:DBFILENAME_AREACODE] selectedDatasWithSQLString:selector];
}

/* 查询指定省信息: 指定key */
+ (NSDictionary*) provinceSelectedAtProvinceCode:(NSString*)provinceCode {
    NSMutableString* selector = [[NSMutableString alloc] initWithString:[self mainSelectionBody]];
    [selector appendString:[self firstCondition:provinceCode forName:kFieldNameKey]];
    [selector appendString:[self otherCondition:kOwnerTypeProvince forName:kFieldNameOwner]];
    [selector appendString:[self terminateSelector]];
    return [[[MySQLiteManager SQLiteManagerWithDBFile:DBFILENAME_AREACODE] selectedDatasWithSQLString:selector] firstObject];
}
/* 查询指定市信息: 指定key */
+ (NSDictionary*) citySelectedAtCityCode:(NSString*)cityCode {
    NSMutableString* selector = [[NSMutableString alloc] initWithString:[self mainSelectionBody]];
    [selector appendString:[self firstCondition:cityCode forName:kFieldNameKey]];
    [selector appendString:[self otherCondition:kOwnerTypeCity forName:kFieldNameOwner]];
    [selector appendString:[self terminateSelector]];
    return [[[MySQLiteManager SQLiteManagerWithDBFile:DBFILENAME_AREACODE] selectedDatasWithSQLString:selector] firstObject];
}
/* 查询指定县/区信息: 指定key */
+ (NSDictionary*) areaSelectedAtAreaCode:(NSString*)areaCode {
    NSMutableString* selector = [[NSMutableString alloc] initWithString:[self mainSelectionBody]];
    [selector appendString:[self firstCondition:areaCode forName:kFieldNameKey]];
    [selector appendString:[self otherCondition:kOwnerTypeArea forName:kFieldNameOwner]];
    [selector appendString:[self terminateSelector]];
    return [[[MySQLiteManager SQLiteManagerWithDBFile:DBFILENAME_AREACODE] selectedDatasWithSQLString:selector] firstObject];
}


#pragma mask ---- PRIVATE INTERFACE
+ (NSString*) mainSelectionBody {
    return @"SELECT * FROM CST_SYS_PARAM ";
}
+ (NSString*) firstCondition:(NSString*)condition forName:(NSString*)conditionName {
    return [NSString stringWithFormat:@" WHERE %@ = '%@' ",conditionName, condition];
}
+ (NSString*) otherCondition:(NSString*)condition forName:(NSString*)conditionName {
    return [NSString stringWithFormat:@" AND %@ = '%@' ",conditionName, condition];
}
+ (NSString*) terminateSelector {
    return @";";
}

@end
