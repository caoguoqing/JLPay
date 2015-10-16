//
//  DoubleFieldCell.m
//  JLPay
//
//  Created by 冯金龙 on 15/10/15.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "DoubleFieldCell.h"
#import "PublicInformation.h"


@interface DoubleFieldCell()<UITextFieldDelegate>
{
    CGFloat fontSize;
}
@property (nonatomic, strong) UILabel* mustInputLabel;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UITextField* bankMasterField;
@property (nonatomic, strong) UITextField* bankBranchField;
@property (nonatomic, strong) UIButton* searchButton;
@end

@implementation DoubleFieldCell

#pragma mask ------ UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL shouldChange = YES;
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        shouldChange = NO;
    }
    return shouldChange;
}

#pragma mask ------ 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        fontSize = 20;
        [self addSubview:self.mustInputLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.bankMasterField];
        [self addSubview:self.bankBranchField];
        [self addSubview:self.searchButton];
    }
    return self;
}

#pragma mask ------ 重载子视图布局
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat insetVertical = 5.0;
    CGFloat insetHorizantol = 15.0;
    CGFloat mustInputWidth = 8;
    CGFloat labelHeight = (50 - insetVertical*2) * 2.0/5.0;
    CGFloat fieldHeight = (50 - insetVertical*2) * 3.0/5.0;
    CGFloat btnHeight = 40;
    CGFloat btnWidth = 100;
    CGFloat fieldWidth = self.frame.size.width - insetHorizantol*2 - btnWidth - insetVertical;
    
    // 必输标记
    CGRect frame = CGRectMake(insetHorizantol, insetVertical, mustInputWidth, labelHeight);
    [self.mustInputLabel setFrame:frame];
    [self.mustInputLabel setFont:[self mustInputFontInFrame:frame]];
    // 标题
    frame.origin.x += frame.size.width;
    frame.size.width = fieldWidth;
    [self.titleLabel setFrame:frame];
    [self.titleLabel setFont:[self newFontInFrame:frame]];
    // 输入框: 行名
    frame.origin.y += frame.size.height + insetVertical;
    frame.size.height = fieldHeight;
    [self.bankMasterField setFrame:frame];
    // 输入框: 分支行关键字
    frame.origin.y += frame.size.height + insetVertical;
    [self.bankBranchField setFrame:frame];
    // 按钮: 查询
    frame.origin.x += frame.size.width + insetVertical;
    frame.origin.y = insetVertical + labelHeight + insetVertical;
    frame.origin.y += (self.frame.size.height - frame.origin.y - insetVertical - btnHeight)/2.0;
    frame.size.width = btnWidth;
    frame.size.height = btnHeight;
    [self.searchButton setFrame:frame];
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


#pragma mask ------ getter
- (UILabel *)mustInputLabel {
    if (_mustInputLabel == nil) {
        _mustInputLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _mustInputLabel.text = @"*";
        _mustInputLabel.textAlignment = NSTextAlignmentLeft;
        _mustInputLabel.textColor = [PublicInformation returnCommonAppColor:@"red"];
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
- (UITextField *)bankMasterField {
    if (_bankMasterField == nil) {
        _bankMasterField = [[UITextField alloc] initWithFrame:CGRectZero];
        [_bankMasterField setPlaceholder:@"请输入开户行银行名"];
        [_bankMasterField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_bankMasterField setDelegate:self];
    }
    return _bankMasterField;
}
- (UITextField *)bankBranchField {
    if (_bankBranchField == nil) {
        _bankBranchField = [[UITextField alloc] initWithFrame:CGRectZero];
        [_bankBranchField setPlaceholder:@"请输入分支行关键字"];
        [_bankBranchField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_bankBranchField setDelegate:self];
    }
    return _bankBranchField;
}
- (UIButton *)searchButton {
    if (_searchButton == nil) {
        _searchButton = [[UIButton alloc] initWithFrame:CGRectZero];
//        [_searchButton setTitle:@"查询" forState:UIControlStateNormal];
        [_searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_searchButton setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        _searchButton.layer.cornerRadius = 5.0;
    }
    return _searchButton;
}
#pragma mask ------ setter
- (void)setTitle:(NSString *)title {
    _title = title;
    [self.titleLabel setText:_title];
}
- (void)setBankNum:(NSString *)bankNum {
    _bankNum = bankNum;
    [self.searchButton setTitle:_bankNum forState:UIControlStateNormal];
}
@end
