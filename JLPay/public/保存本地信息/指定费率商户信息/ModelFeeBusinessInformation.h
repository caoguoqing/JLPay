//
//  ModelFeeBusinessInformation.h
//  JLPay
//
//  Created by jielian on 15/12/23.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kFeeBusinessInfoFeeSaved = @"kFeeBusinessInfoFeeSaved"; // 费率名
static NSString* const kFeeBusinessInfoAreaCode = @"kFeeBusinessInfoAreaCode";
static NSString* const kFeeBusinessInfoBusinessName = @"kFeeBusinessInfoBusinessName";
static NSString* const kFeeBusinessInfoBusinessCode = @"kFeeBusinessInfoBusinessCode";
static NSString* const kFeeBusinessInfoTerminalNum = @"kFeeBusinessInfoTerminalNum";


@interface ModelFeeBusinessInformation : NSObject


/* 保存信息:  */
+ (void) savingFeeBusinessInfo:(NSDictionary*)info;
/* 清空保存 */
+ (void) clearFeeBusinessInfoSaved;

/* 查询: 是否保存 */
+ (BOOL) isSaved;
/* 查询: 费率名 */
+ (NSString*) feeNameSaved;
/* 查询: 地区代码 */
+ (NSString*) areaCodeSaved;
/* 查询: 商户名 */
+ (NSString*) businessNameSaved;
/* 查询: 商户号 */
+ (NSString*) businessNumSaved;
/* 查询: 终端号 */
+ (NSString*) terminalNumSaved;

/* 查询: 费率名列表 */
+ (NSArray*) feeNamesList;
/* 查询: 费率码;指定费率名 */
+ (NSString*) feeTypeOfFeeName:(NSString*)feeName;

@end
