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
#import "Define_Header.h"

@interface Packing8583() {
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
        self.tpdu = @"6000060000";
        self.header = @"600100310000";
    }
    return self;
}



#pragma mask : 域值设置:需要打包的
- (void) setFieldAtIndex:(int)index withValue:(NSString*)value {
    if (value == nil || value.length == 0) {
        return;
    }
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




// -- F60
+ (NSString*) makeF60OnTrantype:(NSString*)tranType {
    NSMutableString* F60 = [[NSMutableString alloc] init];
    // 60.1 N2 交易类型
    if ([tranType isEqualToString:TranType_Consume]) {
        [F60 appendString:@"22"];
    } else if ([tranType isEqualToString:TranType_ConsumeRepeal]) {
        [F60 appendString:@"23"];
    } else if ([tranType isEqualToString:TranType_DownMainKey]) {
        [F60 appendString:@"99"];
    } else if ([tranType isEqualToString:TranType_DownWorkKey]) {
        [F60 appendString:@"00"];
    } else if ([tranType isEqualToString:TranType_YuE]) {
        [F60 appendString:@"01"];
    } else {
        [F60 appendString:@"00"];
    }
    // 60.2 N6 批次号
    [F60 appendString:[PublicInformation returnSignSort]];
    // 60.3 N3 操作类型
    [F60 appendString:@"003"];
    // 60.4 N1 手机统一送1
    [F60 appendString:@"1"];
    // 60.5 N1 费率:
    BOOL hasJiGou = [self isSavedJiGouInfo];
    if (hasJiGou) {
        [F60 appendString:@"9"];
    } else {
        [F60 appendString:@"0"];
    }
    // 60.6 N15 商户号:
    if (hasJiGou && [tranType isEqualToString:TranType_Consume]) {
        [F60 appendString:[self businessNumInJiGou]];
    }
    // 60.7 N8 终端号:
    if (hasJiGou && [tranType isEqualToString:TranType_Consume]) {
        [F60 appendString:[self terminalNumInJiGou]];
    }

    
    return F60;
}
+ (NSString*) makeF60ByLast60:(NSString*)last60 {
    // 只需要修改 60.3 改为 203 // 0019 22 000000 000 500000000
    NSMutableString* new60 = [[NSMutableString alloc] init];
    [new60 appendString:[last60 substringToIndex:2 + 6]];
    [new60 appendString:@"203"];
    [new60 appendString:[last60 substringFromIndex:2+6+3]];
    return new60;
}



#pragma mask -------------- PRIVATE INTERFACE

// 执行排序
- (NSArray*) arraySortBySourceArray:(NSArray*)array {
    if (array.count < 2) {
        return array;
    }
    NSArray* sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[NSNumber numberWithInteger:[obj1 intValue]] compare:[NSNumber numberWithInteger:[obj2 intValue]]];
    }];
    return sortedArray;
}

// 打包
- (NSString*) stringPacking {
    NSMutableString* string = [[NSMutableString alloc] init];
    [string appendString:self.tpdu];
    [string appendString:self.header];
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
    NSLog(@"交易报文所有域:{%@}",self.dictionaryFieldNamesAndValues);
    for (NSString* key in self.dictionaryFieldNamesAndValues.allKeys) {
        NSString* value = [self.dictionaryFieldNamesAndValues valueForKey:key];
        NSString* formationValue = [[ISOFieldFormation sharedInstance] formatStringWithSource:value atIndex:key.intValue];
        if (![formationValue isEqualToString:value]) {
            [self.dictionaryFieldNamesAndValues setValue:formationValue forKey:key];
        }
    }
}


/* 是否保存了机构商户信息 */
+ (BOOL) isSavedJiGouInfo {
    BOOL isSaved = NO;
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* jigouInfo = [userDefaults objectForKey:KeyInfoDictOfJiGou];
    if (jigouInfo) {
        isSaved = YES;
    }
    return isSaved;
}
/* 商户号提取: 从机构商户配置中 */
+ (NSString*) businessNumInJiGou {
    NSString* businessJigou = nil;
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* jigouInfo = [userDefaults objectForKey:KeyInfoDictOfJiGou];
    if (jigouInfo) {
        businessJigou = [jigouInfo valueForKey:KeyInfoDictOfJiGouBusinessNum];
    }
    return businessJigou;
}
/* 终端号提取: 从机构商户配置中 */
+ (NSString*) terminalNumInJiGou {
    NSString* terminalJigou = nil;
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* jigouInfo = [userDefaults objectForKey:KeyInfoDictOfJiGou];
    if (jigouInfo) {
        terminalJigou = [jigouInfo valueForKey:KeyInfoDictOfJiGouTerminalNum];
    }
    return terminalJigou;
}


#pragma mask -------------- getter & setter
- (NSMutableDictionary *)dictionaryFieldNamesAndValues {
    if (_dictionaryFieldNamesAndValues == nil) {
        _dictionaryFieldNamesAndValues = [[NSMutableDictionary alloc] init];
    }
    return _dictionaryFieldNamesAndValues;
}
- (NSString *)MAINKEY {
    return @"9F0605DF000000049F220101DF9981804ff32b878be48f71335aa4a3f3c54bcfc574020b9bc8d28692ff54523db6e57f3a865c4460963d59a3f6fc5c82d366a2cb95655e92224e204afd1b7d22cd2fb012013208970cbb24d22a9072e734acc13afe128191cfaf97e0969bbf2f1658b092398f8f0446421daca0862e93d9ad174e85e2a68eac8ec9897328ca5b5fa4e6";
}
@end
