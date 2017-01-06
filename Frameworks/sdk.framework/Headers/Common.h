//
//  Common.h
//  smitsdk
//
//  Created by smit on 15/7/17.
//  Copyright (c) 2015年 smit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Common : NSObject
/**
 *  Convert json string  to object
 *
 *  @param jsonString json string
 *
 *  @return object
 */
+ (id)jsonStringToObject:(NSString *)jsonString;
+(NSString*)jsonObjectToString:(id)object;
+(BOOL)isDictionary:(id)object;
+(BOOL)isArray:(id)object;
+(BOOL)isString:(id)object;
+(NSUInteger)getTimeStamp;
+(NSString*)getNow;
@end
