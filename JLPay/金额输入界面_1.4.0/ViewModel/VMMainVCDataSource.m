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
#import "MSettlementTypeLocalConfig.h"


@implementation VMMainVCDataSource


- (void)refrashData {
    self.logined = [[MCacheSavedLogin cache] logined];
    
    /* 用户名 */
    self.userName = [self userNameInCache];
    
    /* 商户名 */
    self.businessName = [self foundBusinessNameFromLocalOrCache];
    
    /* 商户编号 */
    self.businessCode = [self foundBusinessCodeFromLocalOrCache];
    
    /* 是否允许切换 */
    self.canSwitchSettlementType = [self foundCanSwitchSettlementTypeEnable];
    
    /* 结算方式 */
    self.settleType = [self foundSettleTypeFromLocalOrCache];
    
    /* 是否绑定设备 */
    self.deviceBinded = [self foundDeviceBindedFlagFromLocalOrCache];
    
    /* 是否需要绑定设备 */
    self.needBindDevice = [self needBindDeviceOnAnalysing];
}



- (void)doswitchSettlementTypeWithVC:(UIViewController *)vc onFinished:(void (^)(void))finishedBlock
{
    [UIAlertController showActSheetWithTitle:@"切换结算方式" message:@"[T+0]工作日当日到账;\n[T+1]下个工作日到账;" target:vc clickedHandle:^(UIAlertAction *action) {
        if ([action.title isEqualToString:kSettlementTypeT_0]) {
            [[MSettlementTypeLocalConfig localConfig] updateLocalConfitWithSettlementType:SettlementType_T0];
            if (finishedBlock) finishedBlock();
        }
        else if ([action.title isEqualToString:kSettlementTypeT_1]) {
            [[MSettlementTypeLocalConfig localConfig] updateLocalConfitWithSettlementType:SettlementType_T1];
            if (finishedBlock) finishedBlock();
        }
    } buttons:@{@(UIAlertActionStyleCancel):@"取消"},@{@(UIAlertActionStyleDefault):kSettlementTypeT_0},@{@(UIAlertActionStyleDefault):kSettlementTypeT_1}, nil];
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
    /* 仅商户被允许T+0,才查询t+0信息 */
    if (loginCache.logined && loginCache.T_0_enable) {
        NameWeakSelf(wself);
        MCacheT0Info* t_0Info = [MCacheT0Info cache];
        [t_0Info reloadCacheWithBusinessCode:loginCache.businessCode onFinished:^{
            MSettlementTypeLocalConfig* settlementConfig = [MSettlementTypeLocalConfig localConfig];

            if (t_0Info.T_0Enable) {
                wself.canSwitchSettlementType = YES;
                if (settlementConfig.curSettlementType == SettlementType_T0) {
                    wself.settleType = kSettlementTypeT_0;
                } else {
                    wself.settleType = kSettlementTypeT_1;
                }
            } else {
                wself.canSwitchSettlementType = NO;
                wself.settleType = kSettlementTypeT_1;
                if (settlementConfig.curSettlementType == SettlementType_T0) {
                    [settlementConfig updateLocalConfitWithSettlementType:SettlementType_T1];
                }
            }
        } onError:^(NSError *error) {
            
        }];
        settleType = t_0Info.T_0Enable ? kSettlementTypeT_0:kSettlementTypeT_1;
    }
    return settleType;
}


- (BOOL) foundCanSwitchSettlementTypeEnable {
    MCacheSavedLogin* loginCache = [MCacheSavedLogin cache];
    MCacheT0Info* t0Cache = [MCacheT0Info cache];
    if (loginCache.logined) {
        if (loginCache.T_0_enable && t0Cache.T_0Enable) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
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
