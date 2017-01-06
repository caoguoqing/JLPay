//
//  SmitServer.h
//  SMPay
//
//  Created by smit on 16/3/15.
//  Copyright © 2016年 smit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmitServer : NSObject
+(NSString*)xlcardExternalAuthWithKey:(NSString*)key sn:(NSString*)sn random:(NSString*)random;
+(int)xlcardDeviceAuthWithKey:(NSString*)key sn:(NSString*)sn random:(NSString*)random encrypt:(NSString*)encrypt;
+(NSString*)xlcardGetTskWidthPubKey:(NSString*)pubKey priKey:(NSString*)priKey encrypt:(NSString*)encrypt;
+(NSString*)xlcardTskEncryptWithKey:(NSString*)key data:(NSString*)data;
+(NSString*)xlcardTskDecryptWithKey:(NSString*)key data:(NSString*)data;
//+(NSDictionary*)xlcardSyncAuthKeyWithMasterKey:(NSString*)masterKey sn:(NSString*)sn random:(NSString*)random type:(int)type newKey:(NSString*)newKey;
+(NSDictionary*)xlcardSyncAuthKeyWithMasterKey:(NSString*)masterKey sn:(NSString*)sn random:(NSString*)random newMasterKey:(NSString*)newMasterKey newAuthKey:(NSString*)newAuthKey;

@end
