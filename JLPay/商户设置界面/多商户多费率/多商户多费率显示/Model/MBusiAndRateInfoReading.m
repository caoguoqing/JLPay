//
//  MBusiAndRateInfoReading.m
//  JLPay
//
//  Created by jielian on 16/8/25.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MBusiAndRateInfoReading.h"
#import "MLoginSavedResource.h"
#import "ModelBusinessInfoSaved.h"
#import "ModelRateInfoSaved.h"
#import <ReactiveCocoa.h>


@implementation MBusiAndRateInfoReading

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addKVOs];
    }
    return self;
}



- (void) addKVOs {
    @weakify(self);
    [RACObserve(self, typeSelected) subscribeNext:^(NSString* type) {
        @strongify(self);
        if ([type isEqualToString:MB_R_Type_moreBusinesses]) {
            /* 商户名称 */
            self.businessNameSaved = [ModelBusinessInfoSaved businessName];
            /* 商户代码 */
            self.businessCodeSaved = [ModelBusinessInfoSaved businessCode];
            /* 终端号 */
            self.terminalCodeSvaed = [ModelBusinessInfoSaved terminalCode];
            /* 费率类型名 */
            self.rateNameSaved = [ModelBusinessInfoSaved rateTypeSelected];
            /* 费率代码 */
            self.rateCodeSaved = [ModelBusinessInfoSaved rateValueOnRateType:self.rateNameSaved];
            /* 省名 */
            self.provinceNameSaved = [ModelBusinessInfoSaved provinceName];
            /* 省代码 */
            self.provinceCodeSaved = [ModelBusinessInfoSaved provinceCode];
            /* 市名 */
            self.cityNameSaved = [ModelBusinessInfoSaved cityName];
            /* 市代码 */
            self.cityCodeSaved = [ModelBusinessInfoSaved cityCode];
        }
        else if ([type isEqualToString:MB_R_Type_moreRates]) {
            /* 商户名称 */
            self.businessNameSaved = nil;
            /* 商户代码 */
            self.businessCodeSaved = nil;
            /* 终端号 */
            self.terminalCodeSvaed = nil;
            /* 费率类型名 */
            self.rateNameSaved = [ModelRateInfoSaved rateTypeSelected];
            /* 费率代码 */
            self.rateCodeSaved = [ModelRateInfoSaved rateValueOnRateType:self.rateNameSaved];
            /* 省名 */
            self.provinceNameSaved = [ModelRateInfoSaved provinceName];
            /* 省代码 */
            self.provinceCodeSaved = [ModelRateInfoSaved provinceCode];
            /* 市名 */
            self.cityNameSaved = [ModelRateInfoSaved cityName];
            /* 市代码 */
            self.cityCodeSaved = [ModelRateInfoSaved cityCode];
        }
    }];
    
    /* 是否保存多商户 or 多费率 */
    RAC(self, saved) = [RACObserve(self, typeSelected) map:^NSNumber* (NSString* typeSelected) {
        if ([typeSelected isEqualToString:MB_R_Type_moreBusinesses] && [ModelBusinessInfoSaved beenSaved]) {
            return @(YES);
        }
        else if ([typeSelected isEqualToString:MB_R_Type_moreRates] && [ModelRateInfoSaved beenSaved]) {
            return @(YES);
        }
        else {
            return @(NO);
        }
    }];
    
    
    
    
}



# pragma mask 4 getter

- (NSArray *)types {
    if (!_types) {
        NSMutableArray* dynaTypes = [NSMutableArray array];
        if ([MLoginSavedResource sharedLoginResource].N_business_enable) {
            [dynaTypes addObject:MB_R_Type_moreBusinesses];
        }
        if ([MLoginSavedResource sharedLoginResource].N_fee_enable) {
            [dynaTypes addObject:MB_R_Type_moreRates];
        }
        _types = [NSArray arrayWithArray:dynaTypes];
    }
    return _types;
}

- (NSString *)typeSelected {
    if (!_typeSelected) {
        /* 初始化选第一个 */
        _typeSelected = [self.types objectAtIndex:0];
    }
    return _typeSelected;
}


@end
