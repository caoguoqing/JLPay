//
//  MTVC_settlementSwitchBtn.m
//  JLPay
//
//  Created by jielian on 2016/10/31.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MTVC_settlementSwitchBtn.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>


@interface MTVC_settlementSwitchBtn()


@end

@implementation MTVC_settlementSwitchBtn


- (void) addKVO {
    RAC(self.switchLabel, hidden) = [RACObserve(self, enabled) map:^id(id value) {
        return @(![value boolValue]);
    }];
}





- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.switchLabel];
        [self addKVO];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.switchLabel.frame = CGRectMake(self.frame.size.width - self.frame.size.height,
                                        0,
                                        self.frame.size.height,
                                        self.frame.size.height);
    
}



# pragma mask 4 getter

- (UILabel *)switchLabel {
    if (!_switchLabel) {
        _switchLabel = [UILabel new];
        _switchLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _switchLabel;
}

@end
