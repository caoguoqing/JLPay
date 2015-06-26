//
//  TotalAmountCell.m
//  JLPay
//
//  Created by jielian on 15/6/8.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "TotalAmountCell.h"
@interface TotalAmountCell()
@property (nonatomic, strong) UILabel* totalAmountLabel;
@property (nonatomic, strong) UILabel* totalRowsLabel;
@property (nonatomic, strong) UILabel* sucRowsLabel;
@property (nonatomic, strong) UILabel* revokeRowsLabel;
//@property (nonatomic, strong) UILabel* flushRowsLabel;


@end


@implementation TotalAmountCell
@synthesize totalAmountLabel = _totalAmountLabel;
@synthesize totalRowsLabel = _totalRowsLabel;
@synthesize sucRowsLabel = _sucRowsLabel;
@synthesize revokeRowsLabel = _revokeRowsLabel;
//@synthesize flushRowsLabel = _flushRowsLabel;


#define CellTextColor    [UIColor whiteColor];  // 文字颜色
#define BigNumberFont               40.0
#define TextDesFont                 12.0
#define NumberFont                  25.0
#define AmountFlagFont              20.0
#define LittleFont                  10.0
#define LeftInset                   10.0

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.totalAmountLabel.text = @"0.00";
        self.totalRowsLabel.text = @"0";
        self.sucRowsLabel.text = @"0";
        self.revokeRowsLabel.text = @"0";
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat modalH = 384.0;
    
    CGRect frame = CGRectMake(0,
                              0,
                              self.bounds.size.width,
                              self.bounds.size.height*(232.0/modalH));

    [self addSubview:[self makeView1:frame]];
    
    frame.origin.y += frame.size.height;
    frame.size.height = self.bounds.size.height - frame.size.height;
    [self addSubview:[self makeView2:frame]];
    [super layoutSubviews];
}

- (UIView*) makeView1: (CGRect)frame {
    
    
    UIView* view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:64.0/255.0 blue:59.0/255.0 alpha:1.0];
    CGRect innerFrame = CGRectMake(LeftInset, 0, frame.size.width - LeftInset, frame.size.height / 4.0);
    // 今日交易总额
    UILabel* label = [[UILabel alloc] initWithFrame:innerFrame];
    label.text = @"今日交易总额 :";
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont boldSystemFontOfSize:TextDesFont];
    label.textColor = CellTextColor;
    [view addSubview:label];
    
    // self.totalAmountLabel
    innerFrame.origin.y += innerFrame.size.height;
    innerFrame.size.width = frame.size.width / 4.0 * 3.0 - LeftInset;
    innerFrame.size.height = frame.size.height - innerFrame.size.height;
    self.totalAmountLabel.frame = innerFrame;
    [view addSubview:self.totalAmountLabel];
    
    // ￥
    innerFrame.origin.x += innerFrame.size.width;
    innerFrame.origin.y += innerFrame.size.height / 4.0;
    innerFrame.size.width = 20;
    innerFrame.size.height *= 3.0/4.0;
    label = [[UILabel alloc] initWithFrame:innerFrame];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = CellTextColor;
    label.text = @"￥";
    label.font = [UIFont boldSystemFontOfSize:AmountFlagFont];
    [view addSubview:label];
    
    return view;
}
- (UIView*) makeView2: (CGRect)frame {
    UIView* view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:99.0/255.0 blue:91.0/255.0 alpha:1.0];
    CGRect innerframe = CGRectMake(LeftInset, 0, frame.size.width - LeftInset, frame.size.height / 3.0);
    
    
    // 交易笔数
    UILabel* label = [[UILabel alloc] initWithFrame:innerframe];
    label.text = @"交易笔数";
    label.textColor = CellTextColor;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont boldSystemFontOfSize:TextDesFont];
    [view addSubview:label];
    
    innerframe.origin.x = 0;
    innerframe.origin.y += innerframe.size.height;
    innerframe.size.width = frame.size.width/3.0;
    CGFloat curHeight = frame.size.height - innerframe.size.height;
    innerframe.size.height = (frame.size.height - innerframe.size.height)/3.0;
    
    // 全部
    label = [[UILabel alloc] initWithFrame:innerframe];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = CellTextColor;
    label.text = @"全部";
    label.font = [UIFont systemFontOfSize:LittleFont];
    [view addSubview:label];
    
    // 成功
    innerframe.origin.x += innerframe.size.width;
    label = [[UILabel alloc] initWithFrame:innerframe];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = @"消费";
    label.font = [UIFont systemFontOfSize:LittleFont];
    [view addSubview:label];
    
    // 撤销
    innerframe.origin.x += innerframe.size.width;
    label = [[UILabel alloc] initWithFrame:innerframe];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = @"撤销";
    label.font = [UIFont systemFontOfSize:LittleFont];
    [view addSubview:label];
    
    // 冲正
