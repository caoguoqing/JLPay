//
//  ReconnectDeviceBtn.m
//  JLPay
//
//  Created by jielian on 16/6/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "ReconnectDeviceBtn.h"
#import "Define_Header.h"
#import "Masonry.h"

@implementation ReconnectDeviceBtn

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
    [self addSubview:self.refreshLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NameWeakSelf(wself);
    
    self.refreshLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:self.frame.size.height scale:0.4]];
    
    [self.refreshLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.titleLabel.mas_right).offset(0);
        make.top.equalTo(wself.mas_top);
        make.bottom.equalTo(wself.mas_bottom);
        make.width.equalTo(wself.refreshLabel.mas_height);
    }];
    
}



# pragma mask 4 getter

- (UILabel *)refreshLabel {
    if (!_refreshLabel) {
        _refreshLabel = [UILabel new];
        _refreshLabel.text = [NSString fontAwesomeIconStringForEnum:FARefresh];
        _refreshLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _refreshLabel;
}

@end
