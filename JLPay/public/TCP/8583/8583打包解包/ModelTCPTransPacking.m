//
//  ModelTCPTransPacking.m
//  JLPay
//
//  Created by jielian on 16/1/25.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "ModelTCPTransPacking.h"
#import "Packing8583.h"
#import "PublicInformation.h"
#import "EncodeString.h"


static NSString* const k8583FieldValue25 = @"00";
static NSString* const k8583FieldValue26 = @"12";
static NSString* const k8583FieldValue49 = @"156";
static NSString* const k8583FieldValue53 = @"2600000000000000";
static NSString* const k8583FieldValue53_NOPIN = @"0600000000000000";



@interface ModelTCPTransPacking()
{
    NSString* transType__;
}


@end

@implementation ModelTCPTransPacking

// 按顺序执行打包
//  |
//  V
+ (instancetype) sharedModel {
    static ModelTCPTransPacking* shared = nil;
    static dispatch_once_t desp;
    dispatch_once(&desp, ^{
        shared = [[ModelTCPTransPacking alloc] init];
    });
    return shared;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
//  |
//  V  : 逐个键入域值
- (void) packingFieldsInfo:(NSDictionary*)fieldsInfo forTransType:(NSString*)transType {
    transType__ = transType;
    [self packingWithFieldsInfo:fieldsInfo];
}
//  |
//  V  : 获取MAC原始串
- (NSString*) getMacStringAfterPacking {
    return [[Packing8583 sharedInstance] macSourcePackintByType:[self msgTypeOnTransType:transType__]];
}
//  |
//  V  : 键入MAC密文串
- (void) repackingWithMacPin:(NSString*)macPin {
    [[Packing8583 sharedInstance] setFieldAtIndex:64 withValue:macPin];
}
//  |
//  V  : 获取最终打包串
- (NSString*) packageFinalyPacking {
    NSString* packing = [[Packing8583 sharedInstance] stringPackingWithType:[self msgTypeOnTransType:transType__]];
    [[Packing8583 sharedInstance] cleanAllFields];
    return packing;
}



#pragma mask 2 PRIVATE INTERFACE

- (void) packingWithFieldsInfo:(NSDictionary*)fieldsInfo {
    // 当前交易类型:
    if ([transType__ isEqualToString:TranType_Consume]) {
        [self packingConsumeFieldsInfo:fieldsInfo];
    }
    else if ([transType__ isEqualToString:TranType_BatchUpload]) {
        [self packingBatchUpFieldsInfo:fieldsInfo];
    }
    else if ([transType__ isEqualToString:TranType_DownMainKey]) {
        [self packingDownMainKFieldsInfo:fieldsInfo];
    }
    else if ([transType__ isEqualToString:TranType_DownWorkKey]) {
        [self packingDownWorkKFieldsInfo:fieldsInfo];
    }
}
- (NSString*) msgTypeOnTransType:(NSString*)transType {
    NSString* msgType = @"0200";
    if ([transType isEqualToString:TranType_Consume]) {
        msgType = @"0200";
    }
    else if ([transType isEqualToString:TranType_BatchUpload]) {
        msgType = @"0320";
    }
    else if ([transType isEqualToString:TranType_DownMainKey]) {
        msgType = @"0800";
    }
    else if ([transType isEqualToString:TranType_DownWorkKey]) {
        msgType = @"0800";
    }
    return msgType;
}

// -- 消费
- (void) packingConsumeFieldsInfo:(NSDictionary*)fieldsInfo {
    Packing8583* packHolder = [Packing8583 sharedInstance];
    [packHolder setFieldAtIndex:2 withValue:fieldsInfo[@"2"]];
    [packHolder setFieldAtIndex:3 withValue:transType__];
    [packHolder setFieldAtIndex:4 withValue:fieldsInfo[@"4"]];
    [packHolder setFieldAtIndex:11 withValue:[PublicInformation exchangeNumber]];
    [packHolder setFieldAtIndex:14 withValue:fieldsInfo[@"14"]];
    [packHolder setFieldAtIndex:22 withValue:fieldsInfo[@"22"]];
    [packHolder setFieldAtIndex:23 withValue:fieldsInfo[@"23"]];
    [packHolder setFieldAtIndex:25 withValue:k8583FieldValue25];
    [packHolder setFieldAtIndex:26 withValue:k8583FieldValue26];
    [packHolder setFieldAtIndex:35 withValue:fieldsInfo[@"35"]];
    [packHolder setFieldAtIndex:36 withValue:fieldsInfo[@"36"]];
    [packHolder setFieldAtIndex:41 withValue:[EncodeString encodeASC:[PublicInformation returnTerminal]]];
    [packHolder setFieldAtIndex:42 withValue:[EncodeString encodeASC:[PublicInformation returnBusiness]]];
    [packHolder setFieldAtIndex:49 withValue:[EncodeString encodeASC:k8583FieldValue49]];
    if ([fieldsInfo[@"22"] hasSuffix:@"10"]) {
        [packHolder setFieldAtIndex:52 withValue:fieldsInfo[@"52"]];
        [packHolder setFieldAtIndex:53 withValue:k8583FieldValue53];
    } else {
        [packHolder setFieldAtIndex:53 withValue:k8583FieldValue53_NOPIN];
    }
    [packHolder setFieldAtIndex:55 withValue:fieldsInfo[@"55"]];
    [packHolder setFieldAtIndex:60 withValue:[Packing8583 makeF60OnTrantype:transType__]];
//    [packHolder setFieldAtIndex:63 withValue:[Packing8583 makeF63OnTranType:transType__]];
    [packHolder setFieldAtIndex:64 withValue:@"0000000000000000"];
    [packHolder preparePacking];
}

// -- 批上送
- (void) packingBatchUpFieldsInfo:(NSDictionary*)responseCardInfo {
    Packing8583* packingHolder = [Packing8583 sharedInstance];
    [packingHolder setFieldAtIndex:2 withValue:[responseCardInfo valueForKey:@"2"]];
    [packingHolder setFieldAtIndex:3 withValue:[responseCardInfo valueForKey:@"3"]];
    [packingHolder setFieldAtIndex:4 withValue:[responseCardInfo valueForKey:@"4"]];
    [packingHolder setFieldAtIndex:11 withValue:[responseCardInfo valueForKey:@"11"]];
    NSString* f22 = [NSString stringWithFormat:@"%@00", [[responseCardInfo valueForKey:@"22"] substringToIndex:2]];
    [packingHolder setFieldAtIndex:22 withValue:f22];
    [packingHolder setFieldAtIndex:23 withValue:[responseCardInfo valueForKey:@"23"]];
    [packingHolder setFieldAtIndex:25 withValue:k8583FieldValue25]; //
    [packingHolder setFieldAtIndex:26 withValue:k8583FieldValue26];
    [packingHolder setFieldAtIndex:41 withValue:[responseCardInfo valueForKey:@"41"]];
    [packingHolder setFieldAtIndex:42 withValue:[responseCardInfo valueForKey:@"42"]];
    [packingHolder setFieldAtIndex:49 withValue:[EncodeString encodeASC:k8583FieldValue49]];
    [packingHolder setFieldAtIndex:55 withValue:[responseCardInfo valueForKey:@"55"]];
    [packingHolder setFieldAtIndex:60 withValue:[Packing8583 makeF60ByLast60:[responseCardInfo valueForKey:@"60"]]];
    [packingHolder preparePacking];
}

// -- 主密钥下载
- (void) packingDownMainKFieldsInfo:(NSDictionary*)fieldsInfo {
    Packing8583* packingHolder = [Packing8583 sharedInstance];

    [packingHolder setFieldAtIndex:11 withValue:[PublicInformation exchangeNumber]];
    [packingHolder setFieldAtIndex:41 withValue:[EncodeString encodeASC:fieldsInfo[@"41"]]];
    [packingHolder setFieldAtIndex:42 withValue:[EncodeString encodeASC:fieldsInfo[@"42"]]];
    [packingHolder setFieldAtIndex:60 withValue:[Packing8583 makeF60OnTrantype:TranType_DownMainKey]];
    [packingHolder setFieldAtIndex:62 withValue:[packingHolder MAINKEY]];
    [packingHolder setFieldAtIndex:63 withValue:[EncodeString encodeASC:@"001"]];
    [packingHolder preparePacking];

}

// --- 工作密钥
- (void) packingDownWorkKFieldsInfo:(NSDictionary*)fieldsInfo {
    Packing8583* packingHolder = [Packing8583 sharedInstance];
    [packingHolder setFieldAtIndex:11 withValue:[PublicInformation exchangeNumber]];
    [packingHolder setFieldAtIndex:41 withValue:[EncodeString encodeASC:fieldsInfo[@"41"]]];
    [packingHolder setFieldAtIndex:42 withValue:[EncodeString encodeASC:fieldsInfo[@"42"]]];
    [packingHolder setFieldAtIndex:60 withValue:[Packing8583 makeF60OnTrantype:TranType_DownWorkKey]];
    [packingHolder setFieldAtIndex:63 withValue:[EncodeString encodeASC:@"001"]];
    [packingHolder preparePacking];
}

@end
