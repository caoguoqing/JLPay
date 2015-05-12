//
//  EncodeString.h
//  PosSwipeCard
//
//  Created by work on 14-6-30.
//  Copyright (c) 2014年 ggwl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncodeString : NSObject


+ (NSString *)encodeBCD:(NSString *)bcdStr;

+ (NSString *)encodeASC:(NSString *)ascStr;

+(NSData *)newBcd:(NSString *)value;

@end
