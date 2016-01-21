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
#define TranType_Consume            @"190000"                           // 消费 同8583 bit3域值
#define TranType_ConsumeRepeal      @"280000"                           // 消费撤销
#define TranType_Chongzheng         @"TranType_Chongzheng"              // 冲正交易
#define TranType_TuiHuo             @"200000"                           // 退货交易
#define TranType_DownMainKey        @"TranType_DownMainKey"             // 下载主密钥
#define TranType_DownWorkKey        @"TranType_DownWorkKey"             // 下载工作密钥
#define TranType_BatchUpload        @"TranType_BatchUpload"             // 披上送，IC卡交易完成后上送
#define TranType_Repay              @"TranType_Repay_"                  // 信用卡还款
#define TranType_Transfer           @"TranType_Transfer_"               // 转账汇款
#define TranType_YuE                @"300000"                           // 余额查询




@interface Packing8583 : NSObject


#pragma mask : 公共入口
+(Packing8583*) sharedInstance;
#pragma mask : 生成F60
+ (NSString*) makeF60OnTrantype:(NSString*)tranType ;
+ (NSString*) makeF60ByLast60:(NSString*)last60;

#pragma mask : 域值设置:需要打包的
- (void) setFieldAtIndex:(int)index withValue:(NSString*)value;


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
