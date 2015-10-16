//
//  DatePickerView.h
//  JLPay
//
//  Created by jielian on 15/7/29.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DatePickerView;

@protocol DatePickerViewDelegate <NSObject>
@required
// 退出picker view后带出的选择完成的数据
- (void) datePickerView:(DatePickerView*)datePickerView didChoosedDate:(id)choosedDate;
@end


@interface DatePickerView : UIView
@property (nonatomic, weak) id<DatePickerViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame andDate:(NSString*)date;

@end


