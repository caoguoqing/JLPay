//
//  PublicInformation.m
//  PosN38Universal
//
//  Created by work on 14-8-8.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import "PublicInformation.h"
#import "Define_Header.h"
#import "Packing8583.h"
#import "Unpacking8583.h"
#import "ModelUserLoginInformation.h"
#import "ModelDeviceBindedInformation.h"
#import "Toast+UIView.h"



static NSString* SignBatchNo = @"SignBatchNo__";


@implementation PublicInformation


// 签到批次号
+(NSString *)returnSignSort{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSString* curBatchNo = [userDefault valueForKey:SignBatchNo];
    if (!curBatchNo || curBatchNo.length == 0) {
        curBatchNo = [self updateSignSort];
    }
    return curBatchNo;
}

// 更新批次号
+(NSString*) updateSignSort {
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSString* curBatchNo = [userDefault objectForKey:SignBatchNo];
    NSString* newBatchNo = nil;
    if (!curBatchNo || curBatchNo.length == 0) {
        curBatchNo = @"000001";
        newBatchNo = curBatchNo;
    } else {
        int batchNo = curBatchNo.intValue + 1;
        if (batchNo > 999999) {
            batchNo = 1;
        }
        newBatchNo = [NSString stringWithFormat:@"%06d", batchNo];
    }
    // save batch number
    [userDefault setObject:newBatchNo forKey:SignBatchNo];
    [userDefault synchronize];
    
    return newBatchNo;
}


//流水号,每次交易，递增,bcd,6(000008)
+(NSString *)exchangeNumber{
    int number;
    static NSString* exchangeNumber = @"exchangeNumber__";
    NSString *exchangeStr=[[NSUserDefaults standardUserDefaults] valueForKey:exchangeNumber];
    if (exchangeStr && ![exchangeStr isEqualToString:@""] && ![exchangeStr isEqualToString:@"(null)"]) {
        number =[[[NSUserDefaults standardUserDefaults] valueForKey:exchangeNumber] intValue] + 1;
    }else{
        number=1;
    }
    if (number > 999999) {
        number =1;
    }
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%06d",number] forKeyPath:exchangeNumber];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [NSString stringWithFormat:@"%06d",number];
}


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
    return [ModelDeviceBindedInformation terminalNoBinded];
}
+(NSString *)returnBusiness{
    return [ModelUserLoginInformation businessNumber];
}
+(NSString *)returnBusinessName{
    return [ModelUserLoginInformation businessName];
}

