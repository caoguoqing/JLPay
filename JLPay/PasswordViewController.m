//
//  PasswordViewController.m
//  JLPay
//
//  Created by jielian on 15/4/16.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "PasswordViewController.h"
#import "LVKeyboardView.h"
#import "Define_Header.h"
#import "CommunicationManager.h"
#import "WaitViewController.h"
#import "CustPayViewController.h"
#import "Toast+UIView.h"

//@interface PasswordViewController ()<UITextFieldDelegate, LVKeyboardDelegate,CommunicationCallBack>
@interface PasswordViewController ()<UITextFieldDelegate, LVKeyboardDelegate>


//@property(nonatomic,strong) CommunicationManager* osmanager;

/**
 *   密码按钮
 */
@property (weak, nonatomic) IBOutlet UITextField *textField;
/**
 *   自定义密码键盘
 */





@property (nonatomic, strong) LVKeyboardView *keyboard;
@property (nonatomic, strong) NSMutableString *passWord;

@end





@implementation PasswordViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:NO];

}

-(void)viewWillAppear:(BOOL)animated
{
//    if (osmanager ==NULL)
//        osmanager = [CommunicationManager sharedInstance];
    [super viewWillAppear:animated];
    
    self.textField.inputAccessoryView = [[LVKeyboardAccessoryBtn alloc] init];
    self.textField.inputView = self.keyboard;
    self.textField.delegate = self;
    self.textField.secureTextEntry = YES;
    [self.textField becomeFirstResponder];
}

#pragma mask ::: 界面子视图的事件或通知
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toCust:) name:Noti_TransSale_Success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToCust:) name:Noti_TransSale_Fail object:nil];

}



#pragma mask ::: 确定消费按钮的事件
- (IBAction)click:(UIButton *)sender {
    long money = [self themoney] ;
//    [self TRANS_Sale:20000 :money :6 :self.textField.text];
    AppDelegate* delegate_  = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate_.device TRANS_Sale:20000 nAmount:money nPasswordlen:6 bPassKey:self.textField.text];
}


#pragma mask ::: 跳转到消费的联机阶段
- (void) toCust: (NSNotification*)notification {
    // 密码
    AppDelegate* delegate_  = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate_.window makeToast:@"刷磁成功,交易处理中..."];
    
     NSString *liushui=[PublicInformation exchangeNumber];
     [[NSUserDefaults standardUserDefaults] setValue:liushui forKey:Current_Liushui_Number];
     [[NSUserDefaults standardUserDefaults] synchronize];
     
     WaitViewController *viewcon = [[WaitViewController alloc]init];
    viewcon.pinstr  = [[NSUserDefaults standardUserDefaults] valueForKey:Sign_in_PinKey];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:viewcon animated:YES];
    });
    
}

#pragma mask ::: 跳转回金额输入界面
- (void) backToCust: (NSNotification*)notification {
    AppDelegate* delegate_  = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate_.window makeToast:@"交易失败!"];
    
    UIStoryboard* storyBoard    = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CustPayViewController* viewController   = [storyBoard instantiateViewControllerWithIdentifier:@"CustPayViewController"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popToViewController:viewController animated:YES];
    });
}



#pragma mask ::: 从本地配置获取金额
-(NSString *)returnMoney{
    NSString *moneyStr=[[NSUserDefaults standardUserDefaults] valueForKey:Consumer_Money];
    if (moneyStr && ![moneyStr isEqualToString:@"0.00"] && ![moneyStr isEqualToString:@"(null)"]) {
        moneyStr=[[NSUserDefaults standardUserDefaults] valueForKey:Consumer_Money];
    }else{
        moneyStr=@"1";
    }
    return moneyStr;
}

#pragma mask ::: 将小数点金额转换为报文需要的无小数点格式
-(int)themoney{
    int money=[[self returnMoney] floatValue]*100;
    return money;
}


