//
//  TotalAmountCell.h
//  JLPay
//
//  Created by jielian on 15/6/8.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TotalAmountCell : UITableViewCell

// 设置总金额
- (void) setTotalAmount: (NSString*)totalAmount ;
// 设置总笔数
- (void) setTotalRows: (NSString*)totalRows ;
// 设置成功笔数
- (void) setSucRows: (NSString*)totalAmount ;
// 设置冲正笔数
- (void) setFlushRows: (NSString*)flushRows ;
// 设置撤销笔数
- (void) setRevokeRows: (NSString*)totalAmount ;

@end
