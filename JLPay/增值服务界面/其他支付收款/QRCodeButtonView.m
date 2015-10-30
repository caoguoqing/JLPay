//
//  QRCodeButtonView.m
//  JLPay
//
//  Created by jielian on 15/10/30.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "QRCodeButtonView.h"

@interface QRCodeButtonView()

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* titleLabel;

@end


@implementation QRCodeButtonView



#pragma mask ---- 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
    }
    return self;
}

#pragma mask ---- 重载子视图
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat bottomInset = 10;
    CGFloat validHeight = self.frame.size.height - bottomInset;
    CGFloat imageHeight = validHeight * (6.0/7.0) * (3.0/4.0);
    CGFloat imageWidth = imageHeight;
    if (self.image) {
        imageWidth *= self.image.size.width / self.image.size.height;
    }
    CGFloat labelHeight = validHeight * (1.0/7.0);
    CGFloat labelWidth = self.frame.size.width;
    
    CGRect frame = CGRectZero;
    frame.origin.x = (self.frame.size.width - imageWidth)/2.0;
    frame.origin.y = (self.frame.size.height - labelHeight - imageHeight)/2.0;
    frame.size.width = imageWidth;
    frame.size.height = imageHeight;
    [self.imageView setFrame:frame];
    
    frame.origin.x = 0;
    frame.origin.y = validHeight - labelHeight;
    frame.size.width = labelWidth;
    frame.size.height = labelHeight;
    [self.titleLabel setFrame:frame];
}


#pragma mask ---- 视图点击事件组
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"多少个点击事件:[%lu]",[touches count]);
    for (UITouch* touch in [touches allObjects]) {
        CGPoint point = [touch locationInView:self];
        NSLog(@"坐标 x:%lf, y:%lf",point.x , point.y);
    }
}



#pragma mask ---- getter
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        [_imageView setImage:self.image];
    }
    return _imageView;
}
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
//        [_titleLabel setText:self.title];
    }
    return _titleLabel;
}
#pragma mask ---- setter
- (void)setTitle:(NSString *)title {
    _title = title;
    [self.titleLabel setText:_title];
}
- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = _image;
}


@end
