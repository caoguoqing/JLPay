//
//  MLIconButtonR.m
//  CustomViewMaker
//
//  Created by jielian on 2016/12/30.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MLIconButtonR.h"
#import "Define_Header.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>



@implementation MLIconButtonR


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.rightIconLabel];
        [self addKVO];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NameWeakSelf(wself);
    
    
    
    
    NSString* title = [self titleForState:UIWindowLevelNormal];
    CGSize textSize = [title sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
    
    [self.rightIconLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(wself.mas_centerX).offset(textSize.width * 0.5);
        make.width.mas_equalTo(wself.rightIconLabel.mas_height).multipliedBy(0.5);
    }];
    
}

- (void) addKVO {
    @weakify(self);
    [[self rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
        @strongify(self);
        self.rightIconLabel.alpha = 0.4;
    }];
    [[self rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        self.rightIconLabel.alpha = 1;
    }];
    [[self rac_signalForControlEvents:UIControlEventTouchUpOutside] subscribeNext:^(id x) {
        @strongify(self);
        self.rightIconLabel.alpha = 1;
    }];
}


# pragma mask 4 getter

- (UILabel *)rightIconLabel {
    if (!_rightIconLabel) {
        _rightIconLabel = [UILabel new];
        _rightIconLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _rightIconLabel;
}



@end
