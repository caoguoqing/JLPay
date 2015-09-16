//
//  GroupPackage8583.m
//  PosN38Universal
//
//  Created by work on 14-8-8.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import "GroupPackage8583.h"

#import "ISOBitmap.h"
#import "ISOHelper.h"
#import "ASCIIString.h"
#import "EncodeString.h"
#import "HeaderString.h"
#import "PublicInformation.h"
#import "Unpacking8583.h"
#import "Define_Header.h"


@implementation GroupPackage8583

+(NSString *)apilyMoney:(NSString *)mon{
    int money=[mon floatValue]*100;
    return [NSString stringWithFormat:@"%012d",money];
}









/************************
 *  签到报文: 会上送到后台
 *************************/
+(NSString *)signIn{
    
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  @"000001",                                                        //11 流水号,bcd,定长6
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],      //41 终端号，asc，定长8
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],      //42 商户号，asc，定长15
                  @"0011000000040030",                                              //60
                  [NSString stringWithFormat:@"%@%@",[PublicInformation ToBHex:3],[EncodeString encodeASC:Manager_Number]],
                  nil];                                                             //63 操作员号asc，不定长999，三位数字
    NSLog(@"签到数据====%@",arr);
    
    // 将准备好的签到数据打成报文: 二进制报文数据
    NSString *binaryDataStr=[HeaderString receiveArr:[NSArray arrayWithObjects:@"11",@"41",@"42",@"60",@"63", nil]
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0800"
                                             DataArr:arr];
    return binaryDataStr;
}


/************************
 *  金额转换
 *************************/
+(NSString *)themoney{
    int money=[[PublicInformation returnMoney] floatValue]*100;
    NSLog(@"*****money****%d*******",money);
    return [NSString stringWithFormat:@"%012d",money];
}




/************************
 *  mac校验证
 *************************/
+(NSArray *)getNewPinAndMac:(NSArray *)arr
                   exchange:(NSString *)typestr
                     bitmap:(NSString *)bitstr{
    //mac校验数据
    // 交易类型+map+所有域的值组成字符串
    NSString *allStr=[NSString stringWithFormat:@"%@%@%@",typestr,bitstr,[arr componentsJoinedByString:@""]];
    int len = (int)allStr.length;
    int other = len % 16;
    // 如不为16的倍数,补零
    NSMutableArray *numArr=[[NSMutableArray alloc] init];
    if (other != 0) {
        for (int i=0; i< (16-other); i++) {
            [numArr addObject:@"0"];
        }
    }
    NSString *newAllStr=[NSString stringWithFormat:@"%@%@",allStr,[numArr componentsJoinedByString:@""]];
    // 域值所有串转为data
    NSData *btData=[PublicInformation NewhexStrToNSData:newAllStr];
    Byte *bt=(Byte *)[btData bytes];
    
    Byte mac[8];
    Byte temp[8];
    int z = 0;
    // 取前8个字节串
    for (int i = 0; i < 8; i++) {
        mac[i] = bt[i];
    }
    // 然后跟后面每8个字节进行异或运算
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
    
    // 最终的运算结果数据转换成ASC字符串
    NSString *newStr=[EncodeString encodeASC:[PublicInformation stringWithHexBytes2:newData]];
    NSLog(@"newStr====%@",newStr);
    
    // 取前16位跟后16位
    NSString *leftString=[newStr substringWithRange:NSMakeRange(0, 16)];
    NSString *rightString=[newStr substringWithRange:NSMakeRange(16, [newStr length]-16)];
    
    //双倍des加密 前16位
    NSLog(@"MAC密钥:%@",[PublicInformation signinMac]);
    NSString *left3descryptStr=[[Unpacking8583 getInstance] threeDesEncrypt:leftString keyValue:[PublicInformation signinMac]];
    NSLog(@"left3descryptStr====%@",left3descryptStr);
    
    // 加密的数据跟后16位进行异或
    Byte *left=(Byte *)[[PublicInformation NewhexStrToNSData:left3descryptStr] bytes];
    Byte *right=(Byte *)[[PublicInformation NewhexStrToNSData:rightString] bytes];
    Byte pwdPlaintext[8];
    for (int i = 0; i < 8; i++) {
        pwdPlaintext[i] = (Byte)(left[i] ^ right[i]);
    }
    NSData *theData = [[NSData alloc] initWithBytes:pwdPlaintext length:sizeof(pwdPlaintext)];
    NSString *resultStr=[PublicInformation stringWithHexBytes2:theData];
    NSLog(@"异或结果%@",resultStr);
    
    // 异或运算后的结果再次进行双倍DES加密
    NSString *str=[[Unpacking8583 getInstance] threeDesEncrypt:resultStr keyValue:[PublicInformation signinMac]];
    NSLog(@"3des====%@",str);
    NSLog(@"mac======%@",[str substringWithRange:NSMakeRange(0, 8)]);
    NSString *macStr=[EncodeString encodeASC:[str substringWithRange:NSMakeRange(0, 8)]];
    NSMutableArray *newArr=[[NSMutableArray alloc] initWithArray:arr];
    
    // 将最后加密后的数据转换成ASC串打包到报文数组
    [newArr addObject:macStr];
    NSLog(@"添加mac校验64域====%@",newArr);
    for (int i=0; i<[newArr count]; i++) {
        NSLog(@"aaaaa=%@",[newArr objectAtIndex:i]);
    }
    return newArr;
}


