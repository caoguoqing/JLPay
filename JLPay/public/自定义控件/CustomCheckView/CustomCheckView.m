//
//  CustomCheckView.m
//  CustomViewMaker
//
//  Created by 冯金龙 on 16/3/9.
//  Copyright © 2016年 冯金龙. All rights reserved.
//

#import "CustomCheckView.h"

@interface CustomCheckView()
{
    CGFloat animationDuration;
    CGFloat animationDelay;
    
    // '勾'的起点、中点、终点坐标
    CGPoint rightStartPoint;
    CGPoint rightMidPoint;
    CGPoint rightEndPoint;
    
    // '叉'的起点、终点坐标
    CGPoint wrongUpStartPoint;
    CGPoint wrongUpEndPoint;
    CGPoint wrongDownStartPoint;
    CGPoint wrongDownEndPoint;
}
//@property (nonatomic, copy) void (^completionBlock) (void);
@end

@implementation CustomCheckView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
    }
    return self;
}

- (void)showDuration:(CGFloat)duration delay:(CGFloat)delay completion:(void (^)(void))completion
{
//    self.completionBlock = completion;
    self.alpha = 1;
    animationDelay = delay;
    animationDuration = duration;
    [self setNeedsDisplay];
    completion();
}

#pragma mask 2 绘制图形: 主要的功能都在这了
- (void)drawRect:(CGRect)rect {
    UIBezierPath* path = [UIBezierPath bezierPath];

    if ([self rightOrWrong] == CustomCheckViewStyleRight) {
        [self initialRightPointsInRect:rect];
        [path moveToPoint:rightStartPoint];
        [path addLineToPoint:rightMidPoint];
        [path addLineToPoint:rightEndPoint];
    }
    else if ([self rightOrWrong] == CustomCheckViewStyleWrong) {
        [self initialWrongPointsInRect:rect];
        [path moveToPoint:wrongUpStartPoint];
        [path addLineToPoint:wrongUpEndPoint];
        [path moveToPoint:wrongDownStartPoint];
        [path addLineToPoint:wrongDownEndPoint];
    }
    path.lineWidth = self.lineWidth;
    if ([self lineRoundOrRect] == CustomCheckViewStyleLineRound) {
        path.lineCapStyle = kCGLineCapRound;
    } else {
        path.lineCapStyle = kCGLineCapButt;
    }
    [self.lineColor setStroke];
    [path stroke];
}

#pragma mask 3 private interface
// -- '勾'或'叉'
- (CustomCheckViewStyle) rightOrWrong {
    return (self.checkViewStyle & (CustomCheckViewStyleRight|CustomCheckViewStyleWrong));
}
// -- '圆角'或'直角'
- (CustomCheckViewStyle) lineRoundOrRect {
    return (self.checkViewStyle & (CustomCheckViewStyleLineRound|CustomCheckViewStyleLineButt));
}

#pragma mask 3 坐标初始化
// -- 初始化'勾'坐标系
- (void) initialRightPointsInRect:(CGRect)rect {
    CGFloat insetHorizontal = rect.size.width * self.innerSizeScale;
    CGFloat unitLength = (rect.size.width - insetHorizontal*2)/3.f;
    CGFloat insetVertical = (rect.size.height - unitLength*2)/2.f;
    rightStartPoint = CGPointMake(insetHorizontal, insetVertical + unitLength);
    rightMidPoint = CGPointMake(insetHorizontal + unitLength, insetVertical + unitLength*2);
    rightEndPoint = CGPointMake(insetHorizontal + unitLength*3, insetVertical);
}
// -- 初始化'叉'坐标系
- (void) initialWrongPointsInRect:(CGRect)rect {
    CGFloat inset = rect.size.width * self.innerSizeScale * (9.f/7.f);
    wrongUpStartPoint = CGPointMake(inset, inset);
    wrongUpEndPoint = CGPointMake(rect.size.width - inset, rect.size.height - inset);
    wrongDownStartPoint = CGPointMake(inset, rect.size.height - inset);
    wrongDownEndPoint = CGPointMake(rect.size.width - inset, inset);
}


#pragma mask 4 getter
- (CustomCheckViewStyle)checkViewStyle {
    if (_checkViewStyle == 0) {
        _checkViewStyle = CustomCheckViewStyleRight|CustomCheckViewStyleLineRound;
    }
    return _checkViewStyle;
}
- (UIColor *)lineColor {
    if (!_lineColor) {
        _lineColor = [UIColor blackColor];
    }
    return _lineColor;
}
- (CGFloat)innerSizeScale {
    if (_innerSizeScale == 0) {
        _innerSizeScale = 1.f/4.5f;
    }
    return _innerSizeScale;
}

@end
