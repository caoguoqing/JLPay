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
@property (nonatomic, strong) UILabel* tranTimeLabel;
@property (nonatomic, strong) UILabel* tranTypeLabel;

@end


@implementation DetailsCell
@synthesize amountLabel = _amountLabel;
@synthesize cardNumberLabel = _cardNumberLabel;
@synthesize tranTimeLabel = _tranTimeLabel;
@synthesize tranTypeLabel = _tranTypeLabel;


#define AmountFont          20.0                // 金额字体大小
#define OtherFont           12.0                // 其他描述信息字体大小


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.amountLabel.text = @"0.00";
        self.cardNumberLabel.text = @"";
        self.tranTimeLabel.text = @"";
    }
    return self;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.amountLabel.text = @"0.00";
        self.cardNumberLabel.text = @"";
        self.tranTimeLabel.text = @"";
    }
    return self;
}


#pragma mask ::: 加载 cell 的子视图
- (void)layoutSubviews {
    CGFloat inset = 20.0;
    CGFloat verticalInset = self.bounds.size.height/3.0/2.0;    // 垂直方向的间隔
    
    // amount
    CGRect frame = self.bounds;
    frame.origin.x += inset;
    frame.origin.y = verticalInset/2.0;
    frame.size.width = (frame.size.width - inset * 2.0)/2.0 /*- 20这20为标示label腾出来*/;
    frame.size.height = (self.bounds.size.height - verticalInset)/ 2.0;  // 高度为 cell.height * 1/2
    self.amountLabel.frame = frame;
    [self addSubview:self.amountLabel];
//    self.amountLabel.backgroundColor = [UIColor orangeColor];
    
    // label:标示该笔交易的交易类型
    frame.origin.y += frame.size.height;
    self.tranTypeLabel.frame = frame;
    [self addSubview:self.tranTypeLabel];
//    self.tranTypeLabel.backgroundColor = [UIColor redColor];
    
    
    // cardNo.
    frame.origin.x += frame.size.width;
    frame.origin.y = 0 + verticalInset;
    frame.size.height = (self.frame.size.height -  verticalInset * 2.0)/2.0;
    self.cardNumberLabel.frame = frame;
    [self addSubview:self.cardNumberLabel];
//    self.cardNumberLabel.backgroundColor = [UIColor greenColor];
    
    
    // tranTime
    frame.origin.y += frame.size.height;
    self.tranTimeLabel.frame = frame;
    [self addSubview:self.tranTimeLabel];
//    self.tranTimeLabel.backgroundColor = [UIColor grayColor];
    [super layoutSubviews];
}

#pragma mask ::: 金额属性赋值 : 000000000010
- (void) setAmount : (NSString*)amount withColor:(UIColor *)color{
//    CGFloat fAmount = [amount floatValue];
//    fAmount /= 100.0;
//    self.amountLabel.text = [NSString stringWithFormat:@"￥ %.02f", fAmount];
    self.amountLabel.text = [NSString stringWithFormat:@"￥ %@",amount];
    self.amountLabel.textColor = color;
}
#pragma mask ::: 卡号属性赋值
- (void) setCardNum : (NSString*)cardNum {
    if (!cardNum || cardNum.length == 0) {
        return;
    }
    NSString* preNum = [cardNum substringToIndex:6];
    NSString* sufNum = [cardNum substringFromIndex:[cardNum length] - 4];
    self.cardNumberLabel.text = [[preNum stringByAppendingString:@"******"] stringByAppendingString:sufNum];
}
#pragma mask ::: 日期时间赋值 : 093412
- (void) setTime : (NSString*)time {
    if (!time || time.length == 0) {
        return;
    }
    self.tranTimeLabel.text = [NSString stringWithFormat:@"%@:%@:%@",
                               [time substringToIndex:2],
                               [time substringWithRange:NSMakeRange(2, 2)],
                               [time substringFromIndex:4]];
}
#pragma mask ::: 设置交易类型标记
- (void) setTranType:(NSString *)tranType withColor:(UIColor *)color{
    self.tranTypeLabel.text = tranType;
    self.tranTypeLabel.textColor = color;
}



#pragma  mask :: getter
- (UILabel *)amountLabel {
    if (_amountLabel == nil) {
        _amountLabel = [[UILabel alloc] init];
        _amountLabel.textAlignment = NSTextAlignmentLeft;
        _amountLabel.textColor = [UIColor colorWithRed:69.0/255.0 green:69.0/255.0 blue:69.0/255.0 alpha:1.0];
        _amountLabel.font = [UIFont boldSystemFontOfSize:AmountFont];
    }
    return _amountLabel;
}
- (UILabel *)cardNumberLabel {
    if (_cardNumberLabel == nil) {
        _cardNumberLabel = [[UILabel alloc] init];
        _cardNumberLabel.textAlignment = NSTextAlignmentRight;
        _cardNumberLabel.textColor = [UIColor colorWithRed:69.0/255.0 green:69.0/255.0 blue:69.0/255.0 alpha:1.0];
        _cardNumberLabel.font = [UIFont systemFontOfSize:OtherFont];
    }
    return _cardNumberLabel;
}
- (UILabel *)tranTimeLabel {
    if (_tranTimeLabel == nil) {
        _tranTimeLabel = [[UILabel alloc] init];
        _tranTimeLabel.textAlignment = NSTextAlignmentRight;
        _tranTimeLabel.textColor = [UIColor colorWithRed:69.0/255.0 green:69.0/255.0 blue:69.0/255.0 alpha:1.0];
        _tranTimeLabel.font = [UIFont systemFontOfSize:OtherFont];
    }
    return _tranTimeLabel;
}
- (UILabel *)tranTypeLabel {
    if (_tranTypeLabel == nil) {
        _tranTypeLabel = [[UILabel alloc] init];
        _tranTypeLabel.textAlignment = NSTextAlignmentLeft;
        _tranTypeLabel.textColor = [UIColor colorWithRed:69.0/255.0 green:69.0/255.0 blue:69.0/255.0 alpha:1.0];
        _tranTypeLabel.font = [UIFont systemFontOfSize:OtherFont ];
    }
    return _tranTypeLabel;
}

@end
