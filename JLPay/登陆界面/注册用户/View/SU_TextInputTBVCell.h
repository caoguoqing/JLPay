//
//  SU_TextInputTBVCell.h
//  JLPay
//
//  Created by 冯金龙 on 16/6/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SU_TextInputTBVCell : UITableViewCell

@property (nonatomic, strong) UILabel* mustInputLabel;              /* 必输标记 */

@property (nonatomic, strong) UITextField* textField;               /* 文本输入框 */

@end
