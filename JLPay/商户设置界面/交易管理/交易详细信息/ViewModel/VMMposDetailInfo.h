//
//  VMMposDetailInfo.h
//  JLPay
//
//  Created by jielian on 16/5/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Define_Header.h"
#import "MMposDetails.h"


static NSString* const kMposInfoNameTransType       = @"交易类型";
static NSString* const kMposInfoNameBusinessNo      = @"商户编号";
static NSString* const kMposInfoNameBusinessName    = @"商户名称";
static NSString* const kMposInfoNameTransMoney      = @"交易金额";
static NSString* const kMposInfoNameCardNo          = @"交易卡号";
static NSString* const kMposInfoNameTransDate       = @"交易日期";
static NSString* const kMposInfoNameTransTime       = @"交易时间";
static NSString* const kMposInfoNameTransState      = @"交易状态";
static NSString* const kMposInfoNameOrderNo         = @"订单编号";
static NSString* const kMposInfoNameTerminalNo      = @"终端编号";
static NSString* const kMposInfoNameSettleType      = @"结算方式";
static NSString* const kMposInfoNameSettleState     = @"结算状态";
static NSString* const kMposInfoNameSettleMoney     = @"结算金额";
static NSString* const kMposInfoNameSettleRefuse    = @"拒绝原因";


/* 交易类型 */
static NSString* const MposInfoNameTransTypeCust    = @"消费";

@interface VMMposDetailInfo : NSObject
<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSDictionary* detailNode;
@property (nonatomic, strong) NSMutableArray* keyDisplayList;
@property (nonatomic, strong) NSDictionary* keysAndTitles;

@end
