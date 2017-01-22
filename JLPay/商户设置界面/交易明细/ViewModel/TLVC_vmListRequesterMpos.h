//
//  TLVC_vmListRequesterMpos.h
//  JLPay
//
//  Created by jielian on 2017/1/13.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLVC_mDetailMpos.h"


@class RACCommand;
@interface TLVC_vmListRequesterMpos : NSObject

/* 商户编号 */
@property (nonatomic, copy) NSString* mchntNo;
/* 终端编号 */
@property (nonatomic, copy) NSString* termNo;
/* 起始日期时间 */
@property (nonatomic, copy) NSString* queryBeginTime;
/* 终止日期时间 */
@property (nonatomic, copy) NSString* queryEndTime;

/* 查询到的交易明细: OUT */
@property (nonatomic, strong) NSArray* detailList;

/* 命令: 查询交易明细 */
@property (nonatomic, strong) RACCommand* cmd_requesting;

@end
