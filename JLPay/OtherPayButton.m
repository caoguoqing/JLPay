//
//  OtherPayButton.m
//  JLPay
//
//  Created by jielian on 15/5/18.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "OtherPayButton.h"

@interface OtherPayButton()
@property (nonatomic, strong)    UIImageView *imageView;                // 支付按钮图标
@property (nonatomic, strong)    UILabel     *labelName;                // 支付按钮标签
@end



@implementation OtherPayButton
@synthesize imageView               = _imageView;
@synthesize labelName               = _labelName;



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 按钮图片
        self.imageView              = [[UIImageView alloc] initWithFrame:CGRectZero];
        // 按钮 label
        self.labelName              = [[UILabel alloc] initWithFrame:CGRectZero];
        
        // 按钮背景色
        self.backgroundColor        = [UIColor colorWithWhite:0.7 alpha:0.5];
    }
    return self;
}

- (void) setImageViewWithName: (NSString*)imageName {
    self.imageView.image            = [UIImage imageNamed:imageName];
}
- (void) setLabelNameWithName: (NSString*)labelName {
    self.labelName.text             = labelName;
    self.labelName.textAlignment    = NSTextAlignmentLeft;
    self.labelName.textColor        = [UIColor whiteColor];
    self.labelName.font             = [UIFont systemFontOfSize:12];
}

- (void)layoutSubviews {
    CGFloat width_imageView         = self.bounds.size.height / 5.0 * 4.0;
    CGFloat x_imageView             = width_imageView / 2.0;
    CGFloat y_imageView             = (self.bounds.size.height - width_imageView) / 2.0;
    
    CGFloat inset                   = 5.0;
    CGFloat width_label             = self.bounds.size.width - width_imageView * 2 - inset;
    CGFloat height_label            = self.bounds.size.height;
    CGFloat x_label                 = x_imageView + width_imageView + inset;
    CGFloat y_label                 = 0;
    
    
    self.imageView.frame            = CGRectMake(x_imageView, y_imageView, width_imageView, width_imageView);
    self.labelName.frame            = CGRectMake(x_label, y_label, width_label, height_label);
    [self addSubview:self.imageView];
    [self addSubview:self.labelName];
}


@end
