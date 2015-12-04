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
    SETTLEMENTTYPE_T_1 = 0, // T+1
    SETTLEMENTTYPE_T_0, // T+0
    SETTLEMENTTYPE_D_1, // D+1
    SETTLEMENTTYPE_D_0 // D+0
} SETTLEMENTTYPE;

@interface SettlementSwitchView : UIView

@end
