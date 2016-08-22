//
//  ElecSignView.h
//  JLPay
//
//  Created by jielian on 16/7/22.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ElecSignView : UIView <UIGestureRecognizerDelegate>

/* 重新签名 */
- (void) reSign;

# pragma mask : private properties

@property (nonatomic, strong) UIBezierPath* signPath;                   /* 记录签名轨迹 */

@property (nonatomic, assign) CGPoint prePoint;                         /* 保存上一个移动点 */

@end
