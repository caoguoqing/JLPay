//
//  TransDetailTBVCell.m
//  JLPay
//
//  Created by jielian on 16/5/4.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "TransDetailTBVCell.h"

@implementation TransDetailTBVCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.moneyLabel];
        [self addSubview:self.transTypeLabel];
        [self addSubview:self.detailsLabel];
        [self addSubview:self.timeLabel];
    }
    return  self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat inset = 4;
    CGFloat heightBigLabel = self.frame.size.height * 0.5;
    CGFloat heightLitLabel = self.frame.size.height - heightBigLabel - inset * 2;
    CGFloat heightMidLabel = (self.frame.size.height - inset * 2) * 0.5;
    
    
    NameWeakSelf(wself);
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.mas_top).offset(inset);
        make.left.equalTo(wself.mas_left).offset(15);
        make.height.mas_equalTo(heightBigLabel);
        make.width.mas_equalTo([@"￥999999.99" resizeAtHeight:heightBigLabel scale:1].width + 15);
        wself.moneyLabel.font = [UIFont boldSystemFontOfSize:[wself.moneyLabel.text resizeFontAtHeight:heightBigLabel scale:1]];
    }];

    [self.transTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(wself.mas_bottom).offset(-inset);
        make.left.equalTo(wself.moneyLabel.mas_left);
        make.top.equalTo(wself.moneyLabel.mas_bottom).offset(0);
        make.width.mas_equalTo(wself.frame.size.width * 0.45);
        wself.transTypeLabel.font = [UIFont boldSystemFontOfSize:[wself.transTypeLabel.text resizeFontAtHeight:heightLitLabel scale:1]];
    }];

    [self.detailsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wself.mas_right).offset(-15);
        make.top.equalTo(wself.mas_top).offset(inset);
        make.width.mas_equalTo([wself.detailsLabel.text resizeAtHeight:heightMidLabel scale:1].width * 1.2);
        make.height.mas_equalTo(heightMidLabel);
        wself.detailsLabel.font = [UIFont systemFontOfSize:[wself.detailsLabel.text resizeFontAtHeight:heightMidLabel scale:0.8]];
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wself.detailsLabel.mas_right);
        make.top.equalTo(wself.detailsLabel.mas_bottom).offset(0);
        make.width.mas_equalTo([wself.timeLabel.text resizeAtHeight:heightMidLabel scale:1].width + 4);
        make.height.mas_equalTo(heightMidLabel);
        wself.timeLabel.font = [UIFont systemFontOfSize:[wself.timeLabel.text resizeFontAtHeight:heightMidLabel scale:0.8]];
    }];
    
}

# pragma mask 4 getter
- (UILabel *)moneyLabel {
    if (!_moneyLabel) {
        _moneyLabel = [UILabel new];
        _moneyLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
    }
    return _moneyLabel;
}
- (UILabel *)transTypeLabel {
    if (!_transTypeLabel) {
        _transTypeLabel = [UILabel new];
        _transTypeLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
    }
    return _transTypeLabel;
}
- (UILabel *)detailsLabel {
    if (!_detailsLabel) {
        _detailsLabel = [UILabel new];
        _detailsLabel.textAlignment = NSTextAlignmentRight;
        _detailsLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
    }
    return _detailsLabel;
}
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
    }
    return _timeLabel;
}

@end
