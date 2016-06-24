//
//  DottedBorderButton.m
//  JLPay
//
//  Created by jielian on 16/5/24.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DottedBorderButton.h"
#import "Define_Header.h"

@implementation DottedBorderButton

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadSublayers];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSublayers];
    }
    return self;
}

- (void) loadSublayers {
    self.layer.cornerRadius = 5.f;
    [self.layer addSublayer:self.shapeLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:5.f];
    
    self.shapeLayer.path = bezierPath.CGPath;
}


# pragma mask 4 getter
- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.lineCap = kCALineCapRound;
        _shapeLayer.lineWidth = 2.f;
        _shapeLayer.strokeColor = [UIColor colorWithHex:0xa9b7b7 alpha:1].CGColor;
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        _shapeLayer.lineDashPattern = @[@(4),@(4)];
    }
    return _shapeLayer;
}

@end
