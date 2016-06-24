//
//  DelegateForTextFieldControl.h
//  JLPay
//
//  Created by jielian on 16/6/14.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    SignInTxtTagUserName,
    SignInTxtTaguserPwd
} SignInTxtTag;

@interface DelegateForTextFieldControl : NSObject
<UITextFieldDelegate>

@property (nonatomic, copy) void (^ pullViewUpFrontKeyBordByOffset) (CGFloat offset);

@end
