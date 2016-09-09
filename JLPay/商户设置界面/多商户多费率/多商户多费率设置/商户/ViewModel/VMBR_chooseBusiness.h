//
//  VMBR_chooseBusiness.h
//  JLPay
//
//  Created by jielian on 16/8/30.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VMBR_chooseBusiness : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString* businessName;

@property (nonatomic, copy) NSString* businessCode;

@property (nonatomic, copy) NSString* terminalCode;


@property (nonatomic, copy) NSString* rateType;
@property (nonatomic, copy) NSString* cityCode;

- (void) getBusinessListOnFinished:(void (^) (void))finishedBlock
                           onError:(void (^) (NSError* error))errorBlock;


- (NSInteger) rowBusinessIndexSelected;

@end
