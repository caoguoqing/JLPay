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
    }
    return self;
}




@end
