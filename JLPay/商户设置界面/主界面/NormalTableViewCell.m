//
//  NormalTableViewCell.m
//  JLPay
//
//  Created by jielian on 15/11/19.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "NormalTableViewCell.h"

@interface NormalTableViewCell()

@property (nonatomic, strong) UIImageView* cellImageView;
@property (nonatomic, strong) UILabel* cellNameLabel;

@end

@implementation NormalTableViewCell

#pragma mask ---- PUBLIC INTERFACE 
/* 设置cell 的图片 */
- (void) setCellImage:(UIImage*)cellImage {
    [self.cellImageView setImage:cellImage];
}

/* 设置cell 的标题 */
- (void) setCellName:(NSString*)cellName {
    [self.cellNameLabel setText:cellName];
}


#pragma mask ---- 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self addSubview:self.cellImageView];
        [self addSubview:self.cellNameLabel];
    }
    return self;
}

#pragma mask ---- 重载子视图
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat insetLeft = 30;
    CGFloat heightImage = self.frame.size.height * 2.0/3.0;
    CGFloat insetImageTop = (self.frame.size.height - heightImage)/2.0;
    CGFloat widthLabel = 200;
    
    CGRect frame = CGRectMake(insetLeft, insetImageTop, heightImage, heightImage);
    // 图片
    [self.cellImageView setFrame:frame];
    // 标题
    frame.origin.x += frame.size.width + insetLeft/2.0;
    frame.origin.y = 0;
    frame.size.width = widthLabel;
    frame.size.height = self.frame.size.height;
    [self.cellNameLabel setFrame:frame];
    
}


#pragma mask ---- getter
- (UIImageView *)cellImageView {
    if (_cellImageView == nil) {
        _cellImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _cellImageView;
}
- (UILabel *)cellNameLabel {
    if (_cellNameLabel == nil) {
        _cellNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _cellNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _cellNameLabel;
}

@end
