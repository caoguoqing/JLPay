//
//  VMBR_chooseRate.h
//  JLPay
//
//  Created by jielian on 16/8/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VMBR_chooseRate  : NSObject <UITableViewDataSource, UITableViewDelegate>

/* 多费率或多商户 */
@property (nonatomic, copy) NSString* typeSelected;

@property (nonatomic, copy) NSString* rateNameSelected;

@property (nonatomic, copy) NSString* rateCodeSelected;

@end
