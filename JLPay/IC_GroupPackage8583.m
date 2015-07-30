//
//  IC_GroupPackage8583.m
//  PosN38Universal
//
//  Created by work on 14-10-21.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import "IC_GroupPackage8583.h"
#import "HeaderString.h"
#import "Define_Header.h"
#import "Unpacking8583.h"
#import "DesUtil.h"
#import "EncodeString.h"
#import "PublicInformation.h"

@implementation IC_GroupPackage8583


+(NSString *)returenKey{
    NSString *str22=[[Unpacking8583 getInstance] threeDESdecrypt:Blue_Suppay_Content keyValue:Blue_Main_Key];
    NSLog(@"根秘钥明文====%@",str22);
    //052344DBA3DABBE2
    //DA1993F7ADEED201
    NSString *snStr=[[NSUserDefaults standardUserDefaults] valueForKey:Blue_Device_CSN];
    NSString *str1=[DesUtil encryptUseDES:snStr key:[str22 substringWithRange:NSMakeRange(0, [str22 length]/2)]];
    NSString *str222=[DesUtil encryptUseDES:snStr key:[str22 substringWithRange:NSMakeRange([str22 length]/2, [str22 length]/2)]];
    NSLog(@"解密key======%@",[NSString stringWithFormat:@"%@%@",str1,str222]);
    return [NSString stringWithFormat:@"%@%@",str1,str222];
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

+(NSString *)return55Info:(NSString *)string{
    //NSString *haystack = @"9F26089770666C4511BE399F37040E6100009F360200FB82027C00950580000008009F330390C8C09F101307010103A0A000010A0100000000001996E5739F02060000000000019F03060000000000009F1A0201565F2A0201569A031410149C01009F2701809F34033F00009F3501229F1E0831323334353637388408A0000003330101019F090200209F41040000000180000000000000";
    NSLog(@"string=====%@",string);
    NSString *needle = @"80";
    NSRange range = [string rangeOfString:needle options:NSBackwardsSearch];  //NSBackwardsSearch 倒序查找
    if (range.location == NSNotFound)
    {
        /* Could NOT find needle in haystack */
    } else {
        /* Found the needle in the haystack */
        NSLog(@"Found %@ in %@ at location %lu",
              needle,
              string,
              (unsigned long)range.location);
    }
    NSString *frontStr = [string substringToIndex:range.location];
    NSLog(@"frontStr====%@",frontStr);
    
    NSString *newStr=@"";
    if ([frontStr length] %2 > 0) {//奇数
       newStr=[NSString stringWithFormat:@"0%d%@0",[frontStr length]/2+1,frontStr];
    }else{//偶数
        newStr=[NSString stringWithFormat:@"0%d%@",[frontStr length]/2,frontStr];
    }
    
    return newStr;//[NSString stringWithFormat:@"0%d%@",[frontStr length]/2,frontStr];
    //return @"01239F26081C019F8590B8D1679F2701809F101307010103A0A000010A010000000000141F54719F37045D2C25009F3602009C82027C00950580000008009A031410149C01319F02060000000000005F2A0201569F1A0201569F03060000000000009F330390C8C09F34033F00009F3501229F1E083132333435363738";//8408A0000003330101019F09020020//246/2
    /*
     NSString *str = @"9F26089770666C4511BE399F37040E6100009F360200FB82027C00950580000008009F330390C8C09F101307010103A0A000010A0100000000001996E5739F02060000000000019F03060000000000009F1A0201565F2A0201569A031410149C01009F2701809F34033F00009F3501229F1E0831323334353637388408A0000003330101019F090200209F41040000000180000000000000";
     NSArray *arr2 = [str componentsSeparatedByString:@"80"];
     NSAssert(arr2.count >= 2, @"str error");
     NSString *retStr = [@"80" stringByAppendingString:arr2[arr2.count - 1]];
     NSLog(@"retStr %@", retStr);
     */
    
    /*
     
     NSLog(@"string========%@",string);
     NSArray *tagArr=[NSArray arrayWithObjects:
     @"9F26",@"9F27",@"9F10",@"9F37",@"9F36",@"95",@"9A",@"9C",@"9F02",@"5F2A",@"82",@"9F1A",@"9F03",@"9F33",@"9F34",@"9F35",@"9F1E",@"84",@"9F09",@"9F41",
     nil];
     NSString *contentLengthStr;
     NSString *contentstr;
     
     NSMutableArray *muArr=[[NSMutableArray alloc] init];
     for (int i=0; i<[tagArr count]; i++) {
     
     NSRange range = [string rangeOfString:[tagArr objectAtIndex:i]];
     if (range.length > 0) {
     NSLog(@"tag====%@",[tagArr objectAtIndex:i]);
     contentLengthStr=[string substringWithRange:NSMakeRange(range.location+[[tagArr objectAtIndex:i] length], 2)];
     NSLog(@"contentLengthStr======%@",contentLengthStr);
     if ([[tagArr objectAtIndex:i] isEqualToString:@"9F10"]) {
     contentstr=[string substringWithRange:NSMakeRange(range.location+range.length+2, [contentLengthStr intValue]*2+12)];
     }
     
     else if ([[tagArr objectAtIndex:i] isEqualToString:@"82"]) {
     if ([contentLengthStr intValue] > 2) {
     contentstr=@"";
     }else{
     contentstr=[string substringWithRange:NSMakeRange(range.location+range.length+2, [contentLengthStr intValue]*2)];
     }
     }
     
     else{
     contentstr=[string substringWithRange:NSMakeRange(range.location+range.length+2, [contentLengthStr intValue]*2)];
     }
     
     [muArr addObject:[NSString stringWithFormat:@"%@%@%@",[tagArr objectAtIndex:i],contentLengthStr,contentstr]];
     }
     NSLog(@"位置====%d====%d",range.location,range.length);
     }
     NSLog(@"muArr======%@",muArr);
     
     NSString *allString=[muArr componentsJoinedByString:@""];
     NSLog(@"555555=====%@",[NSString stringWithFormat:@"0%d%@",[allString length]/2,allString]);
     return [NSString stringWithFormat:@"0%d%@",[allString length]/2,allString];
     
     */
}


//mac校验证
+(NSArray *)IC_getNewPinAndMac:(NSArray *)arr exchange:(NSString *)typestr bitmap:(NSString *)bitstr type:(int)typ
{
    //NSLog(@"原始数据====%@",arr);
    //mac校验数据
    NSString *allStr=[NSString stringWithFormat:@"%@%@%@",typestr,bitstr,[arr componentsJoinedByString:@""]];
    NSLog(@"allStr====%@,=====%d",allStr,[allStr length]);
    int len = allStr.length;
    int other = len % 16;
    
    NSMutableArray *numArr=[[NSMutableArray alloc] init];
    if (other != 0) {
        for (int i=0; i< (16-other); i++) {
            [numArr addObject:@"0"];
        }
    }
    NSString *newAllStr=[NSString stringWithFormat:@"%@%@",allStr,[numArr componentsJoinedByString:@""]];
    NSLog(@"newAllStr=====%@=====%d",newAllStr,[newAllStr length]);
    
    NSData *btData=[PublicInformation NewhexStrToNSData:newAllStr];
    NSLog(@"btData====%@",btData);
    Byte *bt=(Byte *)[btData bytes];
    
    Byte mac[8];
    Byte temp[8];
    int z = 0;
    
    for (int i = 0; i < 8; i++) {
        mac[i] = bt[i];
    }
    // 循环异或
    for (int i = 8; i <= [btData length]; i++, z++) {
        if ((i != 8) && (i % 8 == 0)) {
            for (int j = 0; j < 8; j++) {
                mac[j] = (Byte) (mac[j] ^ temp[j]);
            }
            NSLog(@"mac===========%@",[[NSData alloc] initWithBytes:mac length:sizeof(mac)]);
            z = 0;
            memset(&temp, 0, sizeof(temp));
        }
        if (i != btData.length) {
            temp[z] = bt[i];
        }
    }
    
    NSData *newData = [[NSData alloc] initWithBytes:mac length:sizeof(mac)];
    NSLog(@"newData====%@",newData);
    
    NSString *newStr=[EncodeString encodeASC:[PublicInformation stringWithHexBytes2:newData]];
    NSLog(@"newStr====%@",newStr);
    
    NSString *leftString=[newStr substringWithRange:NSMakeRange(0, 16)];
    NSString *rightString=[newStr substringWithRange:NSMakeRange(16, [newStr length]-16)];
    
//参数更新
    NSString *passKey=@"";
    if (typ == 1) {
        passKey=@"D4A372400FDCAB7A4817643301CF9E6C";
    }else{
        passKey=[PublicInformation signinMac];
    }
    NSLog(@"passKey=====%@",passKey);
    //mack签到明文
    //双倍des加密
    NSString *left3descryptStr=[[Unpacking8583 getInstance] threeDesEncrypt:leftString keyValue:passKey];
    //NSLog(@"left3descryptStr====%@",left3descryptStr);
    
    //异或运算,rightString,left3descryptStr
    
    Byte *left=(Byte *)[[PublicInformation NewhexStrToNSData:left3descryptStr] bytes];
    Byte *right=(Byte *)[[PublicInformation NewhexStrToNSData:rightString] bytes];
    
    Byte pwdPlaintext[8];
    for (int i = 0; i < 8; i++) {
        pwdPlaintext[i] = (Byte)(left[i] ^ right[i]);
    }
    
    NSData *theData = [[NSData alloc] initWithBytes:pwdPlaintext length:sizeof(pwdPlaintext)];
    NSString *resultStr=[PublicInformation stringWithHexBytes2:theData];
    //NSLog(@"异或结果%@",resultStr);
    
    //双倍des加密
    NSString *str=[[Unpacking8583 getInstance] threeDesEncrypt:resultStr keyValue:passKey];
    //NSLog(@"3des====%@",str);
    NSLog(@"mac======%@",[str substringWithRange:NSMakeRange(0, 8)]);
    NSString *macStr=[EncodeString encodeASC:[str substringWithRange:NSMakeRange(0, 8)]];
    NSMutableArray *newArr=[[NSMutableArray alloc] initWithArray:arr];
    if (![typestr isEqualToString:@"0320"]) {
        [newArr addObject:macStr];
    }
    NSLog(@"添加mac校验64域====%@",newArr);
    for (int i=0; i<[newArr count]; i++) {
        NSLog(@"aaaaa=%@",[newArr objectAtIndex:i]);
    }
    return newArr;
}
/*
{
    NSLog(@"原始数据====%@",arr);
    //mac校验数据
    NSString *allStr=[NSString stringWithFormat:@"%@%@%@",typestr,bitstr,[arr componentsJoinedByString:@""]];
    NSLog(@"allStr====%@,=====%d",allStr,[allStr length]);
    int len = allStr.length;
    int other = len % 16;
    
    NSMutableArray *numArr=[[NSMutableArray alloc] init];
    if (other != 0) {
        for (int i=0; i< (16-other); i++) {
            [numArr addObject:@"0"];
        }
    }
    NSString *newAllStr=[NSString stringWithFormat:@"%@%@",allStr,[numArr componentsJoinedByString:@""]];
    NSLog(@"newAllStr=====%@=====%d",newAllStr,[newAllStr length]);
    
    NSData *btData=[PublicInformation NewhexStrToNSData:newAllStr];
    NSLog(@"length====%dbtData====%@",[btData length],btData);
    Byte *bt=(Byte *)[btData bytes];
    
    Byte mac[8];
    Byte temp[8];
    int z = 0;
    
    for (int i = 0; i < 8; i++) {
        mac[i] = bt[i];
    }
    // 循环异或
    for (int i = 8; i <= [btData length]; i++, z++) {
        if ((i != 8) && (i % 8 == 0)) {
            for (int j = 0; j < 8; j++) {
                mac[j] = (Byte) (mac[j] ^ temp[j]);
                NSLog(@"mac===========%@",[[NSData alloc] initWithBytes:mac length:sizeof(mac)]);
            }
            z = 0;
            memset(&temp, 0, sizeof(temp));
        }
        if (i != btData.length) {
            temp[z] = bt[i];
        }
    }
    
    NSData *newData = [[NSData alloc] initWithBytes:mac length:sizeof(mac)];
    NSLog(@"newData====%@",newData);
    
    NSString *newStr=[EncodeString encodeASC:[PublicInformation stringWithHexBytes2:newData]];
    NSLog(@"newStr====%@",newStr);
    
    NSString *leftString=[newStr substringWithRange:NSMakeRange(0, 16)];
    NSString *rightString=[newStr substringWithRange:NSMakeRange(16, [newStr length]-16)];
    //mack签到明文
    //双倍des加密
    NSString *left3descryptStr=[[Unpacking8583 getInstance] threeDesEncrypt:leftString keyValue:@"D4A372400FDCAB7A4817643301CF9E6C"];
    NSLog(@"left3descryptStr====%@",left3descryptStr);
    
    //异或运算,rightString,left3descryptStr
    
    Byte *left=(Byte *)[[PublicInformation NewhexStrToNSData:left3descryptStr] bytes];
    Byte *right=(Byte *)[[PublicInformation NewhexStrToNSData:rightString] bytes];
    
    Byte pwdPlaintext[8];
    for (int i = 0; i < 8; i++) {
        pwdPlaintext[i] = (Byte)(left[i] ^ right[i]);
    }
    
    NSData *theData = [[NSData alloc] initWithBytes:pwdPlaintext length:sizeof(pwdPlaintext)];
    NSString *resultStr=[PublicInformation stringWithHexBytes2:theData];
    NSLog(@"异或结果%@",resultStr);
    
    //双倍des加密
    NSString *str=[[Unpacking8583 getInstance] threeDesEncrypt:resultStr keyValue:[PublicInformation signinMac]];
    NSLog(@"3des====%@",str);
    NSLog(@"mac======%@",[str substringWithRange:NSMakeRange(0, 8)]);
    NSString *macStr=[EncodeString encodeASC:[str substringWithRange:NSMakeRange(0, 8)]];
    NSMutableArray *newArr=[[NSMutableArray alloc] initWithArray:arr];
    [newArr addObject:macStr];
    NSLog(@"添加mac校验64域====%@",newArr);
    for (int i=0; i<[newArr count]; i++) {
        NSLog(@"aaaaa=%@",[newArr objectAtIndex:i]);
    }
    return newArr;
}
*/

+(NSString *)blue_deviceRefreshData:(NSString *)terminalStr{
    NSLog(@"terminalStr====%@",terminalStr);
    //3800006472
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  [PublicInformation exchangeNumber],//11受卡方系统跟踪号(流水号)
                  Blue_IC_PiciNmuber,//56,批次号bcd 6
                  [NSString stringWithFormat:@"%@%@",[PublicInformation ToBHex:[terminalStr length]],[EncodeString encodeASC:terminalStr]],//61,pos序列号 asc 不定长999
                  nil];
    NSLog(@"参数更新=====%@",arr);
    //二进制报文数据
    NSArray *bitmapArr=[NSArray arrayWithObjects:@"11",@"56",@"61",@"64", nil];
    NSString *binaryDataStr=[HeaderString receiveArr:bitmapArr
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0820"
                                             DataArr:[self IC_getNewPinAndMac:arr exchange:@"0820" bitmap:[HeaderString returnBitmap:bitmapArr] type:1]];
    return binaryDataStr;
}


