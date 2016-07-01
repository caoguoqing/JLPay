//
//  DeviceBindingViewController.h
//  JLPay
//
//  Created by jielian on 16/4/12.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCAlertView.h"
#import "DeviceVModel.h"
#import "Masonry.h"
#import "UIColor+HexColor.h"
#import "NSString+Formater.h"
#import <ReactiveCocoa.h>
#import "MLoginSavedResource.h"
#import "AppDelegate.h"
#import "TCPKeysVModel.h"
#import "PullListSegView.h"
#import "TerminalSelectorVModel.h"
#import "MBProgressHUD+CustomSate.h"
#import "ModelDeviceBindedInformation.h"
#import "ReconnectDeviceBtn.h"


@interface DeviceBindingViewController : UIViewController

@property (nonatomic, strong) TerminalSelectorVModel* terminalSelector;
@property (nonatomic, strong) DeviceVModel* deviceVModel;
@property (nonatomic, strong) TCPKeysVModel* tcpVModel;

@property (nonatomic, strong) MBProgressHUD* progressHud;
@property (nonatomic, strong) JCAlertView* alertView;
@property (nonatomic, strong) UITableView* deviceListTable;

@property (nonatomic, strong) UIBarButtonItem* doneBarBtn;
@property (nonatomic, strong) UIButton* rescanBtn;
@property (nonatomic, strong) UIButton* bindingButton;
@property (nonatomic, strong) UIButton* pullButton;

@property (nonatomic, strong) UILabel* terminalLabelPre;
@property (nonatomic, strong) UILabel* terminalLabel;
@property (nonatomic, strong) UIView* backView;
@property (nonatomic, strong) UIImageView* posImageView;
@property (nonatomic, strong) UILabel* stateLabel;
@property (nonatomic, strong) UILabel* deviceNameLabel;

@property (nonatomic, strong) PullListSegView* pullListSegView;

@end
