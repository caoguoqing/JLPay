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

#pragma mask : 截取字符串相关
// 截取指定位字符为*
- (NSString*) stringCuttingXingInRange:(NSRange)range;

#pragma mask : 日期格式化相关
// -- 当前日期的格式化: 指定日;
+ (NSString*) curFormationDateOnDay:(NSString*)day;

#pragma mask : font 和 text size 相关
// -- 重新计算字体大小:指定高度
- (CGFloat) resizeFontAtHeight:(CGFloat)height scale:(CGFloat)scale;
- (CGSize) resizeAtHeight:(CGFloat)height scale:(CGFloat)scale;


#pragma mask : 编码相关
// -- ASC
- (NSString*) ASCIIString;

@end
