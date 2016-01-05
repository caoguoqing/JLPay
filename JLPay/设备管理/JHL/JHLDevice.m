//
//  JHLDevice.m
//  JLPay
//
//  Created by jielian on 15/6/1.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "JHLDevice.h"
#import "CommunicationManager.h"
#import "PublicInformation.h"
#import "CommunicationCallBack.h"
#import "Toast+UIView.h"
#import "Define_Header.h"

@interface JHLDevice()<CommunicationCallBack>
@property (nonatomic, strong) CommunicationManager* osmanager;

@end


@implementation JHLDevice

@synthesize osmanager               = _osmanager;


static FieldTrackData TransData;



#pragma mask --------------------------[Public Interface]--------------------------
#pragma mask : 打开设备探测;
- (void) detecting{
    if (self.osmanager == nil) {
        self.osmanager              = [CommunicationManager sharedInstance];
    }
    [self.osmanager startDetecting];
}


#pragma mask : 打开设备-阻塞线程打开;
- (void)open {
    NSThread* deviceOpenThread      = [[NSThread alloc] initWithTarget:self selector:@selector(deviceOpenThread) object:nil];
    [deviceOpenThread start];
}

#pragma mask : 关闭设备;
- (void) close {
    
}

#pragma mask : 检查设备是否连接;
- (BOOL) isConnected {
    if (self.osmanager == nil) {
        self.osmanager              = [CommunicationManager sharedInstance];
    }
    return [self.osmanager isConnected];
}


#pragma mask : 刷卡
- (int) cardSwipeInTime: (long)timeOut mount: (long)nMount mode: (long)brushMode{
    Byte SendData[1+12 +3+1]={0x00};
    SendData[0] =GETCARD_CMD;
    sprintf((char *)SendData+1, "%012ld", nMount);
    NSString *strDate = [self returnDate];
    NSData* bytesDate =[self StrHexToByte:strDate];
    Byte * ByteDate = (Byte *)[bytesDate bytes];
    memcpy(SendData+13,ByteDate+1, 3);
    if ((timeOut <20000) || (timeOut >60000))
        timeOut =60*1000;
    long ntimeout =timeOut/1000;
    SendData[16] =ntimeout;
    
    NSData *SendArryByte = [[NSData alloc] initWithBytes:SendData length:1+12 +3+1];
    int result =[self.osmanager exchangeData:SendArryByte timeout:timeOut cb:self];
    if (Print_log)
    {
        NSLog(@"%s %@",__func__,SendArryByte);
        NSLog(@"%s,result:%d",__func__,result);
    }
    return SUCESS;
}

#pragma mask : 读取卡片信息：卡号、磁道信息、芯片信息
-(int)TRANS_Sale:(long)timeout :(long)nAmount :(int)nPasswordlen :(NSString*)bPassKey
{
    int nPasLen=0;
    Byte  SendData[25] ={0x00};
    Byte  bPass[8] ={0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff};
    SendData[0] =GETTRACK_CMD;
    SendData[1] =MAIN_KEY_ID;
    sprintf((char *)SendData+2, "%012ld", nAmount);
    NSString *strF =@"f";
    nPasLen =nPasswordlen;
    if (nPasswordlen%2 !=0)
    {
        bPassKey = [bPassKey stringByAppendingString:strF];
        nPasLen ++;
    }
    
    bPass[0]=nPasswordlen;
    NSData* bytesPass =[self StrHexToByte:bPassKey];
    memcpy(bPass + 1,[bytesPass bytes], nPasLen/2);
    memcpy(SendData+14,bPass, 8);
    SendData[22] =PIN_KEY_ID;
    SendData[23] =MAIN_KEY_ID;
    SendData[24] =MAIN_KEY_ID;
    
    NSData *SendArryByte = [[NSData alloc] initWithBytes:SendData length:25];
    int result =[self.osmanager exchangeData:SendArryByte timeout:timeout cb:self];
    return result;
}


#pragma mask : 主密钥下载
- (int) mainKeyDownload{
    return 0;
}

#pragma mask : 工作密钥设置
-(int)WriteWorkKey:(int)len :(NSString*)DataWorkkey
{
    if (self.osmanager ==NULL)
        self.osmanager = [CommunicationManager sharedInstance];
    int result = [self.osmanager isConnected];
    if (!result)
        return  result;
    
    DataWorkkey = [@"38" stringByAppendingString:DataWorkkey];
    
    NSData* bytesDate = [self StrHexToByte:DataWorkkey];
    result = [self.osmanager exchangeData:bytesDate timeout:WAIT_TIMEOUT cb:self];

    return result;
}

