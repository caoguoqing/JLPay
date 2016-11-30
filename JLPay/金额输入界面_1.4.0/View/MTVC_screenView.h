//
//  MTVC_screenView.h
//  CustomViewMaker
//
//  Created by jielian on 16/9/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTVC_settlementSwitchBtn.h"

static NSString* const kSettleTypeT_0 = @"T+0";
static NSString* const kSettleTypeT_1 = @"T+1";




@interface MTVC_screenView : UIView

@property (nonatomic, strong) UILabel* moneyLabel;

@property (nonatomic, strong) MTVC_settlementSwitchBtn* settlementSwitchBtn;

@property (nonatomic, strong) UILabel* businessLabel;

@property (nonatomic, copy) NSAttributedString* deviceBtnAttriTitle;
@property (nonatomic, strong) UIButton* deviceConnectBtn;

@end
