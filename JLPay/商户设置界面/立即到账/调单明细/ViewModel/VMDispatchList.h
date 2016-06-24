//
//  VMDispatchList.h
//  JLPay
//
//  Created by jielian on 16/5/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class HTTPInstance;

@interface VMDispatchList : NSObject
<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) NSInteger indexSelected;

@property (nonatomic, strong) HTTPInstance* http;
@property (nonatomic, copy) NSArray* dispatchList;
@property (nonatomic, strong) NSMutableArray* listSequenced;

- (void) requestingWithBeginDate:(NSString*)beginDate
                      andEndDate:(NSString*)endDate
                      onFinished:(void (^) (void))finished
                         onError:(void (^) (NSError* error))errorBlock;

- (void) terminateRequesting;

@end
