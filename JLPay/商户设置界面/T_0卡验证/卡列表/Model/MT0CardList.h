//
//  MT0CardList.h
//  JLPay
//
//  Created by jielian on 16/7/12.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


/* 卡号 */
static NSString* const kMT0CardListCardNo = @"cardId";
/* 账户名 */
static NSString* const kMT0CardListUserName = @"cardUserName";
/* 审核状态: [0]通过; [1]未审核; [2]拒绝; */
static NSString* const kMT0CardListCheckFlag = @"checkFlag";
/* 拒绝原因 if checkFlag == 2 */
static NSString* const kMT0CardListRefuseReason = @"refuseReason";

@interface MT0CardList : NSDictionary


@end
