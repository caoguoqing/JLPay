//
//  ModelSettlementInformation.h
//  JLPay
//
//  Created by jielian on 15/12/11.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 * 动态保存在内存，而非本地配置
 */


typedef enum {
    SETTLEMENTTYPE_T_1  = 1 << 0,       // T+1
    SETTLEMENTTYPE_T_0  = 1 << 1,       // T+0
    SETTLEMENTTYPE_T_6  = 1 << 2,       // T+6
    SETTLEMENTTYPE_T_15 = 1 << 3,       // T+15
    SETTLEMENTTYPE_T_30 = 1 << 4        // T+30
} SETTLEMENTTYPE;


@interface ModelSettlementInformation : NSObject

+ (instancetype) sharedInstance;

/* 结算方式名: 指定结算方式 */
+ (NSString*) nameOfSettlementType:(SETTLEMENTTYPE)settlementType;

// -- 默认:T+1,可切换
@property (nonatomic, assign) SETTLEMENTTYPE curSettlementType;




@end
