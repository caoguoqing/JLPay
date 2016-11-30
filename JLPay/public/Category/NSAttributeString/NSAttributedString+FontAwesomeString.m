//
//  NSAttributedString+FontAwesomeString.m
//  CustomViewMaker
//
//  Created by jielian on 2016/10/27.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "NSAttributedString+FontAwesomeString.h"


@implementation NSAttributedString (FontAwesomeString)


+ (NSAttributedString*) stringWithAwesomeText:(NSString*)awesomeText
                                  awesomeFont:(UIFont*)awesomeFont
                                 awesomeColor:(UIColor*)awesomeColor
                                         text:(NSString*)text
                                     textFont:(UIFont*)textFont
                                    textColor:(UIColor*)textColor
                              awesomeLocation:(FAwesomeLocation)location
{
    NSString* allString;
    if (location == FAwesomeLocation_left) {
        allString = [NSString stringWithFormat:@"%@ %@", awesomeText, text];
    } else {
        allString = [NSString stringWithFormat:@"%@ %@", text, awesomeText];
    }
    
    NSMutableAttributedString* attriString = [[NSMutableAttributedString alloc] initWithString:allString];

    NSInteger locationOriginAwesome = location == FAwesomeLocation_left ? 0 : allString.length - awesomeText.length;
    NSInteger locationOriginText = location == FAwesomeLocation_left ? allString.length - text.length : 0;
    
    /* 属性: awesome text */
    [attriString addAttribute:NSForegroundColorAttributeName
                        value:awesomeColor
                        range:NSMakeRange(locationOriginAwesome, awesomeText.length)];
    [attriString addAttribute:NSFontAttributeName
                        value:awesomeFont
                        range:NSMakeRange(locationOriginAwesome, awesomeText.length)];
    /* 属性: text */
    [attriString addAttribute:NSForegroundColorAttributeName
                        value:textColor
                        range:NSMakeRange(locationOriginText, text.length)];
    [attriString addAttribute:NSFontAttributeName
                        value:textFont
                        range:NSMakeRange(locationOriginText, text.length)];
    return attriString;
}



/* 带iconfont字体的字段串: 左右各一个,中间一个空格字符 */
+ (NSAttributedString*) stringWithLeftAwesomeText:(NSString*)leftAwesomeText
                                  leftAwesomeFont:(UIFont*)leftAwesomeFont
                                 leftAwesomeColor:(UIColor*)leftAwesomeColor
                                 rightAwesomeText:(NSString*)rightAwesomeText
                                 rightAwesomeFont:(UIFont*)rightAwesomeFont
                                rightAwesomeColor:(UIColor*)rightAwesomeColor
                                             text:(NSString*)text
                                         textFont:(UIFont*)textFont
                                        textColor:(UIColor*)textColor
{
    NSString* allString = [NSString stringWithFormat:@"%@ %@ %@", leftAwesomeText, text, rightAwesomeText];
    
    NSMutableAttributedString* attriString = [[NSMutableAttributedString alloc] initWithString:allString];

    NSInteger locationOriginText = allString.length - rightAwesomeText.length - 1 - text.length;
    NSInteger locationRightAwesomeText = allString.length - rightAwesomeText.length;

    /* 属性: left awesome text */
    [attriString addAttribute:NSForegroundColorAttributeName
                        value:leftAwesomeColor
                        range:NSMakeRange(0, leftAwesomeText.length)];
    [attriString addAttribute:NSFontAttributeName
                        value:leftAwesomeFont
                        range:NSMakeRange(0, leftAwesomeText.length)];
    /* 属性: text */
    [attriString addAttribute:NSForegroundColorAttributeName
                        value:textColor
                        range:NSMakeRange(locationOriginText, text.length)];
    [attriString addAttribute:NSFontAttributeName
                        value:textFont
                        range:NSMakeRange(locationOriginText, text.length)];
    
    /* 属性: right awesome text */
    [attriString addAttribute:NSForegroundColorAttributeName
                        value:rightAwesomeColor
                        range:NSMakeRange(locationRightAwesomeText, rightAwesomeText.length)];
    [attriString addAttribute:NSFontAttributeName
                        value:rightAwesomeFont
                        range:NSMakeRange(locationRightAwesomeText, rightAwesomeText.length)];

    return attriString;

}










@end
