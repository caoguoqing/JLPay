//
//  T0CardUploadViewController.h
//  JLPay
//
//  Created by jielian on 16/7/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMT0CardUploadHttp.h"
#import "VMForT0UploadTBV.h"
#import "MBProgressHUD+CustomSate.h"


@interface T0CardUploadViewController : UIViewController

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) UIBarButtonItem* uploadBarBtnItem;

@property (nonatomic, strong) MBProgressHUD* progressHud;

@property (nonatomic, retain) UITableViewCell* inputedCell;

@property (nonatomic, strong) VMT0CardUploadHttp* uploadHttp;

@property (nonatomic, strong) VMForT0UploadTBV* dataSource;

@end
