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
//  V
- (void) packingFieldsInfo:(NSDictionary*)fieldsInfo forTransType:(NSString*)transType;
//  |
//  V
- (NSString*) getMacStringAfterPacking;
//  |
//  V
- (void) repackingWithMacPin:(NSString*)macPin;
//  |
//  V
- (NSString*) packageFinalyPacking;


@end