//pos状态上送_公钥下载/参数下载ic
//1,公钥下载；2，参数下载

+(NSString *)blue_StatusSend:(int)type{
    NSString *sendType=@"";
    if (1 == type) {
       sendType=@"372";
    }else{
       sendType=@"382";
    }
//60域数据
    NSString *betweenStr;
    NSString *ascStr=[NSString stringWithFormat:@"%@%@%@",[EncodeString encodeASC:@"00"],[EncodeString encodeASC:Blue_IC_PiciNmuber],[EncodeString encodeASC:sendType]];
    betweenStr=[NSString stringWithFormat:@"00%d%@",[ascStr length]/2,ascStr];
    NSLog(@"60域数据=====%@",betweenStr);
    
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],//41终端号asc
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],//42商户号asc
                  betweenStr,//60,自定义域(60.1,60.2,60.3  交易类型码，批次号,网络管理信息码)压缩成BCD码占两个字节+最大13个字节的数字字符域
                  [NSString stringWithFormat:@"000%d%@",[[EncodeString encodeASC:@"100"] length]/2,[EncodeString encodeASC:@"100"]], nil];//62终端状态信息(BCD码表示的2个字节的长度值+数据域)
    NSLog(@"pos状态上送====%@",arr);
    
    //二进制报文数据
    NSString *binaryDataStr=[HeaderString receiveArr:[NSArray arrayWithObjects:@"41",@"42",@"60",@"62",nil]
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0920"
                                             DataArr:arr];
    NSLog(@"pos状态上送数据包======%@",binaryDataStr);
    return binaryDataStr;
}


