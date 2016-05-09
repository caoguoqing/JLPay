//
//  NSError+Custom.h
//  JLPay
//
//  Created by jielian on 16/4/12.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Custom)

// -- 自定义初始化方法
+ (instancetype) errorWithDomain:(NSString*)domain code:(NSInteger)code localizedDescription:(NSString*)localizedDescription;

@end
