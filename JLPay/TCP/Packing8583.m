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

@interface Packing8583() {
    NSString* tpdu;
    NSString* header;
    NSString* exchangeType;
}

@property (nonatomic, strong) NSMutableArray* arrayFieldNamesAndValues;

@end

@implementation Packing8583
@synthesize arrayFieldNamesAndValues = _arrayFieldNamesAndValues;


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
    NSString* keyIndex = [NSString stringWithFormat:@"%d",index];
    NSDictionary* dictHasIndex = nil;
    for (NSDictionary* dict in self.arrayFieldNamesAndValues) {
        NSString* key = [[dict allKeys] objectAtIndex:0];
        if ([key isEqualToString:keyIndex]) {
            dictHasIndex = dict;
            break;
        }
    }
    if (!dictHasIndex) {
        NSDictionary* dict = [NSDictionary dictionaryWithObject:value forKey:keyIndex];
        [self.arrayFieldNamesAndValues addObject:dict];
    } else {
        [dictHasIndex setValue:value forKey:keyIndex];
    }
}


#pragma mask : 打包结果串获取
-(NSString*) stringPackingWithType:(NSString*)type {
    // 位图添加64
//    [self.arrayFieldNamesAndValues addObject:[NSDictionary dictionaryWithObject:@"0000000000000000" forKey:@"64"]];
    // 排序位图
    NSArray* sortedArray = [self arraySortBySourceArray:self.arrayFieldNamesAndValues];
    NSLog(@"排序后的域数组:[%@]",sortedArray);
    // 然后组包
    exchangeType = type;
    NSString* stringPackage = [self stringPacking];
    return stringPackage;
}

#pragma mask : 清空数据
-(void) cleanAllFields {
    [self.arrayFieldNamesAndValues removeAllObjects];
    self.arrayFieldNamesAndValues = nil;
}



#pragma mask -------------- PRIVATE INTERFACE

// 执行排序
- (NSArray*) arraySortBySourceArray:(NSArray*)array {
    if (array.count < 2) {
        return nil;
    }
    NSArray* sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id compare1, id compare2){
        return [self compareDictionary:compare1 withAnotherDictionary:compare2];
    }];
    return sortedArray;
}
// 比较字典类型
- (NSComparisonResult) compareDictionary:(NSDictionary*)dictionary
                   withAnotherDictionary:(NSDictionary*)anotherDictionary
{
    NSString* keySource = [[dictionary allKeys] objectAtIndex:0];
    NSString* keyTarget = [[anotherDictionary allKeys] objectAtIndex:0];
    return [keySource compare:keyTarget];
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
    NSMutableArray* bitMapArray = [[NSMutableArray alloc] init];
    // 组map数组
    for (NSDictionary* dict in self.arrayFieldNamesAndValues) {
        [bitMapArray addObject:[[dict allKeys] objectAtIndex:0]];
    }
    // 生成二进制字符串
    NSMutableString* binaryString = [NSMutableString stringWithCapacity:64];
    for (int i = 0; i < 64; i++) {
        [binaryString appendString:@"0"];
    }
    for (NSString* abit in bitMapArray) {
        [binaryString replaceCharactersInRange:NSMakeRange(abit.intValue - 1, 1) withString:@"1"];
    }
    NSLog(@"位图数组:[%@]",bitMapArray);
    NSLog(@"二进制位图串:%@",binaryString);
    // 二进制转HEX
    return [ISOHelper binaryToHexAsString:binaryString];
}

// 取数据字典中所有值,打包成串
- (NSString*) allDataString {
    NSMutableString* dataString = [[NSMutableString alloc] init];
    for (NSDictionary* dict in self.arrayFieldNamesAndValues) {
        NSString* key = [[dict allKeys] objectAtIndex:0];
        [dataString appendString:[dict valueForKey:key]];
    }
    return dataString;
}

#pragma mask -------------- getter & setter
- (NSMutableArray *)arrayFieldNamesAndValues {
    if (_arrayFieldNamesAndValues == nil) {
        _arrayFieldNamesAndValues = [[NSMutableArray alloc] init];
    }
    return _arrayFieldNamesAndValues;
}
@end
