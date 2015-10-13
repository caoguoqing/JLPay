//
//  TextLabelCell.m
//  JLPay
//
//  Created by jielian on 15/10/13.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "TextLabelCell.h"
#import "PublicInformation.h"

@interface TextLabelCell()
{
    CGFloat fontSize;
    CGFloat rateTitle ;
    CGFloat rateText ;

}
@property (nonatomic, strong) UILabel* mustInputLabel;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* remindLabel;
@property (nonatomic, strong) UIImageView* remindImageView;

@end



@implementation TextLabelCell

#pragma mask ---- 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        fontSize = 20;
        rateTitle = 2.0/5.0;
        rateText = 3.0/5.0;

        [self addSubview:self.mustInputLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.remindLabel];
        [self addSubview:self.remindImageView];
    }
    return self;
}

#pragma mask ---- 加载子视图
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat insetVertical = 5;
    CGFloat insetHorizantal = 15;
    CGFloat mustInputWidth = 8;
    CGSize imageSize = self.remindImageView.image.size;
    CGFloat imageWidth = 27;
    CGFloat imageHeight = imageWidth * (imageSize.height/imageSize.width);
    CGFloat imageY = (self.frame.size.height - imageHeight)/2.0;
    CGFloat titleWidth = self.frame.size.width - insetVertical - insetHorizantal - mustInputWidth - (insetHorizantal + imageWidth);
    CGFloat titleHeight = (self.frame.size.height - insetVertical*2)*rateTitle;
    CGFloat textHeight = (self.frame.size.height - insetVertical*2)*rateText;
    
    CGRect frame = CGRectMake(insetHorizantal, insetVertical, mustInputWidth, titleHeight);
    [self.mustInputLabel setFrame:frame];
    [self.mustInputLabel setFont:[self mustInputFontInFrame:frame]];
    
    frame.origin.x += frame.size.width;
    frame.size.width = titleWidth;
    [self.titleLabel setFrame:frame];
    [self.titleLabel setFont:[self newFontInFrame:frame]];
    
    frame.origin.y += frame.size.height;
    frame.size.height = textHeight;
    [self.remindLabel setFrame:frame];
    
    frame.origin.x += frame.size.width;
    frame.origin.y = imageY;
    frame.size.width = imageWidth;
    frame.size.height = imageHeight;
    [self.remindImageView setFrame:frame];
    
}


/* 字体大小重置: 指定frame */
- (UIFont*) newFontInFrame:(CGRect)frame {
    CGSize sizeFont = [@"testText" sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize]
                                                                                  forKey:NSFontAttributeName]];
    return [UIFont systemFontOfSize:(frame.size.height/sizeFont.height * fontSize) ];
}
- (UIFont*) mustInputFontInFrame:(CGRect)frame {
    CGSize sizeFont = [@"testText" sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize]
                                                                                  forKey:NSFontAttributeName]];
    return [UIFont systemFontOfSize:(frame.size.height/sizeFont.height * fontSize) + 2];
}


#pragma mask ---- getter
- (UILabel *)mustInputLabel {
    if (_mustInputLabel == nil) {
        if (_mustInputLabel == nil) {
            _mustInputLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _mustInputLabel.text = @"*";
            _mustInputLabel.textColor = [PublicInformation returnCommonAppColor:@"red"];
            _mustInputLabel.textAlignment = NSTextAlignmentLeft;
            _mustInputLabel.hidden = YES;
        }
        return _mustInputLabel;
    }
    return _mustInputLabel;
}
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor blueColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}
- (UILabel *)remindLabel {
    if (_remindLabel == nil) {
        _remindLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _remindLabel.textColor = [UIColor grayColor];
        _remindLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _remindLabel;
}
- (UIImageView *)remindImageView {
    if (_remindImageView == nil) {
        _remindImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_remindImageView setImage:[UIImage imageNamed:@"next"]];
    }
    return _remindImageView;
}
#pragma mask ---- setter
- (void)setTitle:(NSString *)title {
    [self.titleLabel setText:title];
}
- (void)setPlaceHolder:(NSString *)placeHolder {
    [self.remindLabel setText:placeHolder];
}
- (void)setMustInput:(BOOL)mustInput {
    [self.mustInputLabel setHidden:!mustInput];
}


@end
