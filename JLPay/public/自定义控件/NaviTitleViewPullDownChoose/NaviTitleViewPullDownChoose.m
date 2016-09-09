//
//  NaviTitleViewPullDownChoose.m
//  JLPay
//
//  Created by jielian on 16/8/24.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "NaviTitleViewPullDownChoose.h"
#import "Masonry.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>


@implementation NaviTitleViewPullDownChoose

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.downLabel];
        self.downPulled = YES;
        
        NameWeakSelf(wself);
        [self.downLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(wself.mas_centerY);
            make.height.equalTo(wself.mas_height).multipliedBy(0.618);
            if (wself.titleLabel) {
                make.left.equalTo(wself.titleLabel.mas_right);
            } else {
                make.left.equalTo(wself.mas_centerX);
            }
            make.width.equalTo(wself.downLabel.mas_height);
        }];
        
        [self addKVOs];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.downLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:self.frame.size.height scale:0.618]];
    
    NameWeakSelf(wself);
    [self.downLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        if (wself.titleLabel) {
            make.left.equalTo(wself.titleLabel.mas_right);
        } else {
            make.left.equalTo(wself.mas_centerX);
        }
    }];

}


- (void) addKVOs {
    @weakify(self);
    [[RACObserve(self, downPulled) deliverOnMainThread] subscribeNext:^(NSNumber* down) {
        if (down.boolValue) {
            [UIView animateWithDuration:0.2 animations:^{
                @strongify(self);
                self.downLabel.transform = CGAffineTransformMakeRotation(0);
            }];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                @strongify(self);
                self.downLabel.transform = CGAffineTransformMakeRotation(M_PI);
            }];
        }
    }];
    
    RAC(self.downLabel, hidden) = [RACObserve(self, enabled) map:^id(id value) {
        return @(![value boolValue]);
    }];
}


#pragma mask 4 getter


- (UILabel *)downLabel {
    if (!_downLabel) {
        _downLabel = [UILabel new];
        _downLabel.textAlignment = NSTextAlignmentCenter;
        _downLabel.text = [NSString fontAwesomeIconStringForEnum:FAAngleDown];
    }
    return _downLabel;
}

@end
