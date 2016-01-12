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
@property (nonatomic, strong) UIImageView* cardImageView;
@property (nonatomic, strong) UIView* lineView;

@end

@implementation SubAndDetailLabelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.leftLabel];
        [self addSubview:self.rightLabel];
        [self addSubview:self.subLabel];
        [self addSubview:self.cardImageView];
        [self addSubview:self.lineView];
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
    self.subLabel.textColor = [UIColor grayColor];
}
- (void) setSubText:(NSString*)text color:(EnumSubTextColor)enumColor {
    self.subLabel.text = text;
    self.subLabel.textColor = [PublicInformation colorForHexInt:enumColor];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat insetHorizantal = 15;
    CGFloat insetVertical = 4;
    
    CGFloat heightImage = self.frame.size.height - insetVertical*2;
    CGFloat widthImage = heightImage;
    
    CGFloat widthLeft = (self.frame.size.width - widthImage - insetHorizantal*3) * 3.0/4.0;
    CGFloat widthRight = (self.frame.size.width - widthImage - insetHorizantal*3) * 1.0/4.0;
    CGFloat widthSub = self.frame.size.width - insetHorizantal*2;
    CGFloat heightUpLabel = (self.frame.size.height - insetVertical*2) * 4.0/7.0;
    CGFloat heightDownLabel = (self.frame.size.height - insetVertical*2) * 3.0/7.0;
    CGFloat widthLine = self.frame.size.width - insetHorizantal*2 - widthImage;
    CGFloat heightLine = 0.5;
    
    
    CGRect frame = CGRectMake(insetHorizantal, insetVertical, widthImage, heightImage);
    [self.cardImageView setFrame:frame];
    [self relocationImageView];
    
    frame.origin.x = insetHorizantal*2 + widthImage;
    frame.size.width = widthLeft;
    frame.size.height = heightUpLabel;
    [self.leftLabel setFrame:frame];
    self.leftLabel.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:frame.size andScale:1]];
    
    frame.origin.x += frame.size.width;
    frame.size.width = widthRight;
    [self.rightLabel setFrame:frame];
    self.rightLabel.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:frame.size andScale:1]];
    
    frame.origin.x = insetHorizantal*2 + widthImage;
    frame.origin.y += frame.size.height;
    frame.size.width = widthSub;
    frame.size.height = heightDownLabel;
    [self.subLabel setFrame:frame];
    [self.subLabel setFont:[UIFont systemFontOfSize:[PublicInformation resizeFontInSize:frame.size andScale:1]]];
    
    frame.origin.y = self.frame.size.height - heightLine;
    frame.size.width = widthLine;
    frame.size.height = heightLine;
    [self.lineView setFrame:frame];
}
- (void) relocationImageView {
    CGSize imageSize = self.cardImageView.image.size;
    CGRect newFrame = self.cardImageView.frame;
    if (imageSize.width/imageSize.height >= 1) {
        newFrame.size.height = newFrame.size.width * imageSize.height/imageSize.width;
        newFrame.origin.y += (newFrame.size.width - newFrame.size.height)/2.0;
    } else {
        newFrame.size.width = newFrame.size.height * imageSize.width/imageSize.height;
        newFrame.origin.x += (newFrame.size.height - newFrame.size.width)/2.0;
    }
    self.cardImageView.frame = newFrame;
}


#pragma mask ---- getter
- (UIImageView *)cardImageView {
    if (_cardImageView == nil) {
        _cardImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _cardImageView.image = [UIImage imageNamed:@"cardShow_blue"];
    }
    return _cardImageView;
}
- (UIView *)lineView {
    if (_lineView == nil) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        [_lineView setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
    }
    return _lineView;
}
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
