//
//  NSString+IconFont.m
//  JLPay
//
//  Created by jielian on 16/6/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "NSString+IconFont.h"

@implementation NSString (IconFont)


+ (NSString*) stringWithIconFontType:(IconFontType)type {
    return [[self fontStringAndTypeDic] objectForKey:@(type)];
}



# pragma mask 2 每次版本更新都要更新数据字典

+ (NSDictionary*) fontStringAndTypeDic {
    return @{
             /* 1.1 */
             @(IconFontType_codeScanning)           : @"\ue667",
             @(IconFontType_barCodeAndQRCode)       : @"\ue654",

             /* V1.0 */
             @(IconFontType_backspace)				: @"\uea82",
             @(IconFontType_user)					: @"\ue611",
             @(IconFontType_alipay)					: @"\ue631",
             @(IconFontType_wechatPay)				: @"\ue6dc",
             @(IconFontType_card)					: @"\ue65f",
             @(IconFontType_search)					: @"\ue677",
             @(IconFontType_creditcard)				: @"\ue630",
             @(IconFontType_lock)					: @"\ue61c",
             @(IconFontType_unlock)					: @"\ue62d",
             @(IconFontType_calculator)				: @"\ue600",
             @(IconFontType_bluetoothSearching)		: @"\ue621",
             @(IconFontType_setting_strock)			: @"\ue64f",
             @(IconFontType_setting_fill)			: @"\ue64e",
             @(IconFontType_link)					: @"\ue685",
             @(IconFontType_billCheck)				: @"\ue605",
             @(IconFontType_detail)					: @"\u343a",
             };
}


@end
