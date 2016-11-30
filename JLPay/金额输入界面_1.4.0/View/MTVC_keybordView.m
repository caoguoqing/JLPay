//
//  MTVC_keybordView.m
//  CustomViewMaker
//
//  Created by jielian on 16/9/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MTVC_keybordView.h"
#import "Masonry.h"
#import "Define_Header.h"



@interface MTVC_keybordView()

/* 按钮组 */
@property (nonatomic, strong) NSArray<UIButton*>* numberBtnList;

/* 按钮点击事件 */
@property (nonatomic, copy) void (^ numberBtnClickedBlock) (NSInteger number);

@end



@implementation MTVC_keybordView


- (instancetype) initWithClickedBlock: (void (^) (NSInteger number)) clickedBlock {
    self = [super init];
    if (self) {
        self.numberBtnClickedBlock = clickedBlock;
        [self loadSubviews];
    }
    return self;
}


- (void) loadSubviews {
    for (UIButton* numberBtn in self.numberBtnList) {
        [self addSubview:numberBtn];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (int i = 0; i < self.numberBtnList.count; i++) {
        UIButton* numberBtn = [self.numberBtnList objectAtIndex:i];
        numberBtn.layer.cornerRadius = numberBtn.frame.size.height * 0.5;
        [numberBtn setTitleColor:self.numBtnTextColor forState:UIControlStateNormal];
        numberBtn.backgroundColor = self.numBtnBackColor;
    }
}

- (void)updateConstraints {

    CGFloat inset = [UIScreen mainScreen].bounds.size.width * 9.f/320.f;
    UIView* lastNumber = nil;
    
    for (int i = 0; i < self.numberBtnList.count; i++) {
        UIView* number = [self.numberBtnList objectAtIndex:i];
        
        [number mas_updateConstraints:^(MASConstraintMaker *make) {
            if (i % 3 == 0) {
                make.left.mas_equalTo(inset);
            } else {
                make.left.mas_equalTo(lastNumber.mas_right).offset(inset);
            }
            if (i % 3 == 2) {
                make.right.mas_equalTo(- inset);
            }
            if (i / 3 == 0) {
                make.top.mas_equalTo(inset);
            } else {
                if (i % 3 == 0) {
                    make.top.mas_equalTo(lastNumber.mas_bottom).offset(inset);
                } else {
                    make.top.mas_equalTo(lastNumber.mas_top);
                }
            }
            if (i % 3 == 0 && i / 3 == 3) {
                make.bottom.mas_equalTo(- inset);
            }
            if (lastNumber) {
                make.width.mas_equalTo(lastNumber.mas_width);
                make.height.mas_equalTo(lastNumber.mas_height);
            }
        }];
        
        lastNumber = number;
    }
    
    [super updateConstraints];
}





# pragma mask 2 IBAction

- (IBAction) clickedNumBtnDown:(UIButton*)numBtn {
    numBtn.transform = CGAffineTransformMakeScale(0.9, 0.9);
}

- (IBAction) clickedNumBtnUpOutside:(UIButton*)numBtn {
    numBtn.transform = CGAffineTransformMakeScale(1, 1);
}

- (IBAction) clickedNumBtnUpInside:(UIButton*)numBtn {
    numBtn.transform = CGAffineTransformMakeScale(1, 1);
    if (self.numberBtnClickedBlock) {
        self.numberBtnClickedBlock(numBtn.tag);
    }
}


# pragma mask 4 getter

- (UIColor *)numBtnBackColor {
    if (!_numBtnBackColor) {
        _numBtnBackColor = [UIColor colorWithHex:0x27384b alpha:1];
    }
    return _numBtnBackColor;
}

- (UIColor *)numBtnTextColor {
    if (!_numBtnTextColor) {
        _numBtnTextColor = [UIColor whiteColor];
    }
    return _numBtnTextColor;
}

- (NSArray<UIButton *> *)numberBtnList {
    if (!_numberBtnList) {
        NSMutableArray* btnList = [NSMutableArray array];
        for (int i = MTVC_keybordNum1; i <= MTVC_keybordNumDel; i++) {
            UIButton* numberBtn = [UIButton new];
            
            NSString* title = [NSString stringWithFormat:@"%d", i];
            if (i == MTVC_keybordNumClear) {
                title = @"C";
            } else if (i == MTVC_keybordNum0) {
                title = @"0";
            } else if (i == MTVC_keybordNumDel) {
                title = [NSString stringWithIconType:IFTypeBackSpace];
            }
            numberBtn.tag = i;
            
            [numberBtn setTitle:title forState:UIControlStateNormal];
            [numberBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
            
            [numberBtn addTarget:self action:@selector(clickedNumBtnDown:) forControlEvents:UIControlEventTouchDown];
            [numberBtn addTarget:self action:@selector(clickedNumBtnUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
            [numberBtn addTarget:self action:@selector(clickedNumBtnUpInside:) forControlEvents:UIControlEventTouchUpInside];

            [btnList addObject:numberBtn];

            if (i == 12) {
                numberBtn.titleLabel.font = [UIFont iconFontWithSize:17];
            } else {
                numberBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            }
            
        }
        _numberBtnList = [NSArray arrayWithArray:btnList];
    }
    return _numberBtnList;
}



@end