/************************
 *  公钥下发
 *************************/
+(NSString *)downloadPublicKey{
    
    NSArray *arr=[[NSArray alloc] initWithObjects:
                 
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],//41,终端号，asc，定长8
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],//42，商户号，asc，定长15

                  @"0011960000034000",//60,
                  @"00129f0605df000000049f220101",//62,


                  nil];

    NSLog(@"公钥下发请求数据=====%@",arr);
    //二进制报文数据
    NSArray *bitmapArr=[NSArray arrayWithObjects:@"41",@"42",@"60",@"62", nil];
    NSString *binaryDataStr=[HeaderString receiveArr:bitmapArr
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0800"
                                             DataArr:arr];
    NSLog(@"binaryDataStr=====%@",binaryDataStr);
    return binaryDataStr;
}



//主密钥下发
+(NSString *)downloadMainKey{
    NSString* liushuiStr = [PublicInformation exchangeNumber];
    [[NSUserDefaults standardUserDefaults] setValue:liushuiStr forKey:Last_Exchange_Number];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  
                  liushuiStr,//11 流水号,bcd,定长6
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],//41,终端号，asc，定长8
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],//42，商户号，asc，定长15
                  
                  @"001399000000003100",//60, 主密钥下载的 60.1 = 99, 60.3 = 003, 60.4 = 1,60.5 = 0
                @"01449F0605DF000000049F220101DF9981804ff32b878be48f71335aa4a3f3c54bcfc574020b9bc8d28692ff54523db6e57f3a865c4460963d59a3f6fc5c82d366a2cb95655e92224e204afd1b7d22cd2fb012013208970cbb24d22a9072e734acc13afe128191cfaf97e0969bbf2f1658b092398f8f0446421daca0862e93d9ad174e85e2a68eac8ec9897328ca5b5fa4e6",//62,
                  
                  @"00113030313030303030303030", //63
                  
                  nil];
    

    //二进制报文数据
    NSArray *bitmapArr=[NSArray arrayWithObjects:@"11",@"41",@"42",@"60",@"62",@"63", nil];
    NSString *binaryDataStr=[HeaderString receiveArr:bitmapArr
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0800"
                                             DataArr:arr];
    NSLog(@"binaryDataStr=====%@",binaryDataStr);
    return binaryDataStr;
}


/************************
 *  消费
 *************************/
