//
//  BusinessVCRefreshButton.m
//  JLPay
//
//  Created by jielian on 16/5/5.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "BusinessVCRefreshButton.h"

@implementation BusinessVCRefreshButton


- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubvies];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubvies];
    }
    return self;
}

- (void) addSubvies {
    [self addSubview:self.refreshImgView];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat widthImage = 68;
    NameWeakSelf(wself);
    [self.refreshImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.mas_centerX);
        make.bottom.equalTo(wself.mas_centerY).offset(- 15);
        make.width.mas_offset(widthImage);
        make.height.mas_equalTo(widthImage);
    }];
}


# pragma mask 4 getter
- (UIImageView *)refreshImgView {
    if (!_refreshImgView) {
        _refreshImgView = [UIImageView new];
        _refreshImgView.image = [UIImage imageNamed:@"refresh_white"];
    }
    return _refreshImgView;
}


@end
