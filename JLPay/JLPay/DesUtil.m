//
//  DesUtil.m
//  PosSwipeCard
//
//  Created by work on 14-8-1.
//  Copyright (c) 2014年 ggwl. All rights reserved.
//

#import "DesUtil.h"
#import "PublicInformation.h"



#import <CommonCrypto/CommonCryptor.h>
#import <UIKit/UIKit.h>
#import "ConverUtil.h"
@implementation DesUtil


//static Byte iv[] = {1,2,3,4,5,6,7,8};
/*
 DES加密
 */
+(NSString *) encryptUseDES:(NSString *)clearText key:(NSString *)key
{
    
    NSString *ciphertext = nil;
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    ;
    NSData *testData=[PublicInformation NewhexStrToNSData:clearText];
    Byte *test=(Byte *)[testData bytes];
    Byte *keybyte=(Byte *)[[PublicInformation NewhexStrToNSData:key] bytes];
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionECBMode,
                                          keybyte, kCCKeySizeDES,
                                          nil,//iv,
                                          test	, [testData length],
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //NSLog(@"DES加密成功");
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        //NSLog(@"data=====+%@",data);//b907676219306eb8c3aa9b0e1f549ef602
        //Byte* bb = (Byte*)[data bytes];
        ciphertext = [self stringWithHexBytes2:data];//[ConverUtil parseByteArray2HexString:bb];
    }else{
        //NSLog(@"DES加密失败");
    }
    return ciphertext;
    
/*
    NSString *ciphertext = nil;
    NSData *textData = [clearText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [clearText length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    
    
    Byte test[]={ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00,0x00};
    
    //D4A372400FDCAB7A
    Byte keybyte[]={ 0xD4, 0xA3, 0x72, 0x40, 0x0F, 0xDC,0xAB,0x7A};
    
    NSString *keyStr=[ConverUtil parseByteArray2HexString:keybyte];
    NSLog(@"keyStr====%@",keyStr);
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionECBMode,
                                          keybyte, kCCKeySizeDES,
                                          nil,//iv,
                                          test	, 8,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSLog(@"DES加密成功");
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        NSLog(@"data=====+%@",data);//b907676219306eb8c3aa9b0e1f549ef602
        Byte* bb = (Byte*)[data bytes];
        ciphertext = [ConverUtil parseByteArray2HexString:bb];
    }else{
        NSLog(@"DES加密失败");
    }
    return ciphertext;
*/
}

/**
 DES解密
 */
+(NSString *) decryptUseDES:(NSString *)plainText key:(NSString *)key
{
    NSString *cleartext = nil;
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    
    NSData *testData=[PublicInformation NewhexStrToNSData:plainText];
    Byte *test=(Byte *)[testData bytes];
    Byte *keybyte=(Byte *)[[PublicInformation NewhexStrToNSData:key] bytes];
/*
    //6B33B7A38AE2C214
    Byte test[]={ 0x6B, 0x33, 0xB7, 0xA3, 0x8A, 0xE2,0xC2,0x14};
    
    //4817643301CF9E6C
    Byte keybyte[]={ 0x48, 0x17, 0x64, 0x33, 0x01, 0xCF,0x9E,0x6C};
*/
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionECBMode,
                                          keybyte, kCCKeySizeDES,
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
        //NSLog(@"DES解密失败");
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
