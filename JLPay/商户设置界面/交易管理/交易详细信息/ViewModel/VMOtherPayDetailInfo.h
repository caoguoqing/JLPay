//
//  VMOtherPayDetailInfo.h
//  JLPay
//
//  Created by jielian on 16/5/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Define_Header.h"
#import "MOtherPayDetails.h"


static NSString* const kOtherPayInfoNameMoney      	 	= @"交易金额";
static NSString* const kOtherPayInfoNameBusinessNo      = @"商户编号";
static NSString* const kOtherPayInfoNameStatus       	= @"交易状体";
static NSString* const kOtherPayInfoNameOrderNo       	= @"订单编号";
static NSString* const kOtherPayInfoNamePayType       	= @"交易类型";
static NSString* const kOtherPayInfoNameTime       		= @"交易时间";
static NSString* const kOtherPayInfoNameDate       		= @"交易日期";
static NSString* const kOtherPayInfoNameGoodsName       = @"商品名称";



@interface VMOtherPayDetailInfo : NSObject

<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSDictionary* detailNode;
@property (nonatomic, strong) NSMutableArray* keyDisplayList;
@property (nonatomic, strong) NSDictionary* keysAndTitles;

@end
