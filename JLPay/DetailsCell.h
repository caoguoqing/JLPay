//
//  DetailsCell.h
//  JLPay
//
//  Created by jielian on 15/6/8.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsCell : UITableViewCell

#pragma mask ::: 金额属性赋值
- (void) setAmount : (NSString*)amount;
#pragma mask ::: 卡号属性赋值
- (void) setCardNum : (NSString*)cardNum;
#pragma mask ::: 日期时间赋值
- (void) setTime : (NSString*)time;



@end
