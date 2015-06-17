//
//  PublicInformation.m
//  PosN38Universal
//
//  Created by work on 14-8-8.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import "PublicInformation.h"
#import "Define_Header.h"
#import "Unpacking8583.h"

@implementation PublicInformation


//bbpos已连接
+(BOOL)bbPosHaveConnect{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"bbpos_connected"];
}


+(NSString *)returnBBposKeyStr{
     NSString *masterKey=@"CED0505457484395C6FAB0358A9E6E65";
     NSString *rightKey =@"C0C0C0C000000000C0C0C0C000000000";
    NSString *csnStr=[[NSUserDefaults standardUserDefaults] valueForKey:The_terminal_Number];//@"01100000000030070000000000000000";//@"0110000000003007";//
    NSLog(@"bbpos===csnStr====%@",csnStr);
     //3des加密
     NSString *firstStr=[[Unpacking8583 getInstance] threeDesEncrypt:csnStr keyValue:masterKey];
     NSLog(@"firstStr======%@",firstStr);
     //异或运算
     Byte *left=(Byte *)[[PublicInformation NewhexStrToNSData:masterKey] bytes];
     Byte *right=(Byte *)[[PublicInformation NewhexStrToNSData:rightKey] bytes];
     
     Byte pwdPlaintext[16];
     for (int i = 0; i < 16; i++) {
     pwdPlaintext[i] = (Byte)(left[i] ^ right[i]);
     }
     
     NSData *theData = [[NSData alloc] initWithBytes:pwdPlaintext length:sizeof(pwdPlaintext)];
     NSString *resultStr=[PublicInformation stringWithHexBytes2:theData];
     NSLog(@"resultStr======%@",resultStr);
     
     //再次3des加密
     NSString *secondStr=[[Unpacking8583 getInstance] threeDesEncrypt:csnStr keyValue:resultStr];
     NSLog(@"secondStr======%@",secondStr);
     //工作秘钥拼接
     NSString *workKeyStr=[NSString stringWithFormat:@"%@%@",[firstStr substringWithRange:NSMakeRange(0, 16)],[secondStr substringWithRange:NSMakeRange(0, 16)]];
     NSLog(@"workKeyStr======%@",workKeyStr);
    return workKeyStr;
}

+(int)returnSelectIndex{
    int deviceSelect;
    NSString *deviceStr=[[NSUserDefaults standardUserDefaults] valueForKey:@"selected"];
    //NSLog(@"deviceStr====%@",deviceStr);
    if (deviceStr && ![deviceStr isEqualToString:@""] && ![deviceStr isEqualToString:@"(null)"]) {
        //第一次设置默认刷卡头，n38
        deviceSelect=[deviceStr intValue];
    }else{
        deviceSelect=2;
    }
    return deviceSelect;
}

//当前带星卡号
+(NSString *)getXingCard{
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:GetCurrentCard_NotAll];
}

//更新主密钥
+(NSString *)getMainSecret{
    NSString *mainkey=@"";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:IsOrRefresh_MainKey]) {
        mainkey=[[NSUserDefaults standardUserDefaults] valueForKey:Refresh_Later_MainKey];
    }else{
        mainkey=@"EF2AE9F834BFCDD5260B974A70AD1A4A";
    }
    NSLog(@"主秘钥内容======%@",mainkey);
    return mainkey;
}

//原交易流水号,消费交易的流水号
+(NSString *)returnLiushuiHao{
    NSString *liushuiStr=[[NSUserDefaults standardUserDefaults] valueForKey:Last_Exchange_Number];
    NSLog(@"liushuiStr====%@",liushuiStr);
    if (liushuiStr && ![liushuiStr isEqualToString:@""] && ![liushuiStr isEqualToString:@"(null)"]) {
        liushuiStr=[[NSUserDefaults standardUserDefaults] valueForKey:Last_Exchange_Number];
    }else{
        liushuiStr=@"000000";
    }
    return liushuiStr;
}

//消费成功的搜索参考号
+(NSString *)returnConsumerSort{
    NSString *consumerStr=[[NSUserDefaults standardUserDefaults] valueForKey:Consumer_Get_Sort];
    NSLog(@"consumerStr====%@",consumerStr);
    if (consumerStr && ![consumerStr isEqualToString:@""] && ![consumerStr isEqualToString:@"(null)"]) {
        consumerStr=[[NSUserDefaults standardUserDefaults] valueForKey:Consumer_Get_Sort];
    }else{
        consumerStr=@"";
    }
    return consumerStr;
}

