//
//  PullListSegView.h
//  JLPay
//
//  Created by jielian on 16/3/3.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullListSegView : UIView

@property (nonatomic, strong) NSArray* dataSouces;      // 数据源
@property (nonatomic, assign) NSInteger selectedIndex;  // 已选择索引
@property (nonatomic, strong) UIColor* tintColor;       // 背景色
@property (nonatomic, strong) UIColor* textColor;       // 字体颜色


- (instancetype) initWithDataSource:(NSArray*)dataSource;

- (void) showForSelection:(void (^) (NSInteger selectedIndex))selectedBlock;


@end
