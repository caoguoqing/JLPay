//
//  SU_MobileNumberCell.m
//  JLPay
//
//  Created by jielian on 16/7/6.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "SU_MobileNumberCell.h"
#import "Define_Header.h"
#import "Masonry.h"


@implementation SU_MobileNumberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void) loadSubviews {
    [self addSubview:self.iconLabel];
    [self addSubview:self.textField];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NameWeakSelf(wself);
    
    self.iconLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:self.frame.size.height scale:0.68]];
    self.textField.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:self.frame.size.height scale:0.35]];
    
    [self.iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.mas_left).offset(5);
        make.top.equalTo(wself.mas_top);
        make.bottom.equalTo(wself.mas_bottom);
        make.width.equalTo(wself.mas_height);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.iconLabel.mas_right);
        make.top.equalTo(wself.mas_top);
        make.bottom.equalTo(wself.mas_bottom);
        make.right.equalTo(wself.mas_right);
    }];
}


# pragma mask 4 getter

- (UILabel *)iconLabel {
    if (!_iconLabel) {
        _iconLabel = [UILabel new];
        _iconLabel.textAlignment = NSTextAlignmentCenter;
        _iconLabel.text = [NSString fontAwesomeIconStringForEnum:FAMobile];
        _iconLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackGray alpha:1];
    }
    return _iconLabel;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.keyboardType = UIKeyboardTypePhonePad;
    }
    return _textField;
}

@end
