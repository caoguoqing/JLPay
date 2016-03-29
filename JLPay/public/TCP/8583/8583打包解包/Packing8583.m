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
#import "EncodeString.h"

#import "ModelSettlementInformation.h"
#import "ModelBusinessInfoSaved.h"
#import "ModelRateInfoSaved.h"

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

#pragma mask : 准备好了数据;准备打包;(会将所有域数据格式化)
- (void) preparePacking {
    [self resetFormatValueOfFieldsDictionary];
}


#pragma mask : 打包结果串获取
-(NSString*) stringPackingWithType:(NSString*)type {
    exchangeType = type;
    return [self stringPacking];
}

#pragma mask : MAC加密源串
- (NSString*) macSourcePackintByType:(NSString*)type {
    exchangeType = type;
    return [self macSourcePacking];
}


#pragma mask : 清空数据
-(void) cleanAllFields {
    [self.dictionaryFieldNamesAndValues removeAllObjects];
    self.dictionaryFieldNamesAndValues = nil;
}




// -- F60
+ (NSString*) makeF60OnTrantype:(NSString*)transType {
    NSMutableString* F60 = [[NSMutableString alloc] init];
    // 60.1 N2 交易类型
    [F60 appendString:[self f60_1typeWithTransType:transType]];
    // 60.2 N6 批次号
    [F60 appendString:[self f60_2BatchNo]];
    // 60.3 N3 网络管理信息码
    [F60 appendString:[self f60_3EncodeCodeWithTransType:transType]];
    // 60.4 N1 手机: T+1:1, T+0:2
    [F60 appendString:[self f60_4feeTypeWithTransType:transType]];
    // 60.5 N1 费率: 指定费率、指定商户
    [F60 appendString:[self f60_5feeWithTransType:transType]];

    return F60;
}

