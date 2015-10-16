//
//  DoubleFieldCell.h
//  JLPay
//
//  Created by 冯金龙 on 15/10/15.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HEIGHT_DOUBLEFIELD_CELL   84


@class DoubleFieldCell;
@protocol DoubleFieldCellDelegate <NSObject>
@required
// 查询到了联行号
- doubleFieldCell:(DoubleFieldCell*)cell didSearchedBankNum:(NSString*)bankNum;

@end


@interface DoubleFieldCell : UITableViewCell
// 代理
@property (nonatomic, retain) id<DoubleFieldCellDelegate>delegate;

// 标题
@property (nonatomic, strong) NSString* title;
// 联行号
@property (nonatomic, strong) NSString* bankNum;

@end
