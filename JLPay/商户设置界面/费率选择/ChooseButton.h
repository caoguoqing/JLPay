//
//  ChooseButton.h
//  JLPay
//
//  Created by jielian on 16/3/3.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    ChooseButtonTypeRect,
    ChooseButtonTypeUnderLine
} ChooseButtonType;

@interface ChooseButton : UIButton


@property (nonatomic, assign) BOOL hasLineBottom;

@property (nonatomic, assign) ChooseButtonType chooseButtonType;

- (void) turningDirection:(BOOL)up;

@property (nonatomic, strong) UIColor* nomalColor;
@property (nonatomic, strong) UIColor* selectedColor;



@end
