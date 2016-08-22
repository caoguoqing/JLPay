//
//  ElecSignFrameView.m
//  JLPay
//
//  Created by jielian on 16/7/25.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "ElecSignFrameView.h"

@implementation ElecSignFrameView


- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void) loadSubviews {
    [self addSubview:self.keyElementLabel];
    [self addSubview:self.elecSignView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.keyElementLabel.frame = self.bounds;
    self.elecSignView.frame = self.bounds;
    
}

# pragma mask 4 getter

- (UILabel *)keyElementLabel {
    if (!_keyElementLabel) {
        _keyElementLabel = [UILabel new];
        _keyElementLabel.textAlignment = NSTextAlignmentCenter;
        _keyElementLabel.textColor = [UIColor blackColor];
        _keyElementLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    return _keyElementLabel;
}

- (ElecSignView *)elecSignView {
    if (!_elecSignView) {
        _elecSignView = [[ElecSignView alloc] initWithFrame:CGRectZero];
        _elecSignView.backgroundColor = [UIColor clearColor];
    }
    return _elecSignView;
}


@end
