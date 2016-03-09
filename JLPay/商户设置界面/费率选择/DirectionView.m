//
//  DirectionView.m
//  JLPay
//
//  Created by 冯金龙 on 16/3/3.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DirectionView.h"

static NSString* const kKeyPathBackGColorChange = @"backGColor";

@implementation DirectionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addObserver:self forKeyPath:kKeyPathBackGColorChange options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}
- (void)dealloc {
    [self removeObserver:self forKeyPath:kKeyPathBackGColorChange];
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath* triPath = [UIBezierPath bezierPath];
    [triPath moveToPoint:CGPointMake(0, 0)];
    [triPath addLineToPoint:CGPointMake(self.frame.size.width, 0)];
    [triPath addLineToPoint:CGPointMake(self.frame.size.width * 0.5f, self.frame.size.height)];
    [triPath closePath];
    
    [self.backGColor setFill];
    [triPath fill];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kKeyPathBackGColorChange]) {
        [self setNeedsDisplay];
    }
}


@end
