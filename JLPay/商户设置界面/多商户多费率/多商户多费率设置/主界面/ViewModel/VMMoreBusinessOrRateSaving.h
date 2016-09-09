//
//  VMMoreBusinessOrRateSaving.h
//  JLPay
//
//  Created by jielian on 16/8/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBusiAndRateInfoReading.h"


@interface VMMoreBusinessOrRateSaving : NSObject

@property (nonatomic, strong) MBusiAndRateInfoReading* lastBusiOrRateInfo;

@property (nonatomic, assign) BOOL saved;


- (void) saving;

- (NSString*) rateCodeOnType:(NSString*)rateType;
@end
