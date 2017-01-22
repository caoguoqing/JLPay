//
//  MLFiterView1Section.h
//  CustomViewMaker
//
//  Created by jielian on 2017/1/4.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLFilterView1Section : UIView

/* 特征色 */
@property (nonatomic, copy) UIColor* tintColor;

/* 默认色 */
@property (nonatomic, copy) UIColor* normalColor;

/* 被选索引号 */
@property (nonatomic, assign) NSInteger selectedIndex;

/* 背景色: cell */
@property (nonatomic, copy) UIColor* backgroundColorOfCell;

/* 是否展开 */
@property (nonatomic, assign) BOOL isSpread;

/* 初始化: 自动添加和卸载筛选器到指定视图控制器,默认是有导航器的;
 * @param superVC:              * 加载本筛选器的视图控制器
 */
- (instancetype) initWithSuperVC:(UIViewController*)superVC;


/* 显示筛选器: 带2个输入和3个响应回调;
 * @param items:                * 选项数据
 * @param completionBlock:      * 回调:选定序号
 * @param cancelBlock:          - 回调:取消
 */
- (void) showWithItems:(NSArray*) items
          onCompletion:(void (^) (NSInteger selectedIndex)) completionBlock
              onCancel:(void (^) (void)) cancelBlock;


/* 隐藏筛选器;
 */
- (void) hide;






@end