//消费成功的金额,方便撤销支付
+(NSString *)returnConsumerMoney{
    NSString *successStr=[[NSUserDefaults standardUserDefaults] valueForKey:SuccessConsumerMoney];
    if (successStr && ![successStr isEqualToString:@""] && ![successStr isEqualToString:@"(null)"]) {
        successStr=[[NSUserDefaults standardUserDefaults] valueForKey:SuccessConsumerMoney];
    }else{
        successStr=@"";
    }
    return successStr;
}


//签到批次号
+(NSString *)returnSignSort{
    NSString *sortStr=[[NSUserDefaults standardUserDefaults] valueForKey:Get_Sort_Number];
    NSLog(@"sortStr====%@",sortStr);
    if (sortStr && ![sortStr isEqualToString:@""] && ![sortStr isEqualToString:@"(null)"]) {
        sortStr=[[NSUserDefaults standardUserDefaults] valueForKey:Get_Sort_Number];
    }else{
        sortStr=@"000000";
    }
    return sortStr;
}

//二磁道数据
+(NSString *)returnTwoTrack{
    NSString *trackStr=[[NSUserDefaults standardUserDefaults] valueForKey:Two_Track_Data];
    if (trackStr && ![trackStr isEqualToString:@""] && ![trackStr isEqualToString:@"(null)"]) {
        trackStr=[[NSUserDefaults standardUserDefaults] valueForKey:Two_Track_Data];
    }else{
        trackStr=@"";
    }
    return trackStr;
}

//银行卡号
+(NSString *)returnposCard{
    NSString *cardStr=[[NSUserDefaults standardUserDefaults] valueForKey:Card_Number];
    if (cardStr && ![cardStr isEqualToString:@""] && ![cardStr isEqualToString:@"(null)"]) {
        cardStr=[[NSUserDefaults standardUserDefaults] valueForKey:Card_Number];
    }else{
        cardStr=@"";
    }
    return cardStr;
}

//刷卡金额
+(NSString *)returnMoney{
    NSString *moneyStr=[[NSUserDefaults standardUserDefaults] valueForKey:Consumer_Money];
    NSLog(@"liushuiStr====%@",moneyStr);

    if (moneyStr && ![moneyStr isEqualToString:@"0.00"] && ![moneyStr isEqualToString:@"(null)"]) {
        moneyStr=[[NSUserDefaults standardUserDefaults] valueForKey:Consumer_Money];
    }else{
        moneyStr=@"1";
    }
    return moneyStr;
}

//流水号,每次交易，递增,bcd,6(000008)

/*
 <?php
 $var=sprintf("%04d", 2);//生成4位数，不足前面补0
 echo $var;//结果为0002
 //("%04d", 2)
 NSLog(@"六位数====%06d",112);
 */

+(NSString *)exchangeNumber{
    int number;
    NSString *exchangeStr=[[NSUserDefaults standardUserDefaults] valueForKey:Exchange_Number];
    if (exchangeStr && ![exchangeStr isEqualToString:@""] && ![exchangeStr isEqualToString:@"(null)"]) {
        number =[[[NSUserDefaults standardUserDefaults] valueForKey:Exchange_Number] intValue] + 1;
    }else{
        number=1;
    }
    if (number > 999999) {
        number =1;
    }
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%06d",number] forKeyPath:Exchange_Number];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"流水号======%@",[NSString stringWithFormat:@"%06d",number]);
    return [NSString stringWithFormat:@"%06d",number];
}

/*
//初始化终端成功，可以签到
+(BOOL)initTerminalSuccess{
    return [[NSUserDefaults standardUserDefaults] boolForKey:Init_Terminal_Success];
}
 */


+(NSString *)returnCard:(NSString *)card{
    int cardlength=card.length;
    NSString *newCard=@"";
    if ((cardlength)%2 > 0) {
        newCard=[NSString stringWithFormat:@"%d%@0",cardlength,card];
    }else{
        newCard=[NSString stringWithFormat:@"%d%@",cardlength,card];
    }
    return newCard;
}

