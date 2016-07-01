//
//  SU_PhotoPickedTBVCell.h
//  JLPay
//
//  Created by 冯金龙 on 16/6/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SU_PhotoPickedTBVCell : UITableViewCell

@property (nonatomic, strong) UILabel* mustInputLabel;              /* 必输标记 */

@property (nonatomic, strong) UILabel* backLabel;                   /* 背景iconLbabel */

@property (nonatomic, strong) UIImageView* imgViewPicked;           /* 图片 */

@end
