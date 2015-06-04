//
//  OtherSignButton.m
//  JLPay
//
//  Created by jielian on 15/5/28.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "OtherSignButton.h"

@interface OtherSignButton()

@property (nonatomic, strong) UIImageView*      imageView;
//@property (nonatomic, strong) NSString*         text;
@end


@implementation OtherSignButton

@synthesize imageView                   = _imageView;
@synthesize text                        = _text;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView                      = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

#pragma mask ---- 设置按钮的标签  :  "立即注册"|"忘记密码?"
- (void) setText:(NSString *)text {
    if (![_text isEqualToString:text]) {
        _text                           = [text copy];
    }
}

- (void)layoutSubviews {
    self.imageView.frame                = self.bounds;
    if ([self.text isEqualToString:@"立即注册"]) {
        self.imageView.image            = [UIImage imageNamed:@"zc"];
    } else {
        self.imageView.image            = [UIImage imageNamed:@"wmm"];
    }
}


@end
