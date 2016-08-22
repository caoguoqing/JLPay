//
//  ISOHelper.h
//  Objective-ISO8583
//
//  Created by Jorge Tapia on 8/29/13.
//  Copyright (c) 2013 Mindshake Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISOHelper : NSObject

+ (NSArray *)stringToArray:(NSString *)string;
+ (NSString *)arrayToString:(NSArray *)array;
+ (NSString *)hexToBinaryAsString:(NSString *)hexString;
+ (NSString *)binaryToHexAsString:(NSString *)binaryString;
+ (NSString *)fillStringWithZeroes:(NSString *)string fieldLength:(NSString *)length;
+ (NSString *)fillStringWithBlankSpaces:(NSString *)string fieldLength:(NSString *)length;
+ (NSString *)limitStringWithQuotes:(NSString *)string;
+ (NSString *)trimString:(NSString *)string;

/* 16进制长度转为int: A0 -> (10 * 16 + 0 = 160); */
+ (int) lenOfTwoBytesHexString:(NSString*)hexString;

/* 十进制数字字符串->16进制字符串:  */
//+ (NSString*) hexStringWithNumberString:(NSString*)numberString;


@end
