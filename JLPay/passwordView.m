//
//  passwordView.m
//  CustomIOSAlertView
//
//  Created by 冯金龙 on 15/6/4.
//  Copyright (c) 2015年 Wimagguc. All rights reserved.
//

#import "passwordView.h"
#import "Define_Header.h"

@interface passwordView()
@property (nonatomic, strong) UILabel* label;
@property (nonatomic, strong) NSArray* arrayWithPasswordCharLabel;
@property (atomic, assign) int      pinCharCount;
@end



@implementation passwordView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        CGFloat inset = 7;
//        CGRect innerFrame = CGRectMake(frame.origin.x + inset, 0, frame.size.width - inset*2, (frame.size.height - inset*2)/2.0);
//        // 支付密码描述
//        [self makeLabel:innerFrame];
//        
//        // 分割线
//        innerFrame.origin.y += (frame.size.height - inset*2)/2.0;
//        innerFrame.size.height = 0.3;
//        [self addSubview:[self line:innerFrame]];
//        
//        // 密码显示框
//        innerFrame.origin.y += inset * 2 - 0.5;
//        innerFrame.size.height = (frame.size.height - inset*2)/2.0;
//        [self passwordDisplayedView:innerFrame];
        
        self.pinCharCount = 0;
    }
    return self;
}

#pragma mask ::: 构造子视图的frame
- (void)layoutSubviews {
    CGFloat inset = 7;
    CGRect innerFrame = CGRectMake(self.frame.origin.x + inset, 0, self.frame.size.width - inset*2, (self.frame.size.height - inset*2)/2.0);
    // 支付密码描述
    [self makeLabel:innerFrame];
    
    // 分割线
    innerFrame.origin.y += (self.frame.size.height - inset*2)/2.0;
    innerFrame.size.height = 0.3;
    [self addSubview:[self line:innerFrame]];
    
    // 密码显示框
    innerFrame.origin.y += inset * 2 - 0.5;
    innerFrame.size.height = (self.frame.size.height - inset*2)/2.0;
    [self passwordDisplayedView:innerFrame];
    
    // 注册密码显示 textField 的字符接收事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCharIntoPassword:) name:Noti_KeyboardNumberClicked object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteCharFromPassword:) name:Noti_keyboardDeleteClicked object:nil];

}

#pragma mask ::: 支付密码描述label
- (void) makeLabel: (CGRect)frame {
    self.label.frame = frame;
    self.label.text = @"请输入支付密码";
    self.label.textColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.label];

}

#pragma mask ::: 分割线
- (UIView*) line: (CGRect)frame {
    UIView* line = [[UIView alloc] initWithFrame:frame];
    line.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
    return line;
}

#pragma mask ::: 初始化6位密码框
- (void) passwordDisplayedView: (CGRect)frame {
    CGFloat borderWidth = 0.5;
    UIColor* borderColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    UIView* view = [[UIView alloc] initWithFrame:frame];
    CGFloat width = frame.size.width/self.arrayWithPasswordCharLabel.count ;

    
    CGRect subFrame = CGRectMake(0, 0, width, frame.size.height);
    for (int i = 0; i < self.arrayWithPasswordCharLabel.count; i++) {
        UITextField* subLabel = [self.arrayWithPasswordCharLabel objectAtIndex:i];
        subLabel.frame = subFrame;
        subLabel.enabled = NO;
        
        subLabel.secureTextEntry = YES;
        subLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:subLabel];
        
        subFrame.origin.x += width;
    }
    
    CGRect borderFrame = CGRectMake(width, 0, borderWidth, frame.size.height);
    for (int i = 0; i < self.arrayWithPasswordCharLabel.count - 1; i++) {
        UIView* line = [self lineView:borderFrame backgroundColor:borderColor];
        [view addSubview:line];
        borderFrame.origin.x += width;
    }
    
    [view.layer setBorderWidth:borderWidth];
    [view.layer setBorderColor:borderColor.CGColor];
    [view.layer setCornerRadius:4.0];
    view.backgroundColor = [UIColor whiteColor];
    [self addSubview:view];
}

- (UIView*) lineView: (CGRect)frame backgroundColor: (UIColor*)color {
    UIView* lieView = [[UIView alloc] initWithFrame:frame];
    lieView.backgroundColor = color;
    return lieView;
}


#pragma mask ::: 注册密码显示 textField 的字符接收事件
- (void) addCharIntoPassword : (NSNotification*)notification {
    if (self.pinCharCount >= 6) {
        return;
    }
    UITextField* textField = [self.arrayWithPasswordCharLabel objectAtIndex:self.pinCharCount];
    textField.text = (NSString*)notification.object;
    self.pinCharCount++;
}
- (void) deleteCharFromPassword : (NSNotification*)notification {
    if (self.pinCharCount < 1) {
        return;
    }
    UITextField* textField = [self.arrayWithPasswordCharLabel objectAtIndex:self.pinCharCount - 1];
    textField.text = nil;

    self.pinCharCount--;
}

#pragma mask ::: getter
- (UILabel *)label {
    if (_label == nil) {
        _label = [[UILabel alloc] init];
    }
    return _label;
}
- (NSArray *)arrayWithPasswordCharLabel {
    if (_arrayWithPasswordCharLabel == nil) {
        _arrayWithPasswordCharLabel = [NSArray arrayWithObjects:
                                       [[UITextField alloc] init],
                                       [[UITextField alloc] init],
                                       [[UITextField alloc] init],
                                       [[UITextField alloc] init],
                                       [[UITextField alloc] init],
                                       [[UITextField alloc] init],nil];
    }
    return _arrayWithPasswordCharLabel;
}


@end
