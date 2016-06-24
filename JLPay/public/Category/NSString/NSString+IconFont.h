//
//  NSString+IconFont.h
//  JLPay
//
//  Created by jielian on 16/6/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    /* V1.1 : IconFont_1_1.ttf */
    IconFontType_codeScanning           = 0xe667,	/* 扫码 */
    IconFontType_barCodeAndQRCode       = 0xe654,	/* 条码二维码 */

    /* V1.0 : IconFont_1_0.ttf */
    IconFontType_backspace				= 0xea82,	/* 退格 */
    IconFontType_user					= 0xe611,	/* 用户名 */
    IconFontType_alipay					= 0xe631,	/* 支付宝 */
    IconFontType_wechatPay				= 0xe6dc,	/* 微信支付 */
    IconFontType_card					= 0xe65f,	/* 卡片 */
    IconFontType_search					= 0xe677,	/* 搜索 */
    IconFontType_creditcard				= 0xe630,	/* 信用卡 */
    IconFontType_lock					= 0xe61c,	/* 锁 */
    IconFontType_unlock					= 0xe62d,	/* 解锁 */
    IconFontType_calculator				= 0xe600,	/* 计算器 */
    IconFontType_bluetoothSearching		= 0xe621,	/* 搜索蓝牙 */
    IconFontType_setting_strock			= 0xe64f,	/* 设置(strock) */
    IconFontType_setting_fill			= 0xe64e,	/* 设置(fill) */
    IconFontType_link					= 0xe685,	/* 链接 */
    IconFontType_billCheck				= 0xe605,	/* 账单查询 */
    IconFontType_detail					= 0x343a 	/* 明细详情 */

} IconFontType;




@interface NSString (IconFont)

/* 生成字体库文字 */
+ (NSString*) stringWithIconFontType:(IconFontType)type;


@end
