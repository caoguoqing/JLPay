//
//  DoubleLayerButton.m
//  JLPay
//
//  Created by jielian on 15/9/18.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "DoubleLayerButton.h"

@interface DoubleLayerButton()
@property (nonatomic, strong) CALayer* subLayer;

@end


@implementation DoubleLayerButton
@synthesize subLayer = _subLayer;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.layer addSublayer:self.subLayer];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer addSublayer:self.subLayer];
    }
    return self;
}


- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    if (layer.bounds.size.width == 0 && layer.bounds.size.height == 0) {
        return;
    }
    CGFloat insetS = 3.0;
    CGRect inBounds = CGRectMake(insetS, insetS, layer.bounds.size.width - insetS*2, layer.bounds.size.height - insetS*2);
    [self.subLayer setBounds:inBounds];
    [self.subLayer setPosition:CGPointMake(layer.bounds.size.width/2.0, layer.bounds.size.height/2.0)];
    
}

- (CALayer *)subLayer {
    if (_subLayer == nil) {
        _subLayer = [CALayer layer];
        [_subLayer setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:69.0/255.0 blue:75.0/255.0 alpha:1.0].CGColor];
        _subLayer.cornerRadius = 5.0;
    }
    return _subLayer;
}

@end