+(NSString *)returnTerminal{
    NSString *terminalNumber=[[NSUserDefaults standardUserDefaults] valueForKey:Terminal_Number];
    if (terminalNumber && ![terminalNumber isEqualToString:@""] && ![terminalNumber isEqualToString:@"(null)"]) {
        terminalNumber=[[NSUserDefaults standardUserDefaults] valueForKey:Terminal_Number];
    }else{
        terminalNumber=@"10006079";     // 72环境终端号
//        terminalNumber = @"10006241";
    }
    return terminalNumber;
}
+(NSString *)returnBusiness{
    NSString *businessNumber=[[NSUserDefaults standardUserDefaults] valueForKey:Business_Number];
    if (businessNumber && ![businessNumber isEqualToString:@""] && ![businessNumber isEqualToString:@"(null)"]) {
        businessNumber=[[NSUserDefaults standardUserDefaults] valueForKey:Business_Number];
    }else{
        businessNumber=@"888584053310002";      // 72环境商户号
//        businessNumber = @"886100000000001";
    }
    return businessNumber;
}
+(NSString *)returnBusinessName{
    NSString *businessName=[[NSUserDefaults standardUserDefaults] valueForKey:Business_Name];
    if (businessName && ![businessName isEqualToString:@""] && ![businessName isEqualToString:@"(null)"]) {
        businessName=[[NSUserDefaults standardUserDefaults] valueForKey:Business_Name];
    }else{
        businessName=@"测试商户";
    }
    return businessName;
}

//签到保存mackey，pinkey
+(NSString *)signinPin{//3A78137C68EA4E670A441384ABC5251E
    return [[NSUserDefaults standardUserDefaults] valueForKey:Sign_in_PinKey];
}
+(NSString *)signinMac{//104E324600A3F13DD2E7757053356383
    return [[NSUserDefaults standardUserDefaults] valueForKey:Sign_in_MacKey];
}

// 金融交易后台ip
+(NSString *)settingIp{
    NSString *ipStr;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:Setting_Ip]) {
        ipStr=[[NSUserDefaults standardUserDefaults] valueForKey:Tcp_IP];
    }else{
//        ipStr=@"192.168.1.50";//122.0.64.19@"211.90.22.167";//
        ipStr   = @"202.104.101.126";
    }
    return ipStr;
}
+(int)settingPort{
    NSString *portStr;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:Setting_Port]) {
        portStr=[[NSUserDefaults standardUserDefaults] valueForKey:Tcp_Port];
    }else{
//        portStr=@"28080";
        portStr = @"9088";
    }
    return [portStr intValue];
}

// 从配置中获取数据后台地址
+(NSString*) getDataSourceIP{
    NSString* ip;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Setting_Ip"]) {
        ip = [[NSUserDefaults standardUserDefaults] valueForKey:@"DataSource_IP"];
    } else {
        ip = @"192.188.8.112";
    }
    return ip;
}
+(NSString*) getDataSourcePort{
    NSString* port;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:Setting_Port]) {
        port = [[NSUserDefaults standardUserDefaults] valueForKey:@"DataSource_Port"];
    }else{
        port = @"8083";
    }
    return port;
}



//十六进制转化二进制
+(NSString *)getBinaryByhex:(NSString *)hex
{
    NSMutableDictionary  *hexDic = [[NSMutableDictionary alloc] init];
    
    hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    
    [hexDic setObject:@"0000" forKey:@"0"];
    
    [hexDic setObject:@"0001" forKey:@"1"];
    
    [hexDic setObject:@"0010" forKey:@"2"];
    
    [hexDic setObject:@"0011" forKey:@"3"];
    
    [hexDic setObject:@"0100" forKey:@"4"];
    
    [hexDic setObject:@"0101" forKey:@"5"];
    
    [hexDic setObject:@"0110" forKey:@"6"];
    
    [hexDic setObject:@"0111" forKey:@"7"];
    
    [hexDic setObject:@"1000" forKey:@"8"];
    
    [hexDic setObject:@"1001" forKey:@"9"];
    
    [hexDic setObject:@"1010" forKey:@"A"];
    
    [hexDic setObject:@"1011" forKey:@"B"];
    
    [hexDic setObject:@"1100" forKey:@"C"];
    
    [hexDic setObject:@"1101" forKey:@"D"];
    
    [hexDic setObject:@"1110" forKey:@"E"];
    
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSString *binaryString=@"";
    
    for (int i=0; i<[hex length]; i++) {
        
        NSRange rage;
        
        rage.length = 1;
        
        rage.location = i;
        
        NSString *key = [hex substringWithRange:rage];
        
        //NSLog(@"%@",[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]);
        
        binaryString = [NSString stringWithFormat:@"%@%@",binaryString,[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]];
        
    }
    
    //NSLog(@"转化后的二进制为:%@",binaryString);
    
    return binaryString;
    
}