+(NSString *)consume:(NSString *)pin{
    //流水号
    NSString *liushuiStr=[[NSUserDefaults standardUserDefaults] valueForKey:Current_Liushui_Number];//[PublicInformation exchangeNumber];
    NSString* money = [PublicInformation returnMoney];
    NSString* newMoney = [PublicInformation moneyStringWithCString:(char*)[money cStringUsingEncoding:NSUTF8StringEncoding]];
    // 22域:是否输入密码
    NSString* f22 = @"0210";
    
    NSMutableArray* dataArray = [[NSMutableArray alloc] init];
    NSMutableArray* macMapArray = [[NSMutableArray alloc] init];
    // F02,卡号
    [dataArray addObject:[PublicInformation returnCard:[PublicInformation returnposCard]]];
    [macMapArray addObject:@"2"];
    // F03
    [dataArray addObject:@"190000"];
    [macMapArray addObject:@"3"];
    // F04
    [dataArray addObject:newMoney];
    [macMapArray addObject:@"4"];
    // F11
    [dataArray addObject:liushuiStr];
    [macMapArray addObject:@"11"];
    // F14
    NSString* effectdate = [[NSUserDefaults standardUserDefaults] valueForKey:Card_DeadLineTime];
    if (effectdate && effectdate.length > 0) {
        [dataArray addObject:effectdate];
        [macMapArray addObject:@"14"];
    }
    // F22
    [dataArray addObject:f22];
    [macMapArray addObject:@"22"];
    // F25
    [dataArray addObject:@"82"];
    [macMapArray addObject:@"25"];
    // F26
    [dataArray addObject:@"12"];
    [macMapArray addObject:@"26"];
    // F35
    [dataArray addObject:[NSString stringWithFormat:@"%d%@",(int)[[PublicInformation returnTwoTrack] length]/2,[PublicInformation returnTwoTrack]]];
    [macMapArray addObject:@"35"];
    // F41
    [dataArray addObject:[EncodeString encodeASC:[PublicInformation returnTerminal]]];
    [macMapArray addObject:@"41"];
    // F42
    [dataArray addObject:[EncodeString encodeASC:[PublicInformation returnBusiness]]];
    [macMapArray addObject:@"42"];
    // F49
    [dataArray addObject:[EncodeString encodeASC:@"156"]];
    [macMapArray addObject:@"49"];
    
    // F52 & F53
    if ([[f22 substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"1"]) {
        // F52
        [dataArray addObject:pin];
        [macMapArray addObject:@"52"];
        // F53
        [dataArray addObject:@"2600000000000000"];
    } else {
        // F53
        [dataArray addObject:@"0600000000000000"];
    }
    [macMapArray addObject:@"53"];

    // F60
    [dataArray addObject:[self makeF60]];
    [macMapArray addObject:@"60"];
    // F63
    [dataArray addObject:[NSString stringWithFormat:@"%@%@",[PublicInformation ToBHex:3],[EncodeString encodeASC:Manager_Number]]];
    [macMapArray addObject:@"63"];
    [macMapArray addObject:@"64"];

    NSString *binaryDataStr=[HeaderString receiveArr:macMapArray
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0200"
                                             DataArr:[self getNewPinAndMac:dataArray exchange:@"0200" bitmap:[HeaderString returnBitmap:macMapArray]]];
    return binaryDataStr;
}

//消费冲正(交易异常)
+(NSString *)consumeReturn{
    NSArray *bitmaparr;
    NSString *liushuiStr=[[NSUserDefaults standardUserDefaults] valueForKey:Last_Exchange_Number];
    //61域数据
    NSString *betweenStr;
    NSString *ascStr=[NSString stringWithFormat:@"%@%@",[EncodeString encodeASC:[PublicInformation returnSignSort]],[EncodeString encodeASC:liushuiStr]];
    betweenStr=[NSString stringWithFormat:@"00%d%@",(int)[ascStr length]/2,ascStr];
    
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
                                             DataArr:[self getNewPinAndMac:arr exchange:@"0400" bitmap:[HeaderString returnBitmap:bitmaparr]]];
    NSLog(@"消费冲正=====%@",binaryDataStr);
    return binaryDataStr;
}

