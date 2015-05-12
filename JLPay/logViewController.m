//
//  ViewController.m
//  JLPay
//
//  Created by jielian on 15/3/30.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "logViewController.h"
#import "Define_Header.h"
#import "TCP/TcpClientService.h"
#import "GroupPackage8583.h"
#import "Unpacking8583.h"
#import "Toast+UIView.h"
#import "CommunicationCallBack.h"
#import "CommunicationManager.h"


@interface logViewController ()<wallDelegate,managerToCard,CommunicationCallBack>
@property(nonatomic,strong) CommunicationManager* osmanager;


//@property (strong,nonatomic)JHNconnect *JHNCON;

@end

@implementation logViewController
@synthesize osmanager;
static FieldTrackData TransData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    [self openDevice];
    [self EndEdit];
    
}


#pragma mark =======点击取消键盘

-(void)EndEdit
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(End) ];
    [self.view addGestureRecognizer:tap];
}

-(void)End
{
    [self.view endEditing:YES];
}

/*
 *登陆点击按钮
 */
- (IBAction)loginClick:(UIButton *)sender {


    [[TcpClientService getInstance] sendOrderMethod:[GroupPackage8583 signIn] IP:Current_IP PORT:Current_Port Delegate:self method:@"tcpsignin"];


}

#pragma mark==========================================wallDelegate

-(void)receiveGetData:(NSString *)data method:(NSString *)str
{
        NSLog(@"app---------------------------------%@",str);
        //签到成功
        if ([str  isEqualToString:@"tcpsignin"]) {
            //        [app_delegate dismissWaitingView];
            if ([data length] > 0) {
                
#pragma mark------------------界面跳转
                
                [app_delegate signInSuccessToLogin:1];
                
                [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
            }else{
                [self.view makeToast:@"签到失败，请重新签到"];
            }
        }
}
-(void)falseReceiveGetDataMethod:(NSString *)str
{
    if ([str  isEqualToString:@"tcpsignin"]) {
        [self.view makeToast:@"连接超时，请重新签到"];
    }

}

-(void)managerToCardState:(NSString *)type isSuccess:(BOOL)state method:(NSString *)metStr
{
    if ([metStr isEqualToString:@"tcpsignin"]) {
        if (state) {

            [[app_delegate window] makeToast:type];

        }else{
            [self.view makeToast:type];
        }
    }
}


-(void)openDevice{
    
    
    NSThread* DeviceThread =[[NSThread alloc] initWithTarget:self selector:@selector(CheckDevceThread1)
                                                      object:nil];
    [DeviceThread start];
}

-(void)CheckDevceThread1
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
-(void )StatusChange:(int )Nstate
{
    NSLog(@"%s,result:%d",__func__,Nstate);
    switch (Nstate) {
        case KNOWED_DEVICE_ING://刷卡器已识别
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self GetSnVersion];
            });
        }
            break;
        case UNKNOW_DEVICE_ING://设备接入但不能识别为刷卡器
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        }
            break;
        case NO_DEVICE_INSERT://没有设备介入 （设备拔出）
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        }
            break;
        case KNOWING_DEVICE_ING://设备正在识别
        {
            dispatch_async(dispatch_get_main_queue(), ^{

            });
        }
            break;
        case DEVICE_NEED_UPDATE_ING://刷卡器已识别，但需要升级
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                

            });
        }
            break;
        default:
            break;
    }
}
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
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
    
    
}
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


#pragma mark       --------------------------------CommunicationCallBack

-(void)onReceive:(NSData*)data{
    
    NSLog(@"%s %@",__func__,data);
    Byte * ByteDate = (Byte *)[data bytes];
    switch (ByteDate[0]) {
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
                   
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
               
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
          
                    
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
            
                    
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
