//
//  TDVC_vmDataSource.h
//  JLPay
//
//  Created by jielian on 2017/1/19.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TLVC_mDetailMpos.h"
#import "TDVC_mItem.h"

@interface TDVC_vmDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, copy) TLVC_mDetailMpos* detaiNode;

@property (nonatomic, strong) NSArray<TDVC_mItem*>* titlesAndContexts;


@end
