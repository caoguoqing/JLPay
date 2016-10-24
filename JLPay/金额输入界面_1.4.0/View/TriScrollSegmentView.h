//
//  TriScrollSegmentView.h
//  CustomViewMaker
//
//  Created by jielian on 16/9/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TriScrollSegmentView : UIScrollView


/* 序号 */
@property (nonatomic, assign) NSInteger curSegIndex;

/* 元素大小 */
@property (nonatomic, assign) CGSize itemSize;

/* 半圆形底部颜色 */
@property (nonatomic, strong) UIColor* backCircleColor;

/*
 NSDictionary<
     [key_name] : [value_type]
        imgName : <NSString>    图片名
          title : <NSString>    标题
     titleColor : <UIColor>     标题色
      backColor : <UIColor>     背景色
 >
 */
@property (nonatomic, copy) NSArray<NSDictionary*>* segInfos;


- (instancetype) initWithSegInfos:(NSArray*)segInfos
               andMidItemCliecked:(void (^) (void))midItemClicked;

@end
