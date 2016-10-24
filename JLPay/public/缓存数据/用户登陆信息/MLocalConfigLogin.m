//
//  MLocalConfigLogin.m
//  JLPay
//
//  Created by jielian on 16/10/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MLocalConfigLogin.h"


static NSString* const kLocalConfigLogin = @"kLocalConfigLogin";



@implementation MLocalConfigLogin


+ (instancetype)sharedConfig {
    static MLocalConfigLogin* config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[MLocalConfigLogin alloc] init];
    });
    return config;
}


- (BOOL)hasBeenSaved {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* config = [userDefaults objectForKey:kLocalConfigLogin];
    BOOL saved = YES;
    
    if (!config || config.count == 0) {
        saved = NO;
    }
    NSString* userName = [config objectForKey:@"userName"];
    if (!userName || userName.length == 0) {
        saved = NO;
    }
    
    return saved;
}


- (void)clearConfig {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kLocalConfigLogin];
    [userDefaults synchronize];
    self.userName = nil;
    self.userPassword = nil;
    self.pwdNeedSeen = NO;
    self.pwdNeedSaved = NO;
}


- (void)reReadConfig {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* config = [userDefaults objectForKey:kLocalConfigLogin];
    if (config && config.count > 0) {
        self.userName = [config objectForKey:@"userName"];
        self.userPassword = [config objectForKey:@"userPassword"];
        self.pwdNeedSaved = [[config objectForKey:@"pwdNeedSaved"] boolValue];
        self.pwdNeedSeen = [[config objectForKey:@"pwdNeedSeen"] boolValue];
    }
}

- (void)reWriteConfig {
    if (!self.userName || self.userName.length <= 0 ||
        !self.userPassword || self.userPassword.length <= 0) {
        return;
    }
    
    NSMutableDictionary* config = [NSMutableDictionary dictionary];
    [config setObject:self.userName forKey:@"userName"];
    [config setObject:self.userPassword forKey:@"userPassword"];
    [config setObject:[NSNumber numberWithBool:self.pwdNeedSaved] forKey:@"pwdNeedSaved"];
    [config setObject:[NSNumber numberWithBool:self.pwdNeedSeen] forKey:@"pwdNeedSeen"];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:config forKey:kLocalConfigLogin];
    [userDefaults synchronize];
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.pwdNeedSeen = NO;
        self.pwdNeedSaved = NO;
        [self reReadConfig];
    }
    return self;
}

@end
