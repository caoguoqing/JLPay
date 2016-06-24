//
//  VMDataSourceMyBusiness.h
//  JLPay
//
//  Created by jielian on 16/5/5.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UserHeadImageTBVCell.h"
#import "BusinessStateTBVCell.h"
#import "MHttpBusinessInfo.h"
#import "UserRegisterViewController.h"
#import "Define_Header.h"
#import "ModelAreaCodeSelector.h"
#import "MLoginSavedResource.h"


static NSString* const VMMyBusinessTitleUser = @"user";
static NSString* const VMMyBusinessTitleState = @"商户状态:";
static NSString* const VMMyBusinessTitleName = @"商户名:";
static NSString* const VMMyBusinessTitleNumber = @"商户编号:";
static NSString* const VMMyBusinessTitleIdNo = @"身份证号:";
static NSString* const VMMyBusinessTitleTelNo = @"手机号码:";
static NSString* const VMMyBusinessTitleEmail = @"邮箱:";
static NSString* const VMMyBusinessTitleBankName = @"结算账户开户行:";
static NSString* const VMMyBusinessTitleSettleAccount = @"结算账号:";
static NSString* const VMMyBusinessTitleAddress = @"商户所在地:";


typedef enum {
    VMDataSourceMyBusiCodeChecked = 32323,          // 正常
    VMDataSourceMyBusiCodeCheckRefuse,              // 审核拒绝
    VMDataSourceMyBusiCodeChecking                  // 审核中
}VMDataSourceMyBusiCode;

@interface VMDataSourceMyBusiness : NSObject
< UITableViewDataSource>

@property (nonatomic, assign) VMDataSourceMyBusiCode businessState;

@property (nonatomic, strong) NSMutableArray* displayTitles;
@property (nonatomic, strong) NSMutableDictionary* titleAndDataKeys;

- (void) requestMyBusinessInfoOnFinished:(void (^) (void))finished
                            onErrorBlock:(void (^) (NSError* error))errorBlock;

- (void) stopRequest;


@end
