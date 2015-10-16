//
//  SelectIndicatorView.m
//  JLPay
//
//  Created by jielian on 15/8/4.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "SelectIndicatorView.h"

@interface SelectIndicatorView()
@property (nonatomic, strong) UIColor* viewColor;
@end

@implementation SelectIndicatorView
@synthesize viewColor;




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [UIView animateWithDuration:0.1 animations:^{
        self.transform = CGAffineTransformMakeScale(0.95, 0.95);
    }];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [UIView animateWithDuration:0.1 animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTouchedInSelectIndicator)]) {
        [self.delegate didTouchedInSelectIndicator];
    }

}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [UIView animateWithDuration:0.1 animations:^{
        self.transform = CGAffineTransformIdentity;
    }];

}




- (instancetype)initWithFrame:(CGRect)frame andViewColor:(UIColor *)color {
    CGRect newFrame = frame;
    newFrame.size.width = newFrame.size.height * 4.0/9.0 * 1.0/sin(M_PI * 60.0/180.0);
    
    self = [super initWithFrame:newFrame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.viewColor = color;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGFloat height = rect.size.width * sin(M_PI * 60.0/180.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint point = CGPointMake(rect.size.width/2.0, 0);
    
    // 上正三角
    CGContextMoveToPoint(context, point.x, point.y);
    
    point.x = 0;
    point.y += height;
    CGContextAddLineToPoint(context, point.x, point.y);
    
    point.x += rect.size.width;
    CGContextAddLineToPoint(context, point.x, point.y);
    
    // 下正三角
    point.x = 0;
    point.y +=  height * 1.0/4.0;
    CGContextMoveToPoint(context, point.x, point.y);

    point.x += rect.size.width;
    CGContextAddLineToPoint(context, point.x, point.y);

    point.x = rect.size.width/2.0;
    point.y += height;
    CGContextAddLineToPoint(context, point.x, point.y);
    
    CGContextClosePath(context);

    [self.viewColor setFill];
    CGContextDrawPath(context, kCGPathFill);
}


@end
