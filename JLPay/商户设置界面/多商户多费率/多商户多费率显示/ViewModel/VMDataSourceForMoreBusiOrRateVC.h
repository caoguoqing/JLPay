//
//  VMDataSourceForMoreBusiOrRateVC.h
//  JLPay
//
//  Created by jielian on 16/8/25.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBusiAndRateInfoReading.h"


@interface VMDataSourceForMoreBusiOrRateVC : NSObject
<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL moreBusinessesAndRates;

@property (nonatomic, copy) NSString* typeSelected;

/* 会根据当前的类型判断 */
@property (nonatomic, assign) BOOL hasSavedBusiOrRate;


/* -- 以下数据绑定在model -- */
@property (nonatomic, copy) NSString* businessNameSaved;
@property (nonatomic, copy) NSString* businessCodeSaved;
@property (nonatomic, copy) NSString* terminalCodeSaved;

@property (nonatomic, copy) NSString* rateNameSaved;
@property (nonatomic, copy) NSString* rateCodeSaved;

@property (nonatomic, copy) NSString* cityNameSaved;
@property (nonatomic, copy) NSString* cityCodeSaved;

@property (nonatomic, copy) NSString* provinceNameSaved;
@property (nonatomic, copy) NSString* provinceCodeSaved;


@property (nonatomic, strong) MBusiAndRateInfoReading* dataSource;


@end
