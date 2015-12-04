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
#import "ErrorType.h"
#import "Define_Header.h"
#import "PosLib.h"
#import "AppDelegate.h"

static Unpacking8583 *sharedObj2 = nil;

@implementation Unpacking8583
//@synthesize delegate;

+(Unpacking8583 *)getInstance{
    @synchronized([Unpacking8583 class]){
        if(sharedObj2 ==nil){
            sharedObj2 = [[self alloc] init];
        }
    }
    return sharedObj2;
}


#pragma mask ---- 重写8583报文解包函数 -----------------------------------------------------------
/*
 * 1. (4  位包长)
 * 2. (10 位 TPDU)
 * 3. (12 位报文头)
 * 4. (4  位交易类型)
 * 5. (16 位 BITMAP 位图串)
 * 6. (实际交易数据)
 */

-(void)unpacking8583:(NSString *)responseString withDelegate:(id<Unpacking8583Delegate>)sdelegate {
    self.stateDelegate = sdelegate;
    NSString* rebackStr = nil;
    BOOL rebackState = YES;
    @try {
        // 交易类型
        NSString* msgType = [responseString substringWithRange:NSMakeRange(26, 4)];

        // map数组: bitmap串(16进制) -> 二进制串 -> 取串中'1'的位置
        NSArray *bitmapArr = [self bitmapArr:[PublicInformation getBinaryByhex:[responseString substringWithRange:NSMakeRange(30, 16)]]];

        
        // 截取纯域值串
        NSMutableString* dataString = [[NSMutableString alloc] initWithString:[responseString substringFromIndex:46]];
        
        // 根据位图信息循环拆包
        NSMutableDictionary* dictFields = [NSMutableDictionary dictionaryWithCapacity:bitmapArr.count];
        for (NSString* bitIndex in bitmapArr) {
            // 并将拆包数据打包到字典
            NSString* content = [[ISOFieldFormation sharedInstance] unformatStringWithFormation:dataString atIndex:bitIndex.intValue];
            [dictFields setValue:content forKey:bitIndex];
        }
        // 追加交易类型
        [dictFields setValue:msgType forKey:@"msgType"];
        
        // 组合响应信息
        NSString* responseCode = [dictFields valueForKey:@"39"];
        responseCode = [PublicInformation stringFromHexString:responseCode];
        if (![responseCode isEqualToString:@"00"]) {
            rebackState = NO;
        }
        rebackStr = [ErrorType errInfo:responseCode];
        rebackStr = [NSString stringWithFormat:@"[%@]%@",responseCode, rebackStr];
        
        // 根据39域值,解析错误类型消息;
        if (self.stateDelegate && [self.stateDelegate respondsToSelector:@selector(didUnpackDatas:onState:withErrorMsg:)]) {
            [self.stateDelegate didUnpackDatas:dictFields onState:rebackState withErrorMsg:rebackStr];
        }

    }
    @catch (NSException *exception) {
        if (self.stateDelegate && [self.stateDelegate respondsToSelector:@selector(didUnpackDatas:onState:withErrorMsg:)]) {
            [self.stateDelegate didUnpackDatas:nil onState:NO withErrorMsg:exception.reason];
        }
    }
    @finally {}
}








#pragma mark ----------3des加密

-(NSString *)threeDesEncrypt:(NSString *)decryptDtr keyValue:(NSString *)key{
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
-(NSString *)threeDESdecrypt:(NSString *)decryptStr keyValue:(NSString *)key{
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
-(NSArray *)bitmapArr:(NSString *)bitmapStr{
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
