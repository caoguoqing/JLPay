//
//  AccountReceivedViewController.h
//  JLPay
//
//  Created by jielian on 16/5/20.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import <ReactiveCocoa.h>
#import "Define_Header.h"
#import "MBProgressHUD+CustomSate.h"
#import "VMAccountReceived.h"
#import "OrderDispatchListViewController.h"
#import "DownPullButton.h"

@interface AccountReceivedViewController : UIViewController
<UITableViewDelegate>
@property (nonatomic, strong) NSString* curDisplayedTime;

@property (nonatomic, strong) UIView* backView;
@property (nonatomic, strong) UILabel* labelNowTime;
@property (nonatomic, strong) UILabel* labelTitleMoney;
@property (nonatomic, strong) UILabel* labelAccountReceived;
@property (nonatomic, strong) UILabel* labelNoteDispatchOrder;
@property (nonatomic, strong) UIButton* buttonDispatchOrder;

@property (nonatomic, strong) DownPullButton* downPullBtn;
@property (nonatomic, strong) UITableView* settledListTBV;

@property (nonatomic, strong) MBProgressHUD* progressHud;

@property (nonatomic, strong) VMAccountReceived* vmAccountReceived;

@property (nonatomic, strong) NSTimer* timeCircle;

@property (nonatomic, strong) UIBarButtonItem* cancelBarBtn;

@end
