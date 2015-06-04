//
//  ViewController.m
//  CommunicationTest

#import "JHNconnect.h"

#import "CommunicationManager.h"
#import "Toast+UIView.h"

static JHNconnect *JHNcon = nil;

@interface JHNconnect ()<CommunicationCallBack>
@property(nonatomic,strong) CommunicationManager* osmanager;




@end

@implementation JHNconnect
@synthesize osmanager;
//@synthesize LabTip;



static int nAmount =100;
static FieldTrackData TransData;


+(JHNconnect *)shareView{
    @synchronized([JHNconnect class]){
        if(JHNcon ==nil){
            JHNcon = [[self alloc] init];
            
        }
    }
    return JHNcon;
}


-(void)openDevice{
    
    
    NSThread* DeviceThread =[[NSThread alloc] initWithTarget:self selector:@selector(CheckDevceThread)
                                                  object:nil];
    [DeviceThread start];
}
/*
-(IBAction)closeDevice{
    if (osmanager ==NULL)
    {
        if (Language ==0)
            [self.LabTip setText:@"请先打开设备"];
        else
            [self.LabTip setText:@"Please Open Device."];
        return;
    }
      if (Language ==0)
         [self.LabTip setText:@"SetMainKey Wait..."];
      else
          [self.LabTip setText:@"正在设置主密钥..."];
    NSString *strkey =@"12345678900987654321123456789012";
    [self WriteMainKey:16:strkey];
}


-(IBAction)closeResource{
    
    if (osmanager ==NULL)
    {
        if (Language ==0)
            [self.LabTip setText:@"请先打开设备"];
        else
            [self.LabTip setText:@"Please Open Device."];
        return;

    }
    if (Language ==0)
        [self.LabTip setText:@"SetWorkKey Wait..."];
    else
        [self.LabTip setText:@"正在设置工作密钥..."];

    NSString *strkey =@"7b77f240a6b49d378046d5b721fa551bf43a277b77f240a6b49d378046d5b721fa551bf43a277b77f240a6b49d378046d5b721fa551bf43a27";
    [self WriteWorkKey:57:strkey];
    
    

}
-(IBAction)exchangeData{
    
    if (osmanager ==NULL)
    {
        if (Language ==0)
            [self.LabTip setText:@"请先打开设备"];
        else
            [self.LabTip setText:@"Please Open Device."];
        return;

    }
    [self.LabCardNum setText:@""];
    if (Language ==0)
         [self.LabTip setText:@"Please swipe card..."];
    else
        [self.LabTip setText:@"请刷卡..."];
    NSLog(@" %@",@"请刷卡...");
    [self MagnCard:20000:nAmount:0];
}
*/
-(void)exchangeData{
    
    
    NSLog(@" %@",@"请刷卡...");
    [self MagnCard:20000:0:0];
}

/*
 设置交易功能
 */

-(void )SetFunction
{
//    if (Language ==0)
//        self.LabTip.text =[NSString stringWithFormat:@"Getting the SN No...."];
//    else
//        self.LabTip.text =[NSString stringWithFormat:@"正在获取SN号..."];
   [self GetSnVersion];
    

    
    //[self.LabTip setText:@"请刷卡..."];
   // NSLog(@" %@",@"请刷卡...");
    //[self MagnCard:20000:nAmount:0];

}

/*
 设备状态 改变
 */
-(void )StatusChange:(int )Nstate
{
     NSLog(@"%s,result:%d",__func__,Nstate);
    switch (Nstate) {
        case KNOWED_DEVICE_ING://刷卡器已识别
        {
             dispatch_async(dispatch_get_main_queue(), ^{
//            if (Language ==0)
//                [self.LabTip setText:@"Open succeeded"];
//            else
//                [self.LabTip setText:@"刷卡器打开成功"];

            [self SetFunction];
             });
        }
            break;
        case UNKNOW_DEVICE_ING://设备接入但不能识别为刷卡器
        {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
//            [self.LabTip setText:@"设备接入但不能识别为刷卡器 "];
             });
        }
            break;
        case NO_DEVICE_INSERT://没有设备介入 （设备拔出）
        {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
//                 if (Language ==0)
//                     [self.LabTip setText:@"No Device"];
//                 else
//                     [self.LabTip setText:@"没有设备介入"];
             });
        }
            break;
        case KNOWING_DEVICE_ING://设备正在识别
        {
             dispatch_async(dispatch_get_main_queue(), ^{
//                 if (Language ==0)
//                     [self.LabTip setText:@"Device is recognition"];
//                 else
//                     [self.LabTip setText:@"设备正在识别 "];
             });
        }
            break;
        case DEVICE_NEED_UPDATE_ING://刷卡器已识别，但需要升级
        {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
//                 [self.LabTip setText:@"刷卡器已识别，但需要升级 "];
             });
        }
            break;
        default:
            break;
    }
}

