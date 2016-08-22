//
//  VMBankBranchListRequester.h
//  JLPay
//
//  Created by 冯金龙 on 16/7/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBankBranchItem.h"

@class RACCommand;
@class RACSignal;



@interface VMBankBranchListRequester : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) RACCommand* cmdBankBranchListRequesting;

@property (nonatomic, copy) NSString* bankCode;

@property (nonatomic, copy) NSString* province;

@property (nonatomic, copy) NSString* city;

# pragma mask : private properties

@property (nonatomic, strong) NSMutableArray* filteredBankBranchList;         /* to display */

@property (nonatomic, copy) NSArray* bankBranchListRequested;                 /* dataSource got */

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, copy) void (^ filterKeyInputedBlock) (void);

@property (nonatomic, strong) UIView* headerView;

@end
