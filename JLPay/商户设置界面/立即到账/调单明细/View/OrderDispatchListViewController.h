//
//  OrderDispatchListViewController.h
//  JLPay
//
//  Created by jielian on 16/5/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define_Header.h"
#import "MonthChooseBtnView.h"
#import <MJRefresh.h>
#import <ReactiveCocoa.h>
#import "Masonry.h"
#import "BusinessVCRefreshButton.h"
#import "MBProgressHUD+CustomSate.h"
#import "MNearestMonths.h"
#import "VMDispatchList.h"


@interface OrderDispatchListViewController : UIViewController

@property (nonatomic, strong) MonthChooseBtnView* chooseMonthBtn;
@property (nonatomic, strong) BusinessVCRefreshButton* refreshBtn;
@property (nonatomic, strong) MBProgressHUD* progressHud;

@property (nonatomic, strong) VMDispatchList* dispatchListVM;

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UITableView* monthsTBV;
@property (nonatomic, strong) MNearestMonths* months;

@end
