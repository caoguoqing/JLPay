//
//  MLoginSavedResource.m
//  JLPay
//
//  Created by jielian on 16/6/14.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MLoginSavedResource.h"

@implementation MLoginSavedResource

+ (instancetype)sharedLoginResource {
    static MLoginSavedResource* sharedResource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedResource = [[MLoginSavedResource alloc] init];
    });
    return sharedResource;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.beenSaved = ([self loginResourceSaved])?(YES):(NO);
        if (self.beenSaved) {
            [self unpackingPropertiesWithLoginResource:[self loginResourceSaved]];
        }
    }
    return self;
}

- (void)doSavingOnFinished:(void (^)(void))finishedBlock onError:(void (^)(NSError *))errorBlock {
    [self savingLoginResource];
    if (finishedBlock) {
        finishedBlock();
    }
}

# pragma mask 1 打包

- (NSDictionary* ) packedWithProperties {
    NSMutableDictionary* package = [NSMutableDictionary dictionary];
    
    [self packingProperty:self.userName withKey:@"userName" intoPackage:package];
    [self packingProperty:@(self.needSaving) withKey:@"needSaving" intoPackage:package];
    if (self.needSaving) {
        [self packingProperty:self.userPwdPan withKey:@"userPwdPan" intoPackage:package];
    }
    [self packingProperty:self.businessName withKey:@"businessName" intoPackage:package];
    [self packingProperty:self.businessNumber withKey:@"businessNumber" intoPackage:package];
    [self packingProperty:self.email withKey:@"email" intoPackage:package];
    [self packingProperty:@(self.terminalCount) withKey:@"terminalCount" intoPackage:package];
    if (self.terminalCount > 0) {
        [self packingProperty:self.terminalList withKey:@"terminalList" intoPackage:package];
    }
    [self packingProperty:@(self.T_0_enable) withKey:@"T_0_enable" intoPackage:package];
    [self packingProperty:@(self.T_N_enable) withKey:@"T_N_enable" intoPackage:package];
    [self packingProperty:@(self.N_fee_enable) withKey:@"N_fee_enable" intoPackage:package];
    [self packingProperty:@(self.N_business_enable) withKey:@"N_business_enable" intoPackage:package];
    [self packingProperty:@(self.checkedState) withKey:@"checkedState" intoPackage:package];
    if (self.checkedState == BusinessCheckedStateCheckRefused) {
        [self packingProperty:self.checkedRefuseReason withKey:@"checkedRefuseReason" intoPackage:package];
    }
    
    return package;
}

- (void) packingProperty:(id)property withKey:(NSString*)key intoPackage:(NSMutableDictionary*)package {
    if (property == nil) {
        return;
    }
    if (object_getClass(property) == [NSString class]) {
        NSString* stringPro = (NSString*)property;
        if (stringPro && stringPro.length > 0) {
            [package setObject:stringPro forKey:key];
        }
    }
    else if (object_getClass(property) == [NSArray class]) {
        NSArray* array = (NSArray*)property;
        if (array && array.count > 0) {
            [package setObject:array forKey:key];
        }
    }
    else {
        [package setObject:property forKey:key];
    }
}

# pragma mask 2 拆包

- (void) unpackingPropertiesWithLoginResource:(NSDictionary*)loginResource {
    
    self.userName = [loginResource objectForKey:@"userName"];
    self.userPwdPan = [loginResource objectForKey:@"userPwdPan"];
    self.needSaving = [[loginResource objectForKey:@"needSaving"] boolValue];
    self.businessName = [loginResource objectForKey:@"businessName"];
    self.businessNumber = [loginResource objectForKey:@"businessNumber"];
    self.email = [loginResource objectForKey:@"email"];
    self.terminalCount = [[loginResource objectForKey:@"terminalCount"] integerValue];
    self.terminalList = [loginResource objectForKey:@"terminalList"];
    self.T_0_enable = [[loginResource objectForKey:@"T_0_enable"] boolValue];
    self.T_N_enable = [[loginResource objectForKey:@"T_N_enable"] boolValue];
    self.N_fee_enable = [[loginResource objectForKey:@"N_fee_enable"] boolValue];
    self.N_business_enable = [[loginResource objectForKey:@"N_business_enable"] boolValue];
    self.checkedState = (BusinessCheckedState)[[loginResource objectForKey:@"checkedState"] integerValue];
    self.checkedRefuseReason = [loginResource objectForKey:@"checkedRefuseReason"];
}

# pragma mask 3 read & write

- (NSDictionary*) loginResourceSaved {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLoginSavedResourceName];
}

- (void) savingLoginResource {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLoginSavedResourceName];
    
    [[NSUserDefaults standardUserDefaults] setObject:[self packedWithProperties] forKey:kLoginSavedResourceName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}





@end
