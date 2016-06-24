//
//  VMHttpMposDetails.h
//  JLPay
//
//  Created by jielian on 16/5/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPInstance.h"
#import "TransDetailTBVCell.h"
#import <UIKit/UIKit.h>
#import "Define_Header.h"
#import "MMposDetails.h"

@interface VMHttpMposDetails : NSObject
<UITableViewDataSource>

@property (nonatomic, assign) CGFloat totalMoney;
@property (nonatomic, strong) HTTPInstance* http;
@property (nonatomic, strong) MMposDetails* detailsData;


- (void) requestDetailsOnBeginDate:(NSString*)beginDate
                        andEndDate:(NSString*)endDate
                        onFinished:(void (^) (void))finishedBlock
                           onError:(void (^) (NSError* error))errorBlock;



@end
