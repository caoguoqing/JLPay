//
//  NaviTitleViewPullDownChoose.h
//  JLPay
//
//  Created by jielian on 16/8/24.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NaviTitleViewPullDownChoose : UIButton

/* 控制上下方向 */
@property (nonatomic, assign) BOOL downPulled;

@property (nonatomic, strong) UILabel* downLabel;

@end
