//
//  UserRegisterViewController.h
//  JLPay
//
//  Created by jielian on 15/8/6.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>


/*
 * 注册类型
 *  0: 新增注册(默认)
 *  1: 修改审核(未审核通过的)
 *  2: 修改信息(已审核通过的)
 */
typedef enum: NSUInteger {
    RegisterTypeNew,            // 新增注册(默认)
    RegisterTypeRefused,        // 修改审核(未审核通过的)
    RegisterTypeOldModify       // 修改信息(已审核通过的)
} RegisterType;


@interface UserRegisterViewController : UIViewController

/* 设置详细地址 */
- (void) setDetailAddr:(NSString*)detailAddr
            inProvince:(NSString*)province
               andCity:(NSString*)city
               andArea:(NSString*)area
           andAreaCode:(NSString*)areaCode;

/* 设置开户行-联行号 */
- (void) setBankNum:(NSString*)bankNum forBankName:(NSString*)bankName;

/* 加载历史注册信息 */
- (void) loadLastRegisterInfo:(NSDictionary*)lastRegisterInfo ;
    
// 注册类型
@property (nonatomic, assign) RegisterType registerType;


@end
