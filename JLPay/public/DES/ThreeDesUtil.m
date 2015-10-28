//
//  ThreeDesUtil.m
//  JLPay
//
//  Created by jielian on 15/6/15.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "ThreeDesUtil.h"
#import "PublicInformation.h"
#import <CommonCrypto/CommonCryptor.h>
#import <UIKit/UIKit.h>
#import "ConverUtil.h"

@implementation ThreeDesUtil



//static Byte iv[] = {1,2,3,4,5,6,7,8};
/*
 DES加密
 */
+(NSString *) encryptUse3DES:(NSString *)clearText key:(NSString *)key
{
    
    NSString *ciphertext = nil;
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    ;
    NSData *testData=[PublicInformation NewhexStrToNSData:clearText];
//    NSLog(@"明文data:%@,length = [%d]", testData, [testData length]);
    Byte *test=(Byte *)[testData bytes];
//    printf("%d",strlen(test));
//    for (int i = 0; i < 16; i++) {
//        NSLog(@"明文data:%x,sizeof(test)=[%lu]", *(test+i), sizeof(test));
//    }

    
    Byte *keybyte=(Byte *)[[PublicInformation NewhexStrToNSData:key] bytes];
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithm3DES,
                                          kCCOptionECBMode|kCCOptionPKCS7Padding,
                                          keybyte,
                                          kCCKeySize3DES,
                                          nil,//iv,
                                          test	, [testData length],
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //NSLog(@"DES加密成功");
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        ciphertext = [self stringWithHexBytes2:data];//[ConverUtil parseByteArray2HexString:bb];
    }else{
        //NSLog(@"DES加密失败");
    }
    return ciphertext;
}

/**
 DES解密
 */
+(NSString *) decryptUse3DES:(NSString *)plainText key:(NSString *)key
{
    NSString *cleartext = nil;
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    
    NSData *testData=[PublicInformation NewhexStrToNSData:plainText];
    Byte *test=(Byte *)[testData bytes];
    Byte *keybyte=(Byte *)[[PublicInformation NewhexStrToNSData:key] bytes];

    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithm3DES,
                                          kCCOptionECBMode|kCCOptionPKCS7Padding,
                                          keybyte, kCCKeySize3DES,
                                          nil,//iv,
                                          test	, [testData length],
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //NSLog(@"DES解密成功");
        
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        //NSLog(@"data====%@",data);
        //Byte* bb = (Byte*)[data bytes];
        cleartext = [self stringWithHexBytes2:data];//[ConverUtil parseByteArray2HexString:bb];
    }else{
        NSLog(@"DES解密失败");
    }
    return cleartext;
}


+ (NSString*)stringWithHexBytes2:(NSData *)theData {
    static const char hexdigits[] = "0123456789ABCDEF";
    const size_t numBytes = [theData length];
    const unsigned char* bytes = [theData bytes];
    char *strbuf = (char *)malloc(numBytes * 2 + 1);
    char *hex = strbuf;
    NSString *hexBytes = nil;
    for (int i = 0; i<numBytes; ++i) {
        const unsigned char c = *bytes++;
        *hex++ = hexdigits[(c >> 4) & 0xF];
        *hex++ = hexdigits[(c ) & 0xF];
    }
    *hex = 0;
    hexBytes = [NSString stringWithUTF8String:strbuf];
    free(strbuf);
    return hexBytes;
}


@end
