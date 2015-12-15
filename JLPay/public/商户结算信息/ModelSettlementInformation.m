//
//  ModelSettlementInformation.m
//  JLPay
//
//  Created by jielian on 15/12/11.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ModelSettlementInformation.h"
#import "HTTPRequestSettlementInfo.h"
#import "Define_Header.h"


static NSString* const stringSettlementT_1 = @"T+1";
static NSString* const stringSettlementT_0 = @"T+0";



@interface ModelSettlementInformation()
{
    SETTLEMENTTYPE settlementType__;
}
@property (nonatomic, strong) NSDictionary* settlementInformation;

@end

static ModelSettlementInformation* modelSettlement = nil;

@implementation ModelSettlementInformation


+ (instancetype) sharedInstance {
    @synchronized(self) {
        if (modelSettlement == nil) {
            modelSettlement = [[ModelSettlementInformation alloc] init];
        }
        return modelSettlement;
    }
}
- (instancetype)init {
    self = [super init];
    if (self) {
        settlementType__ = SETTLEMENTTYPE_T_1;
        self.settlementInformation = nil;
    }
    return self;
}

/* 结算方式名: 指定结算方式 */
+ (NSString*) nameOfSettlementType:(SETTLEMENTTYPE)settlementType {
    NSString* settlementName = nil;
    switch (settlementType) {
        case SETTLEMENTTYPE_T_1:
            settlementName = stringSettlementT_1;
            break;
        case SETTLEMENTTYPE_T_0:
            settlementName = stringSettlementT_0;
            break;
        default:
            settlementName = stringSettlementT_1;
            break;
    }
    return settlementName;
}


/* 当前结算方式 */
- (SETTLEMENTTYPE) curSettlementType {
    return settlementType__;
}

/* 更新结算方式 */
- (void) updateSettlementType:(SETTLEMENTTYPE)settlementType {
    settlementType__ = settlementType;
}

/* 切换结算方式 */
- (SETTLEMENTTYPE) settlementTypeSwitched {
    settlementType__ = settlementType__ << 1;
    if (![self enumExistsSettlemenType:settlementType__]) {
        settlementType__ = SETTLEMENTTYPE_T_1;
    }
    return settlementType__;
}

/* 保存结算信息 */
- (void) saveSettlementInfo:(NSDictionary*)settlementInfo {
    if (settlementInfo) {
        self.settlementInformation = [NSDictionary dictionaryWithDictionary:settlementInfo];
    }
    settlementType__ = SETTLEMENTTYPE_T_1;
}


/* 是否允许T+0 */
- (BOOL) T_0EnableOrNot {
    BOOL enable = NO;
    if (self.settlementInformation) {
        enable = [[self.settlementInformation objectForKey:kSettleInfoNameT_0_Enable] boolValue];
    }
    return enable;
}

/* T+0日结算限额 */
- (NSString*) T_0DaySettlementAmountLimit {
    NSString* limit = @"0.00";
    if (self.settlementInformation) {
        limit = [self.settlementInformation objectForKey:kSettleInfoNameAmountLimit];
        limit = [NSString stringWithFormat:@"%.02lf",limit.floatValue];
    }
    return limit;
}

/* T+0日可刷金额 */
- (NSString*) T_0DaySettlementAmountAvailable {
    NSString* available = @"0.00";
    if (self.settlementInformation) {
        available = [self.settlementInformation objectForKey:kSettleInfoNameAmountAvilable];
        available = [NSString stringWithFormat:@"%.02lf",available.floatValue];
    }
    return available;
}

/* T+0最低消费金额 */
- (NSString*) T_0MinSettlementAmount {
    if (TestOrProduce == 1) {
        return @"500.00";
    }
    else {
        return @"0.01";
    }
}

/* T+0增加费率 */
- (NSString*) T_0SettlementFeeRate {
    NSString* rate = @"0.00";
    if (self.settlementInformation) {
        rate = [self.settlementInformation objectForKey:kSettleInfoNameT_0_Fee];
        rate = [NSString stringWithFormat:@"%.02lf", rate.floatValue];
    }
    return rate;
}


#pragma mask ---- PRIVATE INTERFACE
/* 检查枚举是否存在指定的类型 */
- (BOOL) enumExistsSettlemenType:(NSInteger)type {
    BOOL exists = NO;
    switch (type) {
        case SETTLEMENTTYPE_T_0:
        case SETTLEMENTTYPE_T_1:
            exists = YES;
            break;
        default:
            break;
    }
    return exists;
}


@end
