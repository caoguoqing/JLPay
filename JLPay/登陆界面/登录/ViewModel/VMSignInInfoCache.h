//
//  VMSignInInfoCache.h
//  JLPay
//
//  Created by jielian on 16/6/15.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMSignInInfoCache : NSObject

@property (nonatomic, copy) NSString* userName;

@property (nonatomic, copy) NSString* userPasswordPin;

@property (nonatomic, assign) BOOL seenPasswordAvilable;

@property (nonatomic, assign) BOOL needPasswordSaving;


- (void) reReadLocalConfig;

- (void) reWriteLocalConfig;

@end
