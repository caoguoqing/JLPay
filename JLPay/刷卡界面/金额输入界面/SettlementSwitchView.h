//
//  SettlementSwitchView.h
//  JLPay
//
//  Created by jielian on 15/12/4.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>


/* - 结算方式切换视图 - */



/* 结算方式枚举量 */
typedef enum {
    SETTLEMENTTYPE_T_1 = 1 << 0, // T+1
    SETTLEMENTTYPE_T_0 = 1 << 1, // T+0
} SETTLEMENTTYPE;


@class SettlementSwitchView;
@protocol SettlementSwitchViewDelegate <NSObject>
@optional
/* 切换了结算方式 */
- (void) didSwitchedSettlementType:(SETTLEMENTTYPE)settlementType;

@end


@interface SettlementSwitchView : UIView

@property (nonatomic, assign) id<SettlementSwitchViewDelegate>delegate;

@property (nonatomic, assign) BOOL enableSwitching; // 是否允许切换

/* 当前结算方式文本: 指定结算方式枚举量 */
- (NSString*) textCurrentSettlementType:(SETTLEMENTTYPE)settlementType ;

@end
