//
//  DynamicPickerView.h
//  JLPay
//
//  Created by jielian on 15/9/26.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DynamicPickerView;

#pragma mask == DynamicPickerViewDelegate
@protocol DynamicPickerViewDelegate <NSObject>
@required
// 已选取数据: 指定列
- (void) pickerView:(DynamicPickerView*)pickerView
       didPickedRow:(NSInteger)row
        atComponent:(NSInteger)component;


// 已选择数据: 指定列
- (void) pickerView:(DynamicPickerView *)pickerView
     didSelectedRow:(NSInteger)row
        atComponent:(NSInteger)component;

@end



@interface DynamicPickerView : UIView

@property (nonatomic, weak) id<DynamicPickerViewDelegate>delegate;
@property (nonatomic, strong) NSString* pickerType;

#pragma mask : 显示
- (void) show;
#pragma mask : 隐藏
- (void) hidden;

#pragma mask : 给指定列添加数据
- (void) setDatas:(NSArray*)datas atComponent:(NSInteger)component;
- (void) selectRow:(NSInteger)row atComponent:(NSInteger)component;

#pragma mask : 清理数据
- (void) clearDatas;

@end
