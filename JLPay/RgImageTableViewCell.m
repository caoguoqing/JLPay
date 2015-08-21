//
//  ImageTableViewCell.m
//  TestForRegister
//
//  Created by jielian on 15/8/20.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "RgImageTableViewCell.h"

@interface RgImageTableViewCell()<UIActionSheetDelegate>
@property (nonatomic, strong) UILabel* labTitle;
@property (nonatomic, strong) UIButton* btnImage;
@property (nonatomic, strong) UIImage* btnBackImage;
@property (nonatomic) BOOL addedImage;
@property (nonatomic) CGFloat fontSize;
@end

@implementation RgImageTableViewCell
@synthesize labTitle = _labTitle;
@synthesize btnImage = _btnImage;
@synthesize addedImage;
@synthesize fontSize;



// 设置标题
- (void) setLabelTitle:(NSString*)text {
    [self.labTitle setText:text];
}
- (NSString*)labelTitle {
    return self.labTitle.text;
}

// 设置背景图
- (void) setBackgroundImage:(UIImage*)image {
    [self.btnImage setBackgroundImage:[self newImageForFrame:self.btnImage.bounds withOImage:image] forState:UIControlStateNormal];
}

/*
 * 根据新的frame,用原图片生成一个带空白区域的新的图片
 */
- (UIImage*) newImageForFrame:(CGRect)frame withOImage:(UIImage*)image {
    UIImage* newImage = nil;
    UIView* reLoadImageView = [[UIView alloc] initWithFrame:frame];
    reLoadImageView.backgroundColor = [UIColor whiteColor];
    UIImageView* imageView = nil;
    CGRect newFrame = frame;
    CGFloat kLengthOrWidthFrame = (frame.size.width/frame.size.height)/(image.size.width/image.size.height);
    if (kLengthOrWidthFrame > 1.000000) {
        // frame 横度 比 image 大;则image以满高度填充
        CGFloat oldWidth = frame.size.width;
        newFrame.size.width = newFrame.size.height * (image.size.width/image.size.height);
        newFrame.origin.x = (oldWidth - newFrame.size.width)/2.0;
        imageView = [[UIImageView alloc] initWithFrame:newFrame];
    } else if (kLengthOrWidthFrame < 1.000000) {
        // frame 横度 比 image 小;则image以满长度填充
        CGFloat oldHeight = frame.size.height;
        newFrame.size.height = newFrame.size.width * (image.size.height/image.size.width);
        newFrame.origin.y = (oldHeight - newFrame.size.height)/2.0;
        imageView = [[UIImageView alloc] initWithFrame:newFrame];
    } else {
        // frame 跟 image 长宽比例一致;直接填充
        newImage = image;
    }
    if (imageView) {
        imageView.image = image;
        [reLoadImageView addSubview:imageView];
        // 将重新填充的view装载成image
        UIGraphicsBeginImageContextWithOptions(reLoadImageView.frame.size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [reLoadImageView.layer renderInContext:context];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newImage;
}
// 按图片的原始大小填充
- (UIImage*) newOriginImageForFrame:(CGRect)frame withOImage:(UIImage*)image {
    UIImage* newImage = nil;
    UIView* reLoadImageView = [[UIView alloc] initWithFrame:frame];
    reLoadImageView.backgroundColor = [UIColor whiteColor];
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - image.size.width)/2.0, (frame.size.height - image.size.height)/2.0, image.size.width, image.size.height)];
    imageView.image = image;
    [reLoadImageView addSubview:imageView];
    
    // 将重新填充的view装载成image
    UIGraphicsBeginImageContextWithOptions(reLoadImageView.frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [reLoadImageView.layer renderInContext:context];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


#pragma mask --- 按钮事件:加载图片
- (IBAction) touchToLoadImage:(UIButton*)sender {
    // 调用 delegate 去加载图片
    NSLog(@"调用delegate去加载图片");
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageCell:loadingImageAtCellTitle:)]) {
        [self.delegate imageCell:self loadingImageAtCellTitle:self.labTitle.text];
    }
}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.addedImage = NO;
        self.fontSize = 15.0;
        [self.contentView addSubview:self.labTitle];
        [self.contentView addSubview:self.btnImage];
    }
    return self;
}
- (void)layoutSubviews {
    CGFloat inset = 5.0;
    CGRect frame = CGRectMake(inset, inset, inset*2, self.frame.size.height - inset*2);
    [self.contentView addSubview:[self labelNeedInputInFrame:frame]];
    
    frame.origin.x += frame.size.width;
    frame.size.width = self.frame.size.width/4.0;
    self.labTitle.frame = frame;
    
    frame.origin.x += frame.size.width + inset*3.0;
    frame.size.width = self.frame.size.width - frame.origin.x - inset*2.0;
    self.btnImage.frame = frame;
    if ([self.btnImage backgroundImageForState:UIControlStateNormal] == nil ) {
        [self.btnImage setBackgroundImage:[self newOriginImageForFrame:self.btnImage.bounds withOImage:[UIImage imageNamed:@"camera"]] forState:UIControlStateNormal];
    }
}
// 生成星号label
- (UILabel*) labelNeedInputInFrame:(CGRect)frame {
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.text = @"*";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor redColor];
    label.font = [UIFont systemFontOfSize:self.fontSize];
    return label;
}

#pragma mask ---- getter & setter 
- (UILabel *)labTitle {
    if (_labTitle == nil) {
        _labTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _labTitle.font = [UIFont systemFontOfSize:self.fontSize];
    }
    return _labTitle;
}
- (UIButton *)btnImage {
    if (_btnImage == nil) {
        _btnImage = [[UIButton alloc] initWithFrame:CGRectZero];
        _btnImage.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _btnImage.layer.borderWidth = 0.5;
        _btnImage.layer.cornerRadius = 5.0;
        [_btnImage addTarget:self action:@selector(touchToLoadImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnImage;
}

@end
