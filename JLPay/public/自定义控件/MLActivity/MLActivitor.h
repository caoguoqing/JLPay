//
//  MLActivitor.h
//  CustomViewMaker
//
//  Created by jielian on 2016/11/9.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLActivitor : UIView

/* default 0x888888 */
@property (nonatomic, copy) UIColor* tintColor;

/* 单个item动画时间, default 0.618 */
@property (nonatomic, assign) CGFloat uniteDuration;

/* 一次轮询时间, default 1.f */
@property (nonatomic, assign) CGFloat perCircleDuration;

- (void) show;
- (void) hide;

@end
