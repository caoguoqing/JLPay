//
//  SettlementSwitchView.h
//  JLPay
//
//  Created by jielian on 15/12/4.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModelSettlementInformation.h"


/* - 结算方式切换视图 - */

@class SettlementSwitchView;
@protocol SettlementSwitchViewDelegate <NSObject>
@optional
/* 切换了结算方式 */
- (void) didSwitchedSettlementType:(SETTLEMENTTYPE)settlementType;

@end


@interface SettlementSwitchView : UIView

@property (nonatomic, assign) id<SettlementSwitchViewDelegate>delegate;

@property (nonatomic, assign) BOOL enableSwitching; // 是否允许切换

/* 切换回正常状态 */
- (void) switchNormal;

@end
