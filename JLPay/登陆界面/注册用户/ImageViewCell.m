//
//  ImageViewCell.m
//  JLPay
//
//  Created by 冯金龙 on 15/10/15.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ImageViewCell.h"
#import "PublicInformation.h"

@interface ImageViewCell()
{
    CGFloat fontSize;
    CGFloat logCount ;
    UIImage* imageDisplaying;
}
@property (nonatomic, strong) UILabel* mustInputLabel;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIImageView* imageViewDisplay;

@end

@implementation ImageViewCell
@synthesize title = _title;
@synthesize imageDisplay = _imageDisplay;

#pragma mask ---- 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        fontSize = 20;
        [self addSubview:self.mustInputLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.imageViewDisplay];
    }
    return self;
}
#pragma mask ---- 重载子视图
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat insetVertical = 5.0;
    CGFloat insetHorizantol = 15.0;
    CGFloat mustInputWidth = 8;
    CGFloat labelHeight = (50 - insetVertical*2) * 2.0/5.0;

    // 输入标记
    CGRect frame = CGRectMake(insetHorizantol, insetVertical, mustInputWidth, labelHeight);
    [self.mustInputLabel setFrame:frame];
    [self.mustInputLabel setFont:[self mustInputFontInFrame:frame]];
    // 标题
    frame.origin.x += frame.size.width;
    frame.size.width = self.frame.size.width - insetHorizantol*2 - mustInputWidth;
    [self.titleLabel setFrame:frame];
    [self.titleLabel setFont:[self newFontInFrame:frame]];
    [self.titleLabel setText:self.title];
    // 图片视图
    frame.origin.y += frame.size.height + insetVertical;
    frame.size.height = self.frame.size.height - frame.size.height - insetVertical*3;
    [self.imageViewDisplay setFrame:frame];
    [self.imageViewDisplay setImage:imageDisplaying];
}

/* 字体大小重置: 指定frame */
- (UIFont*) newFontInFrame:(CGRect)frame {
    CGSize sizeFont = [@"testText" sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize]
                                                                                  forKey:NSFontAttributeName]];
    return [UIFont systemFontOfSize:(frame.size.height/sizeFont.height * fontSize)];
}
- (UIFont*) mustInputFontInFrame:(CGRect)frame {
    CGSize sizeFont = [@"testText" sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize]
                                                                                  forKey:NSFontAttributeName]];
    return [UIFont systemFontOfSize:(frame.size.height/sizeFont.height * fontSize) + 2];
}

/* 重置图片: 适应于当前cell frame */
- (UIImage*) newImageWithSourceImage:(UIImage*)sourceImage {
    UIImage* newImage = nil;
    if (self.frame.size.width == 0) {
        return newImage;
    }
    if (!sourceImage) {
        return newImage;
    }
    UIView* view = [[UIView alloc] initWithFrame:self.frame];
    CGFloat newImageWidth = 0;
    CGFloat newImageHeight = 0;

    // 按原图大小来定义新的放置图片的视图
    if (self.frame.size.width/self.frame.size.height > sourceImage.size.width/sourceImage.size.height) {
        newImageHeight = self.frame.size.height;
        newImageWidth = newImageHeight * sourceImage.size.width/sourceImage.size.height;
    }
    else {
        newImageWidth = self.frame.size.width;
        newImageHeight = newImageWidth * sourceImage.size.height/sourceImage.size.width;
    }
    UIImageView* newImageView = [[UIImageView alloc] initWithFrame:CGRectMake((view.frame.size.width - newImageWidth)/2.0,
                                                                              (view.frame.size.height - newImageHeight)/2.0,
                                                                              newImageWidth,
                                                                              newImageHeight)];
    [newImageView setImage:sourceImage];
    [view addSubview:newImageView];
    
    // 将view转换为image
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}



#pragma mask ---- getter
- (UILabel *)mustInputLabel {
    if (_mustInputLabel == nil) {
        _mustInputLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _mustInputLabel.text = @"*";
        _mustInputLabel.textAlignment = NSTextAlignmentLeft;
        _mustInputLabel.textColor = [PublicInformation returnCommonAppColor:@"red"];
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
- (UIImageView *)imageViewDisplay {
    if (_imageViewDisplay == nil) {
        _imageViewDisplay = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageViewDisplay.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        _imageViewDisplay.layer.cornerRadius = 8.0;
    }
    return _imageViewDisplay;
}
#pragma mask ---- setter
- (void)setTitle:(NSString *)title {
    _title = title;
    [self setNeedsLayout];
}
- (void)setImageDisplay:(UIImage *)imageDisplay {
    _imageDisplay = imageDisplay;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        imageDisplaying = [self newImageWithSourceImage:imageDisplay];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsLayout];
        });
    });
}

@end
