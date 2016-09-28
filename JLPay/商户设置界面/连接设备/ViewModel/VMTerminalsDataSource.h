//
//  VMTerminalsDataSource.h
//  JLPay
//
//  Created by jielian on 16/9/7.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VMTerminalsDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString* terminalSelected;

@property (nonatomic, strong) NSArray* terminalList;

@end
