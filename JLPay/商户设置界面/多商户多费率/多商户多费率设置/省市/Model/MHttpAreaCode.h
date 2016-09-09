//
//  MHttpAreaCode.h
//  JLPay
//
//  Created by jielian on 16/8/30.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHttpAreaCode : NSObject

/* NSDictionary<key: @"name", @"code"> in NSArray */

+ (void) getAllProvincesOnFinished:(void (^) (NSArray* allProvinces))finishedBlock
                           onError:(void (^) (NSError* error))errorBlock;

+ (void) getAllCitiesWithProvinceCode:(NSString*)provinceCode
                           onFinished:(void (^) (NSArray* allCities))finishedBlock
                              onError:(void (^) (NSError* error))errorBlock;

@end
