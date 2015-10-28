//
//  TotalAmountDisplayView.h
//  JLPay
//
//  Created by jielian on 15/7/28.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

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
