//
//  MLFilterView2Section.h
//  CustomViewMaker
//
//  Created by jielian on 2016/12/8.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLFilterView2Section : UIView

/* 初始化: 自动添加和卸载筛选器到指定视图控制器,默认是有导航器的;
 * @param superVC:              * 加载本筛选器的视图控制器
 */
- (instancetype) initWithSuperVC:(UIViewController*)superVC;

/* 显示筛选器: 带2个输入和3个响应回调;
 * @param completionBlock:      * 回调:选定了数据(回调的是序号对应的BOOL值)
 * @param cancelBlock:          - 回调:取消
 */
- (void) showOnCompletion:(void (^) (NSArray<NSArray<NSNumber*>*>* subSelectedArray)) completionBlock
                 onCancel:(void (^) (void)) cancelBlock;


/* 隐藏筛选器;
 * @param hideCompletion:       - 回调:完成了动画
 */
- (void) hideOnCompletion:(void (^) (void))hideCompletion;


/* 重置筛选器 */
- (void) resetData;


# pragma mask -- 数据区

/* 特征色 */
@property (nonatomic, copy) UIColor* tintColor;

/* 默认色 */
@property (nonatomic, copy) UIColor* mainNormalColor;
@property (nonatomic, copy) UIColor* subNormalColor;


/* 是否展开 */
@property (nonatomic, assign) BOOL isSpread;

/* 主数据源组 */
@property (nonatomic, copy) NSArray* mainItems;
/* 副数据源组 */
@property (nonatomic, copy) NSArray<NSArray*>* subItems;
/* 数组: 副选项被选 init on subItems */
@property (nonatomic, strong) NSMutableArray* subSelectedArray;


@end