//pos参数传递_公钥下载/参数下载ic
+(NSString *)blue_ParameterSend:(int)type{
    NSString *sendType=@"";
    NSString *tlvStr=@"";
    if (1 == type) {
        sendType=@"370";
        tlvStr=[[NSUserDefaults standardUserDefaults] valueForKey:BlueIC_GongyaoLoad_TLV];
    }else{
        sendType=@"380";
        tlvStr=[[NSUserDefaults standardUserDefaults] valueForKey:BlueIC_ParameterLoad_TLV];
    }
    //60域数据
    NSString *betweenStr;
    NSString *ascStr=[NSString stringWithFormat:@"%@%@%@",[EncodeString encodeASC:@"00"],[EncodeString encodeASC:Blue_IC_PiciNmuber],[EncodeString encodeASC:sendType]];
    betweenStr=[NSString stringWithFormat:@"00%d%@",[ascStr length]/2,ascStr];
    NSLog(@"60域数据=====%@",betweenStr);
    
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],//41终端号asc
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],//42商户号asc
                  betweenStr,//60,自定义域(60.1,60.2,60.3  交易类型码，批次号,网络管理信息码)压缩成BCD码占两个字节+最大13个字节的数字字符域
                  tlvStr, nil];//62终端状态信息
    NSLog(@"pos状态上送====%@",arr);
    
    //二进制报文数据
    NSString *binaryDataStr=[HeaderString receiveArr:[NSArray arrayWithObjects:@"41",@"42",@"60",@"62",nil]
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0900"
                                             DataArr:arr];
    NSLog(@"pos状态上送数据包======%@",binaryDataStr);
    return binaryDataStr;
}