//消费撤销
+(NSString *)consumeRepeal:(NSString *)pin liushui:(NSString *)liushuiStr money:(NSString *)moneyStr{
    //当前流水号
    NSString *currentLiushuiStr=[[NSUserDefaults standardUserDefaults] valueForKey:Current_Liushui_Number];
    //保存撤销金额
    [[NSUserDefaults standardUserDefaults] setValue:moneyStr forKey:Save_Return_Money];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString* F22 = [[NSUserDefaults standardUserDefaults] valueForKey:Service_Entry_22];
    
    //二进制报文数据
    NSArray *bitmaparr;
    //61域数据
    NSString *betweenStr;
    NSString *ascStr=[NSString stringWithFormat:@"%@%@",
                        [PublicInformation returnFdReserved],    // 原交易批次号
                        [PublicInformation returnLiushuiHao]];   // 原交易系统流水号
    betweenStr=[NSString stringWithFormat:@"00%02d%@",(int)[ascStr length],ascStr];
    NSLog(@"61域数据=====%@",betweenStr);
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[PublicInformation returnCard:[PublicInformation returnposCard]]]; // 02
    [arr addObject:@"280000"]; // 03
    [arr addObject:moneyStr]; // 04
    [arr addObject:currentLiushuiStr]; // 11
    [arr addObject:[[NSUserDefaults standardUserDefaults] valueForKey:Card_DeadLineTime]]; // 14
    [arr addObject:F22]; // 22
    if ([F22 hasPrefix:@"05"]) {
        [arr addObject:[[NSUserDefaults standardUserDefaults] valueForKey:ICCardSeq_23]];
    }
    [arr addObject:@"82"]; // 25
    [arr addObject:@"12"]; // 11
    [arr addObject:[NSString stringWithFormat:@"%d%@",
                    (int)[[PublicInformation returnTwoTrack] length]/2,
                    [PublicInformation returnTwoTrack]]]; // 35
    [arr addObject:[EncodeString encodeASC: liushuiStr]]; // 37
    [arr addObject:[EncodeString encodeASC:[[NSUserDefaults standardUserDefaults] valueForKey:LastF41_TerminalNo]]]; // 41
    [arr addObject:[EncodeString encodeASC:[[NSUserDefaults standardUserDefaults] valueForKey:LastF42_BussinessNo]]]; // 42
    [arr addObject:[EncodeString encodeASC:@"156"]]; // 49
    [arr addObject:pin]; // 52
    [arr addObject:@"2600000000000000"]; // 53
    [arr addObject:[self makeF60]]; // 60
    [arr addObject:betweenStr]; // 61

    
    
    //二进制报文数据
    if ([F22 hasPrefix:@"05"]) {
        bitmaparr=[NSArray arrayWithObjects:@"2",@"3",@"4",@"11",@"14",@"22",@"23",@"25",@"26",@"35",@"37",@"41",@"42",@"49",@"52",@"53",@"60",@"61",@"64", nil];
    } else {
        bitmaparr=[NSArray arrayWithObjects:@"2",@"3",@"4",@"11",@"14",@"22",@"25",@"26",@"35",@"37",@"41",@"42",@"49",@"52",@"53",@"60",@"61",@"64", nil];
    }

    
    NSLog(@"消费撤销数据====%@",arr);
    NSString *binaryDataStr=[HeaderString receiveArr:bitmaparr
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0200"
                                             DataArr:[self getNewPinAndMac:arr exchange:@"0200" bitmap:[HeaderString returnBitmap:bitmaparr]]];
    NSLog(@"消费撤销=====%@",binaryDataStr);
    return binaryDataStr;
}


