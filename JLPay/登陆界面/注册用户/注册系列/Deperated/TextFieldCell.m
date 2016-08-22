//
//  TextFieldCell.m
//  JLPay
//
//  Created by jielian on 15/10/12.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "TextFieldCell.h"
#import "PublicInformation.h"

@interface TextFieldCell()<UITextFieldDelegate>
{
    CGFloat fontSize;
    CGFloat rateTitle;
    CGFloat rateText;
}
@property (nonatomic, strong) UILabel* mustInputLabel;
@property (nonatomic, strong) UILabel* titleLabel;

@end


@implementation TextFieldCell


#pragma mask ---- UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    JLPrint(@"<<< DidEndEditing:[%@]",textField.text);
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewCell:didInputedText:)]) {
        [self.delegate tableViewCell:self didInputedText:textField.text];
    }

}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    JLPrint(@"<<< shouldChange:[%@], replacementString[%@]",textField.text, string);
    NSInteger oldLength = textField.text.length;
    NSInteger newLength = string.length;

    BOOL shouldChange = YES;
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        shouldChange = NO;
    }
    if (shouldChange) {
        
        NSMutableString* newString = [NSMutableString stringWithString:textField.text];
        if (oldLength + newLength > self.lengthLimit) {
            [newString replaceCharactersInRange:range withString:[string substringToIndex:self.lengthLimit - oldLength]];
            [textField setText:newString];
            
            shouldChange = NO;
        } else {
            [newString replaceCharactersInRange:range withString:string];
        }
        JLPrint(@"   <<< text.text + string = [%@], range[%@]", newString, NSStringFromRange(range));
//        if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewCell:didInputedText:)]) {
//            [self.delegate tableViewCell:self didInputedText:newString];
//        }
    }
    
    return shouldChange;
}


#pragma mask ---- 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        fontSize = 20.0;
        rateTitle = 2.0/5.0;
        rateText = 3.0/5.0;
        
        [self addSubview:self.mustInputLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.inputField];
    }
    return self;
}

#pragma mask ---- 获取文本
- (NSString *)text {
    return [self.inputField text];
}
#pragma mask ---- 激活输入
- (void) startInput {
    [self.inputField canBecomeFirstResponder];
    [self.inputField becomeFirstResponder];
}

#pragma mask ---- 禁止输入
- (void) disableInput {
    self.inputField.enabled = NO;
}


#pragma mask ---- 加载子视图
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat insetVertical = 5.0;
    CGFloat insetHorizantol = 15.0;
    
    CGFloat mustInputWidth = 8;
    CGFloat labelHeight = (self.frame.size.height - insetVertical*2)* rateTitle;
    
    // rateTitle 为标题
    CGRect inFrame = CGRectMake(insetHorizantol,
                                insetVertical,
                                mustInputWidth,
                                labelHeight);
    // 必输标记
    [self.mustInputLabel setFrame:inFrame];
    [self.mustInputLabel setFont:[self mustInputFontInFrame:inFrame]];
    
    // 标题
    inFrame.origin.x += inFrame.size.width;
    inFrame.size.width = self.frame.size.width - insetHorizantol - inFrame.size.width;
    [self.titleLabel setFrame:inFrame];
    [self.titleLabel setFont:[self newFontInFrame:inFrame]];
    
    // rateText 为输入框
    CGFloat fieldHeight = self.frame.size.height * rateText;
    inFrame.origin.y += inFrame.size.height;
    inFrame.size.height = fieldHeight;
    [self.inputField setFrame:inFrame];
    
}


/* 字体大小重置: 指定frame */
- (UIFont*) newFontInFrame:(CGRect)frame {
    CGSize sizeFont = [@"testText" sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize]
                                                                                  forKey:NSFontAttributeName]];
    return [UIFont systemFontOfSize:(frame.size.height/sizeFont.height * fontSize)];
}
- (UIFont*) mustInputFontInFrame:(CGRect)frame {
    CGSize sizeFont = [@"testText" sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize]
                                                                                  forKey:NSFontAttributeName]];
    return [UIFont systemFontOfSize:(frame.size.height/sizeFont.height * fontSize) + 2];
}


#pragma mask ---- getter
- (UILabel *)mustInputLabel {
    if (_mustInputLabel == nil) {
        _mustInputLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _mustInputLabel.text = @"*";
        _mustInputLabel.textColor = [PublicInformation returnCommonAppColor:@"red"];
        _mustInputLabel.textAlignment = NSTextAlignmentLeft;
        _mustInputLabel.hidden = YES;
    }
    return _mustInputLabel;
}
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor blueColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}
- (UITextField *)inputField {
    if (_inputField == nil) {
        _inputField = [[UITextField alloc] initWithFrame:CGRectZero];
        [_inputField setDelegate:self];
        [_inputField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_inputField setDelegate:self];
    }
    return _inputField;
}


#pragma mask ---- setter
- (void)setTitle:(NSString *)title {
    _title = title;
    [self.titleLabel setText:title];
}
- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    self.inputField.placeholder = placeHolder;
}
- (void)setTextInputed:(NSString *)textInputed {
    _textInputed = textInputed;
    self.inputField.text = textInputed;
}
- (void)setSecureTextEntry:(BOOL)secureTextEntry {
    _secureTextEntry = secureTextEntry;
    [self.inputField setSecureTextEntry:secureTextEntry];
}
- (void)setMustInput:(BOOL)mustInput {
    _mustInput = mustInput;
    [self.mustInputLabel setHidden:!mustInput];
}

@end