//pos公钥下载结束/参数下载结束ic
+(NSString *)blue_GongyaoDownload:(int)type{
    NSString *sendType=@"";
    if (1 == type) {
        sendType=@"371";
    }else{
        sendType=@"381";
    }
//60域数据
    NSString *betweenStr;
    NSString *ascStr=[NSString stringWithFormat:@"%@%@%@",[EncodeString encodeASC:@"00"],[EncodeString encodeASC:Blue_IC_PiciNmuber],[EncodeString encodeASC:sendType]];
    betweenStr=[NSString stringWithFormat:@"00%d%@",[ascStr length]/2,ascStr];
    NSLog(@"60域数据=====%@",betweenStr);
    
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],//41终端号asc
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],//42商户号asc
                  betweenStr,//60,自定义域(60.1,60.2,60.3  交易类型码，批次号,网络管理信息码)压缩成BCD码占两个字节+最大13个字节的数字字符域
                  nil];//62终端状态信息(BCD码表示的2个字节的长度值+数据域)
    NSLog(@"公钥下载结束====%@",arr);
    
    //二进制报文数据
    NSString *binaryDataStr=[HeaderString receiveArr:[NSArray arrayWithObjects:@"41",@"42",@"60",nil]
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0940"
                                             DataArr:arr];
    NSLog(@"公钥下载结束数据包======%@",binaryDataStr);
    return binaryDataStr;
}

