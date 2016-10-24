//
//  ModelRateInfoSaved.h
//  JLPay
//
//  Created by jielian on 16/3/4.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelRateInfoSaved : NSObject



#pragma mask : WRITE FUNC

// -- 保存
+ (void) savingRateInfoWithRateType:(NSString*)rateType
                       provinceName:(NSString*)provinceName
                       provinceCode:(NSString*)provinceCode
                           cityName:(NSString*)cityName
                           cityCode:(NSString*)cityCode;
// -- 清空
+ (void) clearSaved;


#pragma mask : READ FUNC

// -- 是否保存了费率信息
+ (BOOL) beenSaved;


// -- 已选择的费率
+ (NSString*) rateTypeSelected;

// -- 省名
+ (NSString*) provinceName;
// -- 省代码
+ (NSString*) provinceCode;
// -- 城市名
+ (NSString*) cityName;
// -- 城市代码
+ (NSString*) cityCode;





// -- 费率值:指定费率类型
+ (NSString*) rateValueOnRateType:(NSString*)rateType;

// -- 所有的费率类型
+ (NSArray*) allRateTypes;

@end
