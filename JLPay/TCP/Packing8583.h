//
//  Packing8583.h
//  JLPay
//
//  Created by jielian on 15/9/16.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

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

#pragma mask : 清空数据
-(void) cleanAllFields;

@end
