//
//  VMAccountReceived.h
//  JLPay
//
//  Created by jielian on 16/5/20.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define_Header.h"
#import "HTTPInstance.h"
#import <ReactiveCocoa.h>
#import "DispatchDetailCell.h"

typedef enum {
    VMAccountReceivedStateRequestPre,
    VMAccountReceivedStateRequesting,
    VMAccountReceivedStateRequestSuc,
    VMAccountReceivedStateRequestFail
}VMAccountReceivedState;

@interface VMAccountReceived : NSObject
<UITableViewDataSource>
/*
 * 1. 仅查询明细，并计算出总的已结算金额
 * 2. 需要列出明细信息
 */

@property (nonatomic, assign) CGFloat accountReceived;      /* 已结算金额 */

@property (nonatomic, assign) VMAccountReceivedState state;


/* 请求需要的字段 */
@property (nonatomic, copy) NSString* requestPropDateBegin;
@property (nonatomic, copy) NSString* requestPropDateEnd;

@property (nonatomic, strong) HTTPInstance* http;

@property (nonatomic, strong) NSMutableArray* curDateSettleDetailList;
@property (nonatomic, copy) NSError* errorRequested;

@end
