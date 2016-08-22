//
//  SU_MobileCheckCell.h
//  JLPay
//
//  Created by jielian on 16/7/6.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SU_MobileCheckCell : UITableViewCell

@property (nonatomic, strong) UILabel* iconLabel;           /* icon标签 */

@property (nonatomic, strong) UITextField* textField;       /* 文本输入框 */

@property (nonatomic, strong) UIView* seperateView;         /* 分割线 */

@property (nonatomic, strong) UIButton* reCheckBtn;         /* 重新验证按钮 */


@end
