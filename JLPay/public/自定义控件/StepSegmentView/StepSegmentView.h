//
//  StepSegmentView.h
//  JLPay
//
//  Created by jielian on 16/8/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StepSegmentView : UIView


/* 选择的序号 */
@property (nonatomic, assign) NSInteger itemSelected;

/* 主题色 */
@property (nonatomic, strong) UIColor* tintColor;

/* 默认色 */
@property (nonatomic, strong) UIColor* normalColor;

/* 标题组: 只读 */
@property (nonatomic, copy) NSArray* titles;


- (instancetype) initWithTitles:(NSArray*)titles ;

@end
