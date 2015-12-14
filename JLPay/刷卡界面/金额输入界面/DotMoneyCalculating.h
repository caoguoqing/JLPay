//
//  DotMoneyCalculating.h
//  JLPay
//
//  Created by jielian on 15/12/14.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DotMoneyCalculating : NSObject

// 追加数字
- (NSString*) moneyByAddedNumber: (NSString*)number;

// 撤销到上一步
- (NSString*) moneyByRevoked;


@end