#pragma mask : 生成F63
+ (NSString*) makeF63OnTranType:(NSString*)tranType {
    NSMutableString* f63 = [NSMutableString string];
    [f63 appendString:[self f63_1UploadChannel]];
    [f63 appendString:[self f63_2RateType]];
    [f63 appendString:[self f63_3SettlementType]];
    [f63 appendString:[self f63_4AreaCode]];
    [f63 appendString:[self f63_5ChannelBusiness]];
    [f63 appendString:[self f63_6ChannelTerminal]];
    [f63 appendString:[self f63_7ChoosedBusiness]];
    [f63 appendString:[self f63_8ChoosedTerminal]];
    NSLog(@"打包的63域[%@]",f63);
    return [EncodeString encodeASC:f63];
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
// 60.1 N2 交易类型
+ (NSString*) f60_1typeWithTransType:(NSString*)transType {
    NSString* f60_1type = @"00";
    if ([transType isEqualToString:TranType_Consume]) {
        f60_1type = @"22";
    } else if ([transType isEqualToString:TranType_ConsumeRepeal]) {
        f60_1type = @"23";
    } else if ([transType isEqualToString:TranType_DownMainKey]) {
        f60_1type = @"99";
    } else if ([transType isEqualToString:TranType_DownWorkKey]) {
        f60_1type = @"00";
    } else if ([transType isEqualToString:TranType_YuE]) {
        f60_1type = @"01";
    }
    return f60_1type;
}
// 60.2 N6 批次号
+ (NSString*) f60_2BatchNo {
    return [PublicInformation returnSignSort];
}
// 60.3 N3 网络管理信息码
+ (NSString*) f60_3EncodeCodeWithTransType:(NSString*)transType {
    NSString* f60_3 = nil;
    if ([transType isEqualToString:TranType_DownMainKey] ||
        [transType isEqualToString:TranType_DownWorkKey])
    {
        f60_3 = @"003";
    }
    else if ([transType isEqualToString:TranType_BatchUpload]) {
        f60_3 = @"201";
    }
    else {
        f60_3 = @"000";
    }
    return f60_3;
}
// 60.4 N1 手机: T+1:1, T+0:2
+ (NSString*) f60_4feeTypeWithTransType:(NSString*)transType {
    if ([transType isEqualToString:TranType_Consume]) {
        if ([[ModelSettlementInformation sharedInstance] curSettlementType] == SETTLEMENTTYPE_T_0) {
            return @"2";
        } else {
            return @"1";
        }
    }
    else {
        return @"1";
    }
}
// 60.5 N1(+15+8) 费率:
+ (NSString*) f60_5feeWithTransType:(NSString*)transType {
    NSMutableString* f60_5Fee = [[NSMutableString alloc] init];
    
    if (![transType isEqualToString:TranType_Consume]) {
        [f60_5Fee appendString:@"0"];
    }
    else {
        // T+0
        if ([[ModelSettlementInformation sharedInstance] curSettlementType] == SETTLEMENTTYPE_T_0) {
            [f60_5Fee appendString:@"0"];
        }
        // 非 T+0
        else {
            // 多商户
            if ([ModelBusinessInfoSaved beenSaved]) {
                [f60_5Fee appendString:@"9"];
                [f60_5Fee appendString:[ModelBusinessInfoSaved businessCode]];
                [f60_5Fee appendString:[ModelBusinessInfoSaved terminalCode]];
            }
            // 多费率
            else if ([ModelRateInfoSaved beenSaved]) {
                [f60_5Fee appendString:[[ModelRateInfoSaved rateValueOnRateType:[ModelRateInfoSaved rateTypeSelected]] substringWithRange:NSMakeRange(1, 1)]];
                [f60_5Fee appendString:[ModelRateInfoSaved cityCode]];
            }
            // 其他
            else {
                [f60_5Fee appendString:@"0"];
            }
        }
    }
    return f60_5Fee;
}

// 63.1 上送渠道
+ (NSString*) f63_1UploadChannel {
    return @"1"; // 手机端统一送1
}
// 63.2 费率类型
+ (NSString*) f63_2RateType {
    // 选择了非T+1的结算方式，要屏蔽费率
    if ([ModelSettlementInformation sharedInstance].curSettlementType == SETTLEMENTTYPE_T_1) {
        if ([ModelRateInfoSaved beenSaved]) {
            return [[ModelRateInfoSaved rateValueOnRateType:[ModelRateInfoSaved rateTypeSelected]] substringWithRange:NSMakeRange(1, 1)];
        }
        else if ([ModelBusinessInfoSaved beenSaved]) {
            return @"9";
        }
        else {
            return @"0";
        }
    } else {
        return @"0";
    }
}
// 63.3 结算方式
+ (NSString*) f63_3SettlementType {
    NSString* settlementType = nil;
    switch ([[ModelSettlementInformation sharedInstance] curSettlementType]) {
        case SETTLEMENTTYPE_T_1:
            settlementType = @"00";
            break;
        case SETTLEMENTTYPE_T_0:
            settlementType = @"20";
            break;
        case SETTLEMENTTYPE_T_6:
            settlementType = @"26";
            break;
        case SETTLEMENTTYPE_T_15:
            settlementType = @"27";
            break;
        case SETTLEMENTTYPE_T_30:
            settlementType = @"28";
            break;
        default:
            settlementType = @"00";
            break;
    }
    return settlementType;
}
// 63.4 地区码
+ (NSString*) f63_4AreaCode {
    if ([ModelSettlementInformation sharedInstance].curSettlementType == SETTLEMENTTYPE_T_1 && [ModelRateInfoSaved beenSaved]) {
        return [ModelRateInfoSaved cityCode];
    } else {
        return @"0000";
    }
}
// 63.5 商户号
+ (NSString*) f63_5ChannelBusiness {
    return @"000000000000000";
}
// 63.6 终端号
+ (NSString*) f63_6ChannelTerminal {
    return @"00000000";
}
// 63.7 固定商户号
+ (NSString*) f63_7ChoosedBusiness {
    if ([ModelSettlementInformation sharedInstance].curSettlementType == SETTLEMENTTYPE_T_1 && [ModelBusinessInfoSaved beenSaved]) {
        return [ModelBusinessInfoSaved businessCode];
    } else {
        return @"000000000000000";
    }
}
// 63.8 固定终端号
+ (NSString*) f63_8ChoosedTerminal {
    if ([ModelSettlementInformation sharedInstance].curSettlementType == SETTLEMENTTYPE_T_1 && [ModelBusinessInfoSaved beenSaved]) {
        return [ModelBusinessInfoSaved terminalCode];
    } else {
        return @"00000000";
    }
}




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
    JLPrint(@"组完包后的交易报文串:[%@]",retString);
    return retString;
}
// 打MAC源串
- (NSString*) macSourcePacking {
    NSMutableString* string = [[NSMutableString alloc] init];
    [string appendString:exchangeType];
    [string appendString:[self bitMapHexString]];
    [string appendString:[self allDataString]];
    [string deleteCharactersInRange:NSMakeRange(string.length - 16, 16)];
    JLPrint(@"mac原始串:[%@]",string);
    return string;
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
    JLPrint(@"打包所有域:{%@}",self.dictionaryFieldNamesAndValues);
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
- (NSString *)MAINKEY {
    return @"9F0605DF000000049F220101DF9981804ff32b878be48f71335aa4a3f3c54bcfc574020b9bc8d28692ff54523db6e57f3a865c4460963d59a3f6fc5c82d366a2cb95655e92224e204afd1b7d22cd2fb012013208970cbb24d22a9072e734acc13afe128191cfaf97e0969bbf2f1658b092398f8f0446421daca0862e93d9ad174e85e2a68eac8ec9897328ca5b5fa4e6";
}
@end
