//
//  MSettlementTypeLocalConfig.m
//  JLPay
//
//  Created by jielian on 2016/10/31.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MSettlementTypeLocalConfig.h"


static NSString* const keySettlementTypeLocalConfig = @"keySettlementTypeLocalConfig__";




@implementation MSettlementTypeLocalConfig


- (void)updateLocalConfitWithSettlementType:(SettlementType)settlementType {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(settlementType) forKey:keySettlementTypeLocalConfig];
    [userDefaults synchronize];
    self.curSettlementType = settlementType;
}


+ (instancetype)localConfig {
    static MSettlementTypeLocalConfig* config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[MSettlementTypeLocalConfig alloc] init];
    });
    return config;
}



- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialLocalConfigIfNotInitialed];
    }
    return self;
}

- (void) initialLocalConfigIfNotInitialed {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* settlementTypeNode = [userDefaults objectForKey:keySettlementTypeLocalConfig];
    if (!settlementTypeNode) {
        [userDefaults setObject:@(self.curSettlementType) forKey:keySettlementTypeLocalConfig];
        [userDefaults synchronize];
    } else {
        self.curSettlementType = [[userDefaults objectForKey:keySettlementTypeLocalConfig] integerValue];
    }
}

@end
