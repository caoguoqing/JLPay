//
//  Packing8583.h
//  JLPay
//
//  Created by jielian on 15/9/16.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


/*************[交易类型]**************/
#define TranType                    @"TranType"
#define TranType_Consume            @"000000"                           // 消费 同8583 bit3域值  // 190000:000000
#define TranType_ConsumeRepeal      @"280000"                           // 消费撤销
#define TranType_YuE                @"300000"                           // 余额查询
#define TranType_DownMainKey        @"TranType_DownMainKey"             // 下载主密钥
#define TranType_DownWorkKey        @"TranType_DownWorkKey"             // 下载工作密钥
#define TranType_TuiHuo             @"200000"                           // 退货交易

#define TranType_Chongzheng         @"TranType_Chongzheng"              // 冲正交易
#define TranType_BatchUpload        @"TranType_BatchUpload"             // 披上送，IC卡交易完成后上送
#define TranType_Repay              @"TranType_Repay_"                  // 信用卡还款
#define TranType_Transfer           @"TranType_Transfer_"               // 转账汇款




@interface Packing8583 : NSObject


// -- 流程 --
// -> setFieldAtIndex:withValue     2,3,4,...64
// -> preparePacking;
// -> macSourcePackintByType:       if need mac
// -> stringPackingWithType:        packing
// -> cleanAllFields;



#pragma mask : 公共入口
+(Packing8583*) sharedInstance;
#pragma mask : 生成F60
+ (NSString*) makeF60OnTrantype:(NSString*)tranType ;
+ (NSString*) makeF60ByLast60:(NSString*)last60;
#pragma mask : 生成F63
+ (NSString*) makeF63OnTranType:(NSString*)tranType;


#pragma mask : 域值设置:需要打包的
- (void) setFieldAtIndex:(int)index withValue:(NSString*)value;

// -- formatingFieldsData; ?? 执行格式化
#pragma mask : 准备好了数据;准备打包;(会将所有域数据格式化)
- (void) preparePacking;


#pragma mask : 打包结果串获取
-(NSString*) stringPackingWithType:(NSString*)type;

#pragma mask : MAC加密源串
- (NSString*) macSourcePackintByType:(NSString*)type;

#pragma mask : 清空数据
-(void) cleanAllFields;


@property (nonatomic, retain) NSString* tpdu;
@property (nonatomic, retain) NSString* header;

@property (nonatomic, readonly) NSString* MAINKEY; // 主密钥明文


@end
