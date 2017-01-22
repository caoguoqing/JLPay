//
//  TDVC_vLogoHeadView.m
//  JLPay
//
//  Created by jielian on 2017/1/20.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "TDVC_vLogoHeadView.h"
#import "JLLogoView.h"
#import "Define_Header.h"

@interface TDVC_vLogoHeadView()

@property (nonatomic, strong) JLLogoView* logoView;

@end
@implementation TDVC_vLogoHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.logoView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    frame.size.height *= 0.5;
    frame.origin.y = (self.bounds.size.height - frame.size.height) * 0.5;
    frame.size.width -= ScreenWidth * 20/320.f;;
    self.logoView.frame = frame;
}

- (JLLogoView *)logoView {
    if (!_logoView) {
        _logoView = [JLLogoView new];
    }
    return _logoView;
}


@end
