//
//  JLPWDKeyBoardView.m
//  TestForJLPasswordView
//
//  Created by jielian on 16/8/15.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "JLPWDKeyBoardView.h"
#import "UIColor+HexColor.h"
#import "Masonry.h"
#import "NSString+Formater.h"
#import "NSString+IconFont.h"
#import "UIFont+IconFont.h"


@implementation JLPWDKeyBoardView

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
    for (UIButton* btn in self.numberBtns) {
        [self addSubview:btn];
    }
}


- (void)updateConstraints {
    
    __weak JLPWDKeyBoardView* wself = self;
    
    CGFloat inset = 7;
    CGFloat widthBtn = (self.frame.size.width - inset * 4) * 1/3.f;//self.frame.size.width * 1/3.f;
    CGFloat heightBtn = (self.frame.size.height - inset * 5) * 1/4.f;//self.frame.size.height * 1/4.f;
    
    for (int i = 0; i < self.numberBtns.count; i++) {
        UIButton* numbtn = [self.numberBtns objectAtIndex:i];
        if (numbtn.tag == 12) {
            numbtn.titleLabel.font = [UIFont iconFontWithSize:[NSString resizeFontAtHeight:heightBtn scale:0.45]];
        }
        [numbtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wself.mas_left).offset((i%3) * (widthBtn + inset) + inset);
            make.top.equalTo(wself.mas_top).offset((i/3) * (heightBtn + inset) + inset);
            make.width.mas_equalTo(widthBtn);
            make.height.mas_equalTo(heightBtn);
        }];
    }
    
    
    [super updateConstraints];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = [UIColor colorWithHex:0xeeeeee alpha:1];

}

/* 点击键盘按钮: */
- (IBAction) clickedNumerBtn:(UIButton*)numBtn {
    [numBtn setBackgroundColor:[UIColor whiteColor]];
    
    if (numBtn.tag == 10) {         // C: 清空
        self.numbersInputed = nil;
    }
    else if (numBtn.tag == 12) {    // -: 删除一个
        self.numbersInputed = (self.numbersInputed && self.numbersInputed.length > 0) ? ([self.numbersInputed substringToIndex:self.numbersInputed.length - 1]) : (nil);
    }
    else {                          // 0-9: 追加一个
        if (self.numbersInputed == nil) {
            self.numbersInputed = [numBtn titleForState:UIControlStateNormal];
        } else if ( self.numbersInputed.length < 6) {
            self.numbersInputed = [self.numbersInputed stringByAppendingString:[numBtn titleForState:UIControlStateNormal]];
        }
    }
}

- (IBAction) clickedDown:(UIButton*)sender {
    [sender setBackgroundColor:[UIColor colorWithHex:HexColorTypeBlackBlue alpha:0.4]];
}

- (IBAction) clickedOutSide:(UIButton*)sender {
    [sender setBackgroundColor:[UIColor whiteColor]];
}


# pragma mask 4 getter

- (NSArray *)numberBtns {
    if (!_numberBtns) {
        NSMutableArray* btns = [NSMutableArray array];
        for (int i = 1; i <= 12; i++) {
            UIButton* btn = [UIButton new];
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            NSString* title ;
            if (i < 10) {
                title = [NSString stringWithFormat:@"%d", i];
            }
            else if (i == 10) {
                title = @"C";
            }
            else if (i == 11) {
                title = @"0";
            }
            else if (i == 12) {
                title = [NSString stringWithIconFontType:IconFontType_backspace];
            }
            btn.tag = i;
            btn.backgroundColor = [UIColor whiteColor];
            btn.layer.cornerRadius = 5.f;
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithHex:HexColorTypeBlackBlue alpha:1] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(clickedNumerBtn:) forControlEvents:UIControlEventTouchUpInside];
            [btn addTarget:self action:@selector(clickedDown:) forControlEvents:UIControlEventTouchDown];
            [btn addTarget:self action:@selector(clickedOutSide:) forControlEvents:UIControlEventTouchUpOutside];
            
            [btns addObject:btn];
        }
        _numberBtns = [NSArray arrayWithArray:btns];
    }
    return _numberBtns;
}

@end
