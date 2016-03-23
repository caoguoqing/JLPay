//
//  SegRateVCTypes.m
//  JLPay
//
//  Created by jielian on 16/3/2.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "SegRateVCTypes.h"
#import "ModelUserLoginInformation.h"

static NSString* const kSegRateVCTypeRate =         @"费率设置";
static NSString* const kSegRateVCTypeBusinessRate = @"商户设置";

static NSString* const kSegVCNameRate = @"SegRateViewController";
static NSString* const kSegVCNameBusinessRate = @"SegBusiRateViewController"; 

@implementation SegRateVCTypes

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mask 3 getter 
- (NSDictionary *)segRateTypesInfo {
    if (!_segRateTypesInfo) {
        NSMutableDictionary* types = [NSMutableDictionary dictionary];
        if ([ModelUserLoginInformation allowedMoreRate]) {
            [types setObject:kSegVCNameRate forKey:kSegRateVCTypeRate];
        }
        if ([ModelUserLoginInformation allowedMoreBusiness]) {
            [types setObject:kSegVCNameBusinessRate forKey:kSegRateVCTypeBusinessRate];
        }
        _segRateTypesInfo = [NSDictionary dictionaryWithDictionary:types];
    }
    return _segRateTypesInfo;
}

@end