//    innerframe.origin.x += innerframe.size.width;
//    label = [[UILabel alloc] initWithFrame:innerframe];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.textColor = [UIColor whiteColor];
//    label.text = @"冲正";
//    label.font = [UIFont systemFontOfSize:LittleFont];
//    [view addSubview:label];

    // 全部.下面
    innerframe.origin.x = 0;
    innerframe.origin.y += innerframe.size.height;
    innerframe.size.height = curHeight - innerframe.size.height;
    self.totalRowsLabel.frame = innerframe;
    [view addSubview:self.totalRowsLabel];
    // 成功.下面
    innerframe.origin.x += innerframe.size.width;
    self.sucRowsLabel.frame = innerframe;
    [view addSubview:self.sucRowsLabel];
    // 撤销.下面
    innerframe.origin.x += innerframe.size.width;
    self.revokeRowsLabel.frame = innerframe;
    [view addSubview:self.revokeRowsLabel];
    // 冲正.下面
//    innerframe.origin.x += innerframe.size.width;
//    self.flushRowsLabel.frame = innerframe;
//    [view addSubview:self.flushRowsLabel];
    
    // 分割线
    CGFloat width = innerframe.size.width;
    innerframe.origin.x = 0 + innerframe.size.width;
    innerframe.origin.y += 3.0;
    innerframe.size.width = 0.5;
    innerframe.size.height -= 3.0 * 2;
    for (int i = 0; i<3; i++) {
        UIView* line = [[UIView alloc] initWithFrame:innerframe];
        line.backgroundColor = [UIColor whiteColor];
        [view addSubview:line];
        innerframe.origin.x += width;
    }
    
    return view;
}


#pragma mask ::: set 属性值

- (void) setTotalAmount: (NSString*)totalAmount {
    self.totalAmountLabel.text = totalAmount;
}
- (void) setTotalRows: (NSString*)totalRows {
    self.totalRowsLabel.text = totalRows;
}
- (void) setSucRows: (NSString*)totalAmount {
    self.sucRowsLabel.text = totalAmount;
}
//- (void) setFlushRows: (NSString*)flushRows {
//    self.flushRowsLabel.text = flushRows;
//}
- (void) setRevokeRows: (NSString*)totalAmount {
    self.revokeRowsLabel.text = totalAmount;
}



#pragma mask ::: getter
- (UILabel *)totalAmountLabel {
    if (_totalAmountLabel == nil) {
        _totalAmountLabel = [[UILabel alloc] init];
        _totalAmountLabel.textAlignment = NSTextAlignmentRight;
        _totalAmountLabel.textColor = [UIColor whiteColor];
        _totalAmountLabel.font = [UIFont boldSystemFontOfSize:BigNumberFont];
    }
    return _totalAmountLabel;
}
- (UILabel *)totalRowsLabel {
    if (_totalRowsLabel == nil) {
        _totalRowsLabel = [[UILabel alloc] init];
        _totalRowsLabel.textAlignment = NSTextAlignmentCenter;
        _totalRowsLabel.textColor = [UIColor whiteColor];
        _totalRowsLabel.font = [UIFont boldSystemFontOfSize:NumberFont];
    }
    return _totalRowsLabel;
}
- (UILabel *)sucRowsLabel {
    if (_sucRowsLabel == nil) {
        _sucRowsLabel = [[UILabel alloc] init];
        _sucRowsLabel.textColor = [UIColor whiteColor];
        _sucRowsLabel.textAlignment = NSTextAlignmentCenter;
        _sucRowsLabel.font = [UIFont boldSystemFontOfSize:NumberFont];
    }
    return _sucRowsLabel;
}
- (UILabel *)revokeRowsLabel {
    if (_revokeRowsLabel == nil) {
        _revokeRowsLabel = [[UILabel alloc] init];
        _revokeRowsLabel.textAlignment = NSTextAlignmentCenter;
        _revokeRowsLabel.textColor = [UIColor whiteColor];
        _revokeRowsLabel.font = [UIFont boldSystemFontOfSize:NumberFont];
    }
    return _revokeRowsLabel;
}
//- (UILabel *)flushRowsLabel {
//    if (_flushRowsLabel == nil) {
//        _flushRowsLabel = [[UILabel alloc] init];
//        _flushRowsLabel.textColor = [UIColor whiteColor];
//        _flushRowsLabel.textAlignment = NSTextAlignmentCenter;
//        _flushRowsLabel.font = [UIFont boldSystemFontOfSize:NumberFont];
//    }
//    return _flushRowsLabel;
//}



@end
