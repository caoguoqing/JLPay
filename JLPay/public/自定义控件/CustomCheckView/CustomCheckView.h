//
//  CustomCheckView.h
//  CustomViewMaker
//
//  Created by 冯金龙 on 16/3/9.
//  Copyright © 2016年 冯金龙. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    CustomCheckViewStyleRight       = 1 << 0, // 勾
    CustomCheckViewStyleWrong       = 1 << 1, // 叉
    
    CustomCheckViewStyleLineRound   = 1 << 2, // 圆角
    CustomCheckViewStyleLineButt    = 1 << 3  // 直角
} CustomCheckViewStyle;

@interface CustomCheckView : UIView

@property (nonatomic, assign) CustomCheckViewStyle checkViewStyle;

@property (nonatomic, assign) BOOL animationWhenShowing;

@property (nonatomic, assign) CGFloat  innerSizeScale;
@property (nonatomic, strong) UIColor* lineColor;
@property (nonatomic, assign) CGFloat  lineWidth;

- (void) showDuration:(CGFloat)duration delay:(CGFloat)delay completion:(void (^) (void))completion;

@end
