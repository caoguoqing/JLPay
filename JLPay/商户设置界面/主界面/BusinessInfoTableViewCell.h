//
//  BusinessInfoTableViewCell.h
//  JLPay
//
//  Created by jielian on 15/11/19.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define_Header.h"
#import "Masonry.h"

@interface BusinessInfoTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView* headImageView;   // 头像图片
@property (nonatomic, strong) UILabel* labelUserId;         // 登录名标签
@property (nonatomic, strong) UILabel* labelBusinessName;   // 商户名标签
@property (nonatomic, strong) UILabel* labelBusinessNo;     // 商户号标签
@property (nonatomic, strong) UILabel* labelCheckedState;   // 审核状态


@end
