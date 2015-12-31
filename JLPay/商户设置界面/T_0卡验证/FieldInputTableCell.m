//
//  FieldInputTableCell.m
//  JLPay
//
//  Created by jielian on 15/12/29.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "FieldInputTableCell.h"

@interface FieldInputTableCell()
<UITextFieldDelegate>
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UITextField* fieldInput;

@end

@implementation FieldInputTableCell

#pragma mask 0 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.fieldInput];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat insetHorizantal = 15;
    CGFloat visableWidth = self.frame.size.width - insetHorizantal * 2;
    CGFloat widthLabel = visableWidth * 1.0/4.0;
    CGFloat widthField = visableWidth - widthLabel;
    CGFloat heightView = self.frame.size.height;
    
    CGRect frame = CGRectMake(insetHorizantal, 0, widthLabel, heightView);
    [self.titleLabel setFrame:frame];
    
    frame.origin.x += frame.size.width;
    frame.size.width = widthField;
    [self.fieldInput setFrame:frame];
}
- (void) setTitle:(NSString*)title {
    self.titleLabel.text = title;
}
- (void) setPlaceHolder:(NSString*)placeHolder {
    self.fieldInput.placeholder = placeHolder;
}
- (NSString*) textInputed {
    return self.fieldInput.text;
}

#pragma mask 3 UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mask 4 getter
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _titleLabel;
}
- (UITextField *)fieldInput {
    if (_fieldInput == nil) {
        _fieldInput = [[UITextField alloc] initWithFrame:CGRectZero];
        _fieldInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_fieldInput setDelegate:self];
    }
    return _fieldInput;
}


@end
