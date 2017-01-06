//
//  VMSignInInfoCache.m
//  JLPay
//
//  Created by jielian on 16/6/15.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMSignInInfoCache.h"
#import "MLocalConfigLogin.h"
#import "ModelDeviceBindedInformation.h"
#import "ModelBusinessInfoSaved.h"
#import "ModelRateInfoSaved.h"



@implementation VMSignInInfoCache

- (void)reReadLocalConfig {
    MLocalConfigLogin* localConfig = [MLocalConfigLogin sharedConfig];
    [localConfig reReadConfig];
    if ([localConfig hasBeenSaved]) {
        self.userName = localConfig.userName;
        self.userPasswordPin = localConfig.userPassword;
    }
    self.needPasswordSaving = localConfig.pwdNeedSaved;
    self.seenPasswordAvilable = localConfig.pwdNeedSeen;
}

- (void)reWriteLocalConfig {
    // 清空设备绑定、多商户、多费率信息: 当切换了用户时
    MLocalConfigLogin* localConfig = [MLocalConfigLogin sharedConfig];
    [localConfig reReadConfig];
    if (![self.userName isEqualToString:localConfig.userName]) {
        [self clearMoreConfigIfExchagedUserID];
    }
    [localConfig clearConfig];
    
    // 执行保存
    localConfig.userName = self.userName;
    if (self.needPasswordSaving) {
        localConfig.userPassword = self.userPasswordPin;
    }
    localConfig.pwdNeedSeen = self.seenPasswordAvilable;
    localConfig.pwdNeedSaved = self.needPasswordSaving;
    [localConfig reWriteConfig];
}


/* 清空更多的配置: 当切换了ID */
- (void) clearMoreConfigIfExchagedUserID {
    /* 绑定设备信息 */
    [ModelDeviceBindedInformation cleanDeviceBindedInfo];
    /* 多商户 */
    [ModelBusinessInfoSaved clearSaved];
    /* 多费率 */
    [ModelRateInfoSaved clearSaved];
}


- (instancetype)init {
    self = [super init];
    if (self) {
        [self reReadLocalConfig];
    }
    return self;
}


@end