#pragma mask : 参数下载
- (int) parameterDownload{
    return 0;
}
#pragma mask : IC卡公钥下载
- (int) ICPublicKeyDownload{
    return 0;
}
#pragma mask : EMV参数下载
- (int) EMVDownload{
    return 0;
}


#pragma mask --------------------------[Private Interface]--------------------------


#pragma mask : 设备交互的返回数据接收方法
-(void)onReceive:(NSData*)data{
    Byte * ByteDate = (Byte *)[data bytes];
    switch (ByteDate[0]) {
        // 刷卡
        case GETCARD_CMD:
            if (!ByteDate[1])   // 成功
            {
                NSLog(@"%s,result:%@",__func__,@"刷卡成功");
//                NSNotification* notification    = [NSNotification notificationWithName:Noti_CardSwiped_Success object:nil];
//                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
            else                // 失败
            {
                NSLog(@"%s,result:%@",__func__,@"刷卡失败");
//                NSNotification* notification    = [NSNotification notificationWithName:Noti_CardSwiped_Fail object:nil];
//                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
            break;
        // 消费:获取卡数据
        case GETTRACK_CMD:
            if (!ByteDate[1])   // 获取卡数据成功
            {
                [self GetCard:data];    // 解析卡数据到缓存
//                [self cardDataUserDefult];
                // 从缓存中读取密码密文
//                NSNotification* notification    = [NSNotification notificationWithName:Noti_TransSale_Success object:nil];
//                [[NSNotificationCenter defaultCenter] postNotification:notification];   // test for reading card data,not trans
            }
            else
            {
//                NSNotification* notification    = [NSNotification notificationWithName:Noti_TransSale_Fail object:nil];
//                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
            break;
        // 写工作密钥
        case WORKKEY_CMD:
            if (!ByteDate[1]) { // 写成功
//                [[NSNotificationCenter defaultCenter] postNotificationName:Noti_WorkKeyWriting_Success object:nil];
            } else {            // 写失败
//                [[NSNotificationCenter defaultCenter] postNotificationName:Noti_WorkKeyWriting_Fail object:nil];
            }
            break;
        // 读取设备电量
        case BATTERY:
            if (!ByteDate[1]) { // 成功
                int batteryLeft = ByteDate[2];
                NSLog(@"设备电量:%d", batteryLeft);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (batteryLeft < 10) {
                        [PublicInformation makeToast:[NSString stringWithFormat:@"设备打开成功,电量过低:%d%%",batteryLeft]];
                    } else {
                        [PublicInformation makeToast:[NSString stringWithFormat:@"设备打开成功,电量:%d%%",batteryLeft]];
                    }
                });
            } else {            // 失败
                [PublicInformation makeToast:@"设备打开失败"];
            }
            break;

        default:
            break;
    }
}

#pragma mask : 线程中的轮询方法:打开设备
- (void) deviceOpenThread {
    BOOL flag = YES;
    while (YES) {
        int result                  = [self openDevice];
        if (flag) {
            [self stateCheck:result];
            flag = NO;
        }
        if (result == KNOWED_DEVICE_ING) { // 成功
            break;
        }
        [NSThread sleepForTimeInterval:0.5];
    }
    // 出了循环就说明设备打开成功了,需要通知调用方发起签到
    [self ReadBattery];
}

#pragma mask : 打开设备
- (int) openDevice {
    if (!self.osmanager) {
        self.osmanager = [CommunicationManager sharedInstance];
    }
    NSString *astring  =[CommunicationManager getLibVersion];
    NSLog(@"库的版本号:::::%@",astring);
    int result = [self.osmanager openDevice];
    
    NSLog(@".........................openDevice = [%d]",result);
    return result;
}

#pragma mask : 检查设备连接状态
- (void) stateCheck: (int)resultState {
    switch (resultState) {
        case KNOWED_DEVICE_ING:
            dispatch_async(dispatch_get_main_queue(), ^{
                if (Print_log) {
                    NSLog(@"%s, 设备已经打开", __func__);
                }
            });
            break;
        case KNOWING_DEVICE_ING:
            dispatch_async(dispatch_get_main_queue(), ^{
                if (Print_log) {
                    NSLog(@"%s, 设备正在识别......", __func__);
                    [PublicInformation makeToast:@"正在识别设备..."];
                }
            });
            break;
        case UNKNOW_DEVICE_ING:
            dispatch_async(dispatch_get_main_queue(), ^{
                if (Print_log) {
                    NSLog(@"%s, 设备无法识别", __func__);
                    [PublicInformation makeToast:@"无法识别设备"];
                }
            });
            break;
        case NO_DEVICE_INSERT:
            dispatch_async(dispatch_get_main_queue(), ^{
                if (Print_log) {
                    NSLog(@"%s, 没有设备介入 （设备拔出）", __func__);
                    [PublicInformation makeToast:@"没有插入设备"];
                }
            });
            break;
        case DEVICE_NEED_UPDATE_ING:
            dispatch_async(dispatch_get_main_queue(), ^{
                if (Print_log) {
                    NSLog(@"%s, 刷卡器已识别，但需要升级", __func__);
                    [PublicInformation makeToast:@"设备版本过低,请升级固件"];
                }
            });
            break;
        default:
            break;
    }
}


/*
 函 数 名：ReadBattery
 功能描述：获取电池电量
 入口参数：
 返回说明：成功/失败
 **********************************************************/
-(int)ReadBattery
{
    if (self.osmanager ==NULL)
        self.osmanager = [CommunicationManager sharedInstance];
    int result = [self.osmanager isConnected];
    if (!result)
        return  result;
    
    NSMutableData* data = [[NSMutableData alloc] init];
    Byte array[1] = {BATTERY};
    [data appendBytes:array length:1];
    result =[self.osmanager exchangeData:data timeout:WAIT_TIMEOUT cb:self];
    return result;
}


#pragma mask : 获取手机系统年月日
-(NSString *)returnDate
{
    NSDate *theDate = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
    NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:theDate];
    NSString *returnString = [NSString stringWithFormat:@"%02i%02i%02i",(int)[components year],(int)[components month],(int)[components day]];
    return returnString;
}

