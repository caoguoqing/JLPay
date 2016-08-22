//
//  SU_PhotoPickedTBVCell.m
//  JLPay
//
//  Created by 冯金龙 on 16/6/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "SU_PhotoPickedTBVCell.h"
#import "Define_Header.h"
#import "Masonry.h"



@implementation SU_PhotoPickedTBVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void) loadSubviews {
    [self addSubview:self.backIconLabel];
    [self addSubview:self.imgViewPicked];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NameWeakSelf(wself);
    
    self.backIconLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:self.frame.size.height scale:0.3]];
    
    [self.backIconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(wself);
    }];
    
    [self.imgViewPicked mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.mas_centerX);
        make.centerY.equalTo(wself.mas_centerY);
        make.height.equalTo(wself.mas_height).multipliedBy(0.9);
        make.width.equalTo(wself.mas_width).multipliedBy(0.76);
    }];
    
}

# pragma mask 4 getter

- (UILabel *)backIconLabel {
    if (!_backIconLabel) {
        _backIconLabel = [UILabel new];
        _backIconLabel.text = [NSString fontAwesomeIconStringForEnum:FACamera];
        _backIconLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackGray alpha:0.95];
        _backIconLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _backIconLabel;
}

- (UIImageView *)imgViewPicked {
    if (!_imgViewPicked) {
        _imgViewPicked = [[UIImageView alloc] init];
        _imgViewPicked.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
        _imgViewPicked.layer.cornerRadius = 10.f;
    }
    return _imgViewPicked;
}

@end
