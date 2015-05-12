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



@interface Unpacking8583 : NSObject{
    
}

@property (nonatomic, assign) id<managerToCard> delegate;

+(Unpacking8583 *)getInstance;


-(void)unpackingSignin:(NSString *)signin method:(NSString *)methodStr getdelegate:(id)de;

-(NSArray *)bitmapArr:(NSString *)bitmapStr;

-(NSString *)threeDesEncrypt:(NSString *)decryptDtr keyValue:(NSString *)key;

//3des解密
-(NSString *)threeDESdecrypt:(NSString *)decryptStr keyValue:(NSString *)key;

@end