/* 获取服务器域名 */
+ (NSString*) getServerDomain {
    return @"unitepay.com.cn";
}
/* 获取TCP端口 */
+ (NSString*) getTcpPort {
    NSString* port = nil;
    if (TestOrProduce == 1) {
        port = @"28088";
    }
    else if (TestOrProduce == 7) {
        port = @"9088";
    }
    else if (TestOrProduce == 3) {
        port = @"60701";
    }
    else {
        port = @"80";
    }
    return port;
}
/* 获取HTTP端口 */
+ (NSString*) getHTTPPort {
    NSString* port = nil;
    if (TestOrProduce == 7) {
        port = @"8088";
    }
    else if (TestOrProduce == 3) {
        port = @"60780";
    }
    else {
        port = @"80";
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
    
    NSMutableString *binaryString= [[NSMutableString alloc] init];
    NSRange range = NSMakeRange(0, 1);
    for (int i=0; i<[hex length]; i++) {
        range.location = i;
        NSString *key = [hex substringWithRange:range];
        [binaryString appendString:[hexDic valueForKey:key]];
    }
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
    
    NSMutableString *resultStr=[NSMutableString new];
    for (int c=0; c<[newArr count]; c++) {
        
        for (int d=0; d<[[hexDic allKeys] count]; d++) {
            if ([[newArr objectAtIndex:c] isEqualToString:[[hexDic allKeys] objectAtIndex:d]]) {
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
    for (int b=0; b<[arr count]; b++) {
        if ([[arr objectAtIndex:b] isEqualToString:@"0"]) {
            [arr replaceObjectAtIndex:b withObject:@"1"];
        }else{
            [arr replaceObjectAtIndex:b withObject:@"0"];
        }
    }
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
    
    return int_ch;
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
    free(myBuffer);
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
    CGRect rect=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
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

// 获取当前系统日期
+ (NSString*) nowDate {
    NSString* nDate ;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    nDate = [dateFormatter stringFromDate:[NSDate date]];
    nDate = [nDate substringToIndex:8];
    return nDate;
}
+ (NSString*) nowTime {
    NSString* nDate ;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    nDate = [dateFormatter stringFromDate:[NSDate date]];
    nDate = [nDate substringToIndex:14];
    return nDate;
}
/* 当前date+time */
+(NSString*) currentDateAndTime {
    NSString* dateAntTime ;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    dateAntTime = [dateFormatter stringFromDate:[NSDate date]];
    return dateAntTime;
}

+(NSString *)formatDate{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
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
        timeString=@"今天";
    }
    
    if (cha/3600>1&&cha/86400<1) {
        NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"HH:mm"];
        timeString = [NSString stringWithFormat:@"今天"];
    }
    
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@", timeString];
    }
    return timeString;
}


+(NSDate *)settingTime:(NSString *)time{
    NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:GTMzone];
    NSDate *bdate = [dateFormatter dateFromString:time];
    return bdate;
}

+(NSDate *)getCurrentDate{
    NSTimeZone* localzone = [NSTimeZone localTimeZone];
    NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:GTMzone];
    NSDate *day = [NSDate dateWithTimeInterval:(3600 + [localzone secondsFromGMT]) sinceDate:[NSDate date]];
    return day;
}


+(NSString *) NEWreturnUploadTime:(NSString  *)timeStr{
    NSDate *d=[self settingTime:timeStr];
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    NSDate *d1=[self getCurrentDate];
    NSTimeInterval late1=[d1 timeIntervalSince1970]*1;
    
    NSTimeInterval cha=late1-late;
    
    NSString * timeString;
    timeString = [NSString stringWithFormat:@"%f", cha/86400];
    timeString = [timeString substringToIndex:timeString.length-7];
    return timeString;
}

/* 间隔天数: 两个日期 */
+ (int) daysCountDistanceDate:(NSString*)date otherDate:(NSString*)otherDate {
    NSDateFormatter* dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyyMMdd"];
    NSDate* minDate = [dateFormater dateFromString:(date.intValue < otherDate.intValue)?(date):(otherDate)];
    NSDate* maxDate = [dateFormater dateFromString:(date.intValue > otherDate.intValue)?(date):(otherDate)];
    NSTimeInterval timesInterval = [maxDate timeIntervalSinceDate:minDate];
    return (int)timesInterval / (60*60*24);
}



// 获取当前交易的交易类型
+(NSString *)returnTranType{
    NSString *businessNumber=[[NSUserDefaults standardUserDefaults] valueForKey:TranType];
    return businessNumber;
}


/* app通用ui颜色:
 *      red
 *      green
 *      blueBlack
 */
+(UIColor*) returnCommonAppColor:(NSString*)color {
    UIColor* retColor = nil;
    if ([color isEqualToString:@"red"]) {
        retColor = [UIColor colorWithRed:235.0/255.0 green:69.0/255.0 blue:75.0/255.0 alpha:1.0];
    }
    else if ([color isEqualToString:@"green"]) {
        retColor = [UIColor colorWithRed:53.0/255.0 green:176.0/255.0 blue:41.0/255.0 alpha:1.0];
    }
    else if ([color isEqualToString:@"blueBlack"]) {
        retColor = [UIColor colorWithRed:47.0/255.0 green:53.0/255.0 blue:61.0/255.0 alpha:1];
    }
    return retColor;
}

// app状态栏高度
+(CGFloat) returnStatusHeight {
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}



