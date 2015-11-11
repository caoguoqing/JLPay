//
//  TotalAmountDisplayView.h
//  JLPay
//
//  Created by jielian on 15/7/28.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

/* *
 * 总金额显示框
 * 分两部分：
 *  1.总交易金额
 *  2.交易笔数: 总，消费，撤销
 *
 *
 */


@interface TotalAmountDisplayView : UIView

// 设置总金额
- (void) setTotalAmount: (NSString*)totalAmount ;

// 设置总笔数
- (void) setTotalRows: (NSString*)totalRows ;

// 设置成功笔数
- (void) setSucRows: (NSString*)totalAmount ;

// 设置撤销笔数
- (void) setRevokeRows: (NSString*)totalAmount ;


@end
