//
//  NSError+Custom.m
//  JLPay
//
//  Created by jielian on 16/4/12.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "NSError+Custom.h"

@implementation NSError (Custom)

// -- 自定义初始化方法
+ (instancetype) errorWithDomain:(NSString*)domain code:(NSInteger)code localizedDescription:(NSString*)localizedDescription {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:localizedDescription forKey:NSLocalizedDescriptionKey];
    NSError* error = [NSError errorWithDomain:domain code:code userInfo:userInfo];
    return error;
}


@end
