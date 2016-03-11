//
//  VMRateTypes.h
//  JLPay
//
//  Created by jielian on 16/3/10.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    VMRateTypeRate,
    VMRateTypeBusinessRate
}VMRateType;

@interface VMRateTypes : NSObject

- (instancetype) initWithRateType:(VMRateType)rateType;


@property (nonatomic, strong) NSString* rateTypeSelected;
@property (nonatomic, strong) NSString* rateValueSelected;

@end
