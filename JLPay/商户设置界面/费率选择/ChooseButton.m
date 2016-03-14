//
//  ChooseButton.m
//  JLPay
//
//  Created by jielian on 16/3/3.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "ChooseButton.h"
#import "DirectionView.h"
#import "Masonry.h"
#import "Define_Header.h"

@interface ChooseButton()
{
    CGFloat animationDuration;
    BOOL openUp;
}
@property (nonatomic, strong) UIView* lineView;
@property (nonatomic, strong) DirectionView* directionView;

@end

@implementation ChooseButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialProperties];
        [self loadSubViews];
    }
    return self;
}
- (void) initialProperties {
    animationDuration = 0.15;
    openUp = NO;
}
- (void) loadSubViews {
    [self addSubview:self.lineView];
    [self addSubview:self.directionView];
}
- (void)layoutSubviews {
    CGRect textFrame = self.titleLabel.frame;
    CGFloat heightDirection = self.frame.size.height * 1.f/5.f;
    CGFloat widthDirection = heightDirection * 3.f/2.f;
    CGFloat heightLine = 0.6;
    
    NameWeakSelf(wself);
    if (self.chooseButtonType == ChooseButtonTypeUnderLine) {
        self.backgroundColor = [UIColor clearColor];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(textFrame.size.width, heightLine));
            make.left.equalTo(wself.mas_left);
            make.bottom.equalTo(wself.mas_bottom);
        }];
    }
    [self.directionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(widthDirection, heightDirection));
        make.centerY.equalTo(wself.mas_centerY);
        make.centerX.equalTo(wself.mas_right).offset(-24);
    }];

    
    // 设置颜色
    if (openUp) {
        [self setTitleColor:self.selectedColor forState:UIControlStateNormal];
        [self.directionView setBackGColor:self.selectedColor];
    } else {
        [self setTitleColor:self.nomalColor forState:UIControlStateNormal];
        [self.directionView setBackGColor:self.nomalColor];
    }
    
    [super layoutSubviews];
}

#pragma mask 1 public interface 
- (void)turningDirection:(BOOL)up {
    openUp = up;
    if (up) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.directionView.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    } else {
        [UIView animateWithDuration:animationDuration animations:^{
            self.directionView.transform = CGAffineTransformIdentity;
        }];
    }
    [self setNeedsLayout];
}


#pragma mask 4 getter
- (DirectionView *)directionView {
    if (!_directionView ) {
        _directionView = [[DirectionView alloc] initWithFrame:CGRectZero];
        _directionView.backGColor = [UIColor colorWithWhite:0.2 alpha:1];
    }
    return _directionView;
}
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    }
    return _lineView;
}
- (UIColor *)nomalColor {
    if (!_nomalColor) {
        _nomalColor = [UIColor colorWithWhite:0.2 alpha:1];

    }
    return _nomalColor;
}
- (UIColor *)selectedColor {
    if (!_selectedColor) {
        _selectedColor = [UIColor blueColor];
    }
    return _selectedColor;
}

@end