/**
 *  检查设备打开线程
 */

-(void) CheckDevceThread
{
    while (true) {

        int result =[self openJhlDevice];
        [self StatusChange:result];
        if (result ==0)
        {
            break;
        }
        [NSThread sleepForTimeInterval:0.5];
        
    }
}

- (void)timeToZero:(NSTimer *)timer
{

//    LabTip.text = @"12345678";
  
}


/**
 *  打开JHL刷卡头设备
 */
-(int)openJhlDevice
{
    memset(&TransData, 0x00, sizeof(FieldTrackData));
    if (osmanager ==NULL)
        osmanager = [CommunicationManager sharedInstance];
    
    
    NSString *astring  =[CommunicationManager getLibVersion];
    
    NSLog(@"%@",astring);
    int result = [osmanager openDevice];

    NSLog(@"%s,result:%d",__func__,result);
    return result;
    
    
}

/*
 关闭设备
 */
-(void)closeJhlDevice
{
    if (osmanager !=NULL)
    {
        [osmanager closeDevice];
    }
}
/*
 释放相关资源,关闭设备之前调用
 */
-(void)closeJhlResource;
{
    if (osmanager !=NULL)
    {
        [osmanager closeResource];
    }
}
/*
 判断是否处于连接状态
 */
-(BOOL)isConnected
{
    if (osmanager ==NULL)
        osmanager = [CommunicationManager sharedInstance];
    int result = [osmanager isConnected];
    if (Print_log)
        NSLog(@"%s,result:%d",__func__,result);
    return result;
    
}


/*
 读取SN号版本号
 */

-(int)GetSnVersion
{
    if (osmanager ==NULL)
        osmanager = [CommunicationManager sharedInstance];
    int result = [osmanager isConnected];
    if (!result)
        return  result;
    
    NSMutableData* data = [[NSMutableData alloc] init];
    Byte array[1] = {GETSNVERSION};
    [data appendBytes:array length:1];
    result =[osmanager exchangeData:data timeout:WAIT_TIMEOUT cb:self];
    return result;
    
}

/********************************************************************
 
	函 数 名：WriteMainKey
	功能描述：写入主密钥
	入口参数：
 int		len		--主密钥长度
 int 	Datakey		--主密钥数据16个字节
	返回说明：成功/失败
 **********************************************************/

-(int)WriteMainKey:(int)len :(NSString*)Datakey
{
    if (osmanager ==NULL)
        osmanager = [CommunicationManager sharedInstance];
    int result = [osmanager isConnected];
    if (!result)
        return  result;
    
    Datakey = [@"340110" stringByAppendingString:Datakey];
    NSLog(@"datakey ==================%@",Datakey);
    NSData* bytesDate =[self StrHexToByte:Datakey];
    result =[osmanager exchangeData:bytesDate timeout:WAIT_TIMEOUT cb:self];
    if (Print_log)
    {
        NSLog(@"%s %@",__func__,bytesDate);
        NSLog(@"%s,result:%d",__func__,result);
    }
    return SUCESS;
}

/********************************************************************
 
	函 数 名：GetMac
	功能描述：获取MAC值
	入口参数：
 int		len		--MAC长度
 NSString 	Datakey		--Mac数据
	返回说明：成功/失败
 **********************************************************/

