//
//  ScannerImageView.m
//  JLPay
//
//  Created by jielian on 15/11/6.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ScannerImageView.h"


#define KEY_IMAGEANIMATION   @"KEY_IMAGEANIMATION__"  // 图片动画键名


@interface ScannerImageView()

@property (nonatomic, strong) UIImageView* imageViewNet; // 网格框

@property (nonatomic, strong) UIImageView* cornerLeftUp;
@property (nonatomic, strong) UIImageView* cornerLeftDown;
@property (nonatomic, strong) UIImageView* cornerRightUp;
@property (nonatomic, strong) UIImageView* cornerRightDown;



@end



@implementation ScannerImageView

/* 启动网格动画 */
- (void) startImageAnimation {
    [self.imageViewNet.layer addAnimation:[self animationOfImageMoving:self.frame.size.height] forKey:KEY_IMAGEANIMATION];
}
/* 停止网格动画 */
- (void) stopImageAnimation {
    [self.imageViewNet.layer removeAnimationForKey:KEY_IMAGEANIMATION];
}


#pragma mask ---- 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self addSubview:self.imageViewNet];
        [self addSubview:self.cornerLeftUp];
        [self addSubview:self.cornerLeftDown];
        [self addSubview:self.cornerRightUp];
        [self addSubview:self.cornerRightDown];
    }
    return self;
}

#pragma mask ---- 加载子视图
- (void)layoutSubviews {
    CGFloat cornerWH = 18;
    
    CGRect frame = CGRectMake(0, - self.imageViewNet.image.size.height, self.frame.size.width, self.imageViewNet.image.size.height);
    [self.imageViewNet setFrame:frame];
    
    frame.origin.y = 0;
    frame.size.width = cornerWH;
    frame.size.height = cornerWH;
    [self.cornerLeftUp setFrame:frame];
    
    frame.origin.x = self.frame.size.width - cornerWH;
    [self.cornerRightUp setFrame:frame];
    
    frame.origin.x = 0;
    frame.origin.y = self.frame.size.height - cornerWH;
    [self.cornerLeftDown setFrame:frame];
    
    frame.origin.x = self.frame.size.width - cornerWH;
    [self.cornerRightDown setFrame:frame];
}


#pragma mask ---- PRIVATE INTERFACE
/* 网格动画 */
- (CABasicAnimation*) animationOfImageMoving:(CGFloat)moving {
    CABasicAnimation* animation = [CABasicAnimation animation];
    [animation setKeyPath:@"transform.translation.y"];
    [animation setByValue:@(moving)];
    [animation setDuration:1];
    [animation setRepeatCount:MAXFLOAT];
    return animation;
}

#pragma mask ---- getter
- (UIImageView *)imageViewNet {
    if (_imageViewNet == nil) {
        _imageViewNet = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageViewNet.image = [UIImage imageNamed:@"scan_net"];
//        [_imageViewNet.layer addAnimation:[self animationOfImageMoving:self.frame.size.height] forKey:KEY_IMAGEANIMATION];
    }
    return _imageViewNet;
}
- (UIImageView *)cornerLeftUp {
    if (_cornerLeftUp == nil) {
        _cornerLeftUp = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_cornerLeftUp setImage:[UIImage imageNamed:@"scan_1"]];
    }
    return _cornerLeftUp;
}
- (UIImageView *)cornerLeftDown {
    if (_cornerLeftDown == nil) {
        _cornerLeftDown = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_cornerLeftDown setImage:[UIImage imageNamed:@"scan_3"]];
    }
    return _cornerLeftDown;
}
- (UIImageView *)cornerRightUp {
    if (_cornerRightUp == nil) {
        _cornerRightUp = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_cornerRightUp setImage:[UIImage imageNamed:@"scan_2"]];
    }
    return _cornerRightUp;
}
- (UIImageView *)cornerRightDown {
    if (_cornerRightDown == nil) {
        _cornerRightDown = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_cornerRightDown setImage:[UIImage imageNamed:@"scan_4"]];
    }
    return _cornerRightDown;
}

@end
