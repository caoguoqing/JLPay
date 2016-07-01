//
//  MSignUpDataSource.h
//  JLPay
//
//  Created by 冯金龙 on 16/6/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSignUpItem.h"


static NSString* const kSUCellTitleBusinessName         = @"商户名称";
static NSString* const kSUCellTitleUserName             = @"登录用户名";
static NSString* const kSUCellTitleUserPwd              = @"登录密码";
static NSString* const kSUCellTitleConfirmPwd           = @"确认密码";
static NSString* const kSUCellTitleUserID               = @"身份证号";
static NSString* const kSUCellTitleTelphone             = @"手机号码";
static NSString* const kSUCellTitleEmail                = @"邮箱";
static NSString* const kSUCellTitleDetailAddr           = @"详细地址";
static NSString* const kSUCellTitleBankNo               = @"联行号";
static NSString* const kSUCellTitleAccountName          = @"账户名";
static NSString* const kSUCellTitleAccountNum           = @"账号";
static NSString* const kSUCellTitleDeviceSN             = @"绑定设备SN号";
static NSString* const kSUCellTitleIDPhotoFore          = @"上传身份证照(正面)";
static NSString* const kSUCellTitleIDPhotoBack          = @"上传身份证照(反面)";
static NSString* const kSUCellTitleIDPhotoHandle        = @"上传手持身份证照(正面)";
static NSString* const kSUCellTitleDebitCardFore        = @"上传结算银行卡照(正面)";




@interface MSignUpDataSource : NSObject

/*
 1. 基本信息[]
 2. 结算信息[]
 3. 证件卡照[]
 */
@property (nonatomic, strong) NSMutableArray* dataSource;

@end
