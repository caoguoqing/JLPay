//
//  MLStepSegmentView.h
//  CustomViewMaker
//
//  Created by jielian on 2016/11/8.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLStepSegmentView : UIView

/* 选择的序号 */
@property (nonatomic, assign) NSInteger itemSelected;

/* 主题色 */
@property (nonatomic, strong) UIColor* tintColor;

/* 默认色 */
@property (nonatomic, strong) UIColor* normalColor;

/* 单步or多步 */
@property (nonatomic, assign) BOOL stepIsSingle;


- (instancetype) initWithTitles:(NSArray*)titles ;

@end
