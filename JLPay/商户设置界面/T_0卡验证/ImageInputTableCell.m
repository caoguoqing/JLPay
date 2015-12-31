//
//  ImageInputTableCell.m
//  JLPay
//
//  Created by jielian on 15/12/29.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ImageInputTableCell.h"

@interface ImageInputTableCell()
{
    UIImage* initialImage;
}
@property (nonatomic, strong) UIImageView* imageViewInput;

@end

@implementation ImageInputTableCell
@synthesize imageDisplay = _imageDisplay;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.imageViewInput];
        initialImage = [UIImage imageNamed:@"imageUploadBackground_1"];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.frame.size.width != 0 ) {
        CGFloat widthImageView = 0;
        CGFloat heightImageView = 0;
        
        UIImage* newImage = initialImage;
        if (self.imageDisplay) {
            CGSize imageSize = self.imageViewInput.image.size;
            if (self.frame.size.width/self.frame.size.height > imageSize.width/imageSize.height) {
                heightImageView = self.frame.size.height;
                widthImageView = imageSize.width/imageSize.height * heightImageView;
            } else {
                widthImageView = self.frame.size.width;
                heightImageView = imageSize.height/imageSize.width * widthImageView;
            }
            newImage = self.imageDisplay;
        } else {
            heightImageView = self.frame.size.height / 2.0;
            widthImageView = heightImageView;
        }
        
        
        
        CGRect frame = CGRectZero;
        frame.origin.x = (self.frame.size.width - widthImageView)/2.0;
        frame.origin.y = (self.frame.size.height - heightImageView)/2.0;
        frame.size.width = widthImageView;
        frame.size.height = heightImageView;
        [self.imageViewInput setFrame:frame];
        [self.imageViewInput setImage:newImage];
    }
}
- (void)setInputImage:(UIImage *)image {
    [self.imageViewInput setImage:image];
    [self setNeedsLayout];
}

#pragma mask 1 PRIVATE INTERFACE


#pragma mask 2 gettet & setter
- (UIImageView *)imageViewInput {
    if (_imageViewInput == nil) {
        _imageViewInput = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageViewInput;
}
- (void)setImageDisplay:(UIImage *)imageDisplay {
    _imageDisplay = imageDisplay;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsLayout];
    });
}

@end
