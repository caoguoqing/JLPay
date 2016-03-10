//
//  CustomSegmentView.h
//  CustomViewMaker
//
//  Created by 冯金龙 on 16/3/4.
//  Copyright © 2016年 冯金龙. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    // 底线
    CustSegSelectedTypeUnderLine,
    // 单元格;有边框、有分割线、
    CustSegSelectedTypeSingleRect
} CustSegSelectedType; // 切换框类型

static NSString* const kKeyPathSegSelectedItem = @"selectedItem"; // KVO


@interface CustomSegmentView : UIView

- (instancetype) initWithItems:(NSArray*)items;

@property (nonatomic, assign) CustSegSelectedType selectedType;

@property (nonatomic, assign) BOOL canTurnOnSegment;        // 开关:允许切换

@property (nonatomic, strong) UIColor* textColor;           // defualt 0x262626
@property (nonatomic, strong) UIColor* textSelectedColor;   // default blue
@property (nonatomic, strong) UIColor* tintColor;           // default blue

// 已选择的序号;动态;
@property (nonatomic, assign) NSInteger selectedItem;


@end
