//
//  CustomPickerView.h
//  JLPay
//
//  Created by jielian on 15/8/21.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CustomPickerView;
@protocol CustomPickerViewDelegate <NSObject>
/* 
 * 已选择的数据:
 *  1.component有几个就有几个元素
 *  2.每个元素只有一个key:value, key = array%d
 */
- (void) pickerViewDidChooseDatas:(NSDictionary*)dataDictionary;

@end



@interface CustomPickerView : UIView
// 初始化
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<CustomPickerViewDelegate>)idelegate;
/* 
 * 显示:可以显示多列数据的字典
 *  1.每个数组的key: array%d
 */
- (void) showWithData:(NSDictionary*)dataDictionary;
@end
