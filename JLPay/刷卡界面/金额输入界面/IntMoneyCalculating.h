//
//  IntMoneyCalculating.h
//  JLPay
//
//  Created by jielian on 15/12/17.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IntMoneyCalculating : NSObject


// 追加数字
- (NSString*) dotMoneyByAddedNumber: (NSString*)number;

// 撤销到上一步
- (NSString*) dotMoneyByRevoked;


@end
