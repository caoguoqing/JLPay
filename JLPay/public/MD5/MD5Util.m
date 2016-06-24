//
//  MD5Util.m
//  JLPay
//
//  Created by jielian on 16/4/14.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MD5Util.h"

@implementation MD5Util


+ (NSString*) encryptWithSource:(NSString*)source {
    NSMutableString* encryptString = [NSMutableString string];
    const char* souceC = [source UTF8String];
    unsigned char result[CC_MD2_DIGEST_LENGTH];
    
    CC_MD5(souceC, (int)strlen(souceC), result);
    
    for (int i = 0; i < CC_MD2_DIGEST_LENGTH; i++) {
        [encryptString appendFormat:@"%02X",result[i]];
    }

    return [encryptString lowercaseString];
}


@end