//余额查询
+(NSString *)balanceSearch:(NSString *)pin{
    NSString *liushui=[[NSUserDefaults standardUserDefaults] valueForKey:Current_Liushui_Number];
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  [PublicInformation returnCard:[PublicInformation returnposCard]],//2 卡号 bcd（不定长19）
                  liushui,//[PublicInformation exchangeNumber],//11 流水号,bcd,定长6
                  //@"",//14 卡有效期,bcd,(pos获取时存在)
                  //@"",//34,一磁道数据，asc，不定长76，(pos获取时存在)
                  [NSString stringWithFormat:@"%d%@",[[EncodeString encodeASC:[PublicInformation returnTwoTrack]] length]/2,[EncodeString encodeASC:[PublicInformation returnTwoTrack]]],//35，二磁道数据，asc，不定长37，(pos获取时存在)
                  //@"",//36，三磁道数据，asc，不定长104，(pos获取时存在)
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],//41,终端号，asc，定长8
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],//42，商户号，asc，定长15
                  [EncodeString encodeASC:@"156"],//49，货币代码，asc，定长3，（人民币156）
                  pin,//52，个人识别码，PIN，定长8，(参照附录2)//byte[] byte52 = { 0x5B, 0x59, (byte) 0xEE, (byte) 0xC0, 0x0D, (byte) 0xD5, (byte) 0x86, (byte) 0xBE, };
                  [PublicInformation returnSignSort],//56,批次号，bcd，定长6
                  [NSString stringWithFormat:@"%@%@",[PublicInformation ToBHex:3],[EncodeString encodeASC:Manager_Number]],//63,操作员号，asc，不定长999，3字节
                  //@"3246444442373046",,//64,MAC校验数据，PIN，定长8//byte[] byte64 = { 0x42, 0x35, 0x31, 0x46, 0x38, 0x44, 0x31, 0x32, };
                  nil];
    NSLog(@"余额查询数据====%@",arr);
    
    //二进制报文数据
    NSArray *bitmapArr=[NSArray arrayWithObjects:@"2",@"11",@"35",@"41",@"42",@"49",@"52",@"56",@"63",@"64", nil];
    NSString *binaryDataStr=[HeaderString receiveArr:bitmapArr
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0100"
                                             DataArr:[self getNewPinAndMac:arr exchange:@"0100" bitmap:[HeaderString returnBitmap:bitmapArr]]];
    
    return binaryDataStr;
}


//参数更新

+(NSString *)deviceRefreshData:(NSString *)serialStr{
    NSLog(@"serialStr======%@=====%d",serialStr,[serialStr length]);
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  //11,流水号bcd 6
                  [PublicInformation exchangeNumber],//@"000008",
                  //56,批次号bcd 6
                  @"000000",//@"000000",
                  //61,pos序列号 asc 不定长999
                  //[NSString stringWithFormat:@"%@%@",[PublicInformation ToBHex:[serialStr length]],[EncodeString encodeASC:serialStr]],
                  [NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"00%d",[serialStr length]],[EncodeString encodeASC:serialStr]],
                   nil];//3800006472
    NSLog(@"参数更新=====%@",arr);
    NSString *binaryDataStr=[HeaderString receiveArr:[NSArray arrayWithObjects:@"11",@"56",@"61", nil]
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0820"
                                             DataArr:arr];
    NSLog(@"binaryDataStr=======%@",binaryDataStr);
    return binaryDataStr;
}

//回响测试//(终端号：99999986，商户号：999999999999999)
+(NSString *)returnTest{
    NSArray *arr=[[NSArray alloc] initWithObjects:
                 [EncodeString encodeASC:@"99999986"],//终端号asc
                 [EncodeString encodeASC:@"999999999999999"],//商户号asc
                 nil];
    NSLog(@"回响测试数据====%@",arr);
    //二进制报文数据
    NSString *binaryDataStr=[HeaderString receiveArr:[NSArray arrayWithObjects:@"41",@"42", nil]
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"0000"
                                             DataArr:arr];
    return binaryDataStr;
}






