//
//  TransDetailTBVCell.h
//  JLPay
//
//  Created by jielian on 16/5/4.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import <ReactiveCocoa.h>
#import "Define_Header.h"

@interface TransDetailTBVCell : UITableViewCell

@property (nonatomic, strong) UILabel* moneyLabel;
@property (nonatomic, strong) UILabel* transTypeLabel;
@property (nonatomic, strong) UILabel* detailsLabel;
@property (nonatomic, strong) UILabel* timeLabel;

@end
