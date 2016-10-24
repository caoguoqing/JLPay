//
//  NSString+Formater.h
//  CreditCardManager
//
//  Created by 冯金龙 on 16/1/26.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Formater)

#pragma mask : 日期格式化相关    yyyyMMdd
// -- 当前日期
+ (instancetype) curDateString;
// -- 当月最后一天
- (NSString*) lastDayOfCurMonth;

// -- 月份计算: 前一个月
- (NSString*) lastMonth;
// -- 月份计算: 后一个月
- (NSString*) nextMonth;

// -- 两个日期的间隔月数
- (NSInteger) intervalWithOtherMonth:(NSString*)otherMonth;

#pragma mask : 日期&时间 格式化相关    yyyyMMddhhmmss
+ (instancetype) formatedDateStringFromSourceTime:(NSString*)allLenTime;
+ (instancetype) formatedTimeStringFromSourceTime:(NSString*)allLenTime;


#pragma mask : 截取字符串相关
// 截取指定位字符为*
- (NSString*) stringCutting4XingInRange:(NSRange)range;
- (NSString*) stringCuttingXingInRange:(NSRange)range;

// 截取掉头和尾的多余空格
- (NSString*) stringByTrimmingWhiteSpaceAtFontOrSuffWithString:(NSString*)originString;


#pragma mask : font 和 text size 相关
// -- 重新计算字体大小:指定高度
+ (CGFloat) resizeFontAtHeight:(CGFloat)height scale:(CGFloat)scale;

- (CGFloat) resizeFontAtHeight:(CGFloat)height scale:(CGFloat)scale;
- (CGSize) resizeAtHeight:(CGFloat)height scale:(CGFloat)scale;


#pragma mask : 编码相关
// -- ASC
- (NSString*) ASCIIString;

@end
