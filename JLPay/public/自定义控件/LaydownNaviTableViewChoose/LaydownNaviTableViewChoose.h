//
//  LaydownNaviTableViewChoose.h
//  JLPay
//
//  Created by jielian on 16/8/24.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>


/*****************************
 * 列表选择界面:背景黑色透明、占整屏、在navigation下面
 * 数据源由外部提供
 *****************************/


@interface LaydownNaviTableViewChoose : UIView

- (instancetype) initWithSuperView:(UIView*)superView;

- (void) show;
- (void) hide;


@property (nonatomic, strong) UITableView* dataTableView;

@end
