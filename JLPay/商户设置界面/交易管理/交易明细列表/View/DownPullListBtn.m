//
//  DownPullListBtn.m
//  JLPay
//
//  Created by jielian on 16/6/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DownPullListBtn.h"
#import "Masonry.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>

@implementation DownPullListBtn
- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadSubviews];
        [self addKVOs];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubviews];
        [self addKVOs];
    }
    return self;
}

- (void) loadSubviews {
    self.downDirection = YES;
    [self addSubview:self.downLabel];
}

- (void) addKVOs {
    
    @weakify(self);
    [[RACObserve(self, downDirection) deliverOnMainThread] subscribeNext:^(NSNumber* down) {
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
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NameWeakSelf(wself);
    
    self.downLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:self.frame.size.height scale:0.8]];
    
    [self.downLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.titleLabel.mas_right).offset(5);
        make.centerY.equalTo(wself.mas_centerY);
        make.top.equalTo(wself.mas_top);
        make.bottom.equalTo(wself.mas_bottom);
    }];
    
}


# pragma mask 4 getter
- (UILabel *)downLabel {
    if (!_downLabel) {
        _downLabel = [UILabel new];
        _downLabel.textAlignment = NSTextAlignmentCenter;
        _downLabel.text = [NSString fontAwesomeIconStringForEnum:FAAngleDown];
    }
    return _downLabel;
}

@end
