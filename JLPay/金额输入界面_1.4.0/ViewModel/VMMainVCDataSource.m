//
//  VMMainVCDataSource.m
//  JLPay
//
//  Created by jielian on 16/10/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMMainVCDataSource.h"
#import "MCacheSavedLogin.h"
#import "MCacheT0Info.h"
#import "Define_Header.h"
#import "ModelDeviceBindedInformation.h"


@implementation VMMainVCDataSource


- (void)refrashData {
    self.logined = [[MCacheSavedLogin cache] logined];
    
    /* 用户名 */
    self.userName = [self userNameInCache];
    
    /* 商户名 */
    self.businessName = [self foundBusinessNameFromLocalOrCache];
    
    /* 商户编号 */
    self.businessCode = [self foundBusinessCodeFromLocalOrCache];
    
    /* 结算方式 */
    self.settleType = [self foundSettleTypeFromLocalOrCache];
    
    /* 是否绑定设备 */
    self.deviceBinded = [self foundDeviceBindedFlagFromLocalOrCache];
    
    /* 是否需要绑定设备 */
    self.needBindDevice = [self needBindDeviceOnAnalysing];
}



+ (instancetype)dataSource {
    static VMMainVCDataSource* datasource;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        datasource = [[VMMainVCDataSource alloc] init];
    });
    return datasource;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self refrashData];
    }
    return self;
}


- (NSString*) foundBusinessNameFromLocalOrCache {
    NSString* businessName = @"(未登录)";
    MCacheSavedLogin* loginCache = [MCacheSavedLogin cache];
    if (loginCache.logined) {
        businessName = loginCache.businessName;
    }
    return businessName;
}

- (NSString*) foundSettleTypeFromLocalOrCache {
    NSString* settleType = kSettlementTypeT_1;
    MCacheSavedLogin* loginCache = [MCacheSavedLogin cache];
    /* 这里不管商户是否被允许T+0,都要重新查询t+0信息么 */
    if (loginCache.logined /*&& loginCache.T_0_enable*/) {
        NameWeakSelf(wself);
        MCacheT0Info* t_0Info = [MCacheT0Info cache];
        [t_0Info reloadCacheWithBusinessCode:loginCache.businessCode onFinished:^{
            wself.settleType = t_0Info.T_0Enable ? kSettlementTypeT_0:kSettlementTypeT_1;
        } onError:^(NSError *error) {
            
        }];
        settleType = t_0Info.T_0Enable ? kSettlementTypeT_0:kSettlementTypeT_1;
    }
    return settleType;
}


- (BOOL) foundDeviceBindedFlagFromLocalOrCache {
    BOOL binded = NO;
    if ([[MCacheSavedLogin cache] logined] && [ModelDeviceBindedInformation hasBindedDevice]) {
        binded = YES;
    }
    return binded;
}

- (BOOL) needBindDeviceOnAnalysing {
    BOOL need = NO;
    if ([[MCacheSavedLogin cache] logined] && ![ModelDeviceBindedInformation hasBindedDevice]) {
        need = YES;
    }
    return need;
}

/* 商户编号 */
- (NSString*) foundBusinessCodeFromLocalOrCache {
    if ([[MCacheSavedLogin cache] logined] && [[MCacheSavedLogin cache] checkedState] != MCacheSignUpCheckStateCheckRefused) {
        return [MCacheSavedLogin cache].businessCode;
    } else {
        return nil;
    }
}

/* 用户名 */
- (NSString*) userNameInCache {
    if ([[MCacheSavedLogin cache] logined]) {
        return [[MCacheSavedLogin cache] userName];
    } else {
        return @"(未登录)";
    }
}

@end
