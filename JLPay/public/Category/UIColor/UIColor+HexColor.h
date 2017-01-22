//
//  UIColor+HexColor.h
//  JLPay
//
//  Created by jielian on 16/4/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HexColorTypeThemeRed        = 0xeb454b,     // 主题色:红色
    HexColorTypeLightOrangeRed  = 0xEC5B53,     // 亮橘红色
    HexColorTypeGreen           = 0x2da43a,     // 绿色
    HexColorTypeViewCyan        = 0x5AB3B6,     // 靛青色-窗口
    HexColorTypeTextCyan        = 0x4B9993,     // 靛青色-文本
    HexColorTypeLightBlue       = 0x01abf0,     // 亮蓝色-支付宝
    HexColorTypeBlackBlue       = 0x27384B,     // 深蓝色
    HexColorTypeBlackGray       = 0x3C4448,     // 深灰色
    HexColorTypeDarkBlack       = 0x181F25      // 深黑色
} HexColorType;


@interface UIColor (HexColor)

+ (UIColor*) colorWithHex:(NSInteger)hexColor alpha:(CGFloat)alpha;

@end
