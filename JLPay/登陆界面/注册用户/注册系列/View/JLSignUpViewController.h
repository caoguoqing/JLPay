//
//  JLSignUpViewController.h
//  JLPay
//
//  Created by 冯金龙 on 16/6/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMSignUpPhotoPicker.h"

@class MBProgressHUD;

@interface JLSignUpViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, assign) NSInteger seperatedIndex;

@property (nonatomic, strong) UITableView* tableView;           /* 承载数据的表视图 */

@property (nonatomic, strong) UIBarButtonItem* nextBarBtn;      /* 下一步 or 注册 */

@property (nonatomic, strong) MBProgressHUD* progressHud;       /* 指示器 */

@property (nonatomic, retain) UIView* inputedCell;                /* 正在输入的文本框所在cell */

- (void) setFirstStep;

@end
