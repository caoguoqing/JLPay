//
//  VMAvilableBankListRequester.h
//  JLPay
//
//  Created by jielian on 16/7/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBankItem.h"

@class RACCommand;
@class RACSignal;


typedef void (^ oneceFilterKeyInputed) (void);

@interface VMAvilableBankListRequester : NSObject <UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong) RACCommand* cmdAviBankListRequesting;


# pragma mask : private properties

@property (nonatomic, strong) NSMutableArray* filteredBankList;         /* to display */

@property (nonatomic, copy) NSArray* bankListRequested;               /* dataSource got */

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, copy) oneceFilterKeyInputed filterKeyInputedBlock;

@property (nonatomic, strong) UIView* headerView;

@end
