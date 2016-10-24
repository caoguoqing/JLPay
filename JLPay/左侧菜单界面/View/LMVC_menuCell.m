//
//  LMVC_menuCell.m
//  CustomViewMaker
//
//  Created by jielian on 16/10/9.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "LMVC_menuCell.h"
#import "Define_Header.h"

@implementation LMVC_menuCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void) loadSubviews {
    [self.contentView addSubview:self.iconLabel];
    [self.contentView addSubview:self.titleLabel];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    

    CGRect frame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height);
    self.iconLabel.frame = frame;
    
    frame.origin.x += frame.size.width;
    frame.size.height = self.frame.size.height;
    frame.size.width = self.frame.size.width - frame.origin.x;
    self.titleLabel.frame = frame;
        
}


# pragma mask 4 getter

- (UILabel *)iconLabel {
    if (!_iconLabel) {
        _iconLabel = [UILabel new];
        _iconLabel.textColor = [UIColor whiteColor];
        _iconLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _iconLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

@end
