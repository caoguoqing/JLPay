//
//  ISOFieldFormator.m
//  JLPay
//
//  Created by jielian on 15/9/19.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "ISOFieldFormation.h"


@interface ISOFieldFormation()
@property (nonatomic, strong) NSDictionary* dictionaryFieldsAttri;
@end




// 配置文件名.plist
const NSString* fileNameISOFormator = @"newisoconfig";
const NSString* kFieldSpecial = @"special";
const NSString* kFieldType = @"type";
const NSString* kFieldLength = @"length";




@implementation ISOFieldFormation


// 公共入口
+(ISOFieldFormation*) sharedInstance {
    static ISOFieldFormation* ISOformation = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        ISOformation = [[self alloc] init];
    });
    return ISOformation;
}

// 组包域值
- (NSString*) formatStringWithSource:(NSString*)sourceString atIndex:(int)index {
    NSString* formationString = sourceString;
    NSString* infoKey = [NSString stringWithFormat:@"%d",index];
    NSDictionary* infoDictionary = [self.dictionaryFieldsAttri objectForKey:infoKey];
    NSString* special = [infoDictionary valueForKey:(NSString*)kFieldSpecial];

    if ([special isEqualToString:@"99"] || [special isEqualToString:@"999"]) {
        NSString* type = [infoDictionary valueForKey:(NSString*)kFieldType];
        // 加长度
        formationString = [self lengthOfSource:sourceString type:type special:special];
        // 加值
        formationString = [formationString stringByAppendingString:[self packingStrOfSource:sourceString type:type]];
    }
    
    return formationString;
}


// 拆包域值:会截掉已拆包的域
- (NSString*) unformatStringWithFormation:(NSMutableString*)formationString atIndex:(int)index {
    NSString* unformationString = nil;
    NSString* infoKey = [NSString stringWithFormat:@"%d",index];
    NSDictionary* infoDictionary = [self.dictionaryFieldsAttri objectForKey:infoKey];
    NSString* special = [infoDictionary valueForKey:(NSString*)kFieldSpecial];
    NSString* length = [infoDictionary valueForKey:(NSString*)kFieldLength];
    NSString* type  = [infoDictionary valueForKey:(NSString*)kFieldType];

    NSLog(@"拆包前:[%@]",formationString);
    int actureLen = length.intValue;
    if ([special isEqualToString:@"99"] || [special isEqualToString:@"999"]) {
        actureLen = [self lengthOfFormation:formationString special:special];
        unformationString = [self unpackingStrOfFormation:formationString type:type inLength:actureLen];
    } else {
        unformationString = [formationString substringToIndex:actureLen];
        [formationString deleteCharactersInRange:NSMakeRange(0, actureLen)];
    }
    NSLog(@"拆包后:[%@]",formationString);
    NSLog(@"拆出域[%@]:%@",infoKey,unformationString);
    return unformationString;
}

#pragma mask ------------- PRIVATE INTERFACE

// 初始化数据字典
- (instancetype)init {
    self = [super init];
    if (self) {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:(NSString*)fileNameISOFormator ofType:@"plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            self.dictionaryFieldsAttri = [NSDictionary dictionaryWithContentsOfFile:filePath];
        }
    }
    return self;
}

// 长度生成
- (NSString*) lengthOfSource:(NSString*)source type:(NSString*)type special:(NSString*)special {
    int length = (int)source.length;
    if ([type isEqualToString:@"asc"]) {
        length /= 2;
    }
    NSString* lenString = nil;
    if ([special isEqualToString:@"99"]) {
        lenString = [NSString stringWithFormat:@"%02d",length];
    } else {
        lenString = [NSString stringWithFormat:@"%04d",length];
    }
    return lenString;
}
// 长度获取
- (int) lengthOfFormation:(NSMutableString*)formation special:(NSString*)special {
    int length = 0;
    int lenLength = 0;
    if ([special isEqualToString:@"99"]) {
        lenLength = 2;
    } else {
        lenLength = 4;
    }
    length = [formation substringToIndex:lenLength].intValue;
    [formation deleteCharactersInRange:NSMakeRange(0, lenLength)];
    return length;
}


// 打包串
- (NSString*) packingStrOfSource:(NSString*)source type:(NSString*)type {
    NSString* packing = source;
    if ([type isEqualToString:@"bcd"] && source.length%2 > 0) {
        packing = [packing stringByAppendingString:@"0"];
    }
    return packing;
}
// 拆包串
- (NSString*) unpackingStrOfFormation:(NSMutableString*)formation type:(NSString*)type inLength:(int)length {
    NSString* unpacking = nil;
    int unpackingLen = length;
    if ([type isEqualToString:@"asc"]) {
        unpackingLen *= 2;
    } else {
        if (length%2 > 0) {
            unpackingLen += 1;
        }
    }
    unpacking = [formation substringToIndex:unpackingLen];
    if ([type isEqualToString:@"bcd"] && length%2 > 0) {
        unpacking = [unpacking substringToIndex:length];
    }
    [formation deleteCharactersInRange:NSMakeRange(0, unpackingLen)];
    return unpacking;
}


@end
