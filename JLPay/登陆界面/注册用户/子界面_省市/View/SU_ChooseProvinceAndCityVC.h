//
//  SU_ChooseProvinceAndCityVC.h
//  JLPay
//
//  Created by jielian on 16/7/7.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMProvinceAndCityChoose.h"

@interface SU_ChooseProvinceAndCityVC : UIViewController

/* 回调 */
@property (nonatomic, copy) void (^ doneSelected) (NSString* provinceName, NSString* provinceCode, NSString* cityName, NSString* cityCode);


# pragma mask : private properties

@property (nonatomic, strong) UITableView* tableViewMain;
@property (nonatomic, strong) UITableView* tableViewAssistant;


@property (nonatomic, strong) UIBarButtonItem* doneBarBtnItem;
@property (nonatomic, strong) UIBarButtonItem* cancleBarBtnItem;

@property (nonatomic, strong) VMProvinceAndCityChoose* vmProAndCityDataSource;



@end
