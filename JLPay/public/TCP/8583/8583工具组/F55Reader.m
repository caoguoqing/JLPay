//
//  F55Reader.m
//  JLPay
//
//  Created by jielian on 16/8/5.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "F55Reader.h"
#import "PublicInformation.h"
#import "ISOHelper.h"

@implementation F55Reader

+ (NSArray *)subFieldsReadingByOriginF55:(NSString *)f55 {
    NSMutableArray* subFields = [NSMutableArray array];
    
    NSString* name1;
    NSString* name2;
    NSString* len;
    NSString* value;
    
    NSInteger step = 0;
    while (step < f55.length) {
        name1 = nil; name2 = nil; len = nil; value = nil;
        // name
        name1 = [f55 substringWithRange:NSMakeRange(step, 2)];
        step += 2;
        if ([name1 isEqualToString:@"9F"] || [name1 isEqualToString:@"5F"]) {
            name2 = [f55 substringWithRange:NSMakeRange(step, 2)];
            step += 2;
        }
        // len
        len = [f55 substringWithRange:NSMakeRange(step, 2)];
        step += 2;
        // value
        value = [f55 substringWithRange:NSMakeRange(step, [ISOHelper lenOfTwoBytesHexString:len] * 2)];
        step += [ISOHelper lenOfTwoBytesHexString:len] * 2;
        [subFields addObject:@{F55SubFieldKeyName:((name2)?([name1 stringByAppendingString:name2]):(name1)),
                               F55SubFieldKeyLen:len,
                               F55SubFieldKeyValue:value}];
    }
    
    
    return subFields;
}

@end
