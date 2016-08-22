//
//  F55Reader.h
//  JLPay
//
//  Created by jielian on 16/8/5.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString* const F55SubFieldKeyName = @"__name";
static NSString* const F55SubFieldKeyLen = @"__len";
static NSString* const F55SubFieldKeyValue = @"__value";


@interface F55Reader : NSObject

+ (NSArray*) subFieldsReadingByOriginF55:(NSString*)f55 ;

@end
