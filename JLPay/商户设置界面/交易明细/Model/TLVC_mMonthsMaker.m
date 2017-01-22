//
//  TLVC_mMonthsMaker.m
//  JLPay
//
//  Created by jielian on 2017/1/13.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "TLVC_mMonthsMaker.h"
#import "Define_Header.h"

@implementation TLVC_mMonthsMaker

+ (NSArray *)monthsAvilableList {
    NSString* curDate = [[PublicInformation currentDateAndTime] substringToIndex:4+2];
    
    NSMutableArray* months = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        [months addObject:[self formatMonthWithMonth:curDate]];
        curDate = [curDate lastMonth];
    }
    
    return [months copy];
}

+ (NSString*) formatMonthWithMonth:(NSString*)month {
    return [NSString stringWithFormat:@"%@年%@月",
            [month substringWithRange:NSMakeRange(0, 4)], [month substringWithRange:NSMakeRange(4, 2)]];
}

@end
