//
//  TypeConvert.h
//  nccs
//
//  Created by cwm on 15/10/9.
//  Copyright (c) 2015年 bd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Convert : NSObject //bytesToHexString
+(NSData *)hexStringToBytes:(NSString*)value;
+(NSString *)hexStringToString:(NSString*)value;
+(NSString*)bytesToHexString:(NSData*)data;
+(NSString*)bytesToHexString:(NSData*)data startIndex:(int)startIndex length:(int)length;
//+(NSData*)merge:(NSString*)string1 with:(NSString*)string2;
+(NSString*)bytesToString:(NSData*)data startIndex:(int)startIndex length:(int)length;
+(NSString*)bytesToDecString:(NSData*)data startIndex:(int)startIndex length:(int)length;
+(NSData*)decStringToBytes:(NSString*)value count:(int)count;
+(long long)bytesToLld:(NSData*)data startIndex:(int)startIndex length:(int)length;
+(NSData*)lldToBytes:(long long)value count:(int)count;
+(NSData*)merge:(id)data, ...;
+(int)byteToInt:(Byte)value;
@end
