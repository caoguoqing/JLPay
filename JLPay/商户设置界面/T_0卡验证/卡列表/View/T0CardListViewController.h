//
//  T0CardListViewController.h
//  JLPay
//
//  Created by jielian on 16/7/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMT0CardListRequest.h"
#import <MJRefresh.h>
#import "MBProgressHUD+CustomSate.h"

@interface T0CardListViewController : UIViewController

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) UIBarButtonItem* additionBarBtnItem;

@property (nonatomic, strong) VMT0CardListRequest* cardListRequester;

@property (nonatomic, strong) MBProgressHUD* progressHud;

@end
