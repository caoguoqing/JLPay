//
//  VMSignInInfoCache.m
//  JLPay
//
//  Created by jielian on 16/6/15.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMSignInInfoCache.h"

@implementation VMSignInInfoCache

- (void)resetPropertiesBySignInResponseData:(NSDictionary *)signInResponseData {

    self.loginSavedResource.businessName = [signInResponseData objectForKey:kFieldNameSignInDownBusinessName];
    self.loginSavedResource.businessNumber = [signInResponseData objectForKey:kFieldNameSignInDownBusinessNum];
    self.loginSavedResource.email = [signInResponseData objectForKey:kFieldNameSignInDownBusinessEmail];
    self.loginSavedResource.terminalCount = [[signInResponseData objectForKey:kFieldNameSignInDownTerminalCount] integerValue];
    
    /* 解析终端号组 */
    NSString* terminalList = [signInResponseData objectForKey:kFieldNameSignInDownTerminalList];
    if (terminalList && terminalList.length > 0) {
        NSArray* terminals = [NSMutableArray arrayWithArray:[terminalList componentsSeparatedByString:@","]];
        NSMutableArray* visibleTerminals = [NSMutableArray array];
        for (NSString* terminal in terminals) {
            [visibleTerminals addObject:[terminal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        self.loginSavedResource.terminalList = [visibleTerminals copy];
    } else {
        self.loginSavedResource.terminalList = nil;
    }
    
    /* 审核标志 */
    NSInteger code = [[signInResponseData objectForKey:kFieldNameSignInDownCode] integerValue];
    if (code == 801) {
        self.loginSavedResource.checkedState = BusinessCheckedStateChecking;
    }
    else if (code == 802) {
        self.loginSavedResource.checkedState = BusinessCheckedStateCheckRefused;
        self.loginSavedResource.checkedRefuseReason = [signInResponseData objectForKey:kFieldNameSignInDownMessage];
    }
    else {
        self.loginSavedResource.checkedState = BusinessCheckedStateChecked;
    }
    
    /* 允许标志 */
    NSString* allowFlags = [signInResponseData objectForKey:kFieldNameSignInDownAllowTypes];
    self.loginSavedResource.T_0_enable = (allowFlags && allowFlags.length >= 4 && [allowFlags substringWithRange:NSMakeRange(3, 1)].integerValue == 1)?(YES):(NO);
    self.loginSavedResource.T_N_enable = (allowFlags && allowFlags.length >= 1 && [allowFlags substringWithRange:NSMakeRange(0, 1)].integerValue == 1)?(YES):(NO);
    self.loginSavedResource.N_fee_enable = (allowFlags && allowFlags.length >= 2 && [allowFlags substringWithRange:NSMakeRange(1, 1)].integerValue == 1)?(YES):(NO);
    self.loginSavedResource.N_business_enable = (allowFlags && allowFlags.length >= 3 && [allowFlags substringWithRange:NSMakeRange(2, 1)].integerValue == 1)?(YES):(NO);


}

- (void)doLoginResourceSaving {
    [self.loginSavedResource doSavingOnFinished:nil onError:nil];
}

# pragma mask 3 getter
- (MLoginSavedResource *)loginSavedResource {
    if (!_loginSavedResource) {
        _loginSavedResource = [MLoginSavedResource sharedLoginResource];
    }
    return _loginSavedResource;
}

@end