//签到
+(NSString *)blue_signin_IC{
    //60域数据
    NSString *betweenStr;
    NSString *ascStr=[NSString stringWithFormat:@"%@%@%@",[EncodeString encodeASC:@"00"],[EncodeString encodeASC:Blue_IC_PiciNmuber],[EncodeString encodeASC:@"003"]];
    betweenStr=[NSString stringWithFormat:@"00%d%@",[ascStr length]/2,ascStr];
    NSLog(@"60域数据=====%@",betweenStr);
    //63域
    NSString *productNumStr=[NSString stringWithFormat:@"%@",[EncodeString encodeASC:Manager_Number]];
    productNumStr=[NSString stringWithFormat:@"00%d%@",[productNumStr length]/2,productNumStr];
    NSLog(@"63域数据=====%@",productNumStr);
    
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  [PublicInformation exchangeNumber],//流水号bcd
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],//41终端号asc
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],//42商户号asc
                  Blue_IC_PiciNmuber,//56 bcd 批次号
                  betweenStr,//60,自定义域(60.1,60.2,60.3  交易类型码，批次号,网络管理信息码)压缩成BCD码占两个字节+最大13个字节的数字字符域
                  //@"",//62终端信息 终端密钥
                  productNumStr,nil];//63,63.1,操作员号 压缩成BCD码占两个字节+用ASCII码表示的最大163个字节的数据
    NSLog(@"pos状态上送====%@",arr);
    
    //二进制报文数据
    NSString *binaryDataStr=[HeaderString receiveArr:[NSArray arrayWithObjects:@"11",@"41",@"42",@"56",@"60",@"63",nil]
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0800"
                                             DataArr:arr];
    NSLog(@"pos状态上送数据包======%@",binaryDataStr);
    return binaryDataStr;
}

//金额转换
+(NSString *)themoney{
    int money=[[PublicInformation returnMoney] floatValue]*100;
    return [NSString stringWithFormat:@"%012d",money];
}

//消费
+(NSString *)blue_consumer_IC:(NSString *)pin{
    //55域
    NSString *info55Data=[[NSUserDefaults standardUserDefaults] valueForKey:BlueIC55_Information];
    //60域数据
    NSString *betweenStr =[NSString stringWithFormat:@"001922%@000500000000", [PublicInformation returnSignSort]];
    NSLog(@"消费60域数据=====%@",betweenStr);
    NSString* liushuihao = [[NSUserDefaults standardUserDefaults] valueForKey:Current_Liushui_Number];
//    NSString* liushuihao = [PublicInformation exchangeNumber];
    
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  // 2,卡号
                  [PublicInformation returnCard:[PublicInformation returnposCard]],
                  // 3,交易处理码 bcd 6(银联协议)
                  @"190000",
                  // 4,交易金额 bcd 12
                  [self themoney],//@"000000000001",
                  // 11,流水号 bcd 6
                  liushuihao,
                  // 14 有效期
                  [[NSUserDefaults standardUserDefaults] valueForKey:Card_DeadLineTime],
                  // 22,服务点输入方式码 bcd 3(银联协议)
                  @"0510",
                  // 23,卡片序列号 bcd 3 （pos能判断时存在）
                  [PublicInformation returnICCardSeqNo],
                  // 25,服务点条件码 bcd 2
                  @"82",
                  // 26,服务点pin获取码 bcd 2
                  @"12",
                  // 35,二磁道数据，asc，不定长37，(pos获取时存在)
                  [NSString stringWithFormat:@"%d%@",
                                    (int)[[PublicInformation returnTwoTrack] length]/2,
                                    [PublicInformation returnTwoTrack]],
                  // 41终端号asc
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],
                  // 42商户号asc
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],
                  // 49，货币代码，asc，定长3，（人民币156）
                  [EncodeString encodeASC:@"156"],
                  // 52，个人识别码，PIN，定长8，
                  pin,
                  // 53
                  @"2600000000000000",
                  // 55
                  [NSString stringWithFormat:@"%04d%@", (int)info55Data.length/2, info55Data],
                  // 60,自定义域
//                  betweenStr,
                  [self makeF60],
                  nil];
    NSLog(@"IC——消费====%@",arr);
    NSArray *bitmapArr=[NSArray arrayWithObjects:@"2",@"3",@"4",@"11",@"14",@"22",@"23",@"25",@"26",@"35",@"41",@"42",@"49",@"52",@"53",@"55",@"60",@"64",nil];
    
    // 上送交易前先保存当前消费的部分字段,用于冲正、撤销、批上送
    [[NSUserDefaults standardUserDefaults] setValue:@"190000" forKey:LastF03_ProcessingCode];
    [[NSUserDefaults standardUserDefaults] setValue:@"0510" forKey:LastF22_ServiceEntryCode];
    [[NSUserDefaults standardUserDefaults] setValue:betweenStr forKey:LastF60_Reserved];
    [[NSUserDefaults standardUserDefaults] setValue:liushuihao forKey:LastF11_SystemTrace];
    [[NSUserDefaults standardUserDefaults] setValue:liushuihao forKey:Last_Exchange_Number];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    //二进制报文数据
    NSString *binaryDataStr=[HeaderString receiveArr:bitmapArr
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0200"
                                             DataArr:[self IC_getNewPinAndMac:arr exchange:@"0200" bitmap:[HeaderString returnBitmap:bitmapArr] type:2]];
    NSLog(@"IC——消费数据包======%@",binaryDataStr);
    return binaryDataStr;
}