-(int)GetMac:(int)len :(NSString*)Datakey
{
    if (osmanager ==NULL)
        osmanager = [CommunicationManager sharedInstance];
  
    int result = [osmanager isConnected];
    if (!result)
        return  result;

    Byte templen[2]={0};
    NSString* Data =@"";
    templen[0] =(len)/256;
    templen[1] =(len)%256;
    NSString *hexStr=@"";
    for(int i=0;i<2;i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",templen[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    Data = [@"3704" stringByAppendingString:hexStr];
    Datakey = [Data stringByAppendingString:Datakey];
    Datakey = [Datakey stringByAppendingString:@"0301"];
    NSData* bytesDate =[self StrHexToByte:Datakey];
  
    result =[osmanager exchangeData:bytesDate timeout:WAIT_TIMEOUT cb:self];
    if (Print_log)
    {
        NSLog(@"%s %@",__func__,bytesDate);
        NSLog(@"%s,result:%d",__func__,result);
    }
   
   
    return SUCESS;
}



/********************************************************************
 
	函 数 名：WriteWorkKey
	功能描述：写入工作密钥
	入口参数：
 int		len		--主密钥长度
 int 	DataWorkkey	--工作密钥数据57个字节
 16字节PIN密钥+3个字节校验码 +16字节MAC +3个字节MAC校验码 +磁道加密密钥+磁道加密密钥校验码  ==57 个字节
 
	返回说明：成功/失败
 **********************************************************/
-(int)WriteWorkKey:(int)len :(NSString*)DataWorkkey
{
    if (osmanager ==NULL)
        osmanager = [CommunicationManager sharedInstance];
    int result = [osmanager isConnected];
    if (!result)
        return  result;
    DataWorkkey = [@"38" stringByAppendingString:DataWorkkey];
    
    NSLog(@"dataworkkey======= %@",DataWorkkey);

    // arrayData[0] =WORKKEY_CMD;
    NSData* bytesDate =[self StrHexToByte:DataWorkkey];
    result =[osmanager exchangeData:bytesDate timeout:WAIT_TIMEOUT cb:self];
    if (Print_log)
    {
        NSLog(@"%s %@",__func__,bytesDate);
        NSLog(@"%s,result:%d",__func__,result);
    }
    return SUCESS;
}


/*
函 数 名：WriteTernumber
功能描述：写入终端号商户号
入口参数：
NSString 	DataTernumber	--终端号+商户号=23字节 ASCII
返回说明：成功/失败
**********************************************************/
-(int)WriteTernumber:(NSString*)DataTernumber
{
    if (osmanager ==NULL)
        osmanager = [CommunicationManager sharedInstance];
    int result = [osmanager isConnected];
    if (!result)
        return  result;
    DataTernumber = [@"42" stringByAppendingString:DataTernumber];
    
    
    // arrayData[0] =WORKKEY_CMD;
    NSData* bytesDate =[self StrHexToByte:DataTernumber];
    result =[osmanager exchangeData:bytesDate timeout:WAIT_TIMEOUT cb:self];
    if (Print_log)
    {
        NSLog(@"%s %@",__func__,bytesDate);
        NSLog(@"%s,result:%d",__func__,result);
    }
    return SUCESS;
}


/*
 函 数 名：ReadTernumber
 功能描述：读取终端号商户号
 入口参数：
 返回说明：成功/失败
 **********************************************************/
-(int)ReadTernumber
{
    if (osmanager ==NULL)
        osmanager = [CommunicationManager sharedInstance];
    int result = [osmanager isConnected];
    if (!result)
        return  result;
    
    NSMutableData* data = [[NSMutableData alloc] init];
    Byte array[1] = {GETTERNUMBER};
    [data appendBytes:array length:1];
    result =[osmanager exchangeData:data timeout:WAIT_TIMEOUT cb:self];
    return result;
}


-(NSString *)returnDate
{
    NSDate *theDate = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
    NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:theDate];
    
    
    NSString *returnString = [NSString stringWithFormat:@"%02i%02i%02i",(int)[components year],(int)[components month],(int)[components day]];
    
    
    return returnString;
}

-(NSString *)returnTime
{
    NSDate *theDate = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
    NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:theDate];
    
    NSString *returnString = [NSString stringWithFormat:@"%02d%02d%02d",(int)[components hour],(int)[components minute],(int)[components second]];
    
    return returnString;
}

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

-(void) BcdToAsc:(Byte *)Dest:(Byte *)Src:(int)Len
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

/********************************************************************
	函 数 名：MagnCard
	功能描述：刷卡
	入口参数：
 long 	timeout 		--刷卡超时时间(毫秒)
 long 	nAmount			--交易金额,用于IC卡(1元==100),
 查询余额送0即可
 int 	BrushCardM		--刷卡模式(0:不支持降级交易 1:支持降级交易 设置为0芯片卡刷磁条卡返回不允许降级)
	返回说明：
 **********************************************************/
