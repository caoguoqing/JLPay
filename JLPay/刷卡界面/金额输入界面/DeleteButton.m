//
//  DeleteButton.m
//  JLPay
//
//  Created by jielian on 15/5/18.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "DeleteButton.h"
#import "Masonry.h"
#import "Define_Header.h"

@interface DeleteButton ()

@property (nonatomic, strong)  UIImageView *dImageView;

@end



@implementation DeleteButton

@synthesize imageView = _imageView;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.dImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize imageSize = self.dImageView.image.size;
    CGFloat widthImage = self.frame.size.width * 0.5;
    CGFloat heightImage = widthImage * imageSize.height/imageSize.width;
    
    NameWeakSelf(wself);
    [self.dImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.mas_centerX);
        make.centerY.equalTo(wself.mas_centerY);
        make.width.mas_equalTo(widthImage);
        make.height.mas_equalTo(heightImage);
    }];
    
}


# pragma mask 4 getter
- (UIImageView *)dImageView {
    if (!_dImageView) {
        _dImageView = [UIImageView new];
        _dImageView.image = [UIImage imageNamed:@"delete"];
    }
    return _dImageView;
}

@end
