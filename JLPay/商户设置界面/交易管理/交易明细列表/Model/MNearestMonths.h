//
//  MNearestMonths.h
//  JLPay
//
//  Created by jielian on 16/5/16.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define_Header.h"
#import <UIKit/UIKit.h>

@interface MNearestMonths : NSObject
<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray* months;
@property (nonatomic, assign) NSInteger selectedIndex;

@end
