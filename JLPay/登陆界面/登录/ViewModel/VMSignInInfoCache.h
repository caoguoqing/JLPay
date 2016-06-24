//
//  VMSignInInfoCache.h
//  JLPay
//
//  Created by jielian on 16/6/15.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLoginSavedResource.h"
#import "VMHttpSignIn.h"

@interface VMSignInInfoCache : NSObject


@property (nonatomic, retain) MLoginSavedResource* loginSavedResource;

- (void) resetPropertiesBySignInResponseData:(NSDictionary*)signInResponseData;

- (void) doLoginResourceSaving;

@end
