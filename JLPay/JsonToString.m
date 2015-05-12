//
//  JsonToString.m
//  NewZhuanZhuan
//
//  Created by ios2 on 13-7-12.
//  Copyright (c) 2013年 ios2. All rights reserved.
//

#import "JsonToString.h"
#import "JSON.h"

@implementation JsonToString

+(NSDictionary *)getAnalysis:(NSString *)parseString{
    SBJsonParser *publicParser=[[[SBJsonParser alloc] init] autorelease];
    return [publicParser objectWithString:parseString];
}

+(NSArray *)getArrayAnalysis:(NSString *)parseString{
    SBJsonParser *publicParser=[[[SBJsonParser alloc] init] autorelease];
    return [publicParser objectWithString:parseString];
}


+(NSString *)jsonString:(NSDictionary *)theDic{
    //NSLog(@"封装=====%@",theDic);
    return [theDic JSONRepresentation];
}

+(NSString *)toJson:(NSMutableArray *)arr{
    return [arr JSONRepresentation];
}



@end