#pragma mark-----------bbpos卡片序列号无法获取，蓝牙卡头卡片序列号可以获取
//余额查询
+(NSString *)blue_searchMoney_IC:(NSString *)pin{
    //55域
    NSString *info55Data=[[NSUserDefaults standardUserDefaults] valueForKey:BlueIC55_Information];
    //60域数据
    NSString *betweenStr;
    NSString *ascStr=[NSString stringWithFormat:@"%@%@%@",[EncodeString encodeASC:@"01"],[EncodeString encodeASC:[PublicInformation returnSignSort]],[EncodeString encodeASC:@"00560"]];
    betweenStr=[NSString stringWithFormat:@"00%d%@",[ascStr length]/2,ascStr];
    //betweenStr=@"0013 3031 303030303031 3030353630";
    NSLog(@"余额查询60域=====%@",betweenStr);
    //2卡号
    //卡序列号
    NSString *cardSN=[NSString stringWithFormat:@"00%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"masterSNN"]];
    NSLog(@"cardSN=====%@",cardSN);
//14，卡有效期
    NSString *cardTime=[[NSUserDefaults standardUserDefaults] valueForKey:Card_DeadLineTime];
    NSLog(@"cardTime======%@",cardTime);
    
    NSArray *arr;
    arr=[[NSArray alloc] initWithObjects:
                  [PublicInformation returnCard:[PublicInformation returnposCard]],//2,卡号
                  @"310000",//3,交易处理码 bcd 6(银联协议)
                  [PublicInformation exchangeNumber],//11,流水号 bcd 6
                  cardTime,//14,bcd,4([cardTime length] > 0 ? cardTime:nil),//cardTime,
                  @"0510",//22,服务点输入方式码 bcd 3(银联协议)
                  cardSN,//23,卡片序列号 bcd 3 （pos能判断时存在）
                  @"00",//25,服务点条件码
                  @"12",//26,服务点pin获取码 bcd 2
                  [NSString stringWithFormat:@"%d%@",[[EncodeString encodeASC:[PublicInformation returnTwoTrack]] length]/2,[EncodeString encodeASC:[PublicInformation returnTwoTrack]]],//35,二磁道数据，asc，不定长37，(pos获取时存在)
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],//41终端号asc
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],//42商户号asc
                  [EncodeString encodeASC:@"156"],//49，货币代码，asc，定长3，（人民币156）
                  pin,//52，个人识别码，PIN，定长8，
                  @"2600000000000000",//53,n16,bcd 有安全要求或词条信息出现时必选
                  info55Data,//55
                  [PublicInformation returnSignSort],//56 bcd 批次号
                  betweenStr,//60,自定义域(60.1,60.2,60.3  交易类型码，批次号,网络管理信息码)压缩成BCD码占两个字节+最大13个字节的数字字符域
                  nil];
    NSLog(@"IC——查询余额====%@",arr);//([cardTime length] > 0 ? @"14":nil)
    NSArray *bitmapArr=[NSArray arrayWithObjects:@"2",@"3",@"11",@"14",@"22",@"23",@"25",@"26",@"35",@"41",@"42",@"49",@"52",@"53",@"55",@"56",@"60",@"64",nil];
    
    //二进制报文数据
    NSString *binaryDataStr=[HeaderString receiveArr:bitmapArr
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0100"
                                             DataArr:[self IC_getNewPinAndMac:arr exchange:@"0100" bitmap:[HeaderString returnBitmap:bitmapArr] type:2]];
    
    return binaryDataStr;//[binaryDataStr lowercaseStringWithLocale:[NSLocale currentLocale]];
}

