//
//  MPasswordEncrytor.m
//  JLPay
//
//  Created by jielian on 16/10/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MPasswordEncrytor.h"
#import "ThreeDesUtil.h"
#import "PublicInformation.h"
#import "EncodeString.h"


static NSString* const encryptorKey = @"123456789012345678901234567890123456789012345678";



@implementation MPasswordEncrytor

+ (NSString *)pinEncryptedBySource:(NSString *)source {
    return [ThreeDesUtil encryptUse3DES:[EncodeString encodeASC:source] key:encryptorKey];
}

+ (NSString *)pinSourceDecryptedOnPin:(NSString *)pin {
    return [PublicInformation stringFromHexString:[ThreeDesUtil decryptUse3DES:pin key:encryptorKey]];
}

@end
