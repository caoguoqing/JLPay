//
//  KVNProgress+CustomConfiguration.h
//  JLPay
//
//  Created by jielian on 16/1/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "KVNProgress.h"

@interface KVNProgress (CustomConfiguration)

// -- 自定义错误显示时间
+ (void)showErrorWithStatus:(NSString *)status duration:(NSTimeInterval)timeInterval;


@end
