//
//  TransDetailTBVHeader.m
//  JLPay
//
//  Created by jielian on 16/5/12.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "TransDetailTBVHeader.h"

@implementation TransDetailTBVHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.countTransLabel];
        self.contentView.backgroundColor = [UIColor colorWithHex:HexColorTypeBlackGray alpha:0.1];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NameWeakSelf(wself);
    
    CGFloat heightCountLabel = self.frame.size.height * 0.6;
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.contentView.mas_top);
        make.bottom.equalTo(wself.contentView.mas_bottom);
        make.left.equalTo(wself.contentView.mas_left).offset(13);
        make.width.mas_equalTo([wself.titleLabel.text resizeAtHeight:wself.frame.size.height scale:1].width * 1.5);
        wself.titleLabel.font = [UIFont boldSystemFontOfSize:[wself.titleLabel.text resizeFontAtHeight:wself.frame.size.height scale:0.5]];
    }];
    [self.countTransLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(wself.contentView.mas_centerY);
        make.right.equalTo(wself.contentView.mas_right).offset(-15);
        make.height.mas_equalTo(heightCountLabel);
        make.width.mas_equalTo([wself.countTransLabel.text resizeAtHeight:heightCountLabel scale:1].width * 2);
        wself.countTransLabel.font = [UIFont boldSystemFontOfSize:[wself.countTransLabel.text resizeFontAtHeight:heightCountLabel scale:0.68]];
        wself.countTransLabel.layer.cornerRadius = heightCountLabel * 0.5;
    }];
    
}


# pragma mask 4 getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor colorWithHex:HexColorTypeViewCyan alpha:1];
    }
    return _titleLabel;
}
- (UILabel *)countTransLabel {
    if (!_countTransLabel) {
        _countTransLabel = [UILabel new];
        _countTransLabel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.7];
        _countTransLabel.textColor = [UIColor whiteColor];
        _countTransLabel.textAlignment = NSTextAlignmentCenter;
        _countTransLabel.layer.masksToBounds = YES;
    }
    return _countTransLabel;
}


@end
