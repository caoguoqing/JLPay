//
//  RevokeViewCell.h
//  JLPay
//
//  Created by jielian on 15/11/12.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RevokeViewCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier ;


/* 设置标题 */
- (void) setCellTitle:(NSString*)title;
/* 设置值 */
- (void) setCellValue:(NSString*)value withColor:(UIColor*)color;

@end
