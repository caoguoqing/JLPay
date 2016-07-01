//
//  CentreCircleCheckView.m
//  JLPay
//
//  Created by jielian on 16/4/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "CentreCircleCheckView.h"

@implementation CentreCircleCheckView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubviews];
        [self addKVOs];
    }
    return self;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadSubviews];
        [self addKVOs];
    }
    return self;
}
- (void)dealloc {
    [self removeKVOs];
}
- (void) loadSubviews {
    self.checked = NO;
    [self addSubview:self.centreCircleView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width * 0.6f;
    NameWeakSelf(wself);
    [self.centreCircleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(width);
        make.centerX.equalTo(wself.mas_centerX);
        make.centerY.equalTo(wself.mas_centerY);
        wself.centreCircleView.layer.cornerRadius = width * 0.5f;
    }];
}

# pragma mask 2 KVO
- (void) addKVOs {
    [self addObserver:self forKeyPath:@"checked" options:NSKeyValueObservingOptionNew context:nil];
}
- (void) removeKVOs {
    [self removeObserver:self forKeyPath:@"checked"];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NameWeakSelf(wself);
    if ([keyPath isEqualToString:@"checked"]) {
        BOOL check = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (check) {
            [UIView animateWithDuration:0.2 animations:^{
                wself.centreCircleView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                wself.centreCircleView.transform = CGAffineTransformMakeScale(0.0, 0.0);
            }];
        }
    }
}


# pragma mask 4 getter
- (UIView *)centreCircleView {
    if (!_centreCircleView) {
        _centreCircleView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _centreCircleView;
}

@end
