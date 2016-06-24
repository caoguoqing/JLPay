//
//  PullRefrashView.h
//  JLPay
//
//  Created by jielian on 15/11/27.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullRefrashView : UIView


/* 调为下拉状态 */
- (void) turnPullUp;
/* 调为上拉状态 */
- (void) turnPullDown;
/* 调为等待状态 */
- (void) turnWaiting;

/* 查询状态 */
- (BOOL) isRefreshing;
- (BOOL) isPullingUp;
- (BOOL) isPullingDown;

@end
