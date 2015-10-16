//
//  HeaderString.h
//  PosSwipeCard
//
//  Created by work on 14-7-29.
//  Copyright (c) 2014年 ggwl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeaderString : NSObject

+(NSString *)returnBitmap:(NSArray *)arr;

+(NSString *)receiveArr:(NSArray *)arr  Tpdu:(NSString *)tpdu Header:(NSString *)header ExchangeType:(NSString *)exchangetype DataArr:(NSArray *)dataarr;

+(NSString *)IC_receiveArr:(NSArray *)arr  Tpdu:(NSString *)tpdu Header:(NSString *)header ExchangeType:(NSString *)exchangetype DataArr:(NSArray *)dataarr;


/*
 * 8583打包函数:
 *  1.域值打包在字典中传入
 *  2.根据传入的map数组到字典中取对应的 value
 */
+(NSString*) stringPacking8583WithBitmapArray:(NSArray*)mapArray
                                         tpdu:(NSString*)tpdu
                                       header:(NSString*)header
                                 ExchangeType:(NSString*)exchangeType
                               dataDictionary:(NSDictionary*)dict;


@end
