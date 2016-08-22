//
//  MoneyInputViewController.h
//  JLPay
//
//  Created by jielian on 16/7/18.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchBtnsScrollView.h"
#import "VMSettlementInfoRequestor.h"


@interface MoneyInputViewController : UIViewController

@property (nonatomic, strong) UILabel* moneyLabel;                          /* 金额显示 */

@property (nonatomic, strong) UIButton* leftImgView;                        /* 左图片 */

@property (nonatomic, strong) UIButton* rightImgView;                       /* 右图片 */

@property (nonatomic, strong) SwitchBtnsScrollView* switchItemScrollView;   /* 切换滚动按钮 */

@property (nonatomic, strong) UIView* switchItemBackView;                   /* 切换背景图 */

@property (nonatomic, strong) NSMutableArray* seperatorViews;               /* 分割线组:按钮组的 */

@property (nonatomic, strong) VMSettlementInfoRequestor* vmStlmentInfo;     /* VM层: 获取结算信息 */

@end
