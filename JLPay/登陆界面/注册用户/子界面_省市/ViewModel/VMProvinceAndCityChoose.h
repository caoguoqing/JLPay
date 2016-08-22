//
//  VMProvinceAndCityChoose.h
//  JLPay
//
//  Created by jielian on 16/7/7.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelAreaCodeSelector.h"
#import <UIKit/UIKit.h>

typedef enum {
    VMSU_areaTypeProvince = 10,             /* 省 */
    VMSU_areaTypeCity                       /* 市 */
} VMSU_areaType;

@interface VMProvinceAndCityChoose : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray* provinceListRequested;

@property (nonatomic, copy) NSArray* cityListRequested;

@property (nonatomic, assign) NSInteger provinceIndexPicked;

@property (nonatomic, assign) NSInteger cityIndexPicked;

- (void) resetCityDatasOnFinished:(void (^) (void))finished;

/* 监控的数据 */

@property (nonatomic, copy) NSString* provinceNamePicked;
@property (nonatomic, copy) NSString* provinceCodePicked;
@property (nonatomic, copy) NSString* cityNamePicked;
@property (nonatomic, copy) NSString* cityCodePicked;

@end
