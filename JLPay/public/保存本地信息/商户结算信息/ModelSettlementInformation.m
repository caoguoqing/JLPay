//
//  ModelSettlementInformation.m
//  JLPay
//
//  Created by jielian on 15/12/11.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ModelSettlementInformation.h"
#import "Define_Header.h"


static NSString* const stringSettlementT_1 = @"T+1";
static NSString* const stringSettlementT_0 = @"T+0";
static NSString* const stringSettlementT_6 = @"T+6";
static NSString* const stringSettlementT_15 = @"T+15";
static NSString* const stringSettlementT_30 = @"T+30";



@interface ModelSettlementInformation()

@end


@implementation ModelSettlementInformation

+ (instancetype) sharedInstance {
    static ModelSettlementInformation* modelSettlement;
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
        case SETTLEMENTTYPE_T_6:
            settlementName = stringSettlementT_6;
            break;
        case SETTLEMENTTYPE_T_15:
            settlementName = stringSettlementT_15;
            break;
        case SETTLEMENTTYPE_T_30:
            settlementName = stringSettlementT_30;
            break;
        default:
            settlementName = stringSettlementT_1;
            break;
    }
    return settlementName;
}




@end
