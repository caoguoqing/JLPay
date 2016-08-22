//
//  VMBusinessInfoRequester.h
//  JLPay
//
//  Created by jielian on 16/7/15.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBusinessInfo.h"

@class RACCommand;

@interface VMBusinessInfoRequester : NSObject

@property (nonatomic, strong) RACCommand* cmdInfoRequesting;            /* 请求信息的命令: 执行http查询 */

@property (nonatomic, strong) MBusinessInfo* businessInfo;              /* 商户信息数据源 */

@end
