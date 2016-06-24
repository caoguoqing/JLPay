//
//  TransDetailTBVHeader.h
//  JLPay
//
//  Created by jielian on 16/5/12.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import <ReactiveCocoa.h>
#import "Define_Header.h"

@interface TransDetailTBVHeader : UITableViewHeaderFooterView

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* countTransLabel;

@end
