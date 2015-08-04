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
@property (nonatomic, strong) NSMutableArray* months;        // dataSource:月份数组
@property (nonatomic, strong) NSMutableArray* days;        // dataSource:日期数组


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
        self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
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
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
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
    return title;
}

- (void) initialPickerDataWithDate:(NSString*)ndate {
    // date formatter 2015-07-29
    NSString* year = [ndate substringToIndex:4];
    NSString* month = [ndate substringWithRange:NSMakeRange(4+1, 2)];
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
        [self.delegate datePickerView:self didChoosedDate:[NSString stringWithFormat:@"%@-%@-%@",year,month,day]];
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
    [super layoutSubviews];    
    CGRect iFrame = CGRectMake(0,
                               self.frame.size.height - self.pickerView.frame.size.height,
                               self.frame.size.width,
                               self.pickerView.frame.size.height);

    
    // pickerView
    self.pickerView.frame = iFrame;

    // 年份，月份，日期标签
    iFrame.origin.y -= 30;
    iFrame.size.width /= 3.0;
    iFrame.size.height = 30;
    UILabel* label = [[UILabel alloc] initWithFrame:iFrame];
    label.backgroundColor = [UIColor whiteColor];
    label.text = @"年份";
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];

    iFrame.origin.x += iFrame.size.width;
    label = [[UILabel alloc] initWithFrame:iFrame];
    label.backgroundColor = [UIColor whiteColor];
    label.text = @"月份";
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
    iFrame.origin.x += iFrame.size.width;
    label = [[UILabel alloc] initWithFrame:iFrame];
    label.backgroundColor = [UIColor whiteColor];
    label.text = @"日期";
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];

    
    // 按钮:取消
    iFrame.origin.x = 0;
    iFrame.origin.y -= 45;
    iFrame.size.width = (self.frame.size.width /*- horizonInset*3*/)/2.0;
    iFrame.size.height = 45;
    self.cancelButton.frame = iFrame;
    // 确定按钮
    iFrame.origin.x +=  iFrame.size.width;
    self.sureButton.frame = iFrame;
}




#pragma mask ::: getter & setter 
- (UIPickerView *)pickerView {
    if (_pickerView == nil) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        _pickerView.backgroundColor = [UIColor whiteColor];
        [_pickerView setDelegate:self];
        [_pickerView setDataSource:self];
    }
    return _pickerView;
}
- (UIButton *)sureButton {
    if (_sureButton == nil) {
        _sureButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sureButton.backgroundColor = [PublicInformation returnCommonAppColor:@"red"];
        
        [_sureButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_sureButton addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_sureButton addTarget:self action:@selector(touchToBeSure:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}
- (UIButton *)cancelButton {
    if (_cancelButton == nil) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateNormal];
        _cancelButton.backgroundColor = [UIColor grayColor];
        
        [_cancelButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_cancelButton addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_cancelButton addTarget:self action:@selector(touchToCancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}
- (NSMutableArray *)years {
    if (_years == nil) {
        _years = [[NSMutableArray alloc] init];
        NSString* ndate = [self nowDate];
        for (int i = [[ndate substringToIndex:4] intValue]; i >= 2015; i--) {
            [_years addObject:[NSString stringWithFormat:@"%d",i]];
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
