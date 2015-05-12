//
//  DesUtil.h
//  PosSwipeCard
//
//  Created by work on 14-8-1.
//  Copyright (c) 2014年 ggwl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DesUtil : NSObject

/*
//DES加密
*/
+(NSString *) encryptUseDES:(NSString *)plainText key:(NSString *)key;

/**
 DES解密
 */
+(NSString *) decryptUseDES:(NSString *)plainText key:(NSString *)key;



@end