#pragma mask ---- 重写8583报文打包函数 -----------------------------------------------------------
+ (NSString*) stringPacking8583 {
    NSString* string;
    NSMutableDictionary* dataPack = [[NSMutableDictionary alloc] init];
    [dataPack setValue:[self makeF02] forKey:@"2"];
    [dataPack setValue:[self makeF03] forKey:@"3"];
    [dataPack setValue:[self makeF04] forKey:@"4"];
    [dataPack setValue:[self makeF11] forKey:@"11"];
    [dataPack setValue:[self makeF14] forKey:@"14"];
    [dataPack setValue:[self makeF22] forKey:@"22"];
    [dataPack setValue:[self makeF23] forKey:@"23"];
    [dataPack setValue:[self makeF25] forKey:@"25"];
    [dataPack setValue:[self makeF26] forKey:@"26"];
    [dataPack setValue:[self makeF35] forKey:@"35"];
    [dataPack setValue:[self makeF37] forKey:@"37"];
    [dataPack setValue:[self makeF41] forKey:@"41"];
    [dataPack setValue:[self makeF42] forKey:@"42"];
    [dataPack setValue:[self makeF49] forKey:@"49"];
    [dataPack setValue:[self makeF52] forKey:@"52"];
    [dataPack setValue:[self makeF53] forKey:@"53"];
    [dataPack setValue:[self makeF55] forKey:@"55"];
    [dataPack setValue:[self makeF60] forKey:@"60"];
    [dataPack setValue:[self makeF61] forKey:@"61"];
    [dataPack setValue:[self makeF62] forKey:@"62"];
    [dataPack setValue:[self makeF63] forKey:@"63"];
    
//    NSArray* newDataArray = [self getNewPinAndMac:<#(NSArray *)#> exchange:<#(NSString *)#> bitmap:<#(NSString *)#>];
    
    string = [HeaderString stringPacking8583WithBitmapArray:[self arrayBitMap]
                                                       tpdu:TPDU
                                                     header:HEADER
                                               ExchangeType:[self exchangeType8583]
                                             dataDictionary:dataPack];
    [self logDataInDictionay:dataPack forKeyArray:[self arrayBitMap]];
    return string;
}
// 位图信息数组
+ (NSArray*) arrayBitMap {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    NSString* f22 = [[NSUserDefaults standardUserDefaults] valueForKey:Service_Entry_22];
    NSString* tranType = [PublicInformation returnTranType];
    if ([tranType isEqualToString:TranType_Consume]){
        [array addObject:@"2"];
        [array addObject:@"3"];
        [array addObject:@"4"];
        [array addObject:@"11"];
        [array addObject:@"14"];
        [array addObject:@"22"];
        if ([f22 hasPrefix:@"05"]) {
            [array addObject:@"23"];
        }
        [array addObject:@"25"];
        [array addObject:@"26"];
        [array addObject:@"35"];
        [array addObject:@"41"];
        [array addObject:@"42"];
        [array addObject:@"49"];
        if ([f22 hasSuffix:@"10"]) {
            [array addObject:@"52"];
        }
        [array addObject:@"53"];
        if ([f22 hasPrefix:@"05"]) {
            [array addObject:@"55"];
        }
        [array addObject:@"60"];
        [array addObject:@"64"];
    } else if ([tranType isEqualToString:TranType_ConsumeRepeal]) {
        [array addObject:@"2"];
        [array addObject:@"3"];
        [array addObject:@"4"];
        [array addObject:@"11"];
        [array addObject:@"14"];
        [array addObject:@"22"];
        if ([f22 hasPrefix:@"05"]) {
            [array addObject:@"23"];
        }
        [array addObject:@"25"];
        [array addObject:@"26"];
        [array addObject:@"35"];
        [array addObject:@"37"];
        [array addObject:@"41"];
        [array addObject:@"42"];
        [array addObject:@"49"];
        if ([f22 hasSuffix:@"10"]) {
            [array addObject:@"52"];
        }
        [array addObject:@"53"];
        [array addObject:@"60"];
        [array addObject:@"61"];
        [array addObject:@"64"];
    } else if ([tranType isEqualToString:TranType_Chongzheng]) {
    } else if ([tranType isEqualToString:TranType_BatchUpload]) {
        
    } else if ([tranType isEqualToString:TranType_DownMainKey]){
        [array addObject:@"11"];
        [array addObject:@"41"];
        [array addObject:@"42"];
        [array addObject:@"60"];
        [array addObject:@"62"];
        [array addObject:@"63"];
    } else if ([tranType isEqualToString:TranType_DownWorkKey]) {
        [array addObject:@"11"];
        [array addObject:@"41"];
        [array addObject:@"42"];
        [array addObject:@"60"];
        [array addObject:@"63"];
    }
    return array;
}
// 交易类型
+ (NSString*) exchangeType8583 {
    NSString* exchangeType = nil;
    NSString* tranType = [PublicInformation returnTranType];
    if ([tranType isEqualToString:TranType_Consume] ||
        [tranType isEqualToString:TranType_ConsumeRepeal]) {
        exchangeType = @"0200";
    } else if ([tranType isEqualToString:TranType_Chongzheng]) {
        exchangeType = @"0400";
    } else if ([tranType isEqualToString:TranType_BatchUpload]) {
        exchangeType = @"0320";
    } else if ([tranType isEqualToString:TranType_DownMainKey] ||
               [tranType isEqualToString:TranType_DownWorkKey]) {
        exchangeType = @"0800";
    }
    return exchangeType;
}



