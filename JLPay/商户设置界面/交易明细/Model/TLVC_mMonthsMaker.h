//
//  TLVC_mMonthsMaker.h
//  JLPay
//
//  Created by jielian on 2017/1/13.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLVC_mMonthsMaker : NSObject

/* 计算出当前可以查询的月份组: 最多最近的4个月 */
+ (NSArray*) monthsAvilableList;

@end
