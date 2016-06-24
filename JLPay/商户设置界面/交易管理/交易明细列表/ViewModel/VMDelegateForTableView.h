//
//  VMDelegateForTableView.h
//  JLPay
//
//  Created by jielian on 16/5/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TransDetailTBVHeader.h"
#import "Define_Header.h"
#import "MMposDetails.h"
#import "MOtherPayDetails.h"

@interface VMDelegateForTableView : NSObject

<UITableViewDelegate>

@property (nonatomic, copy) void (^ selectedBlock) (NSInteger selectedIndex);

@property (nonatomic, copy) NSString* platform;

@end
