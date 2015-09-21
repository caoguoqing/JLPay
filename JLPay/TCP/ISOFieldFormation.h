//
//  ISOFieldFormator.h
//  JLPay
//
//  Created by jielian on 15/9/19.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISOFieldFormation : NSObject


// 公共入口
+(ISOFieldFormation*) sharedInstance;

// 组包域值
- (NSString*) formatStringWithSource:(NSString*)sourceString atIndex:(int)index;

// 拆包域值
- (NSString*) unformatStringWithFormation:(NSString*)formationString atIndex:(int)index;

@end
