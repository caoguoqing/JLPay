//
//  VMSettlementInfoRequestor.h
//  JLPay
//
//  Created by jielian on 16/7/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACCommand;

@interface VMSettlementInfoRequestor : NSObject

@property (nonatomic, strong) RACCommand* cmdRequestStlInfo;

@end
