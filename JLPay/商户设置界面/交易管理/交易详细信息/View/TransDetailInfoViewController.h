//
//  TransDetailInfoViewController.h
//  JLPay
//
//  Created by jielian on 16/5/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define_Header.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"
#import "VMMposDetailInfo.h"
#import "VMOtherPayDetailInfo.h"
#import "TransDetailListViewController.h"

@interface TransDetailInfoViewController : UIViewController

@property (nonatomic, copy) NSString* platform;                     /* 明细列表界面转场前设置 */

@property (nonatomic, strong) UITableView* infoTableView;
@property (nonatomic, strong) UIImageView* logoImgView;

@property (nonatomic, strong) id dataSource;                        /* swipe or otherPay */

@end
