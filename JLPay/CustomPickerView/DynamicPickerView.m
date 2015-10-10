//
//  DynamicPickerView.m
//  JLPay
//
//  Created by jielian on 15/9/26.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "DynamicPickerView.h"
#import <Foundation/Foundation.h>

@interface DynamicPickerView() <UIPickerViewDelegate, UIPickerViewDataSource>
{
    CGFloat fontSize ;
}

@property (nonatomic, strong) UIButton* btnSure;                    // 按钮: 确定
@property (nonatomic, strong) UIButton* btnCancel;                  // 按钮: 取消
@property (nonatomic, strong) UIView* seperatorView;                // 分割视图
@property (nonatomic, strong) UIColor* seperatorColor;              // 分割视图底色
@property (nonatomic, strong) UIPickerView* pickerView;             // 选择器:

@property (nonatomic, strong) NSMutableDictionary* dataSources;          // 数据源

@end


@implementation DynamicPickerView
@synthesize btnSure = _btnSure;
@synthesize btnCancel = _btnCancel;
@synthesize seperatorView = _seperatorView;
@synthesize seperatorColor;
@synthesize pickerView = _pickerView;
@synthesize dataSources = _dataSources;


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        fontSize = 15.0;
        self.seperatorColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        [self addSubview:self.btnSure];
        [self addSubview:self.btnCancel];
        [self addSubview:self.seperatorView];
        [self addSubview:self.pickerView];
        [self setHidden:YES];
        [self setBackgroundColor:[UIColor whiteColor]];
        self.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        self.layer.borderWidth = 0.5;
    }
    return self;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        fontSize = 15.0;
        self.seperatorColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        [self addSubview:self.btnSure];
        [self addSubview:self.btnCancel];
        [self addSubview:self.seperatorView];
        [self addSubview:self.pickerView];
        [self setHidden:YES];
        [self setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
    }
    return self;
}

#pragma mask : 显示
- (void) show {
    [self setHidden:NO];
}

#pragma mask : 隐藏
- (void) hidden {
    [self setHidden:YES];
}


#pragma mask : 给指定列添加数据
- (void) setDatas:(NSArray*)datas atComponent:(NSInteger)component {
    NSString* key = [NSString stringWithFormat:@"%ld",(long)component];
    if ([self.dataSources objectForKey:key] != nil) {
        [self.dataSources removeObjectForKey:key];
    }
    [self.dataSources setObject:datas forKey:key];
    [self.pickerView reloadAllComponents];
}

#pragma mask : 切换滚轮
- (void)selectRow:(NSInteger)row atComponent:(NSInteger)component {
    [self.pickerView selectRow:row inComponent:component animated:YES];
}

#pragma mask : 清理数据
- (void) clearDatas {
    [self.dataSources removeAllObjects];
    self.dataSources = nil;
    [self.pickerView reloadAllComponents];
    self.pickerType = nil;
}

#pragma mask : === 按钮事件组
/* 按下 */
- (IBAction) touchDown:(UIButton*)sender {
    sender.transform = CGAffineTransformMakeScale(0.95, 0.95);
}
/* 抬起:在外部: */
- (IBAction) touchOut:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
}
/* 抬起:在内部:确定 */
- (IBAction) touchToSure:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    [self hidden];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:didPickedRow:atComponent:)]) {
        for (int i = 0; i < self.pickerView.numberOfComponents; i++) {
            [self.delegate pickerView:self didPickedRow:[self.pickerView selectedRowInComponent:i] atComponent:i];
        }
    }
}
/* 抬起:在内部:取消 */
- (IBAction) touchToCancel:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    [self hidden];
}


#pragma mask : === UIPickerViewDelegate

/* 代理: 选择行 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:didSelectedRow:atComponent:)]) {
            [self.delegate pickerView:self didSelectedRow:row atComponent:component];
        }
    }
}

/* 代理: 行高 */
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return pickerView.frame.size.height/6.0;
}

/* 代理: 文字属性 */
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* textLabel = (UILabel*)view;
    if (textLabel == nil) {
        textLabel = [[UILabel alloc] init];
        textLabel.layer.cornerRadius = 5.0;
        textLabel.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = [UIFont systemFontOfSize:fontSize + 5];
    }
    NSArray* datas = [self.dataSources objectForKey:[NSString stringWithFormat:@"%ld",(long)component]];
    textLabel.text = [datas objectAtIndex:row];
    return textLabel;
}

