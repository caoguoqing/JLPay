//
//  MCacheSavedLogin.m
//  JLPay
//
//  Created by jielian on 16/10/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MCacheSavedLogin.h"
#import <ReactiveCocoa.h>

@implementation MCacheSavedLogin

+ (instancetype)cache {
    static MCacheSavedLogin* shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[MCacheSavedLogin alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        @weakify(self);
        self.logined = NO;
        [RACObserve(self, userName) subscribeNext:^(id x) {
            @strongify(self);
            [self clearCacheWhenUserNameExchanged];
        }];
    }
    return self;
}



- (void) clearCacheWhenUserNameExchanged {
    self.logined = NO;
    self.userPassword = nil;
    self.appVersion = nil;
    self.systemType = nil;
    self.businessCode = nil;
    self.businessName = nil;
    self.terminalCount = 0;
    self.terminalList = nil;
    self.checkedState = MCacheSignUpCheckStateChecked;
    self.checkRefuseReason = nil;
    self.email = nil;
}


@end
