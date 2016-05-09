//
//  UserHeadImageTBVCell.m
//  JLPay
//
//  Created by jielian on 16/5/4.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "UserHeadImageTBVCell.h"

@implementation UserHeadImageTBVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.headImageView];
        [self.contentView addSubview:self.titleLabel];
        self.contentView.backgroundColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat heightImage = self.frame.size.height * 0.5;
    CGFloat heightLabel = heightImage * 0.4;
    CGFloat inset = (self.frame.size.height - heightImage - heightLabel) * 0.5;
    
    NameWeakSelf(wself);
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.mas_centerX);
        make.top.equalTo(wself.mas_top).offset(inset);
        make.width.mas_equalTo(heightImage);
        make.height.mas_equalTo(heightImage);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.headImageView.mas_bottom).offset(heightLabel * 0.3);
        make.left.equalTo(wself.mas_left);
        make.right.equalTo(wself.mas_right);
        make.height.mas_equalTo(heightLabel);
        wself.titleLabel.font = [UIFont systemFontOfSize:[@"test" resizeFontAtHeight:heightLabel scale:0.8]];
    }];
}

# pragma mask 4 getter
- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _headImageView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end
