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

//支付宝
//支付宝二维码消费预下订单
+(NSString *)saomaAndOrderMoney:(NSString *)money{
//通用磁条卡的批次号
    //磁条卡：[PublicInformation returnSignSort]
    //IC卡：[EncodeString encodeASC:Blue_IC_PiciNmuber]
    //60域数据
    
    NSString *betweenStr;
    NSString *ascStr=[NSString stringWithFormat:@"%@%@",[EncodeString encodeASC:@"22"],[EncodeString encodeASC:[PublicInformation returnSignSort]]];
    NSLog(@"ascStr=====%@",ascStr);
    betweenStr=[NSString stringWithFormat:@"000%d%@",[ascStr length]/2,ascStr];
    NSLog(@"betweenStr======%@",betweenStr);
    
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  @"000000",//3,交易处理码，bcd，000000
                  [self apilyMoney:money],//4,交易金额，bcd,n12
                  [PublicInformation exchangeNumber],//11,交易流水号,bcd,6
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],//41,终端编号
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],//42,商户编号
                  [EncodeString encodeASC:@"156"],//49,交易货币代码
                  betweenStr,//60，自定义域,60.1,交易类型码；60.2，批次号
                  [NSString stringWithFormat:@"%@%@",[PublicInformation ToBHex:3],[EncodeString encodeASC:Manager_Number]],//63,自定义域，63.1，操作员代码
                  //64,MAC校验数据，PIN，定长8
                  nil];
    NSLog(@"支付宝二维码消费预下订单=====%@",arr);
    //二进制报文数据
    NSArray *bitmapArr=[NSArray arrayWithObjects:@"3",@"4",@"11",@"41",@"42",@"49",@"60",@"63",@"64", nil];
    NSString *binaryDataStr=[HeaderString receiveArr:bitmapArr
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"1000"
                                             DataArr:[self getNewPinAndMac:arr exchange:@"1000" bitmap:[HeaderString returnBitmap:bitmapArr]]];
    NSLog(@"支付宝二维码消费预下订单binaryDataStr=====%@",binaryDataStr);
    return binaryDataStr;
}

//支付宝条形码消费(下订单并支付)
+(NSString *)tiaoxingmaConsumer:(NSString *)money tiaoxingmaId:(NSString *)maid{
    
    //支付宝查询流水号
    NSString *liushuiStr=[PublicInformation exchangeNumber];
    [[NSUserDefaults standardUserDefaults] setValue:liushuiStr forKey:Zhifubao_search_liushui];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //60域数据
    NSString *betweenStr;
    NSString *ascStr=[NSString stringWithFormat:@"%@%@",[EncodeString encodeASC:@"22"],[EncodeString encodeASC:[PublicInformation returnSignSort]]];
    NSLog(@"ascStr=====%@",ascStr);
    betweenStr=[NSString stringWithFormat:@"000%d%@",[ascStr length]/2,ascStr];
    
    //62域，条形码
    NSString *tiaoxingmaInfoStr=[EncodeString encodeASC:maid];
    NSString *tiaoxingmaStr=[NSString stringWithFormat:@"00%d%@",[tiaoxingmaInfoStr length]/2,tiaoxingmaInfoStr];
    
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  @"000000",//3,交易处理码，bcd，000000
                  [self apilyMoney:money],//4,交易金额，bcd,n12
                  liushuiStr,//11,交易流水号,bcd,6
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],//41,终端编号
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],//42,商户编号
                  [EncodeString encodeASC:@"156"],//49,交易货币代码
                  betweenStr,//60，自定义域,60.1,交易类型码；60.2，批次号
                  tiaoxingmaStr,//62,自定义域，扫描到的条形码id
                  [NSString stringWithFormat:@"%@%@",[PublicInformation ToBHex:3],[EncodeString encodeASC:Manager_Number]],//63,自定义域，63.1，操作员代码
                  //64,MAC校验数据，PIN，定长8//byte[] byte64 = { 0x42, 0x35, 0x31, 0x46, 0x38, 0x44, 0x31, 0x32, };
                  nil];
    NSLog(@"支付宝条形码消费(下订单并支付)=====%@",arr);
    //二进制报文数据
    NSArray *bitmapArr=[NSArray arrayWithObjects:@"3",@"4",@"11",@"41",@"42",@"49",@"60",@"62",@"63",@"64", nil];
    NSString *binaryDataStr=[HeaderString receiveArr:bitmapArr
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"1002"
                                             DataArr:[self getNewPinAndMac:arr exchange:@"1002" bitmap:[HeaderString returnBitmap:bitmapArr]]];
    NSLog(@"支付宝条形码消费(下订单并支付)binaryDataStr=====%@",binaryDataStr);
    return binaryDataStr;
}

