//
//  WatingPayViewController.h
//  JLPay
//
//  Created by jielian on 16/4/27.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayStatusDisplayView.h"
#import "VMOtherPayType.h"
#import "VMHttpAlipay.h"
#import "VMHttpWechatPay.h"
#import "MBProgressHUD+CustomSate.h"
#import <ReactiveCocoa.h>


@interface WatingPayViewController : UIViewController
<UITableViewDelegate>

@property (nonatomic, assign) OtherPayType payType;

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) PayStatusDisplayView* payStatusHeaderView;
@property (nonatomic, strong) UIButton* doneButton;
@property (nonatomic, strong) UIButton* revokeButton;
@property (nonatomic, strong) MBProgressHUD* progressHud;

@property (nonatomic, strong) VMHttpAlipay* httpAlipay;
@property (nonatomic, strong) VMHttpWechatPay* httpWechat;
@end
