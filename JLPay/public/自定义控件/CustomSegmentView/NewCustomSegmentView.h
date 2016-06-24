//
//  NewCustomSegmentView.h
//  JLPay
//
//  Created by jielian on 16/6/6.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CustomSegmentViewStypeUnderLineUp,
    CustomSegmentViewStypeUnderLineDown,
    CustomSegmentViewStypeRect
}CustomSegmentViewStype;


@interface NewCustomSegmentView : UIView

# pragma mask : public

- (instancetype) initWithItems:(NSArray<NSString*>*)items;

@property (nonatomic, assign) CustomSegmentViewStype segmentType;   // 默认: CustomSegmentViewStypeUnderLine

@property (nonatomic, assign) NSInteger selectedItem;               // KVO

@property (nonatomic, strong) UIColor* tintColor;                   // 被选择的颜色: 遮罩+选择文本(默认红色)

@property (nonatomic, strong) UIColor* normalColor;                 // 文本颜色 (默认)

# pragma mask : private

@property (nonatomic, copy) NSArray<NSString*>* items;              // 标题组

@property (nonatomic, strong) NSMutableArray* itemButtons;          // 按钮组
@property (nonatomic, strong) NSMutableArray* itemSeperationViews;  // 分割组

@property (nonatomic, strong) CAShapeLayer* segMaskLayer;           // 指示图层

@end
