//
//  myCollectionCell.m
//  JLPay
//
//  Created by jielian on 15/8/4.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "myCollectionCell.h"

@interface myCollectionCell()
{
//    CGFloat fontOfSize;
}
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* textLabel;

@end

@implementation myCollectionCell
@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;


- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.textLabel];
//        fontOfSize = 12;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    CGFloat inset = 5.0;
    CGFloat labelHeight = 15.0;
    // imageView
    if (self.textLabel.text == nil) {
        // imageView
        frame.size.width /= 3.0;
        frame.size.height = frame.size.width;
        frame.origin.x = (self.bounds.size.width - frame.size.width)/2.0;
        frame.origin.y = (self.bounds.size.height - frame.size.height)/2.0;
        self.imageView.frame = frame;
    } else {
        // imageView
        frame.size.width /= 2.0;
        frame.size.height = frame.size.width;
        frame.origin.x = (self.bounds.size.width - frame.size.width)/2.0;
        frame.origin.y = (self.bounds.size.height - frame.size.height - inset - labelHeight)/2.0;
        self.imageView.frame = frame;
        // textLabel
        frame.origin.x = 0;
        frame.origin.y += frame.size.height + inset;
        frame.size.width = self.bounds.size.width;
        frame.size.height = labelHeight;
        self.textLabel.frame = frame;
        
        // 重置label的文字的大小
        UIFont* font = [UIFont systemFontOfSize:15.0];
        self.textLabel.font = font;
        CGSize textSize = [self.textLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
        if (textSize.height > frame.size.height) {
            font = [UIFont systemFontOfSize:15.0 * frame.size.height/textSize.height];
            self.textLabel.font = font;
        }
    }
    self.layer.borderWidth = 0.3;
    self.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
}

#pragma mask ::: getter & setter 
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
//        _imageView.backgroundColor = [UIColor orangeColor];
    }
    return _imageView;
}
- (UILabel *)textLabel {
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
//        _textLabel.font = [UIFont systemFontOfSize:fontOfSize];
//        _textLabel.backgroundColor = [UIColor orangeColor];
    }
    return _textLabel;
}

#pragma mask ---- setter
- (void)setTitle:(NSString *)title {
    _title = title;
    self.textLabel.text = _title;
}
@end
