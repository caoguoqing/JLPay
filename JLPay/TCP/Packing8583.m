//
//  Packing8583.m
//  JLPay
//
//  Created by jielian on 15/9/16.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "Packing8583.h"
#import "ISOHelper.h"
#import "PublicInformation.h"
#import "ISOFieldFormation.h"

@interface Packing8583() {
    NSString* tpdu;
    NSString* header;
    NSString* exchangeType;
}

@property (nonatomic, strong) NSMutableDictionary* dictionaryFieldNamesAndValues;

@end

@implementation Packing8583
@synthesize dictionaryFieldNamesAndValues = _dictionaryFieldNamesAndValues;


#pragma mask : 公共入口
+ (Packing8583 *)sharedInstance {
    static Packing8583* sharedPacking8583Instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedPacking8583Instance = [[self alloc] init];
    });
    return sharedPacking8583Instance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        tpdu = @"6000060000";
        header = @"600100310000";
    }
    return self;
}



#pragma mask : 域值设置:需要打包的
- (void) setFieldAtIndex:(int)index withValue:(NSString*)value {
    [self.dictionaryFieldNamesAndValues setValue:value forKey:[NSString stringWithFormat:@"%d",index]];
}


#pragma mask : 打包结果串获取
-(NSString*) stringPackingWithType:(NSString*)type {
    exchangeType = type;
    // 根据plist配置格式化所有的域值
    [self resetFormatValueOfFieldsDictionary];
    // 组包
    NSString* stringPackage = [self stringPacking];
    // 清空字典数据
    [self cleanAllFields];
    return stringPackage;
}

#pragma mask : 清空数据
-(void) cleanAllFields {
    [self.dictionaryFieldNamesAndValues removeAllObjects];
    self.dictionaryFieldNamesAndValues = nil;
}



#pragma mask -------------- PRIVATE INTERFACE

// 执行排序
- (NSArray*) arraySortBySourceArray:(NSArray*)array {
    if (array.count < 2) {
        return array;
    }
    NSArray* sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    return sortedArray;
}

// 打包
- (NSString*) stringPacking {
    NSMutableString* string = [[NSMutableString alloc] init];
    [string appendString:tpdu];
    [string appendString:header];
    [string appendString:exchangeType];
    [string appendString:[self bitMapHexString]];
    [string appendString:[self allDataString]];
    NSString* lengthString = [PublicInformation ToBHex:(int)string.length/2];
    NSString* retString = [NSString stringWithFormat:@"%@%@", lengthString, string];
    return retString;
}

// 生成MAP位图串:16进制
- (NSString*) bitMapHexString {
    // 生成二进制字符串
    NSMutableString* binaryString = [NSMutableString stringWithCapacity:64];
    for (int i = 0; i < 64; i++) {
        [binaryString appendString:@"0"];
    }
    // 置换所有域的bit位值
    for (NSString* abit in self.dictionaryFieldNamesAndValues.allKeys) {
        [binaryString replaceCharactersInRange:NSMakeRange(abit.intValue - 1, 1) withString:@"1"];
    }
    // 二进制转HEX
    return [ISOHelper binaryToHexAsString:binaryString];
}

// 取数据字典中所有值,打包成串
- (NSString*) allDataString {
    NSMutableString* dataString = [[NSMutableString alloc] init];
    // 排序位图数组
    NSArray* mapArray = [self arraySortBySourceArray:self.dictionaryFieldNamesAndValues.allKeys];
    // 按排序好的顺序组字符串
    for (NSString* fieldKey in mapArray) {
        [dataString appendString:[self.dictionaryFieldNamesAndValues valueForKey:fieldKey]];
    }
    return dataString;
}

// 重新整理所有域值的格式:根据plist
- (void) resetFormatValueOfFieldsDictionary {
    for (NSString* key in self.dictionaryFieldNamesAndValues.allKeys) {
        NSString* value = [self.dictionaryFieldNamesAndValues valueForKey:key];
        NSString* formationValue = [[ISOFieldFormation sharedInstance] formatStringWithSource:value atIndex:key.intValue];
        if (![formationValue isEqualToString:value]) {
            [self.dictionaryFieldNamesAndValues setValue:formationValue forKey:key];
        }
    }
}


#pragma mask -------------- getter & setter
- (NSMutableDictionary *)dictionaryFieldNamesAndValues {
    if (_dictionaryFieldNamesAndValues == nil) {
        _dictionaryFieldNamesAndValues = [[NSMutableDictionary alloc] init];
    }
    return _dictionaryFieldNamesAndValues;
}
@end
