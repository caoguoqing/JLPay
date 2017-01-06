//
//  BarCodeResultViewController.h
//  JLPay
//
//  Created by jielian on 15/11/9.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicInformation.h"
#import "VMOtherPayType.h"
#import "VMHttpAlipay.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"
#import "MBProgressHUD+CustomSate.h"
#import "JCAlertView.h"

@interface BarCodeResultViewController : UIViewController
{
    UIColor* colorLabelPre;
    UIColor* colorLabelDetail;
}


@property (nonatomic, strong) UIImageView* imageView;

@property (nonatomic, strong) UILabel* labelResult;
@property (nonatomic, strong) UILabel* labelMoney;
@property (nonatomic, strong) UILabel* labelGoodsName;

@property (nonatomic, strong) UILabel* labelOrderNoPre;
@property (nonatomic, strong) UILabel* labelOrderNo;
@property (nonatomic, strong) UILabel* labelBuyerIdPre;
@property (nonatomic, strong) UILabel* labelBuyerId;
@property (nonatomic, strong) UILabel* labelPayOrderPre;
@property (nonatomic, strong) UILabel* labelPayOrder;
@property (nonatomic, strong) UILabel* labelPayTimePre;
@property (nonatomic, strong) UILabel* labelPayTime;

@property (nonatomic, strong) UIButton* buttonDone;
@property (nonatomic, strong) UIButton* buttonRevoke;

@property (nonatomic, strong) id httpTransaction;

@end
