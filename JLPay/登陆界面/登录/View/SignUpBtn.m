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
    [self addSubview:self.directionLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NameWeakSelf(wself);
    
    self.directionLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:self.frame.size.height * 0.45 scale:1]];
    [self.directionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.titleLabel.mas_right).offset(6);
        make.centerY.equalTo(wself.mas_centerY);
        make.height.equalTo(wself.mas_height).multipliedBy(0.5);
        make.width.equalTo(wself.directionLabel.mas_height);
    }];
    
}


# pragma mask 4 getter

- (UILabel *)directionLabel {
    if (!_directionLabel) {
        _directionLabel = [UILabel new];
        _directionLabel.text = [NSString fontAwesomeIconStringForEnum:FASignIn];
        _directionLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _directionLabel;
}


@end
