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

@end
