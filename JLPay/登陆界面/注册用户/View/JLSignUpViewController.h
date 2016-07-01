//
//  JLSignUpViewController.h
//  JLPay
//
//  Created by 冯金龙 on 16/6/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLSignUpViewController : UIViewController

@property (nonatomic, strong) UITableView* tableView;           /* 承载数据的表视图 */

@property (nonatomic, strong) UIButton* signUpBtn;              /* 注册按钮(考虑到后期的'修改') */

@end