#pragma mask : 字符串转16进制的 Byte 型
-(NSData*)StrHexToByte:(NSString*)strHex
{
    NSString *hexString=[[strHex uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

#pragma mask : BCD码 转 ASCII码
-(void) BcdToAsc:(Byte *)Dest :(Byte *)Src :(int)Len
{
    int i;
    for(i=0;i<Len;i++)
    {
        //高Nibble转换
        if(((*(Src + i) & 0xF0) >> 4) <= 9)
        {
            *(Dest + 2*i) = ((*(Src + i) & 0xF0) >> 4) + 0x30;
        }
        else
        {
            *(Dest + 2*i)  = ((*(Src + i) & 0xF0) >> 4) + 0x37;   //大写A~F
        }
        //低Nibble转换
        if((*(Src + i) & 0x0F) <= 9)
        {
            *(Dest + 2*i + 1) = (*(Src + i) & 0x0F) + 0x30;
        }
        else
        {
            *(Dest + 2*i + 1) = (*(Src + i) & 0x0F) + 0x37;   //大写A~F
        }
    }
}


#pragma mask : 解析卡片数据到缓存
-(int)GetCard:(NSData*)TrackData
{
    /*
     20 00 0210
     136210985800012004611d491212061006000000
     136210985800012004611df5f98f2fb41d89000f
     34996210985800012004611d1561560000000000000003000000114000049121d000000000000d000000000000d00000 0061006000
     34996210985800012004611d1561560000000000000003000000114000049121d000000000000d0000000000450b3e bc742369 7f
     000000
     08cb59e6ea6d58c338
     00
     */
    
    int nIndex =0,nIndexlen=0;
    Byte  ByteData[512] ={0x00};
    Byte  szTrack2[80] ={0x00};
    //NSUInteger len = [TrackData length];
    memcpy(ByteData, (Byte *)[TrackData bytes], [TrackData length]);
    nIndex ++;
    TransData.iCardmodem =ByteData[nIndex];
    nIndex ++;
    memcpy(&TransData.szEntryMode, ByteData+nIndex, 2);
    nIndex +=2;
    
    /*
     //pan
     nIndexlen =ByteData[nIndex];
     memcpy(&TransData.TrackPAN, ByteData+nIndex+1, nIndexlen);
     nIndex +=1;
     nIndex +=nIndexlen;
     */
    //2磁道数据
    TransData.nTrack2Len =ByteData[nIndex];
    memcpy(&TransData.szTrack2, ByteData+nIndex+1, TransData.nTrack2Len);
    nIndex +=1;
    nIndex +=TransData.nTrack2Len;
    
    //2磁道加密数据
    TransData.nEncryTrack2Len =ByteData[nIndex];
    memcpy(&TransData.szEncryTrack2, ByteData+nIndex+1, TransData.nEncryTrack2Len);
    nIndex +=1;
    nIndex +=TransData.nEncryTrack2Len;
    
    
    //3磁道数据
    TransData.nTrack3Len =ByteData[nIndex];
    memcpy(&TransData.szTrack3, ByteData+nIndex+1, TransData.nTrack3Len);
    nIndex +=1;
    nIndex +=TransData.nTrack3Len;
    //3磁道加密数据
    TransData.nEncryTrack3Len =ByteData[nIndex];
    memcpy(&TransData.szEncryTrack3, ByteData+nIndex+1, TransData.nEncryTrack3Len);
    nIndex +=1;
    nIndex +=TransData.nEncryTrack3Len;
    
    //IC卡数据长度
    TransData.IccdataLen = ((ByteData[nIndex] << 8) & 0xFF00);
    TransData.IccdataLen |= ByteData[nIndex+1] & 0xFF;
    nIndex +=2;
    memcpy(&TransData.Field55Iccdata, ByteData+nIndex, TransData.IccdataLen);
    nIndex+= TransData.IccdataLen;

    
    //PINBLOCK
    nIndexlen=ByteData[nIndex];
    memcpy(&TransData.sPIN, ByteData+nIndex+1, nIndexlen);
    nIndex +=1;
    nIndex +=nIndexlen;
    
    //卡片序列号
    nIndexlen=ByteData[nIndex];
    memcpy(&TransData.CardSeq, ByteData+nIndex+1, nIndexlen);
    nIndex +=1;
    nIndex +=nIndexlen;
    
    [self BcdToAsc:szTrack2 :TransData.szTrack2 :80];
    for(int i=0;i<80;i++)		// convert 'D' to '='
    {
        if( szTrack2[i]=='D' )
        {
            nIndexlen =i;
            break;
        }
    }
    if(nIndexlen >0)
    {
        // 卡号
        strncpy(TransData.TrackPAN,(char *)szTrack2, nIndexlen);
        // 卡有效期
        strncpy((char*)TransData.CardValid, (char *)szTrack2+nIndexlen + 1, 4);
        //服务代码
        strncpy(TransData.szServiceCode, (char *)szTrack2+nIndexlen + 5, 3);
        if((TransData.szServiceCode[0] == '2') ||(TransData.szServiceCode[0] == '6'))
            TransData.iCardtype =1;
        else
            TransData.iCardtype =0;
    }
    // 打印读到得数据
    [self logTransData];
    
    return  SUCESS;
}

#pragma mask : 将读卡数据的需要的部分值取出，并保存到本地配置
//- (void) cardDataUserDefult {
//    Byte dataStr[512] = {0x00};
//    
//    // 卡片有效期 Card_DeadLineTime
//    memset(dataStr, 0, 512);
//    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%s",(char*)TransData.CardValid] forKey:Card_DeadLineTime];
//    
//    // 2磁道加密数据
//    memset(dataStr, 0, 512);
//    [self BcdToAsc:dataStr :TransData.szEncryTrack2 :TransData.nEncryTrack2Len];
//    NSLog(@"2磁数据:[%s]", dataStr);
//    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%s",dataStr] forKey:Two_Track_Data];
//    
//    // PINBLOCK -- 密文密码
//    memset(dataStr, 0, 512);
//    [self BcdToAsc:dataStr :TransData.sPIN :(int)strlen((char*)TransData.sPIN)];
//    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%s",dataStr] forKey:Sign_in_PinKey];
//
//    // 芯片数据55域信息
//    if (TransData.IccdataLen > 0) {
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CardTypeIsTrack];  // 设置读卡方式:芯片
//        memset(dataStr, 0, 512);
//        [self BcdToAsc:dataStr :TransData.Field55Iccdata :TransData.IccdataLen];
//        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%s",dataStr] forKey:BlueIC55_Information];
//    } else {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CardTypeIsTrack];  // 设置读卡方式:磁条
//    }
//    
//    // 芯片序列号23域值
//    memset(dataStr, 0, 512);
////    [self BcdToAsc:dataStr :TransData.CardSeq :(int)strlen((char*)TransData.CardSeq)];
//    strcpy((char*)dataStr, "0001"); // 不从卡读取了，直接赋值
//
//    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%s",dataStr] forKey:ICCardSeq_23];
//    
//    // 卡号
//    memset(dataStr, 0, 512);
//    NSString *strData ;
//    strData = [[NSString alloc] initWithCString:(const char*)TransData.TrackPAN encoding:NSASCIIStringEncoding];
//    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@*****%@",[strData substringWithRange:NSMakeRange(0, [strData length]-9)],[strData substringWithRange:NSMakeRange([strData length]-4, 4)]] forKey:GetCurrentCard_NotAll];
//    [[NSUserDefaults  standardUserDefaults]setObject:strData forKey:Card_Number];
//    
//    [[NSUserDefaults standardUserDefaults]synchronize];
//}


#pragma mask : CommunicationCallBack 的暂时无用的协议
- (void)onTimeout {
    dispatch_async(dispatch_get_main_queue(), ^{
        [PublicInformation makeToast:@"设备读取超时"];
    });
}

- (void)onError:(NSInteger)code message:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [PublicInformation makeToast:msg];
    });
}
-(void)onSendOK {

}
-(void)onProgress:(NSData*)data{
    
}

