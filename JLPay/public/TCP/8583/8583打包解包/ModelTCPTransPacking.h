//
//  ModelTCPTransPacking.h
//  JLPay
//
//  Created by jielian on 16/1/25.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelTCPTransPacking : NSObject

// 按顺序执行打包
//  |
//  V
+ (instancetype) sharedModel;
//  |
//  V : 设置域的值
- (void) packingFieldsInfo:(NSDictionary*)fieldsInfo forTransType:(NSString*)transType;
//  |
//  V : 获取 mac 原始串
- (NSString*) getMacStringAfterPacking;
//  |
//  V : 重新设置 mac 密文
- (void) repackingWithMacPin:(NSString*)macPin;
//  |
//  V : 执行打包,并获取报文串
- (NSString*) packageFinalyPacking;


@end
