//
//  VMSignUpManager.h
//  JLPay
//
//  Created by 冯金龙 on 16/6/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSignUpDataSource;
@class HTTPInstance;

@interface VMSignUpManager : NSObject

@property (nonatomic, strong) MSignUpDataSource* signUpDataSource;      //

@property (nonatomic, strong) HTTPInstance* signUpHttp;                 //

@end
