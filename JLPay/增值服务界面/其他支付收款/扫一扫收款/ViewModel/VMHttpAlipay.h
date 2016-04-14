//
//  VMHttpAlipay.h
//  JLPay
//
//  Created by jielian on 16/4/14.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPInstance.h"
#import "PublicInformation.h"
#import "ModelUserLoginInformation.h"
#import "MD5Util.h"


@interface VMHttpAlipay : NSObject

@property (nonatomic, copy) NSString* payCode;
@property (nonatomic, copy) NSString* payAmount;
@property (nonatomic, strong) HTTPInstance* http;

- (void) startAlipayTransOnFinished:(void (^) (void))finished onError:(void (^) (NSError* error))errorBlock;
- (void) stopAlipayTrans;

@end
