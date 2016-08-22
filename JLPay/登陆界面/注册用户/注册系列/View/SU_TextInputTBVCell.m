//
//  SU_TextInputTBVCell.m
//  JLPay
//
//  Created by 冯金龙 on 16/6/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "SU_TextInputTBVCell.h"
#import "Define_Header.h"
#import "Masonry.h"


@implementation SU_TextInputTBVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void) loadSubviews {
    [self addSubview:self.textField];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NameWeakSelf(wself);
    
    self.textLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:self.frame.size.height scale:0.38]];
    self.textField.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:self.frame.size.height scale:0.35]];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.textLabel.mas_right);
        make.top.equalTo(wself.mas_top);
        make.bottom.equalTo(wself.mas_bottom);
        make.right.equalTo(wself.mas_right).offset(- 15);
    }];
}



# pragma mask 4 getter 

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
        _textField.textAlignment = NSTextAlignmentRight;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.keyboardType = UIKeyboardTypeDefault;
    }
    return _textField;
}


@end
