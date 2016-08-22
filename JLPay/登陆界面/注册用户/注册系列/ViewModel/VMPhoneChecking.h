//
//  VMPhoneChecking.h
//  JLPay
//
//  Created by jielian on 16/7/20.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMCheckNumTimer.h"

@class RACCommand;
@class RACSignal;

@interface VMPhoneChecking : NSObject

@property (nonatomic, copy) NSString* phoneNumber;

@property (nonatomic, copy) NSString* checkNumber;


@property (nonatomic, strong) RACCommand* cmdCheckNumberRequest;

@property (nonatomic, strong) RACSignal* sigNumberChecking;

@property (nonatomic, strong) VMCheckNumTimer* checkWaitingTimer;



@end
