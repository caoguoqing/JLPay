//
//  passwordView.h
//  CustomIOSAlertView
//
//  Created by 冯金龙 on 15/6/4.
//  Copyright (c) 2015年 Wimagguc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface passwordView : UIView
- (instancetype)initWithFrame:(CGRect)frame ;

#pragma mask ::: 密码添加一位字符
- (void) passwordAppendChar: (NSString*)aChar;

#pragma mask ::: 密码删除一位字符
- (void) passwordRemoveChar;

@end