//支付宝查询
+(NSString *)zhifubaoSearchOrderNum:(NSString *)num{
    NSLog(@"订单号======%@",num);
//支付宝查询流水号
    NSString *liushuiStr=[PublicInformation exchangeNumber];
    [[NSUserDefaults standardUserDefaults] setValue:liushuiStr forKey:Zhifubao_search_liushui];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //60域数据
    NSString *betweenStr;
    NSString *ascStr=[NSString stringWithFormat:@"%@%@",[EncodeString encodeASC:@"22"],[EncodeString encodeASC:[PublicInformation returnSignSort]]];
    betweenStr=[NSString stringWithFormat:@"000%d%@",[ascStr length]/2,ascStr];
    
    //61,自定义域，订单号
    NSString *orderInfoStr=[EncodeString encodeASC:num];
    NSString *orderStr=[NSString stringWithFormat:@"00%d%@",[orderInfoStr length]/2,orderInfoStr];
    NSLog(@"订单号orderStr======%@",orderStr);
    
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  @"000000",//3,交易处理码，bcd，000000
                  liushuiStr,//11,交易流水号,bcd,6
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],//41,终端编号
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],//42,商户编号
                  betweenStr,//60，自定义域,60.1,交易类型码；60.2，批次号
                  orderStr,//61，订单号
                  [NSString stringWithFormat:@"%@%@",[PublicInformation ToBHex:3],[EncodeString encodeASC:Manager_Number]],//63,自定义域，63.1，操作员代码
                  //64,MAC校验数据，PIN，定长8//byte[] byte64 = { 0x42, 0x35, 0x31, 0x46, 0x38, 0x44, 0x31, 0x32, };
                  nil];
    NSLog(@"支付宝查询=====%@",arr);
    //二进制报文数据
    NSArray *bitmapArr=[NSArray arrayWithObjects:@"3",@"11",@"41",@"42",@"60",@"61",@"63",@"64", nil];
    NSString *binaryDataStr=[HeaderString receiveArr:bitmapArr
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"1004"
                                             DataArr:[self getNewPinAndMac:arr exchange:@"1004" bitmap:[HeaderString returnBitmap:bitmapArr]]];
    NSLog(@"支付宝查询binaryDataStr=====%@",binaryDataStr);
    return binaryDataStr;
}

//支付宝撤销
+(NSString *)zhifubaoReplaceDingdanNum:(NSString *)num{
//支付宝撤销流水号
    NSString *liushuiStr=[PublicInformation exchangeNumber];
    [[NSUserDefaults standardUserDefaults] setValue:liushuiStr forKey:ZhifubaoChexiaoLiushui];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //60域数据
    NSString *betweenStr;
    NSString *ascStr=[NSString stringWithFormat:@"%@%@",[EncodeString encodeASC:@"22"],[EncodeString encodeASC:[PublicInformation returnSignSort]]];
    betweenStr=[NSString stringWithFormat:@"000%d%@",[ascStr length]/2,ascStr];
    
    //61,自定义域，订单号
    NSString *orderInfoStr=[EncodeString encodeASC:num];
    NSString *orderStr=[NSString stringWithFormat:@"00%d%@",[orderInfoStr length]/2,orderInfoStr];
    NSLog(@"订单号orderStr======%@",orderStr);
    
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  @"000000",//3,交易处理码，bcd，000000
                  liushuiStr,//11,交易流水号,bcd,6
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],//41,终端编号
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],//42,商户编号
                  betweenStr,//60，自定义域,60.1,交易类型码；60.2，批次号
                  orderStr,//61，订单号
                  [NSString stringWithFormat:@"%@%@",[PublicInformation ToBHex:3],[EncodeString encodeASC:Manager_Number]],//63,自定义域，63.1，操作员代码
                  //64,MAC校验数据，PIN，定长8//byte[] byte64 = { 0x42, 0x35, 0x31, 0x46, 0x38, 0x44, 0x31, 0x32, };
                  nil];
    NSLog(@"支付宝撤销=====%@",arr);
    //二进制报文数据
    NSArray *bitmapArr=[NSArray arrayWithObjects:@"3",@"11",@"41",@"42",@"60",@"61",@"63",@"64", nil];
    NSString *binaryDataStr=[HeaderString receiveArr:bitmapArr
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"1006"
                                             DataArr:[self getNewPinAndMac:arr exchange:@"1006" bitmap:[HeaderString returnBitmap:bitmapArr]]];
    NSLog(@"支付宝撤销binaryDataStr=====%@",binaryDataStr);
    return binaryDataStr;
}