// app的状态栏高度+控制栏高度
+ (CGFloat) heightOfNavigationAndStatusInVC:(UIViewController *)viewController {
    CGFloat height = 0.0;
    height += [[UIApplication sharedApplication] statusBarFrame].size.height;
    height += viewController.navigationController.navigationBar.bounds.size.height;
    return height;
}

// 去掉传入的字符串末尾多余的空白字符,并拷贝一份导出
+ (NSString*) clearSpaceCharAtLastOfString:(NSString*)string {
    if (!string || string.length == 0) {
        return nil;
    }
    const char* originString = [string cStringUsingEncoding:NSUTF8StringEncoding];
    char* newString = (char*)malloc(strlen(originString) + 1);
    memset(newString, 0x00, strlen(originString) + 1);
    int copylen = (int)strlen(originString);
    char* tmp = (char*)(originString + copylen - 1);
    while (1) {
        if (isspace(*tmp)) {
            tmp--;
            copylen--;
        } else {
            break;
        }
    }
    memcpy(newString, originString, copylen);
    NSString* retString = [NSString stringWithCString:newString encoding:NSUTF8StringEncoding];
    free(newString);
    return retString;
}

// 去掉字符串中间的空白字符
+ (NSString*) clearSpaceCharAtContentOfString:(NSString*)string {
    if (!string || string.length == 0) {
        return nil;
    }
    const char* originString = [string cStringUsingEncoding:NSUTF8StringEncoding];
    char* newString = (char*)malloc(strlen(originString) + 1);
    memset(newString, 0x00, strlen(originString) + 1);

    char* temp = newString;
    for (char* origin = (char*)originString; *origin != 0; origin++) {
        if (!isspace(*origin)) {
            *temp = *origin;
            temp++;
        }
    }
    
    NSString* retString = [NSString stringWithCString:newString encoding:NSUTF8StringEncoding];
    free(newString);
    return retString;
}

/* 重置字体大小: 指定size+占比 */
+ (CGFloat) resizeFontInSize:(CGSize)size andScale:(CGFloat)scale {
    CGFloat resize = 0.0;
    CGFloat testFontSize = 20;
    CGSize testSize = [@"test" sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:testFontSize] forKey:NSFontAttributeName]];
    resize = testFontSize * (size.height/testSize.height) * scale;
    return resize;
}


#pragma mask ::: 卡号截取 e.g. 621790******3368
+ (NSString*) cuttingOffCardNo:(NSString*)cardNo {
    if (!cardNo || cardNo.length < 13) {
        return nil;
    }
    NSInteger lengthCardNo = [cardNo length];
    NSInteger lengthCutting = lengthCardNo - 6 - 4;
    
    NSMutableString* cuttingCardNo = [NSMutableString stringWithCapacity:lengthCardNo];
    // 头6位 + 中间n位* + 尾4位
    [cuttingCardNo appendString:[cardNo substringToIndex:6]];
    for (int i = 0; i < lengthCutting; i++) {
        [cuttingCardNo appendString:@"*"];
    }
    [cuttingCardNo appendString:[cardNo substringFromIndex:lengthCardNo - 4]];
    return cuttingCardNo;
}

#pragma mask ::: 交易名称转换 e.g. 消费-190000
+ (NSString*) transNameWithCode:(NSString*)transCode {
    NSString* transName = nil;
    if ([transCode isEqualToString:@"190000"]) {
        transName = @"消费 (SALE)";
    }
    else if ([transCode isEqualToString:@"280000"]) {
        transName = @"消费撤销 (VOID)";
    }
    return transName;
}

#pragma mask ::: 金额: 12位无小数点格式 -> 小数点格式
+ (NSString*) dotMoneyFromNoDotMoney:(NSString*)noDotMoney {
    // 先去掉多余的前0
    NSString* newMoney = [NSString stringWithFormat:@"%d",noDotMoney.intValue];
    NSMutableString* dotMoney = [[NSMutableString alloc] init];
    if (newMoney.length > 2) {
        [dotMoney appendFormat:@"%@.%@",[newMoney substringToIndex:newMoney.length - 2],[newMoney substringFromIndex:newMoney.length - 2]];
    } else if (newMoney.length > 0) {
        [dotMoney appendString:@"0."];
        for (int i = 0; i < 2 - newMoney.length; i++) {
            [dotMoney appendString:@"0"];
        }
        [dotMoney appendString:newMoney];
    } else {
        [dotMoney appendString:@"0.00"];
    }
    return dotMoney;
}