//消费撤销
+(NSString *)blue_consumeRepeal:(NSString *)pin liushui:(NSString *)liushuiStr money:(NSString *)moneyStr{
    
    //55域
    NSString *info55Data=[[NSUserDefaults standardUserDefaults] valueForKey:BlueIC55_Information];
    //60域数据
    NSString *betweenStr11;
    NSString *ascStr11=[NSString stringWithFormat:@"%@%@%@",[EncodeString encodeASC:@"23"],[EncodeString encodeASC:Blue_IC_PiciNmuber],[EncodeString encodeASC:@"000500"]];
    betweenStr11=[NSString stringWithFormat:@"00%d%@",[ascStr11 length]/2,ascStr11];
    //betweenStr=23000001000500;
    NSLog(@"撤销支付60域=====%@",betweenStr11);
    //63域
    NSString *productNumStr=[NSString stringWithFormat:@"%@",[EncodeString encodeASC:Manager_Number]];
    productNumStr=[NSString stringWithFormat:@"00%d%@",[productNumStr length]/2,productNumStr];
    NSLog(@"63域数据=====%@",productNumStr);
    
    //当前流水号
    NSString *currentLiushuiStr=[[NSUserDefaults standardUserDefaults] valueForKey:Current_Liushui_Number];
    //保存撤销金额
    [[NSUserDefaults standardUserDefaults] setValue:moneyStr forKey:Save_Return_Money];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //61域数据
    NSString *betweenStr;
    NSString *ascStr=[NSString stringWithFormat:@"%@%@",[EncodeString encodeASC:[PublicInformation returnSignSort]],[EncodeString encodeASC:liushuiStr]];
    betweenStr=[NSString stringWithFormat:@"00%d%@",[ascStr length]/2,ascStr];
    NSLog(@"61域数据=====%@",betweenStr);
    
    //卡序列号
    NSString* snn = [[NSUserDefaults standardUserDefaults] valueForKey:ICCardSeq_23];
    if (snn == nil || [snn intValue] == 0) {
        snn = @"01";
    }
    NSString *cardSN=[NSString stringWithFormat:@"00%@",snn];
    
    //当前消费之后搜索参考号是否存在
    NSArray *arr;
    //二进制报文数据
    NSArray *bitmaparr;
    arr=[[NSArray alloc] initWithObjects:
         [PublicInformation returnCard:[PublicInformation returnposCard]],//2 卡号 bcd（不定长19）
         @"310000",//3,交易处理码 bcd 6(银联协议)
         moneyStr,//[PublicInformation returnConsumerMoney],//[self themoney],//4 金额，bcd，定长12
         currentLiushuiStr,//[PublicInformation returnLiushuiHao],//11 bcd,定长6
         @"0520",//22,服务点输入方式码 bcd 3(银联协议)
         cardSN,//23,卡片序列号 bcd 3 （pos能判断时存在）
         @"00",//25,服务点条件码 bcd 2
         //@"12",//26,服务点pin获取码 bcd 2
         //@"",//34,一磁道数据，asc，不定长76，(pos获取时存在)
         [NSString stringWithFormat:@"%d%@",
                        [[PublicInformation returnTwoTrack] length]/2,
                        [PublicInformation returnTwoTrack]],//35，二磁道数据，asc，不定长37，(pos获取时存在)
         //@"",//36，三磁道数据，asc，不定长104，(pos获取时存在)
         [PublicInformation returnConsumerSort],//37,搜索参考号
         @"",//38,授权标示应答码
         [EncodeString encodeASC:[PublicInformation returnTerminal]],//41,终端号，asc，定长8
         [EncodeString encodeASC:[PublicInformation returnBusiness]],//42，商户号，asc，定长15
         [EncodeString encodeASC:@"156"],//49，货币代码，asc，定长3，（人民币156）
         pin,//52，个人识别码，PIN，定长8，(参照附录2)//byte[] byte52 = { 0x5B, 0x59, (byte) 0xEE, (byte) 0xC0, 0x0D, (byte) 0xD5, (byte) 0x86, (byte) 0xBE, };
         info55Data,//55
         [PublicInformation returnSignSort],//56,批次号，bcd，定长6
         betweenStr11,//60
         betweenStr,//(消费的批次号和流水号)61,61.1,61.2,原交易信息，原交易批次号，原交易流水号
         [NSString stringWithFormat:@"%@%@",[PublicInformation ToBHex:3],[EncodeString encodeASC:Manager_Number]],//63,操作员号，asc，不定长999，3字节
         nil];
    //二进制报文数据
    bitmaparr=[NSArray arrayWithObjects:@"2",@"3",@"4",@"11",@"22",@"23",@"25",@"35",@"37",@"38",@"41",@"42",@"49",@"52",@"55",@"56",@"60",@"61",@"63",@"64", nil];
    
    NSLog(@"IC-消费撤销数据====%@",arr);
    NSString *binaryDataStr=[HeaderString receiveArr:bitmaparr
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0220"
                                             DataArr:[self IC_getNewPinAndMac:arr exchange:@"0220" bitmap:[HeaderString returnBitmap:bitmaparr] type:2]];
    NSLog(@"IC-消费撤销=====%@",binaryDataStr);
    return binaryDataStr;
}

//消费冲正(交易异常)
+(NSString *)blue_consumeReturn{
    NSArray *bitmaparr;
    NSString *liushuiStr=[[NSUserDefaults standardUserDefaults] valueForKey:Last_Exchange_Number];
    //61域数据
    NSString *betweenStr;
    NSString *ascStr=[NSString stringWithFormat:@"%@%@",[EncodeString encodeASC:[PublicInformation returnSignSort]],[EncodeString encodeASC:liushuiStr]];
    betweenStr=[NSString stringWithFormat:@"00%d%@",[ascStr length]/2,ascStr];
    
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  [PublicInformation returnCard:[PublicInformation returnposCard]],//2 卡号 bcd（不定长19）
                  [self themoney],//4 金额，bcd，定长12
                  liushuiStr,//11 流水号,bcd,定长6
                  //14,卡有效期,bcd,c1,定长4，pos能获取时存在
                  //22输入模式,BCD,m,定长3
                  //39，返回码，asc，m，定长2，原交易返回码，如存在
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],//41,终端号，asc，定长8
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],//42，商户号，asc，定长15
                  [EncodeString encodeASC:@"156"],//49，货币代码，asc，定长3，（人民币156）
                  [PublicInformation returnSignSort],//56,批次号，bcd，定长6
                  betweenStr,//(消费的批次号和流水号)61,61.1,61.2,原交易信息，原交易批次号，原交易流水号
                  nil];
    
    //二进制报文数据
    bitmaparr=[NSArray arrayWithObjects:@"2",@"4",@"11",@"41",@"42",@"49",@"56",@"61",@"64", nil];
    
    NSLog(@"消费冲正数据====%@",arr);
    NSString *binaryDataStr=[HeaderString receiveArr:bitmaparr
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0400"
                                             DataArr:[self IC_getNewPinAndMac:arr exchange:@"0400" bitmap:[HeaderString returnBitmap:bitmaparr] type:2]];
    NSLog(@"消费冲正=====%@",binaryDataStr);
    return binaryDataStr;
}


