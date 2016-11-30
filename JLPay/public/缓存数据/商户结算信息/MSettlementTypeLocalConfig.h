//
//  MSettlementTypeLocalConfig.h
//  JLPay
//
//  Created by jielian on 2016/10/31.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SettlementType) {
    SettlementType_T0,
    SettlementType_T1,
    SettlementType_TN
};


@interface MSettlementTypeLocalConfig : NSObject

/* 单例 */
+ (instancetype) localConfig;

/* 当前结算类型 */
@property (nonatomic, assign) SettlementType curSettlementType;

/* 更新本地配置的结算类型 */
- (void) updateLocalConfitWithSettlementType:(SettlementType)settlementType;

@end
