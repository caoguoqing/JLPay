//
//  JsonToString.h
//  NewZhuanZhuan
//
//  Created by ios2 on 13-7-12.
//  Copyright (c) 2013年 ios2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonToString : NSObject{
    
}
+(NSDictionary *)getAnalysis:(NSString *)parseString;

+(NSArray *)getArrayAnalysis:(NSString *)parseString;

+(NSString *)jsonString:(NSDictionary *)theDic;

+(NSString *)toJson:(NSMutableArray *)arr;

@end