//支付宝退款
+(NSString *)zhifubaoRebateMoney:(NSString *)money tuikuanDingdanNum:(NSString *)num{
//支付宝退款流水号
    NSString *liushuiStr=[PublicInformation exchangeNumber];
    [[NSUserDefaults standardUserDefaults] setValue:liushuiStr forKey:ZhifubaoChexiaoLiushui];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //60域数据
    NSString *betweenStr;
    NSString *ascStr=[NSString stringWithFormat:@"%@%@",[EncodeString encodeASC:@"22"],[EncodeString encodeASC:[PublicInformation returnSignSort]]];
    betweenStr=[NSString stringWithFormat:@"000%d%@",[ascStr length]/2,ascStr];
    
    //61,自定义域，订单号
    NSString *orderInfoStr=[EncodeString encodeASC:num];
    NSString *orderStr=[NSString stringWithFormat:@"00%d%@",[orderInfoStr length]/2,orderInfoStr];
    NSLog(@"订单号orderStr======%@",orderStr);
    
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  @"000000",//3,交易处理码，bcd，000000
                  [self apilyMoney:money],//4,交易金额，bcd,n12
                  liushuiStr,//11,交易流水号,bcd,6
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],//41,终端编号
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],//42,商户编号
                  betweenStr,//60，自定义域,60.1,交易类型码；60.2，批次号
                  orderStr,//61，订单号
                  [NSString stringWithFormat:@"%@%@",[PublicInformation ToBHex:3],[EncodeString encodeASC:Manager_Number]],//63,自定义域，63.1，操作员代码
                  //64,MAC校验数据，PIN，定长8//byte[] byte64 = { 0x42, 0x35, 0x31, 0x46, 0x38, 0x44, 0x31, 0x32, };
                  nil];
    NSLog(@"支付宝退款=====%@",arr);
    //二进制报文数据
    NSArray *bitmapArr=[NSArray arrayWithObjects:@"3",@"4",@"11",@"41",@"42",@"60",@"61",@"63",@"64", nil];
    NSString *binaryDataStr=[HeaderString receiveArr:bitmapArr
                                                Tpdu:TPDU
                                              Header:HEADER
                                        ExchangeType:@"1008"
                                             DataArr:[self getNewPinAndMac:arr exchange:@"1008" bitmap:[HeaderString returnBitmap:bitmapArr]]];
    NSLog(@"支付宝退款binaryDataStr=====%@",binaryDataStr);
    return binaryDataStr;
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
+(NSArray *)getNewPinAndMac:(NSArray *)arr exchange:(NSString *)typestr bitmap:(NSString *)bitstr{
    //NSLog(@"原始数据====%@",arr);
    //mac校验数据
    NSString *allStr=[NSString stringWithFormat:@"%@%@%@",typestr,bitstr,[arr componentsJoinedByString:@""]];
    NSLog(@"allStr====%@,=====%d",allStr,(int)[allStr length]);
    int len = (int)allStr.length;
    int other = len % 16;
    
    NSMutableArray *numArr=[[NSMutableArray alloc] init];
    if (other != 0) {
        for (int i=0; i< (16-other); i++) {
            [numArr addObject:@"0"];
        }
    }
    NSString *newAllStr=[NSString stringWithFormat:@"%@%@",allStr,[numArr componentsJoinedByString:@""]];
    NSLog(@"newAllStr=====%@=====%d",newAllStr,(int)[newAllStr length]);
    
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
    //mack签到明文
    //双倍des加密
    NSString *left3descryptStr=[[Unpacking8583 getInstance] threeDesEncrypt:leftString keyValue:[PublicInformation signinMac]];
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
    NSString *str=[[Unpacking8583 getInstance] threeDesEncrypt:resultStr keyValue:[PublicInformation signinMac]];
    //NSLog(@"3des====%@",str);
    //NSLog(@"mac======%@",[str substringWithRange:NSMakeRange(0, 8)]);
    NSString *macStr=[EncodeString encodeASC:[str substringWithRange:NSMakeRange(0, 8)]];
    NSMutableArray *newArr=[[NSMutableArray alloc] initWithArray:arr];
    [newArr addObject:macStr];
    NSLog(@"添加mac校验64域====%@",newArr);
    for (int i=0; i<[newArr count]; i++) {
        //NSLog(@"aaaaa=%@",[newArr objectAtIndex:i]);
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


/************************
 *  商户登陆
 *************************/
+(NSString *)loadIn{
    
    NSString* user_ID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSString* user_PW = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPW"];
    NSString* AF01 = [NSString stringWithFormat:@"AF01%02d%@",(int)[user_ID length], [EncodeString encodeASC:user_ID] ];
    NSString* AF02 = [NSString stringWithFormat:@"AF02%02d%@", (int)[user_PW length], [EncodeString encodeASC:user_PW]];
    NSString* F62 = [NSString stringWithFormat:@"%04d%@%@", (int)[user_PW length] + (int)[user_ID length] + 6, AF01, AF02];
    
    NSArray *arr=[[NSArray alloc] initWithObjects:
                  [EncodeString encodeASC:[PublicInformation returnTerminal]],  //41,终端号，asc，定长8
                  [EncodeString encodeASC:[PublicInformation returnBusiness]],  //42，商户号，asc，定长15
                  @"0011960000004100",                                          //60,
                  F62,                                                          //62,
                  nil];
    
    NSLog(@"登陆数据=====%@",arr);
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
    [dataArray addObject:[[NSUserDefaults standardUserDefaults] valueForKey:Card_DeadLineTime]];
    [macMapArray addObject:@"14"];
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
    
    //当前消费之后搜索参考号是否存在
    NSArray *arr;
    //二进制报文数据
    NSArray *bitmaparr;
    //61域数据
    NSString *betweenStr;
    NSString *ascStr=[NSString stringWithFormat:@"%@%@",
                        [PublicInformation returnFdReserved],    // 原交易批次号
                        [PublicInformation returnLiushuiHao]];   // 原交易系统流水号
    betweenStr=[NSString stringWithFormat:@"00%02d%@",(int)[ascStr length]/2,ascStr];
    NSLog(@"61域数据=====%@",betweenStr);
    
    arr=[[NSArray alloc] initWithObjects:
         // 2 卡号 bcd（不定长19）
         [PublicInformation returnCard:[PublicInformation returnposCard]],
         // 3 交易类型:280000
         @"280000",
         // 4 金额，bcd，定长12
         moneyStr,
         // 11 bcd,定长6
         currentLiushuiStr,
         // 14 有效期
         [[NSUserDefaults standardUserDefaults] valueForKey:Card_DeadLineTime],
         // 22 输入模式,bcd,m,定长3
         @"0210",
         // 25,条件代码,bcd,定长2
         @"82",
         // 26
         @"12",
         // 35，二磁道数据，asc，不定长37，(pos获取时存在)
         [NSString stringWithFormat:@"%d%@",(int)[[PublicInformation returnTwoTrack] length]/2,[PublicInformation returnTwoTrack]],
         // 37, 搜索参考号
         [EncodeString encodeASC: liushuiStr],
         // 41, 终端号，asc，定长8
         [EncodeString encodeASC:[PublicInformation returnTerminal]],
         // 42，商户号，asc，定长15
         [EncodeString encodeASC:[PublicInformation returnBusiness]],
         // 49，货币代码，asc，定长3，（人民币156）
         [EncodeString encodeASC:@"156"],
         // 52，个人识别码，PIN，定长8
         pin,
         // 53
         @"2600000000000000",
         // 60
         [self makeF60],
         // 61 (消费的批次号和流水号)61,61.1,61.2,原交易信息，原交易批次号，原交易流水号
         betweenStr,  nil];
    
    //二进制报文数据
    bitmaparr=[NSArray arrayWithObjects:@"2",@"3",@"4",@"11",@"14",@"22",@"25",@"26",@"35",@"37",@"41",@"42",@"49",@"52",@"53",@"60",@"61"/*,@"56",@"63"*/,@"64", nil];

    
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
