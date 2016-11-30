//
//  NSAttributedString+FontAwesomeString.h
//  CustomViewMaker
//
//  Created by jielian on 2016/10/27.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <NSString+FontAwesome.h>
#import <UIFont+FontAwesome.h>


typedef NS_ENUM(NSInteger, FAwesomeLocation) {
    FAwesomeLocation_left,
    FAwesomeLocation_right
};

@interface NSAttributedString (FontAwesomeString)




/* 带iconfont字体的字段串: 可左可右,中间一个空格字符 */
+ (NSAttributedString*) stringWithAwesomeText:(NSString*)awesomeText
                                  awesomeFont:(UIFont*)awesomeFont
                                 awesomeColor:(UIColor*)awesomeColor
                                         text:(NSString*)text
                                     textFont:(UIFont*)textFont
                                    textColor:(UIColor*)textColor
                              awesomeLocation:(FAwesomeLocation)location;


/* 带iconfont字体的字段串: 左右各一个,中间一个空格字符 */
+ (NSAttributedString*) stringWithLeftAwesomeText:(NSString*)leftAwesomeText
                                  leftAwesomeFont:(UIFont*)leftAwesomeFont
                                 leftAwesomeColor:(UIColor*)leftAwesomeColor
                                 rightAwesomeText:(NSString*)rightAwesomeText
                                 rightAwesomeFont:(UIFont*)rightAwesomeFont
                                rightAwesomeColor:(UIColor*)rightAwesomeColor
                                             text:(NSString*)text
                                         textFont:(UIFont*)textFont
                                        textColor:(UIColor*)textColor;



@end
