//
//  RevokeViewCell.m
//  JLPay
//
//  Created by jielian on 15/11/12.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "RevokeViewCell.h"


@interface RevokeViewCell()
{
    CGFloat insetHorizantal;
}
@property (nonatomic, strong) UILabel* labelTitle;
@property (nonatomic, strong) UILabel* labelValue;

@end


@implementation RevokeViewCell

/* 设置标题 */
- (void) setCellTitle:(NSString*)title {
    self.labelTitle.text = title;
    self.labelTitle.backgroundColor = [UIColor blueColor];
}
/* 设置值 */
- (void) setCellValue:(NSString*)value withColor:(UIColor*)color {
    self.labelValue.text = value;
    self.labelValue.textColor = color;
    self.labelValue.backgroundColor = [UIColor redColor];

}


#pragma mask ---- 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        insetHorizantal = 30.0;
//        [self addSubview:self.labelTitle];
//        [self addSubview:self.labelValue];
    }
    return self;
}

- (void)layoutSubviews {
    
    CGRect frame = self.frame;
//    if (frame.size.width > 0) {
        frame.origin.x = insetHorizantal;
        frame.size.width = self.frame.size.width / 4.0;
        [self.labelTitle setFrame:frame];
        [self addSubview:self.labelTitle];
        
        frame.origin.x += frame.size.width + insetHorizantal/2.0;
        frame.size.width = self.frame.size.width - frame.origin.x - insetHorizantal/2.0;
        [self.labelValue setFrame:frame];
        [self addSubview:self.labelValue];
//    }
    [super layoutSubviews];
}


#pragma mask ---- getter
- (UILabel *)labelTitle {
    if (_labelTitle == nil) {
        _labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
//        _labelTitle = [[UILabel alloc] init];
        _labelTitle.textAlignment = NSTextAlignmentCenter;
    }
    return _labelTitle;
}
- (UILabel *)labelValue {
    if (_labelValue == nil) {
        _labelValue = [[UILabel alloc] initWithFrame:CGRectZero];
//        _labelTitle = [[UILabel alloc] init];
        _labelValue.textAlignment = NSTextAlignmentLeft;
        _labelValue.font = [UIFont systemFontOfSize:15.0];
    }
    return _labelValue;
}

@end
