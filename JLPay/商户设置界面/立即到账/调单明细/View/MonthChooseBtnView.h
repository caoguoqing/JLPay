//
//  MonthChooseBtnView.h
//  JLPay
//
//  Created by jielian on 16/5/4.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import <ReactiveCocoa.h>
#import "Define_Header.h"


@interface MonthChooseBtnView : UIView


// -- 更新时间按钮日期
- (void) updateCurDateBtnTitleByDate:(NSString*)date;


@property (nonatomic, strong) UIButton* preSwitchBtn;   // 前切换一月
@property (nonatomic, strong) UIButton* sufSwitchBtn;   // 后切换一月
@property (nonatomic, strong) UIButton* curMonthBtn;    // 当前月

@property (nonatomic, assign) BOOL tbvPulledDown;

@end
