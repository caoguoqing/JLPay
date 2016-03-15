//
//  ConcentricCirclesCheckView.m
//  CustomViewMaker
//
//  Created by jielian on 16/3/14.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "ConcentricCirclesCheckView.h"


static NSString* const kKVOCircleCheckViewChecked = @"checked";

@interface ConcentricCirclesCheckView()

@property (nonatomic, strong) UIView* innerCircle;

@end

@implementation ConcentricCirclesCheckView


#pragma mask 2 KVO
- (void) addKVOs {
    NSLog(@"添加kvo");
    [self addObserver:self forKeyPath:kKVOCircleCheckViewChecked options:NSKeyValueObservingOptionNew context:nil];
}
- (void) removeKVOs {
    [self removeObserver:self forKeyPath:kKVOCircleCheckViewChecked context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kKVOCircleCheckViewChecked]) {
        BOOL checked = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (checked) {
            self.innerCircle.hidden = NO;
        } else {
            self.innerCircle.hidden = YES;
        }
    }
}



#pragma mask 3 布局子视图
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    self.layer.borderColor = self.tintColor.CGColor;
    self.layer.borderWidth = self.lineWidth;
    self.layer.cornerRadius = frame.size.width / 2.f;
    
    CGFloat radius = (frame.size.width - self.lineWidth * 4)/2.f;
    self.innerCircle.frame = CGRectMake(0, 0, radius*2, radius*2);
    self.innerCircle.center = CGPointMake(frame.size.width / 2.f, frame.size.height / 2.f);
    self.innerCircle.layer.cornerRadius = radius;
    self.innerCircle.backgroundColor = self.tintColor;
}

#pragma mask 3 初始化
- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubvies];
        [self addKVOs];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
- (void) addSubvies {
    [self addSubview:self.innerCircle];
}

- (void)dealloc {
    [self removeKVOs];
}


#pragma mask 4 getter 
- (UIView *)innerCircle {
    if (!_innerCircle) {
        _innerCircle = [[UIView alloc] init];
        _innerCircle.hidden = YES;
    }
    return _innerCircle;
}
- (UIColor *)tintColor {
    if (!_tintColor) {
        _tintColor = [UIColor greenColor];
    }
    return _tintColor;
}
- (CGFloat)lineWidth {
    if (_lineWidth == 0) {
        _lineWidth = 5.f;
    }
    return _lineWidth;
}

@end