-(int)MagnCard:(long)timeout :(long)nAmount :(int)BrushCardM
{
    // Byte bAmont[12]={0x00};
    Byte SendData[1+12 +3+1]={0x00};
    SendData[0] =GETCARD_CMD;
    // NSString *tempMoney = [NSString stringWithFormat:@"%012i",(int)(nAmount)];
    sprintf((char *)SendData+1, "%012ld", nAmount);
    NSString *strDate = [self returnDate];
    //NSData* bytesDate = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData* bytesDate =[self StrHexToByte:strDate];
    Byte * ByteDate = (Byte *)[bytesDate bytes];
    memcpy(SendData+13,ByteDate+1, 3);
    if ((timeout <20000) || (timeout >60000))
        timeout =60*1000;
    long ntimeout =timeout/1000;
    SendData[16] =ntimeout;
    
    NSData *SendArryByte = [[NSData alloc] initWithBytes:SendData length:1+12 +3+1];
    int result =[osmanager exchangeData:SendArryByte timeout:timeout cb:self];

    NSLog(@"========================%d",result);
    if (Print_log)
    {
        NSLog(@"%s %@",__func__,SendArryByte);
        NSLog(@"%s,result:%d",__func__,result);
    }
    return SUCESS;
    
}

/********************************************************************
	函 数 名：TRANS_Sale
	功能描述：消费,返回消费需要上送数据22域+35+36+IC磁道数据+PINBLOCK+磁道加密随机数
 long timeout				--超时时间 毫秒
 long 		nAmount		--消费金额
 int         nPasswordlen  --密码数据例如:12345
 NSString 	bPassKey		-密码数据例如:12345
	返回说明：
 **********************************************************/

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
    memcpy(bPass+1,[bytesPass bytes], nPasLen/2);
    memcpy(SendData+14,bPass, 8);
    SendData[22] =PIN_KEY_ID;
    SendData[23] =MAIN_KEY_ID;
    SendData[24] =MAIN_KEY_ID;
    
    NSData *SendArryByte = [[NSData alloc] initWithBytes:SendData length:25];
    int result =[osmanager exchangeData:SendArryByte timeout:timeout cb:self];
    if (Print_log)
    {
        NSLog(@"%s %@",__func__,SendArryByte);
        NSLog(@"%s,result:%d",__func__,result);
    }
    return SUCESS;
    
}

//普通字符串转换为十六进制的。

-(NSString *)hexBytToString:(unsigned char *)byteData:(int)Datalen{
    //NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    //Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<Datalen;i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",byteData[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}
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
    
    
    [self BcdToAsc:szTrack2:TransData.szTrack2:80];
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
        strncpy(TransData.TrackPAN,(char *)szTrack2, nIndexlen);
        strncpy(TransData.CardValid, (char *)szTrack2+nIndexlen + 1, 4);
        strncpy(TransData.szServiceCode, (char *)szTrack2+nIndexlen + 5, 3);	//服务代码
        if((TransData.szServiceCode[0] == '2') ||(TransData.szServiceCode[0] == '6'))
            TransData.iCardtype =1;
        else
            TransData.iCardtype =0;
    }
  
    NSString *strData ;
    strData = [[NSString alloc] initWithCString:(const char*)TransData.TrackPAN encoding:NSASCIIStringEncoding];
    
    return  SUCESS;
}
// 十六进制转换为普通字符串的。
-(NSString *)stringFromHexString:(NSString *)hexString { //
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    free(myBuffer);
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
    
    
}



