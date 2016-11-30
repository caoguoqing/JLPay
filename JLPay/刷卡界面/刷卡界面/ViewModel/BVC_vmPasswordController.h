//
//  BVC_vmPasswordController.h
//  JLPay
//
//  Created by jielian on 2016/11/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACCommand;

@interface BVC_vmPasswordController : NSObject

@property (nonatomic, copy) NSString* passwordPin;

@property (nonatomic, strong) RACCommand* cmd_passwordInputting;

@end
