//
//  MSqlAreaCode.h
//  JLPay
//
//  Created by jielian on 16/8/30.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface MSqlAreaCode : NSObject

/* NSDictionary<key: @"name", @"code"> in NSArray */

+ (NSArray*) allProvinces;

+ (NSArray*) allCitiesOnProvinceCode:(NSString*)provinceCode;

@end
