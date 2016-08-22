//
//  Unpacking8583.m
//  PosN38Universal
//
//  Created by work on 14-8-8.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import "Unpacking8583.h"
#import "PublicInformation.h"
#import "ISOFieldFormation.h"


#import "DesUtil.h"
#import "Define_Header.h"
#import "AppDelegate.h"

static Unpacking8583 *sharedObj2 = nil;

@implementation Unpacking8583



#pragma mask ---- 重写8583报文解包函数 -----------------------------------------------------------
/*
 * 1. (4  位包长)
 * 2. (10 位 TPDU)
 * 3. (12 位报文头)
 * 4. (4  位交易类型)
 * 5. (16 位 BITMAP 位图串) ;
 * 6. (实际交易数据;起始位:46)
 */

+ (void)unpacking8583Response:(NSString *)responseString
                   onUnpacked:(void (^)(NSDictionary *))unpackedBlock
                      onError:(void (^)(NSError *))errorBlock
{
    if (!responseString || responseString.length <= 46) {
        NSString* message = [NSString stringWithFormat:@"响应报文数据为空或长度过短[%d]", ((responseString) ? (responseString.length) : (0))];
        errorBlock([NSError errorWithDomain:@"" code:99 localizedDescription:message]);
        return;
    }
    
    NSInteger location = 0;
    /* [4]包长 */
//    NSString* packageLen = [responseString substringToIndex:4];
    location += 4;
    /* [10]TPDU */
//    NSString* tpdu = [responseString substringWithRange:NSMakeRange(location, 10)];
    location += 10;
    /* [12]报文头 */
//    NSString* packageHeader = [responseString substringWithRange:NSMakeRange(location, 12)];
    location += 12;

    /* [4]交易类型 */
    NSString* msgType = [responseString substringWithRange:NSMakeRange(location, 4)];
    location += 4;
    
    /* [16]BITMAP */
    NSString* bitmap = [responseString substringWithRange:NSMakeRange(location, 16)];
    location += 16;

    /* [..]交易数据 */
    NSMutableString* responseDataStr = [NSMutableString stringWithString:[responseString substringFromIndex:location]];

    
    /* -- 解析出每个字段值 -- */
    NSArray *bitmapArr = [self bitmapArr:[PublicInformation getBinaryByhex:bitmap]];
    NSMutableDictionary* dictFields = [NSMutableDictionary dictionaryWithCapacity:bitmapArr.count];
    for (NSString* bitIndex in bitmapArr) {
        NSString* content = [[ISOFieldFormation sharedInstance] unformatStringWithFormation:responseDataStr atIndex:bitIndex.intValue];
        
        if ([bitIndex isEqualToString:@"39"]) {
            [dictFields setValue:[PublicInformation stringFromHexString:content] forKey:bitIndex];
        } else {
            [dictFields setValue:content forKey:bitIndex];
        }
    }
    
    [dictFields setValue:msgType forKey:@"msgType"];
    
    /* 将拆包后的域的集合回调出去 */
    unpackedBlock(dictFields);
}



#pragma mark ----------3des加密

+(NSString *)threeDesEncrypt:(NSString *)decryptDtr keyValue:(NSString *)key{
    /*
     加密:    双倍长密钥加密算法为：
     str = DES(str ,k21)
     str = UDES(str ,k22)
     str = DES(str ,k21)
     其对应的解密过程就不详解了。
     */
    //3des加密8个0
    NSString *key21=[key substringWithRange:NSMakeRange(0, [key length]/2)];
    NSString *key22=[key substringWithRange:NSMakeRange([key length]/2, [key length]/2)];
    NSString *descryptStr1=[DesUtil encryptUseDES:decryptDtr key:key21];
    NSString *descryptStr2=[DesUtil decryptUseDES:descryptStr1 key:key22];
    NSString *descryptStr3=[DesUtil encryptUseDES:descryptStr2 key:key21];
    return descryptStr3;
}


#pragma mark ----------3des解密
+(NSString *)threeDESdecrypt:(NSString *)decryptStr keyValue:(NSString *)key{
    /*
     解密:    双倍长密钥解密算法为：
     str = UDES(str ,k21)
     str = DES(str ,k22)
     str = UDES(str ,k21)
     其对应的解密过程就不详解了。
     */
    NSString *key21=[key substringWithRange:NSMakeRange(0, [key length]/2)];
    NSString *key22=[key substringWithRange:NSMakeRange([key length]/2, [key length]/2)];
    NSString *descryptStr1=[DesUtil decryptUseDES:decryptStr key:key21];
    NSString *descryptStr2=[DesUtil encryptUseDES:descryptStr1 key:key22];
    NSString *descryptStr3=[DesUtil decryptUseDES:descryptStr2 key:key21];
    return descryptStr3;
}




#pragma mark ::: 位图计算
+(NSArray *)bitmapArr:(NSString *)bitmapStr{
    //0000000000111000000000000000000000001010110000000000000100100110
    NSMutableArray *bitmapMuArr=[[NSMutableArray alloc] init];
    for (int i=0; i<([bitmapStr length]+0); i++) {
        if ([[bitmapStr substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"1"]) {
            [bitmapMuArr addObject:[NSString stringWithFormat:@"%d",i+1]];
        }
    }
    return bitmapMuArr;
}

@end