// -- F02
+ (NSString*) makeF02 {
    return [PublicInformation returnCard:[PublicInformation returnposCard]];
}
// -- F03
+ (NSString*) makeF03 {
    NSString* f03 = nil;
    NSString* tranType = [PublicInformation returnTranType];
    if ([tranType isEqualToString:TranType_Consume]) {
        f03 = @"190000";
    } else if ([tranType isEqualToString:TranType_ConsumeRepeal]) {
        f03 = @"280000";
    } else if ([tranType isEqualToString:TranType_BatchUpload]) {
        f03 = [[NSUserDefaults standardUserDefaults] valueForKey:LastF03_ProcessingCode];
    }
    return f03;
}
// -- F04
+ (NSString*) makeF04 {
    NSString* f04 = nil;
    NSString* tranType = [PublicInformation returnTranType];
    if ([tranType isEqualToString:TranType_Consume] ||
        [tranType isEqualToString:TranType_Repay]   ||
        [tranType isEqualToString:TranType_Transfer]) {
        f04 = [PublicInformation returnMoney];
    } else {
        f04 = [PublicInformation returnConsumerMoney];
    }
    return f04;
}
// -- F11
+ (NSString*) makeF11 {
    NSString* f11 = [PublicInformation exchangeNumber];
    return f11;
}
// -- F14
+ (NSString*) makeF14 {
    NSString* f14 = nil;
    f14 = [[NSUserDefaults standardUserDefaults] valueForKey:EXP_DATE_14];
    return f14;
}
// -- F22
+ (NSString*) makeF22 {
    return [[NSUserDefaults standardUserDefaults] valueForKey:Service_Entry_22];
}
// -- F23
+ (NSString*) makeF23 {
    return [[NSUserDefaults standardUserDefaults] valueForKey:ICCardSeq_23];
}
// -- F25
+ (NSString*) makeF25 {
    return @"82";
}
// -- F26
+ (NSString*) makeF26 {
    return @"12";
}
// -- F35
+ (NSString*) makeF35 {
    NSMutableString* f35 = [[NSMutableString alloc] init];
    NSString* card2Track = [PublicInformation returnTwoTrack];
    [f35 appendFormat:@"%d%@",(int)card2Track.length/2,card2Track];
    return f35;
}
// -- F37
+ (NSString*) makeF37 {
    return [[NSUserDefaults standardUserDefaults] valueForKey:LastF37_ReferenceNum];
}
// -- F41
+ (NSString*) makeF41 {
    return [EncodeString encodeASC:[PublicInformation returnTerminal]];
}
// -- F42
+ (NSString*) makeF42 {
    return [EncodeString encodeASC:[PublicInformation returnBusiness]];
}
// -- F49
+ (NSString*) makeF49 {
    return [EncodeString encodeASC:@"156"];
}
// -- F52
+ (NSString*) makeF52 {
    return [[NSUserDefaults standardUserDefaults] valueForKey:Sign_in_PinKey];
}
// -- F53
+ (NSString*) makeF53 {
    NSString* f53 = @"600000000000000";
    NSString* f22 = [[NSUserDefaults standardUserDefaults] valueForKey:Service_Entry_22];
    if ([f22 hasSuffix:@"10"]) {
        f53 = [@"2" stringByAppendingString:f53];
    } else {
        f53 = [@"0" stringByAppendingString:f53];
    }
    return f53;
}
// -- F55
+ (NSString*) makeF55 {
    NSString* ICData = [[NSUserDefaults standardUserDefaults] valueForKey:BlueIC55_Information];
    NSString* f55 = [NSString stringWithFormat:@"%04d%@",(int)ICData.length/2,ICData];
    return f55;
}
// -- F60
+ (NSString*) makeF60 {
    NSMutableString* F60 = [[NSMutableString alloc] initWithString:@"0019"];
    NSString* tranType = [PublicInformation returnTranType];
    // 60.1 N2 交易类型
    if ([tranType isEqualToString:TranType_Consume]) {
        [F60 appendString:@"22"];
    } else if ([tranType isEqualToString:TranType_ConsumeRepeal]) {
        [F60 appendString:@"23"];
    } else if ([tranType isEqualToString:TranType_DownMainKey]) {
        [F60 appendString:@"99"];
    } else if ([tranType isEqualToString:TranType_DownWorkKey]) {
        [F60 appendString:@"00"];
    }
    // 60.2 N6 批次号
    [F60 appendString:[PublicInformation returnSignSort]];
    // 60.3 N3 操作类型
    [F60 appendString:@"003"];
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
    return F60;}
