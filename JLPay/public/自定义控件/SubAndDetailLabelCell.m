//
//  SubAndDetailLabelCell.m
//  JLPay
//
//  Created by jielian on 15/12/29.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "SubAndDetailLabelCell.h"
#import "PublicInformation.h"

@interface SubAndDetailLabelCell()

@property (nonatomic, strong) UILabel* leftLabel;
@property (nonatomic, strong) UILabel* rightLabel;
@property (nonatomic, strong) UILabel* subLabel;

@end

@implementation SubAndDetailLabelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.leftLabel];
        [self addSubview:self.rightLabel];
        [self addSubview:self.subLabel];
    }
    return self;
}

- (void)setLeftText:(NSString *)text {
    self.leftLabel.text = text;
}
- (void) setRightText:(NSString *)text {
    self.rightLabel.text = text;
}
- (void)setSubText:(NSString *)text {
    self.subLabel.text = text;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat insetHorizantal = 15;
    CGFloat insetVertical = 4;
    CGFloat widthLeft = (self.frame.size.width - insetHorizantal*2) * 3.0/4.0;
    CGFloat widthRight = (self.frame.size.width - insetHorizantal*2) * 1.0/4.0;
    CGFloat widthSub = self.frame.size.width - insetHorizantal*2;
    CGFloat heightUpLabel = (self.frame.size.height - insetVertical*2) * 4.0/7.0;
    CGFloat heightDownLabel = (self.frame.size.height - insetVertical*2) * 3.0/7.0;
    
    CGRect frame = CGRectMake(insetHorizantal, insetVertical, widthLeft, heightUpLabel);
    [self.leftLabel setFrame:frame];
    self.leftLabel.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:frame.size andScale:1]];
    
    frame.origin.x += frame.size.width;
    frame.size.width = widthRight;
    [self.rightLabel setFrame:frame];
    self.rightLabel.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:frame.size andScale:1]];
    
    frame.origin.x = insetHorizantal;
    frame.origin.y += frame.size.height;
    frame.size.width = widthSub;
    frame.size.height = heightDownLabel;
    [self.subLabel setFrame:frame];
    [self.subLabel setFont:[UIFont systemFontOfSize:[PublicInformation resizeFontInSize:frame.size andScale:1]]];
}


#pragma mask ---- getter
- (UILabel *)leftLabel {
    if (_leftLabel == nil) {
        _leftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _leftLabel;
}
- (UILabel *)rightLabel {
    if (_rightLabel == nil) {
        _rightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _rightLabel.textAlignment = NSTextAlignmentRight;
    }
    return _rightLabel;
}
- (UILabel *)subLabel {
    if (_subLabel == nil) {
        _subLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subLabel.textColor = [UIColor grayColor];
    }
    return _subLabel;
}

@end
