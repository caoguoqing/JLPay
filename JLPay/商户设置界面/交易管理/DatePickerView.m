//
//  DatePickerView.m
//  JLPay
//
//  Created by jielian on 15/7/29.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "DatePickerView.h"
#import "PublicInformation.h"

@interface DatePickerView()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, strong) UIPickerView* pickerView;     // picker
@property (nonatomic, strong) UIButton* sureButton;         // 确定按钮
@property (nonatomic, strong) UIButton* cancelButton;       // 取消按钮
@property (nonatomic, strong) NSMutableArray* years;        // dataSource:年份数组
@property (nonatomic, strong) NSMutableArray* months;       // dataSource:月份数组
@property (nonatomic, strong) NSMutableArray* days;         // dataSource:日期数组


@end


@implementation DatePickerView
@synthesize pickerView = _pickerView;
@synthesize sureButton = _sureButton;
@synthesize cancelButton = _cancelButton;
@synthesize years = _years;
@synthesize months = _months;
@synthesize days = _days;


- (instancetype)initWithFrame:(CGRect)frame andDate:(NSString *)date {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
        [self addSubview:self.pickerView];
        [self addSubview:self.sureButton];
        [self addSubview:self.cancelButton];
        [self initialPickerDataWithDate:date];
    }
    return self;
}


#pragma mask ---- UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger numberOfRows = 0;
    if (component == 0)
        numberOfRows = [self.years count];
    else if (component == 1)
        numberOfRows = [self.months count];
    else if (component == 2)
        numberOfRows = [self.days count];
    return numberOfRows;
}
#pragma mask ---- UIPickerViewDelegate
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* label = (UILabel*)view;
    if (label == nil) {
        label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:20];
    }
    NSString* title = nil;
    if (component == 0) {
        title = [self.years objectAtIndex:row];
    }
    else if (component == 1) {
        title = [self.months objectAtIndex:row];
    }
    else if (component == 2) {
        title = [self.days objectAtIndex:row];
    }
    label.text = title;
    return label;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 162 / 6.0;
}

- (void) initialPickerDataWithDate:(NSString*)ndate {
    // date formatter 20150729
    NSString* year = [ndate substringToIndex:4];
    NSString* month = [ndate substringWithRange:NSMakeRange(4, 2)];
    NSString* day = [ndate substringFromIndex:ndate.length - 2];

    [self.pickerView selectRow:[self.years indexOfObject:year] inComponent:0 animated:YES];
    [self.pickerView selectRow:[self.months indexOfObject:month] inComponent:1 animated:YES];
    [self.pickerView selectRow:[self.days indexOfObject:day] inComponent:2 animated:YES];
}

#pragma mask ------ 按钮点击事件
// 确定
- (IBAction) touchToBeSure:(id)sender {
    UIButton* button = (UIButton*)sender;
    [UIView animateWithDuration:0.2 animations:^{
        button.transform = CGAffineTransformIdentity;
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(datePickerView:didChoosedDate:)]) {
        NSString* year = [self.years objectAtIndex:[self.pickerView selectedRowInComponent:0]];
        NSString* month = [self.months objectAtIndex:[self.pickerView selectedRowInComponent:1]];
        NSString* day = [self.days objectAtIndex:[self.pickerView selectedRowInComponent:2]];
        [self.delegate datePickerView:self didChoosedDate:[NSString stringWithFormat:@"%@%@%@",year,month,day]];
    }
    [self removeFromSuperview];
    
}
// 取消
- (IBAction) touchToCancel:(id)sender {
    UIButton* button = (UIButton*)sender;
    [UIView animateWithDuration:0.2 animations:^{
        button.transform = CGAffineTransformIdentity;
    }];
    [self removeFromSuperview];
}
- (IBAction) touchDown:(id)sender {
    UIButton* button = (UIButton*)sender;
    [UIView animateWithDuration:0.2 animations:^{
        button.transform = CGAffineTransformMakeScale(0.95, 0.95);
    }];
    
}
- (IBAction) touchUpOutSide:(id)sender {
    UIButton* button = (UIButton*)sender;
    [UIView animateWithDuration:0.2 animations:^{
        button.transform = CGAffineTransformIdentity;
    }];
    
}


