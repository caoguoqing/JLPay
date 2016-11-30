//
//  MonthChooseBtnView.m
//  JLPay
//
//  Created by jielian on 16/5/4.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MonthChooseBtnView.h"

@implementation MonthChooseBtnView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubviews];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void) addSubviews {
    self.clipsToBounds = NO;
    self.tbvPulledDown = NO;
    self.backgroundColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:0.9];
    [self addSubview:self.curMonthBtn];
    [self addSubview:self.preSwitchBtn];
    [self addSubview:self.sufSwitchBtn];
    
    [self updateCurDateBtnTitleByDate:[NSString curDateString]];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat heightImageBtn = self.frame.size.height;
    CGFloat widthCurBtn = self.frame.size.width * 0.5;
    
    self.preSwitchBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:heightImageBtn scale:0.6]];
    self.sufSwitchBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:heightImageBtn scale:0.6]];

    NameWeakSelf(wself);
    [self.curMonthBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.mas_centerX);
        make.width.mas_equalTo(widthCurBtn);
        make.top.equalTo(wself.mas_top);
        make.bottom.equalTo(wself.mas_bottom);
        wself.curMonthBtn.titleLabel.font = [UIFont systemFontOfSize:[@"test" resizeFontAtHeight:wself.frame.size.height scale:0.5]];
    }];
    [self.preSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(heightImageBtn);
        make.height.mas_equalTo(heightImageBtn);
        make.centerY.equalTo(wself.mas_centerY);
        make.right.equalTo(wself.curMonthBtn.mas_left);
    }];
    [self.sufSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(wself.preSwitchBtn);
        make.centerY.equalTo(wself.preSwitchBtn.mas_centerY);
        make.left.equalTo(wself.curMonthBtn.mas_right);
    }];
}

# pragma mask 1 IBAction

- (IBAction) clickToExchangePreDate:(UIButton*)sender {
    NSString* nowDate = [[NSString curDateString] substringToIndex:4+2];
    NSString* curDate = [self curMonthOfCurDateBtn];
    NSString* lastMonth = [curDate lastMonth];
    if ([nowDate intervalWithOtherMonth:lastMonth] > 3) {
        [PublicInformation makeCentreToast:@"月份太久远了哦"];
        return;
    }
    [self updateCurDateBtnTitleByDate:lastMonth];
}

- (IBAction) clickToExchangeSufDate:(UIButton*)sender {
    NSString* nowDate = [[NSString curDateString] substringToIndex:4+2];
    NSString* curMonth = [self curMonthOfCurDateBtn];
    if (nowDate.integerValue == curMonth.integerValue) {
        [PublicInformation makeCentreToast:@"已是最近月份"];
        return;
    }
    [self updateCurDateBtnTitleByDate:[curMonth nextMonth]];
}

- (IBAction) clickToPullChooseDateView:(UIButton*)sender {
    self.tbvPulledDown = !self.tbvPulledDown;
}

// -- 更新时间按钮日期
- (void) updateCurDateBtnTitleByDate:(NSString*)date {
    [self.curMonthBtn setTitle:[NSString stringWithFormat:@"%@年%@月",
                                [date substringToIndex:4],
                                [date substringWithRange:NSMakeRange(4, 2)]]
                      forState:UIControlStateNormal];
}
// -- 提取格式化的日期: 从当前日期按钮
- (NSString*) curMonthOfCurDateBtn {
    NSString* curMonth = [self.curMonthBtn titleForState:UIControlStateNormal];
    return [NSString stringWithFormat:@"%@%@", [curMonth substringToIndex:4], [curMonth substringWithRange:NSMakeRange(4+1, 2)]];
}





# pragma mask 4 getter
- (UIButton *)preSwitchBtn {
    if (!_preSwitchBtn) {
        _preSwitchBtn = [UIButton new];
        [_preSwitchBtn addTarget:self action:@selector(clickToExchangePreDate:) forControlEvents:UIControlEventTouchUpInside];
        [_preSwitchBtn setTitle:[NSString fontAwesomeIconStringForEnum:FACaretLeft] forState:UIControlStateNormal];
        [_preSwitchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _preSwitchBtn;
}

- (UIButton *)sufSwitchBtn {
    if (!_sufSwitchBtn) {
        _sufSwitchBtn = [UIButton new];
        [_sufSwitchBtn addTarget:self action:@selector(clickToExchangeSufDate:) forControlEvents:UIControlEventTouchUpInside];
        [_sufSwitchBtn setTitle:[NSString fontAwesomeIconStringForEnum:FACaretRight] forState:UIControlStateNormal];
        [_sufSwitchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _sufSwitchBtn;
}

- (UIButton *)curMonthBtn {
    if (!_curMonthBtn) {
        _curMonthBtn = [UIButton new];
        [_curMonthBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_curMonthBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateHighlighted];
        [_curMonthBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateDisabled];
        [_curMonthBtn addTarget:self action:@selector(clickToPullChooseDateView:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _curMonthBtn;
}

@end
