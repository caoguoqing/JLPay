//
//  MPasswordEncrytor.h
//  JLPay
//
//  Created by jielian on 16/10/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPasswordEncrytor : NSObject

+ (NSString*) pinEncryptedBySource:(NSString*)source;

+ (NSString*) pinSourceDecryptedOnPin:(NSString*)pin;

@end
