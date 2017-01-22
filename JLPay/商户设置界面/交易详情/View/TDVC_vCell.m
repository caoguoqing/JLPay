//
//  TDVC_vCell.m
//  JLPay
//
//  Created by jielian on 2017/1/19.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "TDVC_vCell.h"
#import "Define_Header.h"
#import "Masonry.h"


@implementation TDVC_vCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.titleLabel];
        [self addSubview:self.contextLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NameWeakSelf(wself);
    CGFloat inset = ScreenWidth * 10/320.f;
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(wself.mas_width).multipliedBy(1 - 0.7);
    }];
    
    [self.contextLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wself.titleLabel.mas_right).offset(inset);
        make.right.top.bottom.mas_equalTo(0);
    }];
    
}


# pragma mask 4 getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentRight;
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _titleLabel.textColor = [UIColor colorWithHex:0x27384b alpha:1];
    }
    return _titleLabel;
}
- (UILabel *)contextLabel {
    if (!_contextLabel) {
        _contextLabel = [UILabel new];
        _contextLabel.textColor = [UIColor colorWithHex:0x777777 alpha:1];
        _contextLabel.textAlignment = NSTextAlignmentLeft;
        _contextLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _contextLabel;
}

@end
