//
//  SU_MobileCheckCell.m
//  JLPay
//
//  Created by jielian on 16/7/6.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "SU_MobileCheckCell.h"
#import "Define_Header.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>


@implementation SU_MobileCheckCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadSubviews];
        [self firstLayoutSuvbiews];
    }
    return self;
}

- (void)dealloc {
    JLPrint(@"---------- SU_MobileCheckCell 被释放了");
}


- (void) loadSubviews {
    [self addSubview:self.iconLabel];
    [self addSubview:self.textField];
    [self addSubview:self.reCheckBtn];
    [self addSubview:self.seperateView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.iconLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:self.frame.size.height scale:0.5]];
    self.textField.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:self.frame.size.height scale:0.35]];
    self.reCheckBtn.titleLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:self.frame.size.height scale:0.35]];

    NameWeakSelf(wself);
    [self.seperateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wself.reCheckBtn.mas_left);
    }];
    [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wself.seperateView.mas_left);
    }];

}

- (void) firstLayoutSuvbiews {
    NameWeakSelf(wself);
    
    [self.iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.mas_left).offset(5);
        make.top.equalTo(wself.mas_top);
        make.bottom.equalTo(wself.mas_bottom);
        make.width.equalTo(wself.mas_height);
    }];
    
    [self.reCheckBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wself.mas_right).offset(-15);
        make.centerY.equalTo(wself.mas_centerY);
        make.height.equalTo(wself.mas_height).multipliedBy(0.8);
        make.width.mas_equalTo([@"请输入验证码" resizeAtHeight:wself.frame.size.height scale:0.4].width);
    }];
    
    [self.seperateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wself.reCheckBtn.mas_left);
        make.centerY.equalTo(wself.mas_centerY);
        make.height.equalTo(wself.mas_height).multipliedBy(0.45);
        make.width.mas_equalTo(1);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.iconLabel.mas_right);
        make.top.equalTo(wself.mas_top);
        make.bottom.equalTo(wself.mas_bottom);
        make.right.equalTo(wself.seperateView.mas_left);
    }];

}



# pragma mask 4 getter

- (UILabel *)iconLabel {
    if (!_iconLabel) {
        _iconLabel = [UILabel new];
        _iconLabel.textAlignment = NSTextAlignmentCenter;
        _iconLabel.text = [NSString fontAwesomeIconStringForEnum:FAShield];
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

- (UIButton *)reCheckBtn {
    if (!_reCheckBtn) {
        _reCheckBtn = [UIButton new];
        _reCheckBtn.layer.cornerRadius = 5.f;
        [_reCheckBtn setTitle:@"获取验证码" forState:UIControlStateNormal];

        [_reCheckBtn setTitleColor:[UIColor colorWithHex:HexColorTypeBlackBlue alpha:1] forState:UIControlStateNormal];
        [_reCheckBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_reCheckBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.4] forState:UIControlStateDisabled];
                
    }
    return _reCheckBtn;
}

- (UIView *)seperateView {
    if (!_seperateView) {
        _seperateView = [UIView new];
        _seperateView.backgroundColor = [UIColor colorWithHex:HexColorTypeBlackGray alpha:0.3];
    }
    return _seperateView;
}

@end
