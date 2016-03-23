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
    CustomCheckViewStyleWarn        = 1 << 2, // 感叹号

    
    
    CustomCheckViewStyleLineRound   = 1 << 8, // 圆角
    CustomCheckViewStyleLineButt    = 1 << 9  // 直角
} CustomCheckViewStyle;

@interface CustomCheckView : UIView

@property (nonatomic, assign) CustomCheckViewStyle checkViewStyle;

@property (nonatomic, assign) CGFloat  innerSizeScale; // 默认 1/4.5
@property (nonatomic, strong) UIColor* lineColor;
@property (nonatomic, assign) CGFloat  lineWidth;

- (void) showAnimation;
- (void) hiddenAnimation;


@end
