//
//  UIColor+HexColor.m
//  JLPay
//
//  Created by jielian on 16/4/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "UIColor+HexColor.h"

@implementation UIColor (HexColor)

+ (UIColor*) colorWithHex:(NSInteger)hexColor alpha:(CGFloat)alpha {
    CGFloat red = (CGFloat)((hexColor & 0xff0000) >> 8 * 2)/0xff;
    CGFloat green = (CGFloat)((hexColor & 0x00ff00) >> 8 * 1)/0xff;
    CGFloat blue = (CGFloat)((hexColor & 0x0000ff) >> 8 * 0)/0xff;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
