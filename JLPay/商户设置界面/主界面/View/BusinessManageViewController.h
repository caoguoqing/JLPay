//
//  BusinessManageViewController.h
//  JLPay
//
//  Created by jielian on 16/6/20.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMBusinessFuncItems.h"
#import "BusinessTBVHeadView.h"

@interface BusinessManageViewController : UIViewController
<UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) VMBusinessFuncItems* businessFuncItems;
@property (nonatomic, strong) BusinessTBVHeadView* headView;

@end