#pragma mask ::: Field 在编辑前的事件:生成并打开键盘
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.textField.text = nil;
    self.passWord = nil;
    
    CGFloat x = 0;
    CGFloat y = self.view.height - 216;
    CGFloat w = self.view.width;
    CGFloat h = 216;
    self.keyboard = [[LVKeyboardView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    self.keyboard.delegate = self;
    
    self.textField.inputView = _keyboard;
    
    return YES;
}

#pragma mark - LVKeyboardDelegate
- (void)keyboard:(LVKeyboardView *)keyboard didClickButton:(UIButton *)button {
    
    if (self.passWord.length > 5) return;
    [self.passWord appendString:button.currentTitle];
    
    self.textField.text = self.passWord;
    NSLog(@"%@", self.textField.text);
}

- (void)keyboard:(LVKeyboardView *)keyboard didClickDeleteBtn:(UIButton *)deleteBtn {
    NSLog(@"删除");
    NSUInteger loc = self.passWord.length;
    if (loc == 0)   return;
    NSRange range = NSMakeRange(loc - 1, 1);
    [self.passWord deleteCharactersInRange:range];
    self.textField.text = self.passWord;
    NSLog(@"%@", self.textField.text);
}

#pragma mark - 密码的 getter
- (NSMutableString *)passWord {
    if (!_passWord) {
        _passWord = [NSMutableString stringWithCapacity:6];
    }
    return _passWord;
}




#pragma mask --------------------------------------------------- 分界线

//
//
//-(NSData*)StrHexToByte:(NSString*)strHex
//{
//    NSString *hexString=[[strHex uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
//    if ([hexString length]%2!=0) {
//        return nil;
//    }
//    Byte tempbyt[1]={0};
//    NSMutableData* bytes=[NSMutableData data];
//    for(int i=0;i<[hexString length];i++)
//    {
//        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
//        int int_ch1;
//        if(hex_char1 >= '0' && hex_char1 <='9')
//            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
//        else if(hex_char1 >= 'A' && hex_char1 <='F')
//            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
//        else
//            return nil;
//        i++;
//        
//        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
//        int int_ch2;
//        if(hex_char2 >= '0' && hex_char2 <='9')
//            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
//        else if(hex_char2 >= 'A' && hex_char2 <='F')
//            int_ch2 = hex_char2-55; //// A 的Ascll - 65
//        else
//            return nil;
//        
//        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
//        [bytes appendBytes:tempbyt length:1];
//    }
//    return bytes;
//}
//
///********************************************************************
//	函 数 名：TRANS_Sale
//	功能描述：消费,返回消费需要上送数据22域+35+36+IC磁道数据+PINBLOCK+磁道加密随机数
// long timeout				--超时时间 毫秒
// long 		nAmount		--消费金额
// int         nPasswordlen  --密码数据例如:12345
// NSString 	bPassKey		-密码数据例如:12345
//	返回说明：
// **********************************************************/
//
//-(int)TRANS_Sale:(long)timeout :(long)nAmount :(int)nPasswordlen :(NSString*)bPassKey
//{
//    int nPasLen=0;
//    Byte  SendData[25] ={0x00};
//    Byte  bPass[8] ={0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff};
//    SendData[0] =GETTRACK_CMD;
//    SendData[1] =MAIN_KEY_ID;
//    sprintf((char *)SendData+2, "%012ld", nAmount);
//    NSString *strF =@"f";
//    nPasLen =nPasswordlen;
//    if (nPasswordlen%2 !=0)
//    {
//        bPassKey = [bPassKey stringByAppendingString:strF];
//        nPasLen ++;
//    }
//    
//    bPass[0]=nPasswordlen;
//    NSData* bytesPass =[self StrHexToByte:bPassKey];
//    memcpy(bPass + 1,[bytesPass bytes], nPasLen/2);
//    memcpy(SendData+14,bPass, 8);
//    SendData[22] =PIN_KEY_ID;
//    SendData[23] =MAIN_KEY_ID;
//    SendData[24] =MAIN_KEY_ID;
//    
//    NSData *SendArryByte = [[NSData alloc] initWithBytes:SendData length:25];
//    int result =[osmanager exchangeData:SendArryByte timeout:timeout cb:self];
//    if (Print_log)
//    {
//        NSLog(@"%s %@",__func__,SendArryByte);
//        NSLog(@"%s,result:%d",__func__,result);
//    }
//    return SUCESS;
//    
//}
//
//
//
//
//
//-(void) BcdToAsc:(Byte *)Dest :(Byte *)Src :(int)Len
//{
//    int i;
//    for(i=0;i<Len;i++)
//    {
//        //高Nibble转换
//        if(((*(Src + i) & 0xF0) >> 4) <= 9)
//        {
//            *(Dest + 2*i) = ((*(Src + i) & 0xF0) >> 4) + 0x30;
//        }
//        else
//        {
//            *(Dest + 2*i)  = ((*(Src + i) & 0xF0) >> 4) + 0x37;   //大写A~F
//        }
//        //低Nibble转换
//        if((*(Src + i) & 0x0F) <= 9)
//        {
//            *(Dest + 2*i + 1) = (*(Src + i) & 0x0F) + 0x30;
//        }
//        else
//        {
//            *(Dest + 2*i + 1) = (*(Src + i) & 0x0F) + 0x37;   //大写A~F
//        }
//    }
//}
//
//-(int)GetCard:(NSData*)TrackData
//{
//    /*
//     20 00 0210
//     136210985800012004611d491212061006000000
//     136210985800012004611df5f98f2fb41d89000f
//     34996210985800012004611d1561560000000000000003000000114000049121d000000000000d000000000000d00000 0061006000
//     34996210985800012004611d1561560000000000000003000000114000049121d000000000000d0000000000450b3e bc742369 7f
//     000000
//     08cb59e6ea6d58c338
//     00
//     */
//    
//    int nIndex =0,nIndexlen=0;
//    Byte  ByteData[512] ={0x00};
//    Byte  szTrack2[80] ={0x00};
//    
//    Byte str[512] = {0x00};
//    
//    
//    //NSUInteger len = [TrackData length];
//    memcpy(ByteData, (Byte *)[TrackData bytes], [TrackData length]);
//    nIndex ++;
//    TransData.iCardmodem =ByteData[nIndex];
//    nIndex ++;
//    memcpy(&TransData.szEntryMode, ByteData+nIndex, 2);
//    nIndex +=2;
//    
//    [self BcdToAsc:str:TransData.szEntryMode:2];
//    
//    NSLog(@"******************  iCardmodem     szentrymode****************  %d    %s",TransData.iCardmodem,str);
//    /*
//     //pan
//     nIndexlen =ByteData[nIndex];
//     memcpy(&TransData.TrackPAN, ByteData+nIndex+1, nIndexlen);
//     nIndex +=1;
//     nIndex +=nIndexlen;
//     */
//    //2磁道数据
//    TransData.nTrack2Len =ByteData[nIndex];
//    memcpy(&TransData.szTrack2, ByteData+nIndex+1, TransData.nTrack2Len);
//    nIndex +=1;
//    nIndex +=TransData.nTrack2Len;
//    
//    [self BcdToAsc:str :TransData.szTrack2 :TransData.nTrack2Len];
//    
//    NSLog(@"******************2磁道数据****************  %s   %d",str,TransData.nTrack2Len);
//    //2磁道加密数据
//    TransData.nEncryTrack2Len =ByteData[nIndex];
//    memcpy(&TransData.szEncryTrack2, ByteData+nIndex+1, TransData.nEncryTrack2Len);
//    nIndex +=1;
//    nIndex +=TransData.nEncryTrack2Len;
//    
//    memset(str, 0, 512);
//    [self BcdToAsc:str:TransData.szEncryTrack2:TransData.nEncryTrack2Len];
//    
//
//    [[NSUserDefaults  standardUserDefaults]setObject:[NSString stringWithFormat:@"%s",str] forKey:Two_Track_Data];
//    [[NSUserDefaults standardUserDefaults]synchronize];
//    NSLog(@"******************2磁道加密数据****************  %s     %d",str,TransData.nEncryTrack2Len);
//    
//    
//    //3磁道数据
//    TransData.nTrack3Len =ByteData[nIndex];
//    memcpy(&TransData.szTrack3, ByteData+nIndex+1, TransData.nTrack3Len);
//    nIndex +=1;
//    nIndex +=TransData.nTrack3Len;
//    
//    memset(str, 0, 512);
//    
//    [self BcdToAsc:str:TransData.szTrack3:TransData.nTrack3Len];
//    
//    
//    NSLog(@"******************3磁道数据****************  %s     %d",str,TransData.nTrack3Len);
//    
//    //3磁道加密数据
//    TransData.nEncryTrack3Len =ByteData[nIndex];
//    memcpy(&TransData.szEncryTrack3, ByteData+nIndex+1, TransData.nEncryTrack3Len);
//    nIndex +=1;
//    nIndex +=TransData.nEncryTrack3Len;
//    
//    memset(str, 0, 512);
//    
//    [self BcdToAsc:str:TransData.szEncryTrack3:TransData.nEncryTrack3Len];
//    
//    NSLog(@"******************3磁道加密数据****************  %s      %d",str,TransData.nEncryTrack3Len);
//    
//    //IC卡数据长度
//    TransData.IccdataLen = ((ByteData[nIndex] << 8) & 0xFF00);
//    TransData.IccdataLen |= ByteData[nIndex+1] & 0xFF;
//    nIndex +=2;
//    memcpy(&TransData.Field55Iccdata, ByteData+nIndex, TransData.IccdataLen);
//    nIndex+= TransData.IccdataLen;
//    
//    memset(str, 0, 512);
//    
//    [self BcdToAsc:str:TransData.Field55Iccdata:TransData.IccdataLen];
//    
//    NSLog(@"******************IC卡数据****************  %s     %d",str,TransData.IccdataLen);
//    
//    //PINBLOCK
//    nIndexlen=ByteData[nIndex];
//    memcpy(&TransData.sPIN, ByteData+nIndex+1, nIndexlen);
//    nIndex +=1;
//    nIndex +=nIndexlen;
//    
//    memset(str, 0, 512);
//    
//    [self BcdToAsc:str:TransData.sPIN:nIndexlen];
//    
//
//    NSString *string = [NSString stringWithFormat:@"%s",str];
//    self.pinStr = string;
//    [[NSUserDefaults  standardUserDefaults]setObject:string forKey:Sign_in_PinKey];
//    [[NSUserDefaults standardUserDefaults]synchronize];
//    NSLog(@"******************PINBLOCK****************%@    %s      %d",string,str,nIndexlen);
//    
//    //卡片序列号
//    nIndexlen=ByteData[nIndex];
//    memcpy(&TransData.CardSeq, ByteData+nIndex+1, nIndexlen);
//    nIndex +=1;
//    nIndex +=nIndexlen;
//    
//    memset(str, 0, 512);
//    
//    [self BcdToAsc:str:TransData.CardSeq:nIndexlen];
//    
//    NSLog(@"******************卡片序列号****************  %s      %d",str,nIndexlen);
//    
//    [self BcdToAsc:szTrack2:TransData.szTrack2:80];
//    for(int i=0;i<80;i++)		// convert 'D' to '='
//    {
//        if( szTrack2[i]=='D' )
//        {
//            nIndexlen =i;
//            break;
//        }
//    }
//    if(nIndexlen >0)
//    {
//        strncpy(TransData.TrackPAN,(char *)szTrack2, nIndexlen);
//        strncpy(TransData.CardValid, (char *)szTrack2+nIndexlen + 1, 4);
//        strncpy(TransData.szServiceCode, (char *)szTrack2+nIndexlen + 5, 3);	//服务代码
//        if((TransData.szServiceCode[0] == '2') ||(TransData.szServiceCode[0] == '6'))
//            TransData.iCardtype =1;
//        else
//            TransData.iCardtype =0;
//    }
//    
//    
//    NSString *strData ;
//    strData = [[NSString alloc] initWithCString:(const char*)TransData.TrackPAN encoding:NSASCIIStringEncoding];
//    
//    NSLog(@"******************卡号***************  %@",strData);
//    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@*****%@",[strData substringWithRange:NSMakeRange(0, [strData length]-9)],[strData substringWithRange:NSMakeRange([strData length]-4, 4)]] forKey:GetCurrentCard_NotAll];
//    [[NSUserDefaults  standardUserDefaults]setObject:strData forKey:Card_Number];
//    [[NSUserDefaults standardUserDefaults]synchronize];
//
//    return  SUCESS;
//}
//
//#pragma mark-------------------------------------CommunicationCallBack
//
//-(void)onReceive:(NSData*)data{
//    
//    NSLog(@"%s %@",__func__,data);
//    Byte * ByteDate = (Byte *)[data bytes];
//    switch (ByteDate[0]) {
//        case GETCARD_CMD:
//            if (!ByteDate[1])   // 刷卡成功
//            {
//                NSLog(@"%s,result:%@",__func__,@"刷卡成功");
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSString *strPan=@"";
//                    int nlen =ByteDate[2]&0xff;
//                    for (int i=0; i <nlen; i++) {
//                        NSString *newHexStr = [NSString stringWithFormat:@"%x",ByteDate[i+3]&0xff];///16进制数
//                        strPan = [strPan stringByAppendingString:newHexStr];
//                        
//                    }
////                    strPan =[self stringFromHexString:strPan];
//                });
//                
//            }
//            else
//            {
//                NSLog(@"%s,result:%@",__func__,@"刷卡失败");
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    
//                });
//            }
//            
//            break;
//        case GETTRACK_CMD:
//            if (!ByteDate[1])   // 获取卡号数据成功
//            {
//                NSLog(@"%s,result:%@",__func__,@"获取卡号数据成功");
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self GetCard:data];
//                    
//                    NSString *liushui=[PublicInformation exchangeNumber];
//                    [[NSUserDefaults standardUserDefaults] setValue:liushui forKey:Current_Liushui_Number];
//                    [[NSUserDefaults standardUserDefaults] synchronize];
//                    
//                    WaitViewController *viewcon = [[WaitViewController alloc]init];
//                    viewcon.pinstr = self.pinStr;
//                    [self.navigationController pushViewController:viewcon animated:YES];
//                    
//                });
//            }
//            else
//            {
//                NSLog(@"%s,result:%@",__func__,@"获取卡号数据失败");
//            }
//            
//            break;
//        default:
//            break;
//    }
//    
//    
//}
//-(void)onSendOK{
//    NSLog(@"%s",__func__);
//}
//-(void)onTimeout{
//    NSLog(@"%s",__func__);
//}
//-(void)onError:(NSInteger)code message:(NSString*)msg{
//    NSLog(@"%s",__func__);
//}
//-(void)onProgress:(NSData*)data{
//    NSLog(@"%s %@",__func__,data);
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