-(void)onReceive:(NSData*)data{

    NSLog(@"%s %@",__func__,data);
    Byte * ByteDate = (Byte *)[data bytes];
    switch (ByteDate[0]) {
        case GETCARD_CMD:
            if (!ByteDate[1])   // 刷卡成功
            {
                NSLog(@"%s,result:%@",__func__,@"刷卡成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *strPan=@"";
                    int nlen =ByteDate[2]&0xff;
                    for (int i=0; i <nlen; i++) {
                        NSString *newHexStr = [NSString stringWithFormat:@"%x",ByteDate[i+3]&0xff];///16进制数
                        strPan = [strPan stringByAppendingString:newHexStr];
                        
                    }
                });

                
            
                
            }
            else
            {
               NSLog(@"%s,result:%@",__func__,@"刷卡失败");
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertTip;
                    
                     alertTip = [[UIAlertView alloc] initWithTitle:nil message:@"刷卡失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
               

                
                    [alertTip show];

                    return;

                });

            }
            
            break;
        case GETTRACK_CMD:
             if (!ByteDate[1])   // 获取卡号数据成功
             {
                   NSLog(@"%s,result:%@",__func__,@"获取卡号数据成功");
                  dispatch_async(dispatch_get_main_queue(), ^{
                   [self GetCard:data];
                    
                  });
             }
            else
            {
                NSLog(@"%s,result:%@",__func__,@"获取卡号数据失败");
            }
            break;
        case MAINKEY_CMD:
            if (!ByteDate[1])   // 主密钥设置成功
            {
                NSLog(@"%s,result:%@",__func__,@"主密钥设置成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                });

            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                });

            }
            

            break;
        case WORKKEY_CMD:
            if (!ByteDate[1])   // 工作密钥设置成功
            {
                NSLog(@"%s,result:%@",__func__,@"工作密钥设置成功");
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Set WorkKey Sucess";
//                    else
//                        self.LabTip.text = @"工作密钥设置成功";
                });

            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Set WorkKey Fail";
//                    else
//                        self.LabTip.text = @"工作密钥设置失败";
                });

            }
            break;
        case GETSNVERSION:
            if (!ByteDate[1])   // SN号获取成功
            {
                NSString * strSN =@"";
                for (int i=3; i <19; i++) {
                    NSString *newHexStr = [NSString stringWithFormat:@"%x",ByteDate[i]&0xff];///16进制数
                    strSN = [strSN stringByAppendingString:newHexStr];
                    
                }
                 strSN =[self stringFromHexString:strSN];
   
            
                dispatch_async(dispatch_get_main_queue(), ^{
//                 self.LabSn.text = strSN;
                 NSLog(@"SN获取成功  %@",strSN);
                 NSString * SN =@"SN:";
                 SN = [SN stringByAppendingString:strSN];
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:SN delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                });
    
            }
            break;
        case GETMAC_CMD:
            if (!ByteDate[1])   // MAC
            {
                NSLog(@"%s,result:%@",__func__,@"MAC 获取成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString * strMAC =@"";
                    strMAC = [NSString stringWithFormat:@"%@",data];
                    strMAC = [strMAC stringByReplacingOccurrencesOfString:@" " withString:@""];
                    strMAC =[strMAC substringFromIndex:5];
                    strMAC = [strMAC substringToIndex:16];
//                    self.LabMac.text =strMAC;
    
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"GET  MAC  Fail";
//                    else
//                        self.LabTip.text = @"MAC获取失败";

                });
                
            }
            

            
            break;
        case WRITETERNUMBER:
            if (!ByteDate[1])   // 工作密钥设置成功
            {
                NSLog(@"%s,result:%@",__func__,@"终端号商户号设置成功");
                dispatch_async(dispatch_get_main_queue(), ^{

                    [self ReadTernumber];  //读取终端号
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                });
                
            }

            break;
        case GETTERNUMBER:
            if (!ByteDate[1])   // 终端号
            {
            
                NSString * strTerNumber =@"";
                strTerNumber = [NSString stringWithFormat:@"%@",data];
                
                strTerNumber = [strTerNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                strTerNumber =[strTerNumber substringFromIndex:5];
                strTerNumber = [strTerNumber substringToIndex:23];
                
                dispatch_async(dispatch_get_main_queue(), ^{
//                    self.LabTerid.text = strTerNumber;
                    NSString * strTer =@"";
                    strTer = [@"终端商户号:" stringByAppendingString:strTerNumber];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:strTer delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                    
                    
                });
                
            }

            break;
        default:
            break;
    }
    
    
}
-(void)onSendOK{
    NSLog(@"%s",__func__);
}
-(void)onTimeout{
    NSLog(@"%s",__func__);
}
-(void)onError:(NSInteger)code message:(NSString*)msg{
    NSLog(@"%s",__func__);
}
-(void)onProgress:(NSData*)data{
    NSLog(@"%s %@",__func__,data);
}







@end
