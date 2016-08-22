//
//  VMT0CardListRequest.h
//  JLPay
//
//  Created by jielian on 16/7/12.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class RACCommand;

@interface VMT0CardListRequest : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) RACCommand* cmdRequesting;            /*  */

@property (nonatomic, copy) NSArray* cardListReqested;              /* 获取到的卡列表 */

@end
