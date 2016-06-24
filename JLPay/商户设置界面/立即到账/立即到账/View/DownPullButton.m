//
//  DownPullButton.m
//  JLPay
//
//  Created by jielian on 16/5/26.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DownPullButton.h"
#import "Define_Header.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>

@implementation DownPullButton


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
    self.down = YES;
    [self addSubview:self.downImgView];
}

- (void) addKVOs {
    @weakify(self);
    [[[RACObserve(self, down) skip:1] deliverOnMainThread] subscribeNext:^(NSNumber* down) {
        if (down.boolValue) {
            [UIView animateWithDuration:0.2 animations:^{
                @strongify(self);
                self.transform = CGAffineTransformMakeRotation(0);
            }];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                @strongify(self);
                self.transform = CGAffineTransformMakeRotation(M_PI);
            }];
        }
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NameWeakSelf(wself);
    
    [self.downImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.mas_centerX);
        make.centerY.equalTo(wself.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
}



# pragma mask 4 getter
- (UIImageView *)downImgView {
    if (!_downImgView) {
        _downImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"directionDown_lightGray"]];
    }
    return _downImgView;
}

@end
