//
//  JLSigninInputView.m
//  JLPay
//
//  Created by jielian on 16/10/12.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "JLSigninInputView.h"
#import "Define_Header.h"

@implementation JLSigninInputView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void) loadSubviews {
    [self addSubview:self.iconLabel];
    [self addSubview:self.textField];
    [self addSubview:self.rightBtn];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat inset = self.frame.size.height * 0.5;
    CGFloat iconHeight = self.frame.size.height * 0.5;
    CGFloat insetVertical = (self.frame.size.height - iconHeight) * 0.5;
    
    CGRect frame = CGRectMake(inset, insetVertical, iconHeight, iconHeight);
    self.iconLabel.frame = frame;
    self.iconLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:iconHeight scale:1]];
    
    frame.origin.x = self.frame.size.width - inset - iconHeight;
    self.rightBtn.frame = frame;
    self.rightBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:iconHeight scale:1]];
    
    if (self.rightBtn.hidden) {
        frame.origin.x = 0;
        frame.size.width = self.frame.size.width;
    } else {
        frame.origin.x = inset + iconHeight;
        frame.size.width = self.frame.size.width - inset * 2 - iconHeight * 2;
    }
    frame.origin.y = 0;
    frame.size.height = self.frame.size.height;
    self.textField.frame = frame;
    self.textField.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:iconHeight scale:0.8]];

}


# pragma mask 4 getter

- (UILabel *)iconLabel {
    if (!_iconLabel) {
        _iconLabel = [UILabel new];
        _iconLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _iconLabel;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField new];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.textAlignment = NSTextAlignmentCenter;
    }
    return _textField;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [UIButton new];
    }
    return _rightBtn;
}

@end