// 获取当前系统日期
- (NSString*) nowDate {
    NSString* nDate ;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    nDate = [dateFormatter stringFromDate:[NSDate date]];
    nDate = [nDate substringToIndex:8];
    return nDate;
}

// 加载子视图
- (void)layoutSubviews {
//    [super layoutSubviews];
    CGFloat pickerHeighth = 162;
    CGRect iFrame = CGRectMake(0,
                               self.frame.size.height - pickerHeighth,//self.pickerView.frame.size.height,
                               self.frame.size.width,
                               pickerHeighth);//self.pickerView.frame.size.height);

    
    // pickerView
    self.pickerView.frame = iFrame;

    // 分割线
    iFrame.origin.y -= 0.5;
    iFrame.size.height = 0.5;
    UIView* lineView = [[UIView alloc] initWithFrame:iFrame];
    lineView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [self addSubview:lineView];

    CGFloat cancelBtnWidth = [self.cancelButton.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:self.cancelButton.titleLabel.font forKey:NSFontAttributeName]].width + 8*2;
    CGFloat sureBtnWidth = [self.sureButton.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:self.sureButton.titleLabel.font forKey:NSFontAttributeName]].width + 8*2;
    CGFloat midLeaveViewWidth = self.bounds.size.width - cancelBtnWidth - sureBtnWidth;
    
    // 按钮:取消
    iFrame.origin.x = 0;
    iFrame.origin.y -= 40;
    iFrame.size.width = cancelBtnWidth;
    iFrame.size.height = 40;
    self.cancelButton.frame = iFrame;
    
    // 空白视图
    iFrame.origin.x += iFrame.size.width;
    iFrame.size.width = midLeaveViewWidth;
    UIView* view = [[UIView alloc] initWithFrame:iFrame];
    view.backgroundColor = self.cancelButton.backgroundColor;
    [self addSubview:view];
    
    // 确定按钮
    iFrame.origin.x +=  iFrame.size.width;
    iFrame.size.width = sureBtnWidth;
    self.sureButton.frame = iFrame;
}




#pragma mask ::: getter & setter 
- (UIPickerView *)pickerView {
    if (_pickerView == nil) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 162)];
        _pickerView.backgroundColor = [UIColor whiteColor];
        [_pickerView setShowsSelectionIndicator:YES];
        [_pickerView setDelegate:self];
        [_pickerView setDataSource:self];
    }
    return _pickerView;
}
- (UIButton *)sureButton {
    if (_sureButton == nil) {
        _sureButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton.titleLabel setTextAlignment:NSTextAlignmentRight];
        [_sureButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_sureButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_sureButton setBackgroundColor:[UIColor whiteColor]];
        [_sureButton addTarget:self action:@selector(touchToBeSure:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}
- (UIButton *)cancelButton {
    if (_cancelButton == nil) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        [_cancelButton addTarget:self action:@selector(touchToCancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}
- (NSMutableArray *)years {
    if (_years == nil) {
        _years = [[NSMutableArray alloc] init];
        NSString* ndate = [self nowDate];
        for (int date = 2015; date <= [ndate substringToIndex:4].intValue; date++) {
            [_years addObject:[NSString stringWithFormat:@"%d",date]];
        }
    }
    return _years;
}
- (NSMutableArray *)months {
    if (_months == nil) {
        _months = [[NSMutableArray alloc] init];
        for (int i = 0; i < 12; i++) {
            [_months addObject:[NSString stringWithFormat:@"%02d",i + 1]];
        }
    }
    return _months;
}
- (NSMutableArray *)days {
    if (_days == nil) {
        _days = [[NSMutableArray alloc] init];
        for (int i = 0; i < 31; i++) {
            [_days addObject:[NSString stringWithFormat:@"%02d",i + 1]];
        }
    }
    return _days;
}

@end
