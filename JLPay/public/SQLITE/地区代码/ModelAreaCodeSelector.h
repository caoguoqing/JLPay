//
//  ModelAreaCodeSelector.h
//  JLPay
//
//  Created by jielian on 15/12/23.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString* const kFieldNameOwner =    @"OWNER";
static NSString* const kFieldNameKey =      @"KEY";
static NSString* const kFieldNameValue =    @"VALUE";
static NSString* const kFieldNameDescr =    @"DESCR";
static NSString* const kFieldNameType =     @"TYPE";
static NSString* const kFieldNameReserve =  @"RESERVE";




@interface ModelAreaCodeSelector : NSObject


/* 查询所有省信息 */
+ (NSArray*) allProvincesSelected;
/* 查询所有市信息: 指定省 */
+ (NSArray*) allCitiesSelectedAtProvinceCode:(NSString*)provinceCode;
/* 查询所有县/区信息: 指定市 */
+ (NSArray*) allAreasSelectedAtCityCode:(NSString*)cityCode;

/* 查询指定省信息: 指定key */
+ (NSDictionary*) provinceSelectedAtProvinceCode:(NSString*)provinceCode;
/* 查询指定市信息: 指定key */
+ (NSDictionary*) citySelectedAtCityCode:(NSString*)cityCode;
/* 查询指定县/区信息: 指定key */
+ (NSDictionary*) areaSelectedAtAreaCode:(NSString*)areaCode;

@end
