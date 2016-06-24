//
//  CardCheckListCell.m
//  JLPay
//
//  Created by jielian on 16/6/22.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "CardCheckListCell.h"
#import "Masonry.h"

@implementation CardCheckListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.creditCardLabel];
        [self addSubview:self.cardNoLabel];
        [self addSubview:self.checkStateLabel];
        [self addSubview:self.cardCustName];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat inset = 5;
    self.creditCardLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:self.frame.size.height scale:0.5]];
    self.cardNoLabel.font = [UIFont boldSystemFontOfSize:[NSString resizeFontAtHeight:self.frame.size.height scale:0.45]];
    self.checkStateLabel.font = [UIFont systemFontOfSize:11];
    self.cardCustName.font = [UIFont systemFontOfSize:15];

    
    NameWeakSelf(wself);
    [self.creditCardLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.mas_left).offset(0);
        make.top.equalTo(wself.mas_top);
        make.bottom.equalTo(wself.mas_bottom);
        make.width.equalTo(wself.creditCardLabel.mas_height);
    }];
    [self.cardNoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.creditCardLabel.mas_right);
        make.right.equalTo(wself.mas_right);
        make.top.equalTo(wself.mas_top).offset(inset);
        make.bottom.equalTo(wself.mas_bottom).offset( - (inset + (wself.frame.size.height - inset * 2) * 0.4));
    }];
    [self.checkStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.cardNoLabel.mas_left);
        make.right.equalTo(wself.cardNoLabel.mas_right);
        make.top.equalTo(wself.cardNoLabel.mas_bottom);
        make.bottom.equalTo(wself.mas_bottom).offset(- inset);
    }];
    [self.cardCustName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wself.mas_right).offset(- inset * 2);
        make.width.mas_equalTo(100);
        make.top.equalTo(wself.cardNoLabel.mas_top);
        make.bottom.equalTo(wself.cardNoLabel.mas_bottom);
    }];
    
}


# pragma mask 4 getter

- (UILabel *)creditCardLabel {
    if (!_creditCardLabel) {
        _creditCardLabel = [UILabel new];
        _creditCardLabel.textAlignment = NSTextAlignmentCenter;
        _creditCardLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
        _creditCardLabel.text = [NSString fontAwesomeIconStringForEnum:FACreditCard];
        _creditCardLabel.backgroundColor = [UIColor clearColor];
    }
    return _creditCardLabel;
}

- (UILabel *)cardNoLabel {
    if (!_cardNoLabel) {
        _cardNoLabel = [UILabel new];
        _cardNoLabel.textAlignment = NSTextAlignmentLeft;
        _cardNoLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
        _cardNoLabel.backgroundColor = [UIColor clearColor];

    }
    return _cardNoLabel;
}

- (UILabel *)checkStateLabel {
    if (!_checkStateLabel) {
        _checkStateLabel = [UILabel new];
        _checkStateLabel.textAlignment = NSTextAlignmentLeft;
        _checkStateLabel.backgroundColor = [UIColor clearColor];

    }
    return _checkStateLabel;
}

- (UILabel *)cardCustName {
    if (!_cardCustName) {
        _cardCustName = [UILabel new];
        _cardCustName.textAlignment = NSTextAlignmentRight;
        _cardCustName.textColor = [UIColor colorWithHex:HexColorTypeDarkBlack alpha:1];
        _cardCustName.backgroundColor = [UIColor clearColor];

    }
    return _cardCustName;
}



@end
