//
//  QRCodeViewController.h
//  JLPay
//
//  Created by jielian on 15/10/30.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OtherPayCollectViewController.h"
#import "Define_Header.h"
#import "MBProgressHUD+CustomSate.h"
#import "Masonry.h"
#import "VMWechatQRCodePay.h"
#import "VMOtherPayType.h"

@interface QRCodeViewController : UIViewController

@property (nonatomic, strong) UILabel* labelMoneyDisplay;
@property (nonatomic, strong) UILabel* labelGoodsName;
@property (nonatomic, strong) UILabel* labelLog;
@property (nonatomic, strong) UIImageView* imageViewQRCode;
@property (nonatomic, strong) UIImageView* imageViewPlatform;
@property (nonatomic, strong) UIActivityIndicatorView* activitor;
@property (nonatomic, strong) MBProgressHUD* progressHUD;

@property (nonatomic, strong) VMWechatQRCodePay* wechatQRCodePayer;

@property (nonatomic, strong) UIButton* doneButton;

@end