#pragma mask : === UIPickerViewDataSource
/* 数据源: 列数 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    NSInteger number = self.dataSources.count;
    return number;
}

/* 数据源: 行数,指定列 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.dataSources.count <= component) {
        return 0;
    } else {
        NSArray* datas = [self.dataSources objectForKey:[NSString stringWithFormat:@"%ld",(long)component]];
        return datas.count;
    }
}


#pragma mask : === 解析出已选择的所有列的数据
- (NSArray*) arrayDatasPicked {
    NSMutableArray* arrayDatas = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.pickerView.numberOfComponents; i++) {
        NSString* key = [NSString stringWithFormat:@"%d",i];
        // get数组对象 from dictionary -> get字符串 from array;
        NSString* value = [[self.dataSources objectForKey:key] objectAtIndex:[self.pickerView selectedRowInComponent:i]];
        NSDictionary* dict = [NSDictionary dictionaryWithObject:value forKey:key];
        [arrayDatas addObject:dict];
    }
    return arrayDatas;
}

#pragma mask : === 子视图布局
- (void)layoutSubviews {
    CGSize sizeOfBtnTitle = [@"确定" sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize] forKey:NSFontAttributeName]];
    CGFloat widthBtn = sizeOfBtnTitle.width + 30;
    CGFloat heightBtn = 40;
    CGFloat heightPicker = self.frame.size.height - heightBtn;
    CGFloat widthPicker = self.frame.size.width;
    CGFloat widthSeperView = widthPicker - widthBtn * 2;
    
    CGRect inFrame = CGRectMake(0, 0, widthBtn, heightBtn);
    // 按钮: 取消
    [self.btnCancel setFrame:inFrame];
    // 分割视图
    inFrame.origin.x += inFrame.size.width;
    inFrame.size.width = widthSeperView;
    [self.seperatorView setFrame:inFrame];
    // 按钮: 确定
    inFrame.origin.x += inFrame.size.width;
    inFrame.size.width = widthBtn;
    [self.btnSure setFrame:inFrame];
    // 选择器
    inFrame.origin.x = 0;
    inFrame.origin.y += inFrame.size.height;
    inFrame.size.width = widthPicker;
    inFrame.size.height = heightPicker;
    [self.pickerView setFrame:inFrame];
}


#pragma mask : === GETTER
/* 按钮: 确定 */
- (UIButton *)btnSure {
    if (_btnSure == nil) {
        _btnSure = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnSure setTitle:@"确定" forState:UIControlStateNormal];
        [_btnSure setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_btnSure setBackgroundColor:self.seperatorColor];

        [_btnSure addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_btnSure addTarget:self action:@selector(touchOut:) forControlEvents:UIControlEventTouchUpOutside];
        [_btnSure addTarget:self action:@selector(touchToSure:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSure;
}
/* 按钮: 取消 */
- (UIButton *)btnCancel {
    if (_btnCancel == nil) {
        _btnCancel = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [_btnCancel setTitleColor:[UIColor colorWithWhite:0.2 alpha:1] forState:UIControlStateNormal];
        [_btnCancel setBackgroundColor:self.seperatorColor];
        
        [_btnCancel addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_btnCancel addTarget:self action:@selector(touchOut:) forControlEvents:UIControlEventTouchUpOutside];
        [_btnCancel addTarget:self action:@selector(touchToCancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnCancel;
}
// 分割视图
- (UIView *)seperatorView {
    if (_seperatorView == nil) {
        _seperatorView = [[UIView alloc] initWithFrame:CGRectZero];
        [_seperatorView setBackgroundColor:self.seperatorColor];
    }
    return _seperatorView ;
}

/* 选择器 */
- (UIPickerView *)pickerView {
    if (_pickerView == nil) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        [_pickerView setDelegate:self];
        [_pickerView setDataSource:self];
    }
    return _pickerView;
}

/* 动态数组: 数据源 */
- (NSMutableDictionary *)dataSources {
    if (_dataSources == nil) {
        _dataSources = [[NSMutableDictionary alloc] init];
    }
    return _dataSources;
}


@end
