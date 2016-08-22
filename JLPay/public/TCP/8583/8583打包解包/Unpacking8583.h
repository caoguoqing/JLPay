//
//  Unpacking8583.h
//  PosN38Universal
//
//  Created by work on 14-8-8.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ErrorType.h"


@interface Unpacking8583 : NSObject

/*
 * 8583响应数据拆包 接口:
 *         只需要类方法;block做回调;拆出来的每个子域都以 2-64 数字做域名;
 *
 *  @param responseString: 交易响应报文串  (IN)
 *  @param  unpackedBlock: 拆包成功的回调  (BLOCK)
 *  @param     errorBlock: 拆包失败的回调  (BLOCK)
 */
+ (void) unpacking8583Response:(NSString*)responseString
                    onUnpacked:(void (^) (NSDictionary* unpackedInfo))unpackedBlock
                       onError:(void (^) (NSError* error))errorBlock;



// 3DES加密
+(NSString *)threeDesEncrypt:(NSString *)decryptDtr keyValue:(NSString *)key;

// 3DES解密
+(NSString *)threeDESdecrypt:(NSString *)decryptStr keyValue:(NSString *)key;


@end
