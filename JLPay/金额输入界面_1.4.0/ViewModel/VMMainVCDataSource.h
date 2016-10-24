//
//  VMMainVCDataSource.h
//  JLPay
//
//  Created by jielian on 16/10/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 为主界面提供数据: 从各个数据源和缓存提取数据
 */


@interface VMMainVCDataSource : NSObject

+ (instancetype) dataSource;

/* 是否登录 */
@property (nonatomic, assign) BOOL logined;

/* 用户名 */
@property (nonatomic, copy) NSString* userName;

/* 结算方式 */
@property (nonatomic, copy) NSString* settleType;

/* 商户名 */
@property (nonatomic, copy) NSString* businessName;

/* 商户编码 */
@property (nonatomic, copy) NSString* businessCode;

/* 是否需要绑定设备 */
@property (nonatomic, assign) BOOL needBindDevice;

/* 是否绑定设备 */
@property (nonatomic, assign) BOOL deviceBinded;






/* 刷新数据 */
- (void) refrashData;

@end