//二进制转十六进制
+(NSString *)binaryToHexString:(NSString *)str{
    NSMutableDictionary  *hexDic = [[NSMutableDictionary alloc] init];
    hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    
    [hexDic setObject:@"0" forKey:@"0000"];
    
    [hexDic setObject:@"1" forKey:@"0001"];
    
    [hexDic setObject:@"2" forKey:@"0010"];
    
    [hexDic setObject:@"3" forKey:@"0011"];
    
    [hexDic setObject:@"4" forKey:@"0100"];
    
    [hexDic setObject:@"5" forKey:@"0101"];
    
    [hexDic setObject:@"6" forKey:@"0110"];
    
    [hexDic setObject:@"7" forKey:@"0111"];
    
    [hexDic setObject:@"8" forKey:@"1000"];
    
    [hexDic setObject:@"9" forKey:@"1001"];
    
    [hexDic setObject:@"A" forKey:@"1010"];
    
    [hexDic setObject:@"B" forKey:@"1011"];
    
    [hexDic setObject:@"C" forKey:@"1100"];
    
    [hexDic setObject:@"D" forKey:@"1101"];
    
    [hexDic setObject:@"E" forKey:@"1110"];
    
    [hexDic setObject:@"F" forKey:@"1111"];
    
    
    NSMutableArray *newArr=[[NSMutableArray alloc] init];
    NSMutableString *newStr=[NSMutableString stringWithString:str];
    int a=0;
    for (int i=0; i<[str length]/4; i++) {
        [newArr addObject:[newStr substringWithRange:NSMakeRange(a, 4)]];
        a=a+4;
    }
    //NSLog(@"newArr=======%@",newArr);
    
    NSMutableString *resultStr=[NSMutableString new];
    
    for (int c=0; c<[newArr count]; c++) {
        
        for (int d=0; d<[[hexDic allKeys] count]; d++) {
            if ([[newArr objectAtIndex:c] isEqualToString:[[hexDic allKeys] objectAtIndex:d]]) {
                //NSLog(@"key=======%@,object======%@",[newArr objectAtIndex:c],[hexDic objectForKey:[newArr objectAtIndex:c]]);
                [resultStr appendString:[hexDic objectForKey:[newArr objectAtIndex:c]]];
            }
        }
        
    }
    
    return resultStr;
}

//二进制取反
+(NSString *)binaryToAgain:(NSString *)str{
    NSMutableString *newStr=[NSMutableString stringWithString:str];
    
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    int a=0;
    for (int i=0; i<[str length]; i++) {
        [arr addObject:[newStr substringWithRange:NSMakeRange(a, 1)]];
        a++;
    }
    //NSLog(@"arr=====%@,======%d",arr,[arr count]);
    
    for (int b=0; b<[arr count]; b++) {
        if ([[arr objectAtIndex:b] isEqualToString:@"0"]) {
            [arr replaceObjectAtIndex:b withObject:@"1"];
        }else{
            [arr replaceObjectAtIndex:b withObject:@"0"];
        }
    }
    //NSLog(@"newarr=======%@=====%d",arr,[arr count]);
    NSString *thenewStr=[arr componentsJoinedByString:@""];
    return thenewStr;
}

//十六进制转十进制

+(int)sistenToTen:(NSString*)tmpid{
    int int_ch;
    unichar hex_char1 = [tmpid characterAtIndex:0]; ////两位16进制数中的第一位(高位*16)
    int int_ch1;
    if(hex_char1 >= '0'&& hex_char1 <='9')
        int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
    
    else if(hex_char1 >= 'A'&& hex_char1 <='F')
        
        int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
    else
        int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
    
    unichar hex_char2 = [tmpid characterAtIndex:1]; ///两位16进制数中的第二位(低位)
    
    int int_ch2;
    if(hex_char2 >= '0'&& hex_char2 <='9')
        
        int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
    
    else if(hex_char1 >= 'A'&& hex_char1 <='F')
        
        int_ch2 = hex_char2-55; //// A 的Ascll - 65
    
    else
        int_ch2 = hex_char2-87; //// a 的Ascll - 97
    
    int_ch = int_ch1+int_ch2;
    
    //NSLog(@"int========%d",int_ch);
    
    return int_ch;
}

