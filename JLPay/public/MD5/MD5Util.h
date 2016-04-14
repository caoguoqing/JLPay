//
//  MD5Util.h
//  JLPay
//
//  Created by jielian on 16/4/14.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface MD5Util : NSObject

+ (NSString*) encryptWithSource:(NSString*)source;

@end
