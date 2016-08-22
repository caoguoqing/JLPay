//
//  BankBranchListViewController.h
//  JLPay
//
//  Created by 冯金龙 on 16/7/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMBankBranchListRequester.h"


@interface BankBranchListViewController : UIViewController

@property (nonatomic, copy) void (^ selectedBlock) (NSDictionary* selectedNode);

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) UIBarButtonItem* doneBarBtn;

@property (nonatomic, strong) UIBarButtonItem* cancleBarBtn;

@property (nonatomic, strong) VMBankBranchListRequester* bankBranchListRequester;

@end
