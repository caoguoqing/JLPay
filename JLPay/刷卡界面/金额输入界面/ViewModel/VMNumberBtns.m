//
//  VMNumberBtns.m
//  JLPay
//
//  Created by jielian on 16/7/18.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMNumberBtns.h"
#import "Define_Header.h"

static CGFloat const MoneyUnitLimited = 10000 * 10 * 100;         /* 金额上限限制单位: 10w */


@implementation VMNumberBtns

+ (instancetype)sharedNumberInput {
    static VMNumberBtns* numberBtns;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberBtns = [[VMNumberBtns alloc] init];
    });
    return numberBtns;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.intMoney = 0;
    }
    return self;
}



# pragma mask 3 IBAction

- (IBAction) clickedNumBtn:(UIButton*)sender {
    [sender setBackgroundColor:[UIColor clearColor]];
    
    switch (sender.tag) {
        case NumBtnKeyClear:
        {
            self.intMoney = 0;
        }
            break;
        case NumBtnKeyDelete:
        {
            if (self.intMoney > 0) {
                self.intMoney = self.intMoney / 10;
            }
        }
            break;

        default:
        {
            if (self.intMoney < MoneyUnitLimited) {
                self.intMoney = self.intMoney * 10 + (sender.tag % 10);
            }
        }
            break;
    }
}

- (IBAction) touchDown:(UIButton*)sender {
    [sender setBackgroundColor:[UIColor colorWithHex:HexColorTypeBlackGray alpha:0.8]];
}

- (IBAction) touchUpOutside:(UIButton*)sender {
    [sender setBackgroundColor:[UIColor clearColor]];
}

# pragma mask 4 getter

- (NSMutableArray *)keyNumBtns {
    if (!_keyNumBtns) {
        _keyNumBtns = [NSMutableArray array];
        /* 1-9 */
        for (int i = 1; i <= 9; i++) {
            UIButton* numItemBtn = [UIButton new];
            numItemBtn.tag = i;
            [numItemBtn setTitle:[NSString stringWithFormat:@"%d", i % 10] forState:UIControlStateNormal];
            [numItemBtn setTitleColor:[UIColor colorWithHex:HexColorTypeBlackBlue alpha:1] forState:UIControlStateNormal];
            [numItemBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            numItemBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
            [_keyNumBtns addObject:numItemBtn];
        }
        
        /* Clear */
        UIButton* clearItemBtn = [UIButton new];
        clearItemBtn.tag = NumBtnKeyClear;
        [clearItemBtn setTitle:@"C" forState:UIControlStateNormal];
        [clearItemBtn setTitleColor:[UIColor colorWithHex:HexColorTypeBlackBlue alpha:1] forState:UIControlStateNormal];
        [clearItemBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        clearItemBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [_keyNumBtns addObject:clearItemBtn];
        
        /* 0 */
        UIButton* zeroItemBtn = [UIButton new];
        zeroItemBtn.tag = NumBtnKey0;
        [zeroItemBtn setTitle:@"0" forState:UIControlStateNormal];
        [zeroItemBtn setTitleColor:[UIColor colorWithHex:HexColorTypeBlackBlue alpha:1] forState:UIControlStateNormal];
        [zeroItemBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        zeroItemBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [_keyNumBtns addObject:zeroItemBtn];
        
        /* Delete */
        UIButton* deleteItemBtn = [UIButton new];
        deleteItemBtn.tag = NumBtnKeyDelete;
        [deleteItemBtn setTitle:[NSString stringWithIconFontType:IconFontType_backspace] forState:UIControlStateNormal];
        [deleteItemBtn setTitleColor:[UIColor colorWithHex:HexColorTypeBlackBlue alpha:1] forState:UIControlStateNormal];
        [deleteItemBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        deleteItemBtn.titleLabel.font = [UIFont iconFontWithSize:20];
        
        [_keyNumBtns addObject:deleteItemBtn];
        
        
        for (UIButton* btn in _keyNumBtns) {
            [btn addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
            [btn addTarget:self action:@selector(touchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
            [btn addTarget:self action:@selector(clickedNumBtn:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    return _keyNumBtns;
}




@end