#pragma mask ::: 金额: 小数点格式 -> 12位无小数点格式
+ (NSString*) intMoneyFromDotMoney:(NSString*)dotMoney {
    NSString* intMoney = nil;
    if ([dotMoney rangeOfString:@"."].length > 0) {
        NSRange dotRange = [dotMoney rangeOfString:@"."];
        NSString* intPart = (dotRange.location > 0)?([dotMoney substringToIndex:dotRange.location]):(@"0");
        NSString* dotPart = (dotRange.location + dotRange.length == dotMoney.length)?(@"0"):([dotMoney substringFromIndex:dotRange.location + dotRange.length]);
        intMoney = [NSString stringWithFormat:@"%012d",intPart.intValue * 100 + dotPart.intValue];
    }
    return intMoney;
}


#pragma mask ::: 金额: c小数点格式 -> 12位无小数点格式
+ (NSString*) moneyStringWithCString:(char*)cstring {
    char* newString = (char*)malloc(12+1);
    memset(newString, 0x00, 12+1);
    memset(newString, '0', 12);
    int len = (int)strlen(cstring);
    int setIndex = 12 - 1;
    char* tmp = cstring + len - 1;
    while (1) {
        if (tmp == cstring) {
            newString[setIndex] = *tmp;
            break;
        }
        if (*tmp != '.') {
            newString[setIndex] = *tmp;
            setIndex--;
        }
        tmp--;
    }
    
    NSString* moneyString = [NSString stringWithCString:newString encoding:NSUTF8StringEncoding];
    free(newString);
    return moneyString;
}

// 缩放图片
+ (UIImage*) imageScaledBySourceImage:(UIImage*)image
                       withWidthScale:(CGFloat)wScale
                       andHeightScale:(CGFloat)hScale
{
    CGRect newRect = CGRectMake(0, 0, image.size.width*wScale, image.size.height*hScale);
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, [UIScreen mainScreen].scale);
    [image drawInRect:newRect];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/* 版本号 */
+ (NSString*) AppVersionNumber {
    NSString* versionNumber = nil;
    versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    if (NeedPrintLog) {
        NSLog(@"app的版本号:[%@]",versionNumber);
    }
    return versionNumber;
}

/* 创建一个空的回退bar按钮 */
+ (UIBarButtonItem*) newBarItemWithNullTitle {
    return [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}
+ (UIBarButtonItem*) newBarItemNullTitleInViewController:(UIViewController*)viewController {
    return [[UIBarButtonItem alloc] initWithTitle:@""
                                            style:UIBarButtonItemStylePlain
                                           target:viewController.navigationController
                                           action:@selector(popViewControllerAnimated:)];
}

/* 拉丝提示 */
+ (void) makeToast:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate.window makeToast:message];
    });
}
+ (void) makeCentreToast:(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate.window makeToast:message duration:1.5f position:@"center"];
    });
}

// -- AlertView 简化
+ (void) alertCancleAndSureWithTitle:(NSString*)title message:(NSString*)message tag:(NSInteger)tag delegate:(id)delegate // 取消+确定
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView setTag:tag];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
}
+ (void) alertSureWithTitle:(NSString *)title message:(NSString *)message tag:(NSInteger)tag delegate:(id)delegate  // 确定
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView setTag:tag];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
}
+ (void) alertCancleAndOther:(NSString*)other title:(NSString*)title message:(NSString*)message tag:(NSInteger)tag delegate:(id)delegate // 取消+"其他"
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"取消" otherButtonTitles:other, nil];
    [alertView setTag:tag];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
}




@end
