//
//  NormalTableViewCell.m
//  JLPay
//
//  Created by jielian on 15/11/19.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "NormalTableViewCell.h"
#import "Define_Header.h"
#import "Masonry.h"

@implementation NormalTableViewCell



#pragma mask ---- 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.iconLabel];
    }
    return self;
}

#pragma mask ---- 重载子视图
- (void)layoutSubviews {
    [super layoutSubviews];
    
    NameWeakSelf(wself);
    [self.iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.mas_left).offset(5);
        make.top.equalTo(wself.mas_top);
        make.bottom.equalTo(wself.mas_bottom);
        make.height.equalTo(wself.iconLabel.mas_width);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.iconLabel.mas_right);
        make.top.equalTo(wself.mas_top);
        make.bottom.equalTo(wself.mas_bottom);
        make.right.equalTo(wself.mas_right);
    }];
}


#pragma mask ---- getter

- (UILabel *)iconLabel {
    if (!_iconLabel) {
        _iconLabel = [UILabel new];
        _iconLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _iconLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

@end
