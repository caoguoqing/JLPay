//
//  MyBusinessViewController.h
//  JLPay
//
//  Created by jielian on 16/5/4.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMDataSourceMyBusiness.h"
#import "MBProgressHUD+CustomSate.h"
#import "JCAlertView.h"
#import "BusinessVCRefreshButton.h"


typedef enum {
    MyBusiAlertTagLogout,
    MyBusiAlertTagUpdateBusiness,
    MyBusiAlertTagReaplyBusinessInfo,
    MyBusiAlertTagUploadBusinessInfo
}MyBusiAlertTag;

@interface MyBusinessViewController : UIViewController
<UIAlertViewDelegate, UITableViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIButton* uploadBtn;
@property (nonatomic, strong) UIButton* reaplyBtn;

@property (nonatomic, strong) BusinessVCRefreshButton* refreshBtn;
@property (nonatomic, strong) VMDataSourceMyBusiness* dataSource;
@property (nonatomic, strong) MBProgressHUD* progressHud;

@end
