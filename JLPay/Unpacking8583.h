//
//  Unpacking8583.h
//  PosN38Universal
//
//  Created by work on 14-8-8.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import <Foundation/Foundation.h>



@class Unpacking8583;
@protocol managerToCard <NSObject>
@required
@optional
-(void)managerToCardState:(NSString *)type  isSuccess:(BOOL)state method:(NSString *)metStr;
@end

#pragma mask ---- 不用原来的 managerToCard,新建一个协议
@protocol Unpacking8583Delegate <NSObject>
@required
// 解包结果:成功或失败;如果失败,带回错误信息
- (void) didUnpackDatas:(NSDictionary*)dataDict onState:(BOOL)state withErrorMsg:(NSString*)message;
@end

// 拆包后的每个域的名字 KEY
//#define KEY_RES_8583_ @"KEY_RES_8583_"


@interface Unpacking8583 : NSObject
@property (nonatomic, assign) id<managerToCard> delegate;
@property (nonatomic, assign) id<Unpacking8583Delegate> stateDelegate;

// 单例:入口
+(Unpacking8583 *)getInstance;
// 解包 -- 旧接口,代码太多重复
-(void)unpackingSignin:(NSString *)signin method:(NSString *)methodStr getdelegate:(id)de;
// 拆包 -- 新接口:字段已拆出,但未保存
-(void)unpacking8583:(NSString *)responseString withDelegate:(id<Unpacking8583Delegate>)delegate ;
// 获取位图信息
-(NSArray *)bitmapArr:(NSString *)bitmapStr;
// 3DES加密
-(NSString *)threeDesEncrypt:(NSString *)decryptDtr keyValue:(NSString *)key;
// 3DES解密
-(NSString *)threeDESdecrypt:(NSString *)decryptStr keyValue:(NSString *)key;

@end
