//
//  DelegateForTextFieldControl.m
//  JLPay
//
//  Created by jielian on 16/6/14.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DelegateForTextFieldControl.h"

@implementation DelegateForTextFieldControl


# pragma mask 3 UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // 处理遮挡
    CGFloat textFieldBottom = textField.frame.origin.y + textField.frame.size.height;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat offset = ((screenHeight - textFieldBottom) < (216 + 35 + 20))?(216 + 35 + 20 - screenHeight + textFieldBottom):(0);
    
    if (self.pullViewUpFrontKeyBordByOffset) {
        self.pullViewUpFrontKeyBordByOffset(offset);
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // 处理取消键盘和回档
    if (self.pullViewUpFrontKeyBordByOffset) {
        self.pullViewUpFrontKeyBordByOffset(0);
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.pullViewUpFrontKeyBordByOffset) {
        self.pullViewUpFrontKeyBordByOffset(0);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == SignInTxtTaguserPwd) { // 密码限制输入8位
        if (textField.text.length < 8) {
            return YES;
        }
        else {
            if (string.length == 0) { /* 退格键 */
                return YES;
            } else {
                return NO;
            }
        }
    }
    else {
        return YES;
    }
}


@end