//十进制转16进制
+(NSString *)ToBHex:(int)tmpid{
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

//16进制转字符串（ascii）
+(NSString *)stringFromHexString:(NSString *)hexString { //
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[[NSScanner alloc] initWithString:hexCharStr] autorelease];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
    
    
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

//16进制颜色(html颜色值)字符串转为UIColor
+(UIColor *) hexStringToColor: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    
    if ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+ (UIImage *) createImageWithColor: (UIColor *) color
{
    CGRect rect=CGRectMake(0, 0, Screen_Width, 44);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



//更新十六进制字符串转bytes

+(NSData *) NewhexStrToNSData:(NSString *)hexStr

{
    
    NSMutableData* data = [NSMutableData data];
    
    int idx;
    
    for (idx = 0; idx+2 <= hexStr.length; idx+=2) {
        
        NSRange range = NSMakeRange(idx, 2);
        
        NSString* ch = [hexStr substringWithRange:range];
        
        NSScanner* scanner = [NSScanner scannerWithString:ch];
        
        unsigned int intValue;
        
        [scanner scanHexInt:&intValue];
        
        [data appendBytes:&intValue length:1];
        
    }
    
    return data;
    
}


+(NSString *)formatDate{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    //[formatter setDateFormat:@"MM-dd    HH:mm"];
    NSString* str = [formatter stringFromDate:[NSDate date]];
    return str;
}

+(NSString *)formatCompareDate{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* str = [formatter stringFromDate:[NSDate date]];
    return str;
}


+(BOOL)isCurrentToday:(NSString *)dateStr{
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *tomorrow, *yesterday;
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    NSString * todayString = [[today description] substringToIndex:10];
    NSString *dateString;
    NSLog(@"时间比较dateStr====%@,todayString====%@",dateStr,todayString);
    if (dateStr.length > 10) {
        dateString=[dateStr substringToIndex:10];
    }else{
        dateString=dateStr;
    }
    if ([dateString isEqualToString:todayString])
    {
        return YES;
    } else {
        return NO;
    }
}


//判断两个日期是否是同一天
+(BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

+(NSString *) returnUploadTime:(NSString  *)timeStr{
    //Tue May 21 10:56:45 +0800 2013
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * d = [formater dateFromString:timeStr];
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        //timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
        timeString=@"今天";
    }
    
    if (cha/3600>1&&cha/86400<1) {
        //        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        //        timeString = [timeString substringToIndex:timeString.length-7];
        //        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
        NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"HH:mm"];
        //timeString = [NSString stringWithFormat:@"今天 %@",[dateformatter stringFromDate:d]];
        timeString = [NSString stringWithFormat:@"今天"];
    }
    
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        //timeString=[NSString stringWithFormat:@"%@天前", timeString];
        timeString=[NSString stringWithFormat:@"%@", timeString];
        //        NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
        //        [dateformatter setDateFormat:@"YY-MM-dd HH:mm"];
        //        timeString = [NSString stringWithFormat:@"%@",[dateformatter stringFromDate:d]];
    }
    return timeString;
}


+(NSDate *)settingTime:(NSString *)time{
    NSTimeZone* localzone = [NSTimeZone localTimeZone];
    NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:GTMzone];
    NSDate *bdate = [dateFormatter dateFromString:time];
    NSDate *day = [NSDate dateWithTimeInterval:(3600 + [localzone secondsFromGMT]) sinceDate:bdate];
    
    NSString *text = [dateFormatter stringFromDate:day];
    NSLog(@"text======%@====%@====%@",text,day,bdate);
    return bdate;
}

+(NSDate *)getCurrentDate{
    NSTimeZone* localzone = [NSTimeZone localTimeZone];
    NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:GTMzone];
    NSDate *day = [NSDate dateWithTimeInterval:(3600 + [localzone secondsFromGMT]) sinceDate:[NSDate date]];
    NSLog(@"day=====%@",day);
    return day;
}


+(NSString *) NEWreturnUploadTime:(NSString  *)timeStr{
    NSLog(@"timeStr====%@",timeStr);
    NSDate *d=[self settingTime:timeStr];
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    NSDate *d1=[self getCurrentDate];
    NSTimeInterval late1=[d1 timeIntervalSince1970]*1;
    
    NSTimeInterval cha=late1-late;
    
    NSString * timeString;
    timeString = [NSString stringWithFormat:@"%f", cha/86400];
    timeString = [timeString substringToIndex:timeString.length-7];
    return timeString;
    /*
     NSDate * startDate1 = [self settingTime:timeStr];
     NSLog(@"startDate1=======%@",startDate1);
     NSDate *startDate2=[self getCurrentDate];
     NSLog(@"startDate2===%@",startDate2);
     NSCalendar* chineseClendar = [ [ NSCalendar alloc ] initWithCalendarIdentifier:NSGregorianCalendar ];
     NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
     NSDateComponents *cps = [ chineseClendar components:unitFlags fromDate:startDate1  toDate:startDate2  options:0];
     NSLog(@"间隔天数======%d",[cps day]);
     return [NSString stringWithFormat:@"%d",[cps day]];
     */
}



@end
