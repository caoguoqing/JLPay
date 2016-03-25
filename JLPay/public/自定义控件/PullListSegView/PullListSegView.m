//
//  PullListSegView.m
//  JLPay
//
//  Created by jielian on 16/3/3.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//


#import "PullListSegView.h"


@interface PullListSegView()
{
    CGFloat     animationDuration;
    NSInteger   iMaxDisplayCount;
    CGFloat     fWidthOfTri;
    CGFloat     fHeightOfTri;
}
@property (nonatomic, strong) CAShapeLayer* shapeLayer;
@end

@implementation PullListSegView

#pragma mask 1 public interface 
- (void)showAnimation {
    [self.tableView reloadData];
    [self setNeedsLayout];
    [self setNeedsDisplay];
    [self animationShow];
}
- (void)hiddenAnimation {
    [self animationHidden];
}
- (void) showWithCompletion:(void (^) (void))completion {
    [self.tableView reloadData];
    [self setNeedsLayout];
    [self setNeedsDisplay];
    
    self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (finished) {
            completion();
        }
    }];

}
- (void) hideWithCompletion:(void (^) (void))completion {
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        if (finished) {
            self.transform = CGAffineTransformIdentity;
            completion();
        }
    }];
}



#pragma mask 3 private interface
// -- animation: show
- (void) animationShow {
    self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}
// -- animation: hidden
- (void) animationHidden {
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        self.transform = CGAffineTransformIdentity;
    }];
}

#pragma mask 4 geter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorInset = UIEdgeInsetsMake(15, 0, 0, 15);
        _tableView.rowHeight = 37.f;
    }
    return _tableView;
}
- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
    }
    return _shapeLayer;
}

- (UIColor *)tintColor {
    if (!_tintColor) {
        _tintColor = [UIColor colorWithRed:(2*16+4)/255.f green:(2*16+4)/255.f blue:(3*16+4)/255.f alpha:0.98];  //0x242434
    }
    return _tintColor;
}
- (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor whiteColor];
    }
    return _textColor;
}

#pragma mask 0 生命周期,和布局
- (instancetype) init {
    self = [super init];
    if (self) {
        [self initialProperties];
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        [self loadSubViews];
    }
    return self;
}

- (void) initialProperties {
    animationDuration = 0.2;
    iMaxDisplayCount = 5;
    fWidthOfTri = 20.f;
    fHeightOfTri = 20.f * 2.f/3.f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = fHeightOfTri;
    NSInteger dataSourceCount = [self.tableView numberOfRowsInSection:0];
    if (dataSourceCount >= iMaxDisplayCount) {
        height += iMaxDisplayCount * self.tableView.rowHeight;
    } else {
        height += dataSourceCount * self.tableView.rowHeight;
    }
    
    CGRect frame = self.frame;
    frame.size.height = height;
    [self setFrame:frame];
    
    frame.origin.x = 0;
    frame.origin.y = 0;
    [self.shapeLayer setFrame:frame];
    self.shapeLayer.fillColor = self.tintColor.CGColor;
    [self resetPathOfShapeLayer:self.shapeLayer];
    
    frame.origin.y = fHeightOfTri;
    frame.size.height -= fHeightOfTri;
    [self.tableView setFrame:frame];
}

- (void) loadSubViews {
    [self.layer addSublayer:self.shapeLayer];
    [self addSubview:self.tableView];
}

- (void) resetPathOfShapeLayer:(CAShapeLayer*)layer {
    CGRect frame = layer.bounds;
    CGFloat radius = 8.f;
    CGFloat width= frame.size.width;
    CGFloat height = frame.size.height;
    CGFloat centerX = width/2.f;
    
    CGPoint triTopP = CGPointMake(centerX, 0);
    CGPoint triBottomLeftP = CGPointMake(centerX - fWidthOfTri/2.f, fHeightOfTri);
    CGPoint triBottomRightP = CGPointMake(centerX + fWidthOfTri/2.f, fHeightOfTri);
    
    CGPoint rectTopRightStartP = CGPointMake(width - radius, fHeightOfTri);
    CGPoint rectTopRightContrlP = CGPointMake(width, fHeightOfTri);
    CGPoint rectTopRightEndP = CGPointMake(width, fHeightOfTri + radius);
    
    CGPoint rectBottomRightStartP = CGPointMake(width, height - radius);
    CGPoint rectBottomRightContrlP = CGPointMake(width, height);
    CGPoint rectBottomRightEndP = CGPointMake(width - radius, height);

    CGPoint rectBottomLeftStartP = CGPointMake(radius, height);
    CGPoint rectBottomLeftContrlP = CGPointMake(0, height);
    CGPoint rectBottomLeftEndP = CGPointMake(0, height - radius);

    CGPoint rectTopLeftStartP = CGPointMake(0, fHeightOfTri + radius);
    CGPoint rectTopLeftContrlP = CGPointMake(0, fHeightOfTri);
    CGPoint rectTopLeftEndP = CGPointMake(radius, fHeightOfTri);
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:triBottomLeftP];
    [path addLineToPoint:triTopP];
    [path addLineToPoint:triBottomRightP];
    
    [path addLineToPoint:rectTopRightStartP];
    [path addQuadCurveToPoint:rectTopRightEndP controlPoint:rectTopRightContrlP];
    
    [path addLineToPoint:rectBottomRightStartP];
    [path addQuadCurveToPoint:rectBottomRightEndP controlPoint:rectBottomRightContrlP];
    
    [path addLineToPoint:rectBottomLeftStartP];
    [path addQuadCurveToPoint:rectBottomLeftEndP controlPoint:rectBottomLeftContrlP];
    
    [path addLineToPoint:rectTopLeftStartP];
    [path addQuadCurveToPoint:rectTopLeftEndP controlPoint:rectTopLeftContrlP];
    
    [path addLineToPoint:triBottomLeftP];
    [path closePath];
    layer.path = path.CGPath;
}

@end
