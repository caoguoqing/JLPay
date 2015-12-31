//
//  CustomPickerView.m
//  JLPay
//
//  Created by jielian on 15/8/21.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "CustomPickerView.h"

@interface CustomPickerView()<UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) UIPickerView* pickerView;
@property (nonatomic, strong) UIButton* btnCancel;
@property (nonatomic, strong) UIButton* btnDone;
@property (nonatomic, strong) UIView* lineView;
@property (nonatomic, strong) UIView* midLeaveView;
@property (nonatomic, strong) NSDictionary* dataDict;   // keys: array0,array1,array2...
@property (nonatomic, strong) id<CustomPickerViewDelegate>delegate;

@end


@implementation CustomPickerView
@synthesize pickerView = _pickerView;
@synthesize btnCancel = _btnCancel;
@synthesize btnDone = _btnDone;
@synthesize dataDict;

#pragma mask ---- UIPickerViewDataSource, UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.dataDict.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSString* key = [NSString stringWithFormat:@"array%d",(int)component];
    NSArray* dataArray = [self.dataDict objectForKey:key];
    return dataArray.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString* key = [NSString stringWithFormat:@"array%d",(int)component];
    NSArray* dataArray = [self.dataDict objectForKey:key];
    return [dataArray objectAtIndex:row];
}

// 显示
- (void) showWithData:(NSDictionary*)dataDictionary {
    self.dataDict = dataDictionary;
    self.hidden = NO;
    [self.pickerView reloadAllComponents];
}

// 确定 / 取消
- (IBAction) touchTo:(UIButton*)sender {
    if ([sender.titleLabel.text isEqualToString:@"确定"]) {
        // 保存已选择的信息
        NSMutableDictionary* datasDict = [[NSMutableDictionary alloc] init];
        NSInteger componetCount = [self.pickerView numberOfComponents];
        for (int i = 0; i < componetCount; i++) {
            NSInteger rowIndex = [self.pickerView selectedRowInComponent:i];
            NSString* key = [NSString stringWithFormat:@"array%d",i];
            NSArray* dataArray = [self.dataDict objectForKey:key];
            [datasDict setObject:[dataArray objectAtIndex:rowIndex] forKey:[NSString stringWithFormat:@"array%d",i]];
        }
        // 将已选择的信息带出 delegate
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerViewDidChooseDatas:)]) {
            [self.delegate pickerViewDidChooseDatas:datasDict];
        }
    }
    self.dataDict = nil;
    self.hidden = YES;
}

#pragma mask ---- 初始化
// 初始化
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<CustomPickerViewDelegate>)idelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // 创建完成先隐藏
        self.hidden = YES;
        self.delegate = idelegate;
        [self addSubview:self.pickerView];
        [self addSubview:self.lineView];
        [self addSubview:self.btnCancel];
        [self addSubview:self.midLeaveView];
        [self addSubview:self.btnDone];
        self.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.7];
    }
    return self;
}
// 加载子视图
- (void)layoutSubviews {
    CGFloat btnHeight = 40.0;
    CGFloat inset = 10;
    CGFloat pickerHeight = self.pickerView.frame.size.height;
    CGFloat btnCancelWidth = [self.btnCancel.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:self.btnCancel.titleLabel.font forKey:NSFontAttributeName]].width + inset*2;
    CGFloat btnDoneWidth = [self.btnDone.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:self.btnDone.titleLabel.font forKey:NSFontAttributeName]].width + inset*2;
    // pickerView
    CGRect frame = CGRectMake(0, self.bounds.size.height - pickerHeight, self.bounds.size.width, pickerHeight);
    [self.pickerView setFrame:frame];
    // 分割线
    frame.origin.y -= 0.5;
    frame.size.height = 0.5;
    self.lineView.frame = frame;
    // 取消按钮
    frame.origin.y -= btnHeight;
    frame.size.width = btnCancelWidth;
    frame.size.height = btnHeight;
    self.btnCancel.frame = frame;
    // 间隔空白视图
    frame.origin.x += frame.size.width;
    frame.size.width = self.frame.size.width - btnCancelWidth - btnDoneWidth;
    self.midLeaveView.frame = frame;
    // 确定按钮
    frame.origin.x += frame.size.width;
    frame.size.width = btnDoneWidth;
    self.btnDone.frame = frame;
}


#pragma mask ---- getter & setter
- (UIPickerView *)pickerView {
    if (_pickerView == nil) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        [_pickerView setDataSource:self];
        [_pickerView setDelegate:self];
        [_pickerView setBackgroundColor:[UIColor whiteColor]];
    }
    return _pickerView;
}
- (UIButton *)btnDone {
    if (_btnDone == nil) {
        _btnDone = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnDone setBackgroundColor:[UIColor whiteColor]];
        [_btnDone setTitle:@"确定" forState:UIControlStateNormal];
        [_btnDone setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_btnDone addTarget:self action:@selector(touchTo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnDone;
}
- (UIButton *)btnCancel {
    if (_btnCancel == nil) {
        _btnCancel = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnCancel setBackgroundColor:[UIColor whiteColor]];
        [_btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [_btnCancel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnCancel addTarget:self action:@selector(touchTo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnCancel;
}
- (UIView *)lineView {
    if (_lineView == nil) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        [_lineView setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
    }
    return _lineView;
}
- (UIView *)midLeaveView {
    if (_midLeaveView == nil) {
        _midLeaveView = [[UIView alloc] initWithFrame:CGRectZero];
        [_midLeaveView setBackgroundColor: [UIColor whiteColor]];
    }
    return _midLeaveView;
}
@end
