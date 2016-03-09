//
//  PullListSegView.h
//  JLPay
//
//  Created by jielian on 16/3/3.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullListSegView : UIView


@property (nonatomic, strong) NSArray* dataSouces;

@property (nonatomic, assign) NSInteger selectedIndex;

//@property (nonatomic, assign) CGPoint triPoint;

- (instancetype) initWithDataSource:(NSArray*)dataSource;


- (void) showForSelection:(void (^) (NSInteger selectedIndex))selectedBlock;


@end
