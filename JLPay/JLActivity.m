//
//  JLActivity.m
//  TestForCustomActivity
//
//  Created by jielian on 15/6/16.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "JLActivity.h"

@interface JLActivity()
@property (nonatomic) BOOL      animate;
@property (nonatomic, strong) UIImageView*  imageView;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, assign) int acounting;
@end

#define ANIMATED_DURATION               0.08f                // 动画间隔时间

@implementation JLActivity
@synthesize animate = _animate;
@synthesize imageView = _imageView;
@synthesize timer = _timer;
@synthesize acounting = _acounting;


// 初始化
- (instancetype)init{
    self = [super init];
    if (self) {
        _animate = NO;
        _acounting = 1;
        self.hidden = YES;
        self.frame = [UIScreen mainScreen].bounds;
        [self addSubview:self.imageView];
        
        self.backgroundColor = [UIColor colorWithRed:135.0/255.0 green:135.0/255.0 blue:135.0/255.0 alpha:0.4];

    }
    return self;
}


#pragma mask ::: 检查是否正在动画
- (BOOL) isAnimating {
    return self.animate;
}

#pragma mask ::: 开始转动
- (void) startAnimating {
    if (self.hidden) {
        self.hidden = NO;
    }
    self.animate = YES;
    // 启动定时器，开始转动
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:@"NSDefaultRunLoopMode"];
}
#pragma mask ::: 停止转动
- (void) stopAnimating {
    self.animate = NO;
    // 关闭定时器，停止转动
    [self.timer invalidate];
    self.timer = nil;
    self.acounting = 1;
    if (!self.hidden) {
        self.hidden = YES;
    }
}

#pragma mask ::: 转动的实现
- (void) turningAround: (id) sender {
    int i = self.acounting%12; // 1-12-0-1-12-0
    if (i == 0) {
        i = 12;
    }
    self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"activitor%02d", i]];
    self.acounting++;

}

#pragma mask ::: getter & setter
- (BOOL)animate {
    return _animate;
}
- (UIImageView *)imageView {
    CGFloat width = self.bounds.size.width/6.0;
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width - width)/2.0,
                                                                   (self.bounds.size.height - width - 80)/2.0,
                                                                   width,
                                                                   width)];
    }
    return _imageView;
}
- (int)acounting {
    return _acounting;
}
- (NSTimer *)timer {
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:ANIMATED_DURATION target:self selector:@selector(turningAround:) userInfo:nil repeats:YES];
    }
    return _timer;
}

@end
