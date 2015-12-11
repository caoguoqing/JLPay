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


#pragma mask 0-------------------------------------------0 签到批次号相关
// 签到批次号
+(NSString *)returnSignSort;
// 更新批次号
+(NSString *) updateSignSort;


#pragma mask 0-------------------------------------------0 手机交易流水号
// 流水号,每次交易，递增,bcd,6(000008)
+(NSString *)exchangeNumber;


#pragma mask 0-------------------------------------------0 商户信息相关
// 获取商户的终端号、商户号、商户名
+(NSString *) returnTerminal;
+(NSString *) returnBusiness;
+(NSString *) returnBusinessName;

#pragma mask 0-------------------------------------------0 获取服务器ip+port
/* 获取服务器域名 */
+ (NSString*) getServerDomain;
/* 获取TCP端口 */
+ (NSString*) getTcpPort;
/* 获取HTTP端口 */
+ (NSString*) getHTTPPort;


#pragma mask 0-------------------------------------------0 字符转换相关
// 十六进制 -> 二进制
+ (NSString *)getBinaryByhex:(NSString *)hex;
// 二进制 -> 十六进制
+ (NSString *)binaryToHexString:(NSString *)str;
// 二进制取反
+ (NSString *)binaryToAgain:(NSString *)str;
// 十六进制 -> 十进制
+ (int)sistenToTen:(NSString*)tmpid;
// 十进制 -> 16进制
+ (NSString *)ToBHex:(int)tmpid;
// 16进制 -> 字符串（ascii）
+ (NSString *)stringFromHexString:(NSString *)hexString;
// data -> nsstring
+ (NSString*)stringWithHexBytes2:(NSData *)theData;
// 更新十六进制字符串 -> bytes
+ (NSData *) NewhexStrToNSData:(NSString *)hexStr;


// 16进制颜色(html颜色值)字符串 ->  为UIColor
+(UIColor *) hexStringToColor: (NSString *) stringToConvert;
+ (UIImage *) createImageWithColor: (UIColor *) color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;



#pragma mask 0-------------------------------------------0 时间、日期相关
// yyyy/MM/dd HH:mm:ss
+(NSString *)formatDate;
// yyyy-MM-dd HH:mm:ss
+(NSString *)formatCompareDate;
// 判断指定日期是否当前日期
+(BOOL)isCurrentToday:(NSString *)dateStr;
// 获取当前系统日期\时间 yyyyMMdd\HHmmss
+ (NSString*) nowDate ;
+ (NSString*) nowTime ;
// 当前date+time yyyyMMddHHmmss
+(NSString*) currentDateAndTime ;

//判断两个日期是否是同一天
+(BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2;

+(NSString *) returnUploadTime:(NSString  *)timeStr;

+(NSString *) NEWreturnUploadTime:(NSString  *)timeStr;

// 获取当前交易的交易类型
+(NSString *)returnTranType;



#pragma mask 0-------------------------------------------0 App内颜色方案
/* app通用ui颜色 color :
 *      red 
 *      green
 */
+(UIColor*) returnCommonAppColor:(NSString*)color;

#pragma mask 0-------------------------------------------0 App信息相关
/* 版本号 */
+ (NSString*) AppVersionNumber;


// app状态栏高度
+(CGFloat) returnStatusHeight;
// app的状态栏高度+控制栏高度
+ (CGFloat) heightOfNavigationAndStatusInVC:(UIViewController*)viewController;

#pragma mask 0-------------------------------------------0 字符串相关
// 去掉末尾多余的空白字符,并拷贝一份导出
+ (NSString*) clearSpaceCharAtLastOfString:(NSString*)string ;
// 去掉字符串中间的空白字符
+ (NSString*) clearSpaceCharAtContentOfString:(NSString*)string ;

/* 重置字体大小: 指定size+占比 */
+ (CGFloat) resizeFontInSize:(CGSize)size andScale:(CGFloat)scale;

#pragma mask 0-------------------------------------------0 图片相关
// 缩放图片
+ (UIImage*) imageScaledBySourceImage:(UIImage*)image
                       withWidthScale:(CGFloat)wScale
                       andHeightScale:(CGFloat)hScale;

#pragma mask 0-------------------------------------------0 8583交易相关

#pragma mask ::: 卡号截取 e.g. 621790******3368
+ (NSString*) cuttingOffCardNo:(NSString*)cardNo ;

#pragma mask ::: 交易名称转换 e.g. 消费-190000
+ (NSString*) transNameWithCode:(NSString*)transCode;

#pragma mask ::: 金额: c小数点格式 -> 12位无小数点格式
+ (NSString*) moneyStringWithCString:(char*)cstring ;

#pragma mask ::: 金额: 12位无小数点格式 -> 小数点格式
+ (NSString*) dotMoneyFromNoDotMoney:(NSString*)noDotMoney;

#pragma mask ::: 金额: 小数点格式 -> 12位无小数点格式
+ (NSString*) intMoneyFromDotMoney:(NSString*)dotMoney;

#pragma mask 0-------------------------------------------0 界面相关
/* 创建一个空的回退bar按钮 */
+ (UIBarButtonItem*) newBarItemWithNullTitle;

@end
