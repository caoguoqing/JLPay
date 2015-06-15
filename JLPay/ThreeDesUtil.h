//
//  ThreeDesUtil.h
//  JLPay
//
//  Created by jielian on 15/6/15.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreeDesUtil : NSObject
/*
 //DES加密
 */
+(NSString *) encryptUse3DES:(NSString *)plainText key:(NSString *)key;

/**
 DES解密
 */
+(NSString *) decryptUse3DES:(NSString *)plainText key:(NSString *)key;

@end