// -- F61
+ (NSString*) makeF61 {
    NSMutableString* f61 = [[NSMutableString alloc] init];
    [f61 appendString:[PublicInformation returnFdReserved]];
    [f61 appendString:[PublicInformation returnLiushuiHao]];
    return [NSString stringWithFormat:@"%04d%@",(int)f61.length,f61];
}
// -- F62
+ (NSString*) makeF62 {
    return @"01449F0605DF000000049F220101DF9981804ff32b878be48f71335aa4a3f3c54bcfc574020b9bc8d28692ff54523db6e57f3a865c4460963d59a3f6fc5c82d366a2cb95655e92224e204afd1b7d22cd2fb012013208970cbb24d22a9072e734acc13afe128191cfaf97e0969bbf2f1658b092398f8f0446421daca0862e93d9ad174e85e2a68eac8ec9897328ca5b5fa4e6";
}
// -- F63
+ (NSString*) makeF63 {
    NSString* f63 = [EncodeString encodeASC:Manager_Number];
    f63 = [NSString stringWithFormat:@"%02d%@",(int)f63.length/2,f63];
    return [EncodeString encodeASC:[PublicInformation returnBusiness]];
}


////////
+ (void) logDataInDictionay:(NSDictionary*)dataDictionary forKeyArray:(NSArray*)keyArray {
    if (!dataDictionary || !keyArray || dataDictionary.count == 0 || keyArray.count == 0) {
        return;
    }
    for (NSString* key in keyArray) {
        NSString* value = [dataDictionary valueForKey:key];
        NSLog(@"KEY[%02d]:VALUE[%@]",(int)[key intValue],value);
    }
}

@end
