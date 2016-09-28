//
//  DC_titleViewChooseTerminal.h
//  JLPay
//
//  Created by jielian on 16/9/7.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DC_titleViewChooseTerminal : UIView

@property (nonatomic, strong) UILabel* titleLabel;

@property (nonatomic, strong) UILabel* contentLabel;

@property (nonatomic, strong) UIButton* switchBtn;

/* 展开属性 */
@property (nonatomic, assign) BOOL disclosured;


@end
