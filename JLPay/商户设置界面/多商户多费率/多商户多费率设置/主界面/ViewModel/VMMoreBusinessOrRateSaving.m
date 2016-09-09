//
//  VMMoreBusinessOrRateSaving.m
//  JLPay
//
//  Created by jielian on 16/8/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMMoreBusinessOrRateSaving.h"
#import "ModelBusinessInfoSaved.h"
#import "ModelRateInfoSaved.h"
#import <ReactiveCocoa.h>


@implementation VMMoreBusinessOrRateSaving

- (instancetype)init {
    self = [super init];
    if (self) {
        self.saved = NO;
        
        RAC(self, saved) = [[RACSignal merge:@[RACObserve(self.lastBusiOrRateInfo, rateNameSaved),
                                              RACObserve(self.lastBusiOrRateInfo, cityNameSaved),
                                              RACObserve(self.lastBusiOrRateInfo, businessNameSaved)]] map:^id(NSString* value) {
            if (value && value.length > 0) {
                return @(self.saved);
            } else {
                return @(NO);
            }
        }];
    }
    return self;
}

- (void)saving {
    if ([self.lastBusiOrRateInfo.typeSelected isEqualToString:MB_R_Type_moreBusinesses]) {
        [ModelBusinessInfoSaved savingBusinessInfoWithRateType:self.lastBusiOrRateInfo.rateNameSaved
                                                  provinceName:self.lastBusiOrRateInfo.provinceNameSaved
                                                  provinceCode:self.lastBusiOrRateInfo.provinceCodeSaved
                                                      cityName:self.lastBusiOrRateInfo.cityNameSaved
                                                      cityCode:self.lastBusiOrRateInfo.cityCodeSaved
                                                  businessName:self.lastBusiOrRateInfo.businessNameSaved
                                                  businessCode:self.lastBusiOrRateInfo.businessCodeSaved
                                                  terminalCode:self.lastBusiOrRateInfo.terminalCodeSvaed];
        [ModelRateInfoSaved clearSaved];
    }
    else if ([self.lastBusiOrRateInfo.typeSelected isEqualToString:MB_R_Type_moreRates]) {
        [ModelRateInfoSaved savingRateInfoWithRateType:self.lastBusiOrRateInfo.rateNameSaved
                                          provinceName:self.lastBusiOrRateInfo.provinceNameSaved
                                          provinceCode:self.lastBusiOrRateInfo.provinceCodeSaved
                                              cityName:self.lastBusiOrRateInfo.cityNameSaved
                                              cityCode:self.lastBusiOrRateInfo.cityCodeSaved];
        [ModelBusinessInfoSaved clearSaved];
    }
    self.saved = YES;
}

- (MBusiAndRateInfoReading *)lastBusiOrRateInfo {
    if (!_lastBusiOrRateInfo) {
        _lastBusiOrRateInfo = [[MBusiAndRateInfoReading alloc] init];
    }
    return _lastBusiOrRateInfo;
}

- (NSString *)rateCodeOnType:(NSString *)rateType {
    return [ModelBusinessInfoSaved rateValueOnRateType:rateType];
}

@end
