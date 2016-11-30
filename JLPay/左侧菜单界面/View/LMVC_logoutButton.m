//
//  LMVC_logoutButton.m
//  CustomViewMaker
//
//  Created by jielian on 16/10/9.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "LMVC_logoutButton.h"
#import <ReactiveCocoa.h>
#import "Define_Header.h"


@implementation LMVC_logoutButton

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
    [self addSubview:self.iconLabel];
    [self addSubview:self.logoutLabel];
}

- (void) addKVOs {
    self.logined = YES;
    
    @weakify(self);
    [[RACObserve(self, logined) deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self);
        if ([x boolValue]) {
            self.iconLabel.textColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
            self.logoutLabel.text = @"退出登录";
        } else {
            self.iconLabel.textColor = [UIColor colorWithHex:HexColorTypeGreen alpha:1];
            self.logoutLabel.text = @"请登录";
        }
    }];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height);
    self.iconLabel.frame = frame;
    
    frame.origin.x += frame.size.width;
    frame.size.width = self.frame.size.width - frame.size.width;
    self.logoutLabel.frame = frame;
}


# pragma mask 4 getter

- (UILabel *)iconLabel {
    if (!_iconLabel) {
        _iconLabel = [UILabel new];
        _iconLabel.textColor = [UIColor whiteColor];
        _iconLabel.textAlignment = NSTextAlignmentCenter;
        _iconLabel.text = [NSString fontAwesomeIconStringForEnum:FAPowerOff];
        _iconLabel.font = [UIFont fontAwesomeFontOfSize:15];
    }
    return _iconLabel;
}

- (UILabel *)logoutLabel {
    if (!_logoutLabel) {
        _logoutLabel = [[UILabel alloc] init];
        _logoutLabel.textColor = [UIColor whiteColor];
        _logoutLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    return _logoutLabel;
}


@end
