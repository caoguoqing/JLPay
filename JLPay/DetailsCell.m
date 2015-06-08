//
//  DetailsCell.m
//  JLPay
//
//  Created by jielian on 15/6/8.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "DetailsCell.h"

@interface DetailsCell()
@property (nonatomic, strong) UILabel* amountLabel;
@property (nonatomic, strong) UILabel* cardNumberLabel;
@property (nonatomic, strong) UILabel* tranDateLabel;

@end


@implementation DetailsCell
@synthesize amountLabel = _amountLabel;
@synthesize cardNumberLabel = _cardNumberLabel;
@synthesize tranDateLabel = _tranDateLabel;



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.amountLabel];
        [self addSubview:self.cardNumberLabel];
        [self addSubview:self.tranDateLabel];

    }
    return self;
}

#pragma mask ::: 加载 cell 的子视图
- (void)layoutSubviews {
    CGFloat inset = 20.0;
    
    CGRect frame = self.bounds;
    frame.origin.x += inset;
    frame.size.width = (frame.size.width - inset * 2.0)/2.0;
    self.amountLabel.frame = frame;
//    self.amountLabel.backgroundColor = [UIColor greenColor];

    
    frame.origin.x += frame.size.width;
    frame.size.height /= 2.0;
    self.cardNumberLabel.frame = frame;
    self.cardNumberLabel.textAlignment = NSTextAlignmentRight;
//    self.cardNumberLabel.backgroundColor = [UIColor orangeColor];
    
    frame.origin.y += frame.size.height;
    self.tranDateLabel.frame = frame;
    self.tranDateLabel.textAlignment = NSTextAlignmentRight;

//    self.tranDateLabel.backgroundColor = [UIColor grayColor];
}

#pragma mask ::: 金额属性赋值
- (void) setAmount : (NSString*)amount {
    
}
#pragma mask ::: 卡号属性赋值
- (void) setCardNum : (NSString*)cardNum {
    
}
#pragma mask ::: 日期时间赋值
- (void) setDate : (NSString*)date {
    
}



#pragma  mask :: getter
- (UILabel *)amountLabel {
    if (_amountLabel == nil) {
        _amountLabel = [[UILabel alloc] init];
    }
    return _amountLabel;
}
- (UILabel *)cardNumberLabel {
    if (_cardNumberLabel == nil) {
        _cardNumberLabel = [[UILabel alloc] init];
    }
    return _cardNumberLabel;
}
- (UILabel *)tranDateLabel {
    if (_tranDateLabel == nil) {
        _tranDateLabel = [[UILabel alloc] init];
    }
    return _tranDateLabel;
}

@end
