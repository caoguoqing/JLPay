//
//  TransDetailListViewController.h
//  JLPay
//
//  Created by jielian on 16/5/4.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TotalMoneyLabView.h"
#import "Define_Header.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>
#import <MJRefresh.h>
#import "MBProgressHUD+CustomSate.h"
#import "TransDetailInfoViewController.h"
#import "SiftViewController.h"
#import "NewCustomSegmentView.h"
#import "DownPullListBtn.h"

#import "MNearestMonths.h"
#import "VMHttpMposDetails.h"
#import "VMHttpOtherPayDetails.h"
#import "VMDelegateForTableView.h"


static NSString* const TransPlatformTypeSwipe = @"MPOS刷卡明细";
static NSString* const TransPlatformTypeOtherPay = @"微信消费明细";



@interface TransDetailListViewController : UIViewController


@property (nonatomic, strong) NewCustomSegmentView* platSegmentView;
@property (nonatomic, strong) DownPullListBtn* downPullBtn;

@property (nonatomic, strong) UITableView* nearestMonthsTBV;
@property (nonatomic, strong) MNearestMonths* nearestMonths;

@property (nonatomic, strong) UITableView* detailsTableView;
@property (nonatomic, strong) TotalMoneyLabView* totalMoneyLabelView;
@property (nonatomic, strong) MBProgressHUD* progressHud;

@property (nonatomic, strong) VMHttpMposDetails* mposDataSource;
@property (nonatomic, strong) VMHttpOtherPayDetails* otherPayDataSource;
@property (nonatomic, strong) VMDelegateForTableView* delegateForTBV;

@property (nonatomic, strong) UIWindow* siftWindow;
@property (nonatomic, strong) SiftViewController* siftViewCtr;

@property (nonatomic, strong) UIButton* backHomeBtn;
@property (nonatomic, strong) UIButton* filterBtn;

@end