#pragma mask : 锦宏霖设备的入口初始化
- (instancetype)init {
    self                            = [super init];
    if (self) {
        _osmanager                  = [CommunicationManager sharedInstance];
        memset(&TransData, 0x00, sizeof(FieldTrackData));   // 卡片数据缓存区
    }
    return self;
}


// 打印读到的芯片卡得数据
- (void) logTransData {
    NSMutableString* logStr = [[NSMutableString alloc] initWithString:@"\n----\nTransData:[\n"];
    /*
     unsigned char iTransNo;         //交易类型,指的什么交易 目前暂未使用
     int iCardtype;                          //刷卡卡类型  磁条卡 IC卡
     int iCardmodem;                         //刷卡模式
     char TrackPAN[21];                      //域2  主帐号
     unsigned char CardValid[5];       //域14 卡有效期
     char szServiceCode[4];                  //服务代码
     unsigned char CardSeq[2];       //域23 卡片序列号
     unsigned char szEntryMode[3];     //域22 服务点输入方式
     unsigned char szTrack2[40];       //域35 磁道2数据
     unsigned char szEncryTrack2[40];    //域35 磁道2加密数据 第一个字节为长度
     unsigned char szTrack3[108];      //域36 磁道3数据
     unsigned char szEncryTrack3[108];   //域36 磁道3加密数据
     unsigned char sPIN[13];         //域52 个人标识数据(pind ata)
     unsigned char Field55Iccdata[300];    //的55域信息512->300
     unsigned char FieldEncrydata[300];    //随机加密数据 //针对客户
     */
    [logStr appendString:[NSString stringWithFormat:@"iTransNo = [%c]\n", TransData.iTransNo]];
    [logStr appendString:[NSString stringWithFormat:@"iCardtype = [%d]\n", TransData.iCardtype]];
    [logStr appendString:[NSString stringWithFormat:@"iCardmodem = [%d]\n", TransData.iCardmodem]];
    [logStr appendString:[NSString stringWithFormat:@"TrackPAN = [%s]\n", TransData.TrackPAN]];
    [logStr appendString:[NSString stringWithFormat:@"CardValid = [%s]\n", TransData.CardValid]];
    [logStr appendString:[NSString stringWithFormat:@"szServiceCode = [%s]\n", TransData.szServiceCode]];
    [logStr appendString:[NSString stringWithFormat:@"CardSeq = [%s]\n", TransData.CardSeq]];
    [logStr appendString:[NSString stringWithFormat:@"szEntryMode = [%s]\n", TransData.szEntryMode]];
    [logStr appendString:[NSString stringWithFormat:@"szTrack2 = [%s]\n", TransData.szTrack2]];
    [logStr appendString:[NSString stringWithFormat:@"szEncryTrack2 = [%s]\n", TransData.szEncryTrack2]];
    [logStr appendString:[NSString stringWithFormat:@"szTrack3 = [%s]\n", TransData.szTrack3]];
    [logStr appendString:[NSString stringWithFormat:@"szEncryTrack3 = [%s]\n", TransData.szEncryTrack3]];
    [logStr appendString:[NSString stringWithFormat:@"sPIN = [%s]\n", TransData.sPIN]];
    [logStr appendString:[NSString stringWithFormat:@"Field55Iccdata = [%s]\n", TransData.Field55Iccdata]];
    [logStr appendString:[NSString stringWithFormat:@"FieldEncrydata = [%s]\n", TransData.FieldEncrydata]];
    [logStr appendString:[NSString stringWithFormat:@"iccDataLen = [%d]\n", TransData.IccdataLen]];

    
    [logStr appendString:@"]----\n"];
    NSLog(@"%@",logStr);
    
}



@end
