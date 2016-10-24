//
//  LMVC_userHeadView.m
//  CustomViewMaker
//
//  Created by jielian on 16/10/9.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "LMVC_userHeadView.h"
#import "UIColor+HexColor.h"
#import "NSString+Formater.h"


@implementation LMVC_userHeadView


# pragma mask 3 初始化和布局

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
    [self addSubview:self.headImgView];
    [self addSubview:self.busiNameLabel];
    [self addSubview:self.busiNumLabel];
    [self addSubview:self.busiCheckedStateLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat inset = 8;
    CGFloat heightImgView = self.frame.size.height;
    CGFloat hBusiNameLabel = self.frame.size.height * 0.3;
    CGFloat hBusiNumLabel = self.frame.size.height * 0.25;
    CGFloat hBusiCheckLabel = self.frame.size.height * 0.5 - inset * 0.25 - hBusiNumLabel;
    CGFloat wBusiCheckLabel = self.frame.size.width * 0.25;
    
    CGFloat wLabel = self.frame.size.width - heightImgView - inset;
    
    CGRect frame = CGRectMake(0, 0, heightImgView, heightImgView);
    self.headImgView.frame = frame;
    
    frame.origin.x += frame.size.width + inset;
    frame.size.width = wLabel;
    frame.origin.y = self.frame.size.height * 0.5 - hBusiNumLabel * 0.5;
    frame.size.height = hBusiNumLabel;
    self.busiNumLabel.frame = frame;
    
    frame.origin.y -= inset * 0.2 + hBusiNameLabel;
    frame.size.height = hBusiNameLabel;
    self.busiNameLabel.frame = frame;
    
    frame.origin.y = self.busiNumLabel.frame.origin.y + hBusiNumLabel + inset * 0.5;
    frame.size.height = hBusiCheckLabel;
    frame.size.width = wBusiCheckLabel;
    self.busiCheckedStateLabel.frame = frame;
    
    
    self.busiCheckedStateLabel.layer.cornerRadius = hBusiCheckLabel * 0.5;
    self.busiCheckedStateLabel.layer.masksToBounds = YES;
    
    self.busiNameLabel.font = [UIFont boldSystemFontOfSize:[NSString resizeFontAtHeight:hBusiNameLabel scale:1]];
    self.busiNumLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:hBusiNumLabel scale:1]];
    self.busiCheckedStateLabel.font = [UIFont boldSystemFontOfSize:[NSString resizeFontAtHeight:hBusiCheckLabel scale:0.7]];
}




# pragma mask 4 getter

- (UIImageView *)headImgView {
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userHeadGray"]];
    }
    return _headImgView;
}

- (UILabel *)busiNameLabel {
    if (!_busiNameLabel) {
        _busiNameLabel = [UILabel new];
        _busiNameLabel.textColor = [UIColor colorWithHex:0x27384b alpha:1];
    }
    return _busiNameLabel;
}

- (UILabel *)busiNumLabel {
    if (!_busiNumLabel) {
        _busiNumLabel = [UILabel new];
        _busiNumLabel.textColor = [UIColor colorWithHex:0xcccccc alpha:1];
    }
    return _busiNumLabel;
}

- (UILabel *)busiCheckedStateLabel {
    if (!_busiCheckedStateLabel) {
        _busiCheckedStateLabel = [UILabel new];
        _busiCheckedStateLabel.backgroundColor = [UIColor colorWithHex:0xffd300 alpha:1];
        _busiCheckedStateLabel.textColor = [UIColor whiteColor];
        _busiCheckedStateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _busiCheckedStateLabel;
}

@end
