//
//  NSString+Formater.m
//  CreditCardManager
//
//  Created by 冯金龙 on 16/1/26.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "NSString+Formater.h"

@implementation NSString (Formater)


#pragma mask : 日期格式化相关

// -- 当前日期的格式化: 指定日;
+ (NSString*) curDateString {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMdd"];
    NSString* curFormationDate = [dateFormatter stringFromDate:[NSDate date]];
    return curFormationDate;
}

// -- 当月最后一天
- (NSString*) lastDayOfCurMonth {
    NSString* nextMonth = [self nextMonth];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMdd"];
    
    NSDate* firstDayOfNextMonth = [dateFormatter dateFromString:[nextMonth stringByAppendingString:@"01"]];
    
    return [dateFormatter stringFromDate:[NSDate dateWithTimeInterval:- 24 * 60 * 60 sinceDate:firstDayOfNextMonth]];
}

// -- 月份计算: 前一个月
- (NSString*) lastMonth {
    if (!self || self.length < 6) {
        return nil;
    }
    NSInteger curYYYY = [[self substringToIndex:4] integerValue];
    NSInteger curMM = [[self substringWithRange:NSMakeRange(4, 2)] integerValue];
    
    if (curMM == 1) {
        curMM = 12;
        curYYYY --;
    } else {
        curMM --;
    }
    return [NSString stringWithFormat:@"%d%02d",curYYYY,curMM];
}
// -- 月份计算: 后一个月
- (NSString*) nextMonth {
    if (!self || self.length < 6) {
        return nil;
    }
    NSInteger curYYYY = [[self substringToIndex:4] integerValue];
    NSInteger curMM = [[self substringWithRange:NSMakeRange(4, 2)] integerValue];
    
    if (curMM == 12) {
        curMM = 1;
        curYYYY ++;
    } else {
        curMM ++;
    }
    return [NSString stringWithFormat:@"%d%02d",curYYYY,curMM];
}

// -- 两个日期的间隔月数
- (NSInteger) intervalWithOtherMonth:(NSString*)otherMonth {
    NSInteger curMonthyyyy = [self substringToIndex:4].integerValue;
    NSInteger curMonthMM = [self substringWithRange:NSMakeRange(4, 2)].integerValue;
    NSInteger otherMonthyyyy = [otherMonth substringToIndex:4].integerValue;
    NSInteger otherMonthMM = [otherMonth substringWithRange:NSMakeRange(4, 2)].integerValue;
    
    if (curMonthyyyy == otherMonthyyyy) {
        return curMonthMM - otherMonthMM;
    }
    else if (curMonthyyyy > otherMonthyyyy) {
        return curMonthMM + (12 - otherMonthMM) + (curMonthyyyy - otherMonthyyyy - 1) * 12;
    }
    else {
        return - ((12 - curMonthMM) + otherMonthMM + (otherMonthyyyy - curMonthyyyy - 1) * 12);
    }
}

#pragma mask : 日期&时间 格式化相关    yyyyMMddhhmmss
+ (instancetype) formatedDateStringFromSourceTime:(NSString*)allLenTime {
    return [NSString stringWithFormat:@"%@/%@/%@",
            [allLenTime substringToIndex:4],
            [allLenTime substringWithRange:NSMakeRange(4, 2)],
            [allLenTime substringWithRange:NSMakeRange(6, 2)]];
}
+ (instancetype) formatedTimeStringFromSourceTime:(NSString*)allLenTime {
    return [NSString stringWithFormat:@"%@:%@:%@",
            [allLenTime substringWithRange:NSMakeRange(8, 2)],
            [allLenTime substringWithRange:NSMakeRange(10, 2)],
            [allLenTime substringWithRange:NSMakeRange(12, 2)]];
}




#pragma mask : 截取字符串相关

// 截取指定位字符为*
- (NSString*) stringCuttingXingInRange:(NSRange)range {
    NSMutableString* newString = [[NSMutableString alloc] init];
    if (range.location >= self.length) {
        newString = nil;
    } else {
        [newString appendString:[self substringToIndex:range.location]];
        NSInteger xingCount = (range.location + range.length >= self.length)?(self.length - range.location):(range.length);
        for (NSInteger i = 0; i < 4; i++) {
            [newString appendString:@"*"];
        }
        [newString appendString:[self substringFromIndex:range.location + xingCount]];
    }
    return newString;
}


#pragma mask : font 和 text size 相关
// -- 重新计算字体大小:指定高度
+ (CGFloat) resizeFontAtHeight:(CGFloat)height scale:(CGFloat)scale {
    CGFloat testFontSize = 20.f;
    CGSize oldTextSize = [@"test" sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:testFontSize] forKey:NSFontAttributeName]];
    return (height/oldTextSize.height) * testFontSize * scale;
}

- (CGFloat) resizeFontAtHeight:(CGFloat)height scale:(CGFloat)scale{
    CGFloat testFontSize = 20.f;
    CGSize oldTextSize = [self sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:testFontSize] forKey:NSFontAttributeName]];
    return (height/oldTextSize.height) * testFontSize * scale;
}

- (CGSize) resizeAtHeight:(CGFloat)height scale:(CGFloat)scale{
    CGFloat newFontSize = [self resizeFontAtHeight:height scale:scale];
    CGSize size = [self sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:newFontSize] forKey:NSFontAttributeName]];
    size.height = height;
    return size;
}


#pragma mask : 编码相关
// -- ASC
- (NSString*) ASCIIString {
    NSMutableString* ascString = [NSMutableString string];
    NSData* ascData = [self dataUsingEncoding:NSASCIIStringEncoding];
    NSString* mask = @"0123456789ABCDEF";
    Byte* ascBytes = (Byte*)[ascData bytes];
    for (int i = 0; i < [ascData length]; i++) {
        [ascString appendFormat:@"%c", (char)[mask characterAtIndex:(ascBytes[i] & 0xf0 >> 4)]];
        [ascString appendFormat:@"%c", (char)[mask characterAtIndex:(ascBytes[i] & 0x0f >> 0)]];
    }
    return ascString;
}

@end
