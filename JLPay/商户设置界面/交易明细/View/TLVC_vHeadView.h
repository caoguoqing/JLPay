//
//  TLVC_vHeadView.h
//  CustomViewMaker
//
//  Created by jielian on 2016/12/26.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLVC_vHeadView : UITableViewHeaderFooterView

/* 标题视图 */
@property (nonatomic, strong) UILabel* titleLabel;

/* 状态视图 */
@property (nonatomic, strong) UILabel* stateLabel;

/* 展开标示视图 */
@property (nonatomic, strong) UIButton* spreadBtn;


@end
