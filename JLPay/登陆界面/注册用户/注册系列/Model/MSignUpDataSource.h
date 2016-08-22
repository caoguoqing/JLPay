//
//  MSignUpDataSource.h
//  JLPay
//
//  Created by 冯金龙 on 16/6/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSignUpItem.h"


/* 0: 手机验证 */
static NSString* const kSUCellTitleMobilePhone          = @"手机号码";
static NSString* const kSUCellTitleCheckNo              = @"验证码";

/* 1: 登陆密码 */
static NSString* const kSUCellTitleUserPwd              = @"登录密码";
static NSString* const kSUCellTitleConfirmPwd           = @"确认密码";

/* 2: 商户信息 */
static NSString* const kSUCellTitleBusinessName         = @"商户名称";
static NSString* const kSUCellTitleProvinceAndCity      = @"省/市";
static NSString* const kSUCellTitleDetailAddr           = @"详细地址";
static NSString* const kSUCellTitleDeviceSN             = @"绑定设备SN号";

/* 3: 结算信息 */
static NSString* const kSUCellTitleAccountName          = @"账户名";
static NSString* const kSUCellTitleAccountNum           = @"账号";
static NSString* const kSUCellTitleUserID               = @"身份证号";

/* 4: 结算卡分支行 */
static NSString* const kSUCellTitleBankName             = @"银行名称";
static NSString* const kSUCellTitleBankBranch           = @"分支行";

/* 5: 证件上传 */
static NSString* const kSUCellTitleIDPhotoFore          = @"上传身份证照(正面)";
static NSString* const kSUCellTitleIDPhotoBack          = @"上传身份证照(反面)";
static NSString* const kSUCellTitleIDPhotoHandle        = @"上传手持身份证照(正面)";
static NSString* const kSUCellTitleDebitCardFore        = @"上传结算银行卡照(正面)";


/* -- 标题 */
static NSString* kSignUpItemsTitleMobileCheck       = @"手机验证";
static NSString* kSignUpItemsTitlePassword          = @"登录密码";
static NSString* kSignUpItemsTitleBusinessInfo      = @"商户信息";
static NSString* kSignUpItemsTitleStlInfo           = @"结算信息";
static NSString* kSignUpItemsTitleStlBankBranch     = @"结算卡分支行";
static NSString* kSignUpItemsTitleCerUpload         = @"证件上传";



@interface MSignUpDataSource : NSObject

@property (nonatomic, strong) NSArray* itemsTitles;                     /* 单元组的标题 */

@property (nonatomic, strong) NSMutableDictionary* itemsGroup;          /* {标题:单元组} 每个value是一个二维数组 */

@end
