//
//  ModelBusinessInfoSaved.h
//  JLPay
//
//  Created by jielian on 16/3/8.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelBusinessInfoSaved : NSObject

#pragma mask : WRITE FUNC

// -- 保存
+ (void) savingBusinessInfoWithRateType:(NSString*)rateType
                           provinceName:(NSString*)provinceName
                           provinceCode:(NSString*)provinceCode
                               cityName:(NSString*)cityName
                               cityCode:(NSString*)cityCode
                           businessName:(NSString*)businessName
                           businessCode:(NSString*)businessCode
                           terminalCode:(NSString*)terminalCode;
// -- 清空
+ (void) clearSaved;


#pragma mask : READ FUNC

// -- 是否保存了商户信息
+ (BOOL) beenSaved;

// -- 所有的索引类型
+ (NSArray*) allRateTypes;

// -- 已选择的费率
+ (NSString*) rateTypeSelected;

// -- 费率值:指定费率类型
+ (NSString*) rateValueOnRateType:(NSString*)rateType;

// -- 省名
+ (NSString*) provinceName;
// -- 省代码
+ (NSString*) provinceCode;
// -- 城市名
+ (NSString*) cityName;
// -- 城市代码
+ (NSString*) cityCode;
// -- 商户名
+ (NSString*) businessName;
// -- 商户代码
+ (NSString*) businessCode;
// -- 终端号
+ (NSString*) terminalCode;

@end
