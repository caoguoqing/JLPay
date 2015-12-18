//
//  TriangleLeftTurnView.m
//  JLPay
//
//  Created by jielian on 15/12/18.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "TriangleLeftTurnView.h"
#import "PublicInformation.h"

@implementation TriangleLeftTurnView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    
    NSLog(@"重绘 drawRect[%@]",NSStringFromCGRect(rect) );
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    

    CGContextMoveToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y);
    CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height/2.0);
    CGContextMoveToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    
//    CGContextClosePath(ctx);
    
//    [[PublicInformation returnCommonAppColor:@"red"] set];
    //235.0/255.0 green:69.0/255.0 blue:75.0/255.0
    CGContextSetRGBFillColor(ctx, 235.0/255.0, 69.0/255.0, 75.0/255.0, 1);
    
    
    CGContextFillPath(ctx);
}


@end
