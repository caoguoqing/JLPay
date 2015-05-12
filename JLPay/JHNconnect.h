//
//  ViewController.h
//  CommunicationTest


#import <UIKit/UIKit.h>

@interface JHNconnect : NSObject

//@property(strong,nonatomic)IBOutlet  UILabel *LabTip;
//@property (weak, nonatomic) IBOutlet  UILabel *LabSn;
//@property (strong, nonatomic) IBOutlet UILabel *LabMac;
//
//@property (strong, nonatomic) IBOutlet UILabel *LabCardNum;
//@property (strong, nonatomic) IBOutlet UILabel *LabTerid;

//- (IBAction)BtnSetTerid:(id)sender;
//- (IBAction)BtnGetMac:(id)sender;


+(JHNconnect *  )shareView;

/**
 *  刷卡
 */
-(void)exchangeData;

/**
 *  打开设备
 */
-(void  )openDevice;

/**
 *  读取终端号商户号
 */
-(int)ReadTernumber;

/**
 *  打开JHL刷卡头设备
 */
-(int)openJhlDevice;
/*
 关闭设备
 */
-(void)closeJhlDevice;
/*
 释放相关资源,关闭设备之前调用
 */
-(void)closeJhlResource;
/*
 判断是否处于连接状态
 */
-(BOOL)isConnected;

/*
 获取SN号+版本号
 */
-(int)GetSnVersion;
/*
 设置主密钥
 datakey  16个字节主密钥明文
 */

-(int)WriteMainKey:(int)len :(NSString*)Datakey;
/*
 设置工作密钥
 DataWorkkey  16个字节PIN+3个字节校验 + 16字节MAC +3个字节校验+16字节磁道加密+3个字节校验  ==57 字节
 */
-(int)WriteWorkKey:(int)len :(NSString*)DataWorkkey;

/*
 刷卡
 */
-(int)MagnCard:(long)timeout :(long)nAmount :(int)BrushCardM;
/********************************************************************
	函 数 名：TRANS_Sale
	功能描述：消费,返回消费需要上送数据22域+35+36+IC磁道数据+PINBLOCK+磁道加密随机数
 long timeout				--超时时间 毫秒
 long 		nAmount		--消费金额
 int         nPasswordlen  --密码数据例如:12345
 NSString 	bPassKey		-密码数据例如:12345
	返回说明：
 **********************************************************/
-(int)TRANS_Sale:(long)timeout :(long)nAmount :(int)nPasswordlen :(NSString*)bPassKey;
//处理收到的卡号分析
-(int)GetCard:(NSData*)TrackData;
-(void) BcdToAsc:(Byte *)Dest:(Byte *)Src:(int)Len;
-(void) CheckDevceThread;
-(NSString *)stringFromHexString:(NSString *)hexString;
-(NSString *)hexBytToString:(unsigned char *)byteData:(int)Datalen;
@end
