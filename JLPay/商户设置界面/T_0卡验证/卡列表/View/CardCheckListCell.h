//
//  CardCheckListCell.h
//  JLPay
//
//  Created by jielian on 16/6/22.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define_Header.h"

@interface CardCheckListCell : UITableViewCell

@property (nonatomic, strong) UILabel* creditCardLabel;     // 信用卡字体
@property (nonatomic, strong) UILabel* cardNoLabel;         // 卡号
@property (nonatomic, strong) UILabel* checkStateLabel;     // 审核状态
@property (nonatomic, strong) UILabel* cardCustName;        // 户名

@end
