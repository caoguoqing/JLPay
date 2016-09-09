//
//  VMBR_chooseProvinceAndCity.h
//  JLPay
//
//  Created by jielian on 16/8/30.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/* 标记 dataSource 是属于哪个tableView */
typedef NS_ENUM(NSInteger, VMBR_ENUM_ProvinceOrCity) {
    VMBR_ENUM_Province,
    VMBR_ENUM_City
};

@interface VMBR_chooseProvinceAndCity : NSObject <UITableViewDelegate, UITableViewDataSource>


/* 多费率或多商户 */
@property (nonatomic, copy) NSString* typeSelected;

@property (nonatomic, copy) NSString* provinceNameSelected;
@property (nonatomic, copy) NSString* provinceCodeSelected;

@property (nonatomic, copy) NSString* cityNameSelected;
@property (nonatomic, copy) NSString* cityCodeSelected;


- (void) updateProvincesOnFinished:(void (^) (void))finished ;

- (void) updateCitiesWithProvinceCode:(NSString*)provinceCode onFinished:(void (^) (void))finished;

- (NSInteger) rowIndexOfProvinceSelected;
- (NSInteger) rowIndexOfCitySelected;

@end
