//
//  SelectIndicatorView.h
//  JLPay
//
//  Created by jielian on 15/8/4.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//



/**
 * 小工具: 选择指示器: 两个上下堆叠的三角形
 * 已弃用了
 *
 */


#import <UIKit/UIKit.h>

@protocol SelectIndicatorViewDelegate <NSObject>

@optional
- (void)didTouchedInSelectIndicator;

@end


@interface SelectIndicatorView : UIView
@property (nonatomic, weak) id<SelectIndicatorViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame andViewColor:(UIColor*)color;

@end
