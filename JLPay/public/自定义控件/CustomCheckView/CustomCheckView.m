//
//  CustomCheckView.m
//  CustomViewMaker
//
//  Created by 冯金龙 on 16/3/9.
//  Copyright © 2016年 冯金龙. All rights reserved.
//

#import "CustomCheckView.h"

@interface CustomCheckView()

@property (nonatomic, strong) CAShapeLayer* shapeLayer;

@end

@implementation CustomCheckView

- (void)showAnimation {
    [self initialLinesProperties];
    [self setShapeOnShapeLayer];
    self.shapeLayer.strokeEnd = 1;
    
}
- (void)hiddenAnimation {
    self.shapeLayer.strokeEnd = 0;
}



- (instancetype)init {
    self = [super init];
    if (self) {
        [self initial];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initial];
    }
    return self;
}
- (void) initial {
    self.backgroundColor = [UIColor clearColor];
    [self.layer addSublayer:self.shapeLayer];
}


#pragma mask 3 坐标,线条初始化
// -- 初始化'勾'坐标系
- (void) initialRightPointsInRect:(CGRect)rect {
    CGFloat insetHorizontal = rect.size.width * self.innerSizeScale;
    CGFloat unitLength = (rect.size.width - insetHorizontal*2)/3.f;
    CGFloat insetVertical = (rect.size.height - unitLength*2)/2.f;
    CGPoint rightStartPoint = CGPointMake(insetHorizontal, insetVertical + unitLength);
    CGPoint rightMidPoint = CGPointMake(insetHorizontal + unitLength, insetVertical + unitLength*2);
    CGPoint rightEndPoint = CGPointMake(insetHorizontal + unitLength*3, insetVertical);
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:rightStartPoint];
    [path addLineToPoint:rightMidPoint];
    [path addLineToPoint:rightEndPoint];
    self.shapeLayer.path = path.CGPath;
}
// -- 初始化'叉'坐标系
- (void) initialWrongPointsInRect:(CGRect)rect {
    CGFloat inset = rect.size.width * self.innerSizeScale * (9.f/7.f);
    CGPoint wrongUpStartPoint = CGPointMake(inset, inset);
    CGPoint wrongUpEndPoint = CGPointMake(rect.size.width - inset, rect.size.height - inset);
    CGPoint wrongDownStartPoint = CGPointMake(inset, rect.size.height - inset);
    CGPoint wrongDownEndPoint = CGPointMake(rect.size.width - inset, inset);
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:wrongUpStartPoint];
    [path addLineToPoint:wrongUpEndPoint];
    [path moveToPoint:wrongDownStartPoint];
    [path addLineToPoint:wrongDownEndPoint];
    self.shapeLayer.path = path.CGPath;
}
// -- 初始化'感叹号'坐标系
- (void) initialWarnPointsInRect:(CGRect)rect {
    CGFloat insetVertical = rect.size.width * self.innerSizeScale;
    CGFloat insetDotAndLine = rect.size.height * 0.15;
    CGFloat radius = self.lineWidth/2.f;
    
    CGPoint dotPoint = CGPointMake(rect.size.width/2.f, rect.size.height - insetVertical);
    CGPoint lineStartPoint = CGPointMake(rect.size.width/2.f, insetVertical);
    CGPoint lineEndPoint = CGPointMake(rect.size.width/2.f, dotPoint.y - radius - insetDotAndLine);
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:lineStartPoint];
    [path addLineToPoint:lineEndPoint];
    UIBezierPath* arcPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(dotPoint.x - radius, dotPoint.y - radius, radius*2, radius*2) cornerRadius:radius];
    [path appendPath:arcPath];
    self.shapeLayer.path = path.CGPath;
}


// -- 线条属性初始化
- (void) initialLinesProperties {
    self.shapeLayer.lineWidth = self.lineWidth;
    self.shapeLayer.strokeColor = self.lineColor.CGColor;
    
    switch ([self lineStyle]) {
        case CustomCheckViewStyleLineRound:
            self.shapeLayer.lineCap = kCALineCapRound;
            break;
        case CustomCheckViewStyleLineButt:
            self.shapeLayer.lineCap = kCALineCapButt;
            break;
        default:
            self.shapeLayer.lineCap = kCALineCapRound;
            break;
    }
}

// -- 设置 shapeLayer 的形状
- (void) setShapeOnShapeLayer {
    switch ([self shapeStyle]) {
        case CustomCheckViewStyleRight:
            [self initialRightPointsInRect:self.bounds];
            break;
        case CustomCheckViewStyleWrong:
            [self initialWrongPointsInRect:self.bounds];
            break;
        case CustomCheckViewStyleWarn:
            [self initialWarnPointsInRect:self.bounds];
            break;
        default:
            [self initialRightPointsInRect:self.bounds];
            break;
    }
}

#pragma mask 3 private interface
// -- 当前形状
- (CustomCheckViewStyle) shapeStyle {
    int allShapes = CustomCheckViewStyleRight | CustomCheckViewStyleWrong | CustomCheckViewStyleWarn;
    return (self.checkViewStyle & allShapes);
}
// -- 当前线条类型
- (CustomCheckViewStyle) lineStyle {
    int allLines = CustomCheckViewStyleLineButt | CustomCheckViewStyleLineRound;
    return (self.checkViewStyle & allLines);
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
- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        _shapeLayer.strokeStart = 0;
        _shapeLayer.strokeEnd = 0;
    }
    return _shapeLayer;
}
@end
