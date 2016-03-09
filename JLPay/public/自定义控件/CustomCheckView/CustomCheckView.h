//
//  CustomCheckView.h
//  JLPay
//
//  Created by jielian on 16/3/9.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CustomCheckViewStyleNullBorder,
    CustomCheckViewStyleCircleBorder,
    CustomCheckViewStyleRectBorder,
    
    CustomCheckViewStyleCheckRight,
    CustomCheckViewStyleCheckWrong
} CustomCheckViewStyle;

@interface CustomCheckView : UIView

@property (nonatomic, assign) BOOL canAnimation;

@property (nonatomic, strong) UIColor* tintColor;
@property (nonatomic, strong) UIColor* backColor;

//@property (nonatomic)

@end
