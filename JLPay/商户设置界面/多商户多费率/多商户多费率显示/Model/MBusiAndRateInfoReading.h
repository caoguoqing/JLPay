//
//  MBusiAndRateInfoReading.h
//  JLPay
//
//  Created by jielian on 16/8/25.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* MB_R_Type_moreBusinesses = @"商户设置";
static NSString* MB_R_Type_moreRates = @"费率设置";



@interface MBusiAndRateInfoReading : NSObject

/* 数据类型: 多商户+多费率组 */
@property (nonatomic, strong) NSArray* types;

/* 已选择的类型: 多商户 or 多费率 */
@property (nonatomic, copy) NSString* typeSelected;


/* 标志: 是否保存(多商户 or 多费率 任意一个) */
@property (nonatomic, assign) BOOL saved;



/* 以下是保存的信息(多商户or多费率有区别) */
@property (nonatomic, copy) NSString* businessNameSaved; /* typeSelected == 多商户时 */
@property (nonatomic, copy) NSString* businessCodeSaved; /* typeSelected == 多商户时 */
@property (nonatomic, copy) NSString* terminalCodeSvaed; /* typeSelected == 多商户时 */

@property (nonatomic, copy) NSString* rateNameSaved;
@property (nonatomic, copy) NSString* rateCodeSaved;

@property (nonatomic, copy) NSString* cityNameSaved;
@property (nonatomic, copy) NSString* cityCodeSaved;

@property (nonatomic, copy) NSString* provinceNameSaved;
@property (nonatomic, copy) NSString* provinceCodeSaved;


@end
