//
//  AvilableBankListViewController.h
//  JLPay
//
//  Created by jielian on 16/7/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMAvilableBankListRequester.h"
#import "MBProgressHUD+CustomSate.h"




typedef void (^ doneWithSeleced) (NSDictionary* selectedNode);




@interface AvilableBankListViewController : UIViewController


@property (nonatomic, copy) doneWithSeleced selectedBlock;

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) UIBarButtonItem* doneBarBtn;

@property (nonatomic, strong) UIBarButtonItem* cancleBarBtn;

@property (nonatomic, strong) MBProgressHUD* progressHud;

@property (nonatomic, strong) VMAvilableBankListRequester* bankListRequester;

@end
