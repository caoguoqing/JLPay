//
//  ModelAppInformation.h
//  JLPay
//
//  Created by jielian on 16/1/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString* const kNotiKeyAppStoreInfoRequested = @"kNotiKeyAppStoreInfoRequested";

@interface ModelAppInformation : NSObject

// -- AppStore URL
+ (NSString*) URLStringInAppStore;


+ (instancetype) sharedInstance;

- (BOOL) appStoreInfoRequested;

- (void) requestAppStoreInfo;

// -- AppStore 版本号 (小数点格式)
- (NSString*) appStoreVersion;
// -- 更新信息
- (NSString*) appUpdatedDescription;

@end
