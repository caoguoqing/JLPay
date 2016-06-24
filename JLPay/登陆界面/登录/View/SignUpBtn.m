//
//  SignUpBtn.m
//  JLPay
//
//  Created by jielian on 16/6/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "SignUpBtn.h"
#import "Define_Header.h"
#import "Masonry.h"

@implementation SignUpBtn

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
    [self addSubview:self.directionImg];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NameWeakSelf(wself);
    
    [self.directionImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.titleLabel.mas_right).offset(2);
        make.centerY.equalTo(wself.mas_centerY);
        make.height.equalTo(wself.mas_height).multipliedBy(0.5);
        make.width.equalTo(wself.directionImg.mas_height);
    }];
    
}


# pragma mask 4 getter

- (UILabel *)directionLabel {
    if (!_directionLabel) {
        _directionLabel = [UILabel new];
        _directionLabel.text = [NSString fontAwesomeIconStringForEnum:FAAngleRight];
        _directionLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _directionLabel;
}

- (UIImageView *)directionImg {
    if (!_directionImg) {
        _directionImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next"]];
    }
    return _directionImg;
}


@end
