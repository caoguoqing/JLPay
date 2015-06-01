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

@interface JHLDevice()<CommunicationCallBack>
@property (nonatomic, strong) CommunicationManager* osmanager;

@end


@implementation JHLDevice

@synthesize osmanager               = _osmanager;





#pragma mask --------------------------[Public Interface]--------------------------

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
    // NSString *tempMoney = [NSString stringWithFormat:@"%012i",(int)(nAmount)];
    sprintf((char *)SendData+1, "%012ld", nMount);
    NSString *strDate = [self returnDate];
    //NSData* bytesDate = [str dataUsingEncoding:NSUTF8StringEncoding];
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

#pragma mask : 主密钥下载
- (int) mainKeyDownload{
    return 0;
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

/*************************************
 * 功  能 : 锦宏霖设备入口的初始化;
 * 参  数 :
 * 返  回 : 无
 *************************************/
- (instancetype)init {
    self                            = [super init];
    if (self) {
        _osmanager                  = [CommunicationManager sharedInstance];
    }
    return self;
}

- (void) deviceOpenThread {
    while (YES) {
        int result                  = [self openDevice];
        [self stateCheck:result];
        if (result == 0) {
            break;
        }
        [NSThread sleepForTimeInterval:0.5];
    }
}

/*************************************
 * 功  能 : 打开设备;
 * 参  数 :
 * 返  回 : 无
 *************************************/
- (int) openDevice {
    int result;
    if (!self.osmanager) {
        self.osmanager              = [CommunicationManager sharedInstance];
    }
    result                          = [self.osmanager openDevice];
    if (Print_log) {
        NSLog(@"%s, 设备打开的结果:[%d]", __func__, result);
    }
    return result;
}

/*************************************
 * 功  能 : 操作结果检查;
 * 参  数 : 
 *          (int) resultState
 * 返  回 : 无
 *************************************/
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
                }
            });
            break;
        case UNKNOW_DEVICE_ING:
            dispatch_async(dispatch_get_main_queue(), ^{
                if (Print_log) {
                    NSLog(@"%s, 设备无法识别", __func__);
                }
            });
            break;
        case NO_DEVICE_INSERT:
            dispatch_async(dispatch_get_main_queue(), ^{
                if (Print_log) {
                    NSLog(@"%s, 没有设备介入 （设备拔出）", __func__);
                }
            });
            break;
        case DEVICE_NEED_UPDATE_ING:
            dispatch_async(dispatch_get_main_queue(), ^{
                if (Print_log) {
                    NSLog(@"%s, 刷卡器已识别，但需要升级", __func__);
                }
            });
            break;
        default:
            break;
    }
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
                    
                    // 怎么让刷卡界面跳转功能：输入密码？？？？？？？？？？
                    
                    [[(AppDelegate *)[UIApplication sharedApplication].delegate window] makeToast:@"刷卡成功"];
                    
                    // 刷卡成功要跳转到 输入密码界面:进行密码验证以及交易报文上送
//                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//                    UIViewController *viewcon = [storyboard instantiateViewControllerWithIdentifier:@"password"];
//                    [self.navigationController pushViewController:viewcon animated:YES];
                });
            }
            else
            {
                NSLog(@"%s,result:%@",__func__,@"刷卡失败");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[(AppDelegate *)[UIApplication sharedApplication].delegate window] makeToast:@"刷卡失败"];

//                    [self.navigationController popViewControllerAnimated:YES];
//                    [[(AppDelegate *)[UIApplication sharedApplication].delegate window] makeToast:@"刷卡失败"];
                });
            }
            break;
        case GETTRACK_CMD:
            if (!ByteDate[1])   // 获取卡号数据成功
            {
                NSLog(@"%s,result:%@",__func__,@"获取卡号数据成功");
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self GetCard:data];
                });
            }
            else
            {
                NSLog(@"%s,result:%@",__func__,@"获取卡号数据失败");
            }
            
            break;
        default:
            break;
    }
    
    
}





-(NSString *)returnDate
{
    NSDate *theDate = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
    NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:theDate];
    
    
    NSString *returnString = [NSString stringWithFormat:@"%02i%02i%02i",(int)[components year],(int)[components month],(int)[components day]];
    
    
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




- (void)onTimeout {
    
}
- (void)onError:(NSInteger)code message:(NSString *)msg {
    
}

@end
