//
//  ElecSignView.m
//  JLPay
//
//  Created by jielian on 16/7/22.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "ElecSignView.h"
#import "Define_Header.h"
#import "Masonry.h"


static CGPoint midPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake( (p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5 );
}


@implementation ElecSignView


- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSignPath];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSignPath];
    }
    return self;
}

- (void) reSign {
    [self.signPath removeAllPoints];
    [self setNeedsDisplay];
}



- (void) addSignPath {
    UIPanGestureRecognizer* panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(ganGes:)];
    panGes.maximumNumberOfTouches = 1;
    panGes.delegate = self;
    [self addGestureRecognizer:panGes];
}


# pragma mask 3 UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer.view isKindOfClass:[ElecSignView class]]) {
        return NO;
    } else {
        return YES;
    }
}

- (IBAction) ganGes:(UIPanGestureRecognizer*)ges {
    
    CGPoint curPoint = [ges locationInView:self];
    
    if (ges.state == UIGestureRecognizerStateBegan) {
        [self.signPath moveToPoint:curPoint];
    }
    else if (ges.state == UIGestureRecognizerStateChanged) {
        [self.signPath addQuadCurveToPoint:midPoint(curPoint, self.prePoint) controlPoint:self.prePoint];
    }
    
    self.prePoint = curPoint;
    
    [self setNeedsDisplay];
    
}


- (void)drawRect:(CGRect)rect {
    
    [[UIColor blackColor] setStroke];
    
    [self.signPath stroke];
}



# pragma mask 4 getter

- (UIBezierPath *)signPath {
    if (!_signPath) {
        _signPath = [UIBezierPath bezierPath];
        _signPath.lineWidth = 3.f;
        _signPath.lineCapStyle = kCGLineCapRound;
    }
    return _signPath;
}


@end
