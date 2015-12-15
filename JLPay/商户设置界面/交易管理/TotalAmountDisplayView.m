//
//  TotalAmountDisplayView.m
//  JLPay
//
//  Created by jielian on 15/7/28.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "TotalAmountDisplayView.h"

@interface TotalAmountDisplayView()
@property (nonatomic, strong) UILabel* totalAmountLabel;
@property (nonatomic, strong) UILabel* totalRowsLabel;
@property (nonatomic, strong) UILabel* sucRowsLabel;
@property (nonatomic, strong) UILabel* revokeRowsLabel;

@end


#define CellTextColor    [UIColor whiteColor];  // 文字颜色
#define BigNumberFont               40.0
#define TextDesFont                 12.0
#define NumberFont                  25.0
#define AmountFlagFont              20.0
#define LittleFont                  10.0
#define LeftInset                   10.0


@implementation TotalAmountDisplayView
@synthesize totalAmountLabel = _totalAmountLabel;
@synthesize totalRowsLabel = _totalRowsLabel;
@synthesize sucRowsLabel = _sucRowsLabel;
@synthesize revokeRowsLabel = _revokeRowsLabel;


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
- (void) setRevokeRows: (NSString*)totalAmount {
    self.revokeRowsLabel.text = totalAmount;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.totalAmountLabel.text = @"0.00";
        self.totalRowsLabel.text = @"0";
        self.sucRowsLabel.text = @"0";
        self.revokeRowsLabel.text = @"0";
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame1 = self.bounds;
    frame1.size.height *= 3.0/5.0;
    [self addSubview:[self makeView1:frame1]];
    
    frame1.origin.y += frame1.size.height;
    frame1.size.height = self.frame.size.height - frame1.size.height;
    [self addSubview:[self makeView2:frame1]];
}

- (UIView*) makeView1: (CGRect)frame {
    UIView* view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:64.0/255.0 blue:59.0/255.0 alpha:1.0];
    CGRect innerFrame = CGRectMake(LeftInset, 0, frame.size.width - LeftInset, frame.size.height / 4.0);
    // 今日交易总额
    UILabel* label = [[UILabel alloc] initWithFrame:innerFrame];
    label.text = @"交易总额 :";
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
    
    // 全部.值
    innerframe.origin.x = 0;
    innerframe.origin.y += innerframe.size.height;
    innerframe.size.height = curHeight - innerframe.size.height;
    self.totalRowsLabel.frame = innerframe;
    [view addSubview:self.totalRowsLabel];
    // 成功.值
    innerframe.origin.x += innerframe.size.width;
    self.sucRowsLabel.frame = innerframe;
    [view addSubview:self.sucRowsLabel];
    // 撤销.值
    innerframe.origin.x += innerframe.size.width;
    self.revokeRowsLabel.frame = innerframe;
    [view addSubview:self.revokeRowsLabel];
    
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


#pragma mask ::: getter & setter
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

@end
