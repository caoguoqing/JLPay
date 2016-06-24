//
//  PayStatusDisplayView.h
//  JLPay
//
//  Created by jielian on 16/4/27.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "PublicInformation.h"

@interface PayStatusDisplayView : UIView

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* labelStatus;
@property (nonatomic, strong) UILabel* labelMoney;
@property (nonatomic, strong) UILabel* labelGoodsName;


@end
