//
//  RgBasicInfoTableViewCell.m
//  TestForRegister
//
//  Created by jielian on 15/8/17.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "RgBasicInfoTableViewCell.h"


@interface RgBasicInfoTableViewCell ()<UITextFieldDelegate>
@property (nonatomic, strong) UILabel* flagInputLabel;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UITextField* textField;
@property (nonatomic) CGFloat fontSize;
@end



@implementation RgBasicInfoTableViewCell
@synthesize flagInputLabel = _flagInputLabel;
@synthesize titleLabel = _titleLabel;
@synthesize textField = _textField;
@synthesize mustBeInputed;


#pragma mask ---- UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text && textField.text.length > 0) {
        if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(textBeInputedInCellTitle:inputedText:)]) {
            [self.cellDelegate textBeInputedInCellTitle:self.titleLabel.text inputedText:textField.text];
        }
    }
}

// 获取输入的值
- (NSString*) textInputed {
    return self.textField.text;
}

// 设置标题
- (void) setTitleText:(NSString*)text {
    [self.titleLabel setText:text];
}
// 设置文本输入框提示信息
- (void) setTextPlaceholder:(NSString*)placeholder {
    [self.textField setPlaceholder:placeholder];
}


// 判断是否正在输入
- (BOOL) isTextEditing {
    return [self.textField isFirstResponder];
}
// 取消输入动作
- (void) endingTextEditing {
    [self.textField resignFirstResponder];
}


// 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
           andNeededInputFlag:(BOOL)flag
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.fontSize = 15.0;
        self.mustBeInputed = flag;
        [self.contentView addSubview:self.flagInputLabel];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.textField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // *
    CGFloat inset = 5;
    CGFloat midInset = inset*3;
    CGFloat rightInset = inset*2;
    CGRect iFrame = CGRectMake(inset, 0, inset* 2, self.frame.size.height);
    self.flagInputLabel.frame = iFrame;
    if (self.mustBeInputed) {
        [self.flagInputLabel setText:@"*"];
    } else {
        [self.flagInputLabel setText:@""];
    }
    // 标题
    iFrame.origin.x += iFrame.size.width;
    iFrame.size.width = self.frame.size.width/4.0;
    self.titleLabel.frame = iFrame;
    // 值
    iFrame.origin.x += iFrame.size.width + midInset;
    iFrame.origin.y = inset;
    iFrame.size.width = self.frame.size.width - iFrame.origin.x - rightInset;
    iFrame.size.height = self.frame.size.height - inset*2;
    self.textField.frame = iFrame;

}

#pragma mask ---- getter & setter
- (UILabel *)flagInputLabel {
    if (_flagInputLabel == nil) {
        _flagInputLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _flagInputLabel.textAlignment = NSTextAlignmentCenter;
        if (self.mustBeInputed) {
            _flagInputLabel.text = @"*";
            _flagInputLabel.textColor = [UIColor redColor];
        }
    }
    return _flagInputLabel;
}
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
    }
    return _titleLabel;
}
- (UITextField *)textField {
    if (_textField == nil) {
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.layer.cornerRadius = 5.0;
        _textField.layer.masksToBounds = YES;
        _textField.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _textField.layer.borderWidth = 0.5;
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 1)];
        [_textField setLeftView:view];
        [_textField setLeftViewMode:UITextFieldViewModeAlways];
        _textField.font = [UIFont systemFontOfSize:self.fontSize];
        [_textField setDelegate:self];
    }
    return _textField;
}

@end
