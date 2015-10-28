//
//  Unpacking8583.h
//  PosN38Universal
//
//  Created by work on 14-8-8.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import <Foundation/Foundation.h>



@class Unpacking8583;

#pragma mask ---- 拆包协议
@protocol Unpacking8583Delegate <NSObject>
@required
// 解包结果:成功或失败;如果失败,带回错误信息
- (void) didUnpackDatas:(NSDictionary*)dataDict onState:(BOOL)state withErrorMsg:(NSString*)message;
@end



@interface Unpacking8583 : NSObject
@property (nonatomic, assign) id<Unpacking8583Delegate> stateDelegate;

// 单例:入口
+(Unpacking8583 *)getInstance;

// 拆包 -- 新接口:字段已拆出,但未保存
-(void)unpacking8583:(NSString *)responseString withDelegate:(id<Unpacking8583Delegate>)delegate ;

// 3DES加密
-(NSString *)threeDesEncrypt:(NSString *)decryptDtr keyValue:(NSString *)key;

// 3DES解密
-(NSString *)threeDESdecrypt:(NSString *)decryptStr keyValue:(NSString *)key;

@end
