//
//  PublicInformation.h
//  PosN38Universal
//
//  Created by work on 14-8-8.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface PublicInformation : NSObject

//bbpos已连接
+(BOOL)bbPosHaveConnect;

+(NSString *)returnBBposKeyStr;

+(int)returnSelectIndex;

//当前带星卡号
+(NSString *)getXingCard;

//更新主密钥
+(NSString *)getMainSecret;

//原交易流水号,消费交易的流水号
+(NSString *)returnLiushuiHao;

//消费成功的搜索参考号
+(NSString *)returnConsumerSort;

//消费成功的金额,方便撤销支付
+(NSString *)returnConsumerMoney;

//签到批次号
+(NSString *)returnSignSort;
//原交易批次号,用于撤销时获取
+(NSString *)returnFdReserved;

//二磁道数据
+(NSString *)returnTwoTrack;
//银行卡号
+(NSString *)returnposCard;

//刷卡金额
+(NSString *)returnMoney;

//流水号,每次交易，递增,bcd,6(000008)
+(NSString *)exchangeNumber;

// 操作员号
+(NSString*) returnOperatorNum;
// 操作员密码
+(NSString*) returnOperatorPassword;

//卡号转换
+(NSString *)returnCard:(NSString *)card;

//保存终端号，商户号，商户名称
+(NSString *)returnTerminal;
+(NSString *)returnBusiness;
+(NSString *)returnBusinessName;

// 返回IC卡序列号
+(NSString *)returnICCardSeqNo;

//签到保存mackey，pinkey
+(NSString *)signinPin;
+(NSString *)signinMac;

// 从配置中获取后台主机ip跟port
+(NSString *)settingIp;
+(int)settingPort;
// 从配置中获取数据后台地址
+(NSString*) getDataSourceIP;
+(NSString*) getDataSourcePort;

//十六进制转化二进制
+(NSString *)getBinaryByhex:(NSString *)hex;

//二进制转十六进制
+(NSString *)binaryToHexString:(NSString *)str;

//二进制取反
+(NSString *)binaryToAgain:(NSString *)str;

//十六进制转十进制
+(int)sistenToTen:(NSString*)tmpid;

//十进制转16进制
+(NSString *)ToBHex:(int)tmpid;

//16进制转字符串（ascii）
+(NSString *)stringFromHexString:(NSString *)hexString;

//data转nsstring
+ (NSString*)stringWithHexBytes2:(NSData *)theData;


//16进制颜色(html颜色值)字符串转为UIColor
+(UIColor *) hexStringToColor: (NSString *) stringToConvert;
+ (UIImage *) createImageWithColor: (UIColor *) color;


+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

//更新十六进制字符串转bytes
+(NSData *) NewhexStrToNSData:(NSString *)hexStr;

+(NSString *)formatDate;

+(NSString *)formatCompareDate;

+(BOOL)isCurrentToday:(NSString *)dateStr;

// 获取当前系统日期
+ (NSString*) nowDate ;
+ (NSString*) nowTime ;
//判断两个日期是否是同一天
+(BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2;

+(NSString *) returnUploadTime:(NSString  *)timeStr;

+(NSString *) NEWreturnUploadTime:(NSString  *)timeStr;

// 获取当前交易的交易类型
+(NSString *)returnTranType;

// 读卡的方式 : YES(磁条) NO(芯片)
+(BOOL) returnCardType_Track;

/* app通用ui颜色:
 *      red 
 *      green
 *
 */
+(UIColor*) returnCommonAppColor:(NSString*)color;

// app状态栏高度
+(CGFloat) returnStatusHeight;

// 将获取到的c字符串金额重新封装成12位的 NSString 格式
+ (NSString*) moneyStringWithCString:(char*)cstring ;
// app的状态栏高度+控制栏高度
+ (CGFloat) heightOfNavigationAndStatusInVC:(UIViewController*)viewController;
// 去掉传入的字符串末尾多余的空白字符,并拷贝一份导出
+ (NSString*) clearSpaceCharAtLastOfString:(NSString*)string ;


// 缩放图片
+ (UIImage*) imageScaledBySourceImage:(UIImage*)image
                       withWidthScale:(CGFloat)wScale
                       andHeightScale:(CGFloat)hScale;

@end
