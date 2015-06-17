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
//    NSLog(@"newArr====%@",newArr);
    NSString *bitmapStr=[ISOHelper binaryToHexAsString:[newArr componentsJoinedByString:@""]];
    return bitmapStr;
}

+(NSString *)receiveArr:(NSArray *)arr  Tpdu:(NSString *)tpdu Header:(NSString *)header ExchangeType:(NSString *)exchangetype DataArr:(NSArray *)dataarr{

    NSString *bitmapStr=[self returnBitmap:arr];
    NSLog(@"位图======%@",bitmapStr);
    
    NSString *dataStr=[dataarr componentsJoinedByString:@""];
    NSString *allStr=[NSString stringWithFormat:@"%@%@%@%@%@",tpdu,header,exchangetype,bitmapStr,dataStr];
    NSLog(@"%@  %@ %@ %@ %@ %@",[self ToBHex:(int)[allStr length]/2],tpdu,header,exchangetype,bitmapStr,dataStr);
    return [NSString stringWithFormat:@"%@%@",[self ToBHex:(int)[allStr length]/2],allStr];
}


+(NSString *)IC_receiveArr:(NSArray *)arr  Tpdu:(NSString *)tpdu Header:(NSString *)header ExchangeType:(NSString *)exchangetype DataArr:(NSArray *)dataarr{
    
    NSString *bitmapStr=[self returnBitmap:arr];
    NSLog(@"位图======%@",bitmapStr);
    
    NSString *dataStr=[dataarr componentsJoinedByString:@""];
    NSString *allStr=[NSString stringWithFormat:@"%@%@%@%@%@",tpdu,header,exchangetype,bitmapStr,dataStr];
    return [NSString stringWithFormat:@"0%d%@",(int)[allStr length]/2,allStr];
}


//十进制转16进制
+(NSString *)ToBHex:(int)tmpid{
    //NSLog(@"tmpid=====%d",tmpid);
    NSString *endtmp=@"";
    NSString *nLetterValue;
    NSString *nStrat;
    int ttmpig=tmpid%16;
    int tmp=tmpid/16;
    switch (ttmpig)
    {
        case 10:
            nLetterValue =@"A";break;
        case 11:
            nLetterValue =@"B";break;
        case 12:
            nLetterValue =@"C";break;
        case 13:
            nLetterValue =@"D";break;
        case 14:
            nLetterValue =@"E";break;
        case 15:
            nLetterValue =@"F";break;
        default:nLetterValue=[[NSString alloc]initWithFormat:@"%i",ttmpig];
            
    }
    switch (tmp)
    {
        case 10:
            nStrat =@"A";break;
        case 11:
            nStrat =@"B";break;
        case 12:
            nStrat =@"C";break;
        case 13:
            nStrat =@"D";break;
        case 14:
            nStrat =@"E";break;
        case 15:
            nStrat =@"F";break;
        default:nStrat=[[NSString alloc]initWithFormat:@"%i",tmp];
            
    }
    endtmp=[[NSString alloc]initWithFormat:@"%@%@",nStrat,nLetterValue];
    NSString *str=@"";
    if([endtmp length]<4)
    {
        for (int x=[endtmp length]; x<4; x++) {
            str=[str stringByAppendingString:@"0"];
        }
        endtmp=[[NSString alloc]initWithFormat:@"%@%@",str,endtmp];
    }
    return endtmp;
}


//(DL_UINT8)((DL_ASCHEX_2_NIBBLE(dataPtr[0]) << 4) |
//DL_ASCHEX_2_NIBBLE(dataPtr[1])         )



char uniteBytes(char a,char b)
{
    char c1 = (a-'0') << 4;
    char c2 =b-'0';
    return c1+c2;
//    char c = (int(a-'0') << 4)+ b-'0';
//    return c;
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
    int len = strlen(accno);
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


/*
-(void)getHPin:(char *)pin code:(char *)encode{
    encode[0] = 6;
    encode[1] = uniteBytes(pin[0], pin[1]);
    encode[2] = uniteBytes(pin[2], pin[3]);
    encode[3] = uniteBytes(pin[4], pin[5]);
    encode[4] = 255;
    encode[5] = 255;
    encode[6] = 255;
    encode[7] = 255;
}

-(char *)getHAccno:(char *)accno code:(char *)encode{
    int len = strlen(accno);
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

-(void)process:(char *)pin acc:(char *)accno ret:(char *)pHexRet{
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
 */



@end
