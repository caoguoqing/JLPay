//
//  myCollectionCell.m
//  JLPay
//
//  Created by jielian on 15/8/4.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "myCollectionCell.h"
#import "Masonry.h"
#import "PublicInformation.h"

@interface myCollectionCell()
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
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.textLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.contentView.bounds;
    CGFloat heightImageView = frame.size.height * 0.38;
    CGFloat heightLabel = heightImageView * 0.5;
    
    CGFloat insetBig = (frame.size.height - heightImageView - heightLabel) * 0.38;
    CGFloat insetLittle = insetBig * 0.5;
    
    NameWeakSelf(wself);
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.mas_top).offset(insetBig);
        make.centerX.equalTo(wself.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(heightImageView, heightImageView));
    }];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(wself.imageView.mas_bottom).offset(insetLittle);
        make.bottom.equalTo(wself.mas_bottom).offset(-insetBig);
        make.left.equalTo(wself.mas_left);
        make.right.equalTo(wself.mas_right);
        make.height.mas_equalTo(heightLabel);
        wself.textLabel.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(10, heightLabel) andScale:0.8]];
    }];
    
    self.contentView.layer.borderWidth = 0.3;
    self.contentView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
}

#pragma mask ::: getter & setter 
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}
- (UILabel *)textLabel {
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
    }
    return _textLabel;
}

#pragma mask ---- setter
- (void)setTitle:(NSString *)title {
    _title = title;
    self.textLabel.text = _title;
}
@end
