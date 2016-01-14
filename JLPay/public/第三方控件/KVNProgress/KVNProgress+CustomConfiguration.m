//
//  KVNProgress+CustomConfiguration.m
//  JLPay
//
//  Created by jielian on 16/1/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "KVNProgress+CustomConfiguration.h"

@implementation KVNProgress (CustomConfiguration)

// -- 自定义错误显示时间
+ (void)showErrorWithStatus:(NSString *)status duration:(NSTimeInterval)timeInterval {
    KVNProgressConfiguration* configuration = [KVNProgress configuration];
    [configuration setMinimumErrorDisplayTime:timeInterval];
    [KVNProgress setConfiguration:configuration];
    
    [KVNProgress showErrorWithStatus:status];
}

@end
