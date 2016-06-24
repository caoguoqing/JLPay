//
//  DispatchDetailCell.m
//  JLPay
//
//  Created by jielian on 16/5/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DispatchDetailCell.h"
#import "Masonry.h"
#import "Define_Header.h"

@implementation DispatchDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.cardNoLabel];
        [self.contentView addSubview:self.moneyLabel];
        [self.contentView addSubview:self.timeLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NameWeakSelf(wself);
    
    CGFloat inset = 4.f;
    CGFloat heightBig = (self.contentView.frame.size.height - inset * 2) * 0.5;
    CGFloat heightLit = heightBig * 0.5;
    
    self.cardNoLabel.font = [UIFont systemFontOfSize:[@"e" resizeFontAtHeight:heightBig scale:0.95]];
    self.moneyLabel.font = [UIFont systemFontOfSize:[@"e" resizeFontAtHeight:heightLit scale:1]];
    self.timeLabel.font = [UIFont systemFontOfSize:[@"e" resizeFontAtHeight:heightLit scale:1]];

    [self.cardNoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.contentView.mas_left).offset(15);
        make.right.equalTo(wself.contentView.mas_right);
        make.top.equalTo(wself.contentView.mas_top).offset(inset);
        make.height.mas_equalTo(heightBig);
    }];
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.contentView.mas_left).offset(15);
        make.right.equalTo(wself.contentView.mas_right);
        make.top.equalTo(wself.cardNoLabel.mas_bottom).offset(0);
        make.height.mas_equalTo(heightLit);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.contentView.mas_left).offset(15);
        make.right.equalTo(wself.contentView.mas_right);
        make.top.equalTo(wself.moneyLabel.mas_bottom).offset(0);
        make.height.mas_equalTo(heightLit);
    }];
    
}


# pragma mask 4 getter
- (UILabel *)cardNoLabel {
    if (!_cardNoLabel) {
        _cardNoLabel = [UILabel new];
        _cardNoLabel.backgroundColor = [UIColor clearColor];
    }
    return _cardNoLabel;
}
- (UILabel *)moneyLabel {
    if (!_moneyLabel) {
        _moneyLabel = [UILabel new];
        _moneyLabel.backgroundColor = [UIColor clearColor];
    }
    return _moneyLabel;
}
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.backgroundColor = [UIColor clearColor];
    }
    return _timeLabel;
}

@end
