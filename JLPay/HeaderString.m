//
//  HeaderString.m
//  PosSwipeCard
//
//  Created by work on 14-7-29.
//  Copyright (c) 2014年 ggwl. All rights reserved.
//

#import "HeaderString.h"
#import "ISOHelper.h"

@implementation HeaderString


+(NSString *)returnBitmap:(NSArray *)arr{
    NSMutableArray *newArr=[[NSMutableArray alloc] init];
    for (int i=1; i<65; i++) {
        [newArr addObject:@"0"];
    }
    for (int b=1; b<65; b++) {
        for (int c=0; c<[arr count]; c++) {
            [newArr replaceObjectAtIndex:[[arr objectAtIndex:c] intValue]-1 withObject:@"1"];
        }
    }
    NSString *bitmapStr=[ISOHelper binaryToHexAsString:[newArr componentsJoinedByString:@""]];
    return bitmapStr;
}

+(NSString *)receiveArr:(NSArray *)arr
                   Tpdu:(NSString *)tpdu
                 Header:(NSString *)header
           ExchangeType:(NSString *)exchangetype
                DataArr:(NSArray *)dataarr
{
    NSString *bitmapStr=[self returnBitmap:arr];
    NSString *dataStr=[dataarr componentsJoinedByString:@""];
    NSString *allStr=[NSString stringWithFormat:@"%@%@%@%@%@",tpdu,header,exchangetype,bitmapStr,dataStr];
    return [NSString stringWithFormat:@"%@%@",[self ToBHex:(int)[allStr length]/2],allStr];
}


///////////////////////////////////
/*
 * 8583打包函数:
 *  1.域值打包在字典中传入
 *  2.根据传入的map数组到字典中取对应的 value
 */
+(NSString*) stringPacking8583WithBitmapArray:(NSArray*)mapArray
                                        tpdu:(NSString*)tpdu
                                       header:(NSString*)header
                                 ExchangeType:(NSString*)exchangeType
                               dataDictionary:(NSDictionary*)dict
{
    NSMutableString* packedString = [[NSMutableString alloc] init];
    [packedString appendString:tpdu];
    [packedString appendString:header];
    [packedString appendString:exchangeType];
    [packedString appendString:[self returnBitmap:mapArray]];
    for (NSString* key in mapArray) {
        [packedString appendString:[dict valueForKey:key]];
    }
    return [NSString stringWithFormat:@"%@%@",[self ToBHex:(int)packedString.length/2],packedString];
}
///////////////////////////////////



+(NSString *)IC_receiveArr:(NSArray *)arr  Tpdu:(NSString *)tpdu Header:(NSString *)header ExchangeType:(NSString *)exchangetype DataArr:(NSArray *)dataarr{
    
    NSString *bitmapStr=[self returnBitmap:arr];
    NSLog(@"位图======%@",bitmapStr);
    
    NSString *dataStr=[dataarr componentsJoinedByString:@""];
    NSString *allStr=[NSString stringWithFormat:@"%@%@%@%@%@",tpdu,header,exchangetype,bitmapStr,dataStr];
    return [NSString stringWithFormat:@"0%d%@",(int)[allStr length]/2,allStr];
}


//十进制转16进制

+(NSString *)ToBHex:(int)tmpid{
    NSString *endtmp=@"";
    int yushu = 0;
    int chushu = 0;
    while (1) {
        yushu = tmpid % 16;     // 余数
        chushu = tmpid / 16;    // 除数
        // 追加余数到 endTmp
        if (yushu < 10) {
            endtmp = [[NSString stringWithFormat:@"%d",yushu] stringByAppendingString:endtmp];
        } else {
            endtmp = [[NSString stringWithFormat:@"%c",yushu - 10 + 'A'] stringByAppendingString:endtmp];
        }
        if (chushu == 0) break;
        tmpid /= 16;
    }
    int icount = 4 - (int)[endtmp length];
    NSMutableString* added0 = [[NSMutableString alloc] init];
    if (icount > 0) {
        for (int i = 0; i < icount; i++) {
            [added0 appendString:@"0"];
        }
        endtmp = [added0 stringByAppendingString:endtmp];
    }
    return endtmp;
}




char uniteBytes(char a,char b)
{
    char c1 = (a-'0') << 4;
    char c2 =b-'0';
    return c1+c2;
}

/**
 * getHPin
 * 对密码进行转换
 * PIN格式
 * BYTE 1 PIN的长度
 * BYTE 2 – BYTE 3/4/5/6/7 4--12个PIN(每个PIN占4个BIT)
 * BYTE 4/5/6/7/8 – BYTE 8 FILLER “F” (每个“F“占4个BIT)
 * @param pin String
 * @return byte[]
 */
void getHPin(char* pin, char* encode)
{
    encode[0] = 6;
    encode[1] = uniteBytes(pin[0], pin[1]);
    encode[2] = uniteBytes(pin[2], pin[3]);
    encode[3] = uniteBytes(pin[4], pin[5]);
    encode[4] = 255;
    encode[5] = 255;
    encode[6] = 255;
    encode[7] = 255;
}

/**
 * getHAccno
 * 对帐号进行转换
 * BYTE 1 — BYTE 2 0X0000
 * BYTE 3 — BYTE 8 12个主帐号
 * 取主帐号的右12位（不包括最右边的校验位），不足12位左补“0X00”。
 * @param accno String
 * @return byte[]
 */
char* getHAccno(char* accno,char* encode)
{
    int len = (int)strlen(accno);
    int beginPos = len < 13 ? 0 : len - 13;
    char arrTemp[13] = {0};
    memcpy(arrTemp, accno+beginPos, len-beginPos-1);
    char arrAccno[12];
    for(int i=0; i<12; i++)
    {
        arrAccno[i] = (i <= strlen(arrTemp) ? arrTemp[i] : 0);
    }
    
    encode[0] = 0;
    encode[1] = 0;
    encode[2] = uniteBytes(arrAccno[0], arrAccno[1]);
    encode[3] = uniteBytes(arrAccno[2], arrAccno[3]);
    encode[4] = uniteBytes(arrAccno[4], arrAccno[5]);
    encode[5] = uniteBytes(arrAccno[6], arrAccno[7]);
    encode[6] = uniteBytes(arrAccno[8], arrAccno[9]);
    encode[7] = uniteBytes(arrAccno[10], arrAccno[11]);
    return encode;
}


/**
 * getPinBlock
 * 标准ANSI X9.8 Format（带主帐号信息）的PIN BLOCK计算
 * PIN BLOCK 格式等于 PIN 按位异或 主帐号;
 * @param pin String
 * @param accno String
 * @return byte[]
 */
void process(char* pin, char* accno,char* pHexRet)
{
    char arrAccno[128]={0};
    getHAccno(accno,arrAccno);
    char arrPin[128]={0};
    getHPin(pin, arrPin);
    unsigned char arrRet[8]={0};
    for(int i=0; i<8; i++){
        arrRet[i] = (unsigned char)(arrPin[i] ^ arrAccno[i]);
    }
    
    binary2char(pHexRet, arrRet, 8);
}

void binary2char(char* charArray, const unsigned char* binArray, int binLen)
{
    int i;
    for(i = 0; i < binLen; i++)
    {
        sprintf(charArray + 2*i, "%02X", binArray[i]);
    }
    charArray[2*i] = '\0';
}






@end