/**********************
 * 功  能: 批上传
 *          IC卡交易成功返回后，都要做一次批上传
 **********************/
+(NSString *)uploadBatchTransOfICC { 
    //55域
    NSString *info55Data=[[NSUserDefaults standardUserDefaults] valueForKey:BlueIC55_Information];
    NSString* oldF60 = [[NSUserDefaults standardUserDefaults] valueForKey:LastF60_Reserved];
    //60,   60.3 改为 203 // 0019 22 000000 000 500000000   Reserved Private
    NSString* newF60 = [[oldF60 substringToIndex:12] stringByAppendingString:@"203"];
    newF60 = [newF60 stringByAppendingString:[oldF60 substringFromIndex:15]];
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  //2,卡号
                  [PublicInformation returnCard:[PublicInformation returnposCard]],
                  //3,交易处理码                 -- 跟上一笔交易保持一致  Processing Code
                  [[NSUserDefaults standardUserDefaults] valueForKey:LastF03_ProcessingCode],
                  //4,交易金额 bcd 12
                  [self themoney],//@"000000000001",
                  //11,流水号 bcd 6           -- 跟上一笔交易保持一致    System Trace
                  [[NSUserDefaults standardUserDefaults] valueForKey:LastF11_SystemTrace],
                  //22,服务点输入方式码         -- 跟上一笔交易保持一致    Service Entry Code
                  [[NSUserDefaults standardUserDefaults] valueForKey:LastF22_ServiceEntryCode],
                  //23,卡片                   -- 跟上一笔交易保持一致    Card Sequence Number
                  [PublicInformation returnICCardSeqNo],
                  //25,服务点条件码 bcd 2
                  @"82",
                  //26,服务点pin获取码 bcd 2
                  @"12",
                  //41终端号asc
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],
                  //42商户号asc
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],
                  //49，货币代码，asc，定长3，（人民币156）
                  [EncodeString encodeASC:@"156"],
                  //55                          -- 跟上一笔交易保持一致   IC Card Data
                  [NSString stringWithFormat:@"%04d%@", (int)info55Data.length/2, info55Data],
                  //60,   60.3 改为 203 // 0019 22 000000 000 500000000   Reserved Private
                  newF60,
                  nil];
    NSLog(@"IC——披上送====%@",arr);
    NSArray *bitmapArr=[NSArray arrayWithObjects:@"2",@"3",@"4",@"11",@"22",@"23",@"25",@"26",@"41",@"42",@"49",@"55",@"60",nil];
    
    //二进制报文数据
    NSString *binaryDataStr=[HeaderString receiveArr:bitmapArr
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0320"
                                             DataArr:[self IC_getNewPinAndMac:arr exchange:@"0320" bitmap:[HeaderString returnBitmap:bitmapArr] type:2]]; //type =1 测试用
    NSLog(@"IC—-披上送请求数据======%@",binaryDataStr);
    return binaryDataStr;

}

+ (NSString*) makeF60 {
    NSMutableString* F60 = [[NSMutableString alloc] initWithString:@"0019"];
    NSString* tranType = [PublicInformation returnTranType];
    // 60.1 N2 交易类型
    if ([tranType isEqualToString:TranType_Consume]) {
        [F60 appendString:@"22"];
    } else if ([tranType isEqualToString:TranType_ConsumeRepeal]) {
        [F60 appendString:@"23"];
    }
    // 60.2 N6 批次号
    [F60 appendString:[PublicInformation returnSignSort]];
    // 60.3 N3 操作类型
    [F60 appendString:@"000"];
    // 60.4 N1 磁条:2 , IC : 5 手机端统一送1
    [F60 appendString:@"1"];
    // 60.5 N1 费率:
    NSString* rate = [[NSUserDefaults standardUserDefaults] valueForKey:Key_RateOfPay];
    if (rate == nil || [rate isEqualToString:@""]) {
        rate = @"0";
    }
    [F60 appendString:[rate substringToIndex:1]];
    // 60.6 N4
    [F60 appendString:@"0000"];
    // 60.7 N2
    [F60 appendString:@"00"];
    // 补齐整数位
    [F60 appendString:@"0"];
    return F60;
}


@end
