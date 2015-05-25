//
//  AdditionalButton.m
//  JLPay
//
//  Created by jielian on 15/5/25.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

/*
 *  添加按钮 : 只有一个 "+" 按钮;
 */


#import "AdditionalButton.h"

@implementation AdditionalButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitle:@"+" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.titleLabel.font        = [UIFont boldSystemFontOfSize:30.0];
//        self.layer.borderWidth      = 2.0;
//        self.layer.borderColor      = [UIColor blackColor].CGColor;
        
        self.layer.borderColor      = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        self.layer.borderWidth      = 0.3;
        
        
        
        // 添加按钮的点击事件: 开始点击、点击完成
        [self addTarget:self action:@selector(clickButtonDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(clickButtonUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(clickButtonOutUp:) forControlEvents:UIControlEventTouchUpOutside];

    }
    return self;
}

/*************************************
 * 功  能 : clickButtonDown: 功能按钮的点击开始;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (IBAction) clickButtonDown:(AdditionalButton*)sender {
    self.backgroundColor            = [UIColor colorWithWhite:0.5 alpha:0.5];
}

/*************************************
 * 功  能 : clickButtonUp: 功能按钮的点击结束;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (IBAction) clickButtonUp:(AdditionalButton*)sender {
    self.backgroundColor            = [UIColor clearColor];
}
/*************************************
 * 功  能 : clickButtonOutUp: 功能按钮的点击结束;
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (IBAction) clickButtonOutUp:(AdditionalButton*)sender {
    self.backgroundColor            = [UIColor clearColor];
}


@end
