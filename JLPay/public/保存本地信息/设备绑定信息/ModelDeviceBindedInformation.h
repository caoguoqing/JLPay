//
//  ModelDeviceBindedInformation.h
//  JLPay
//
//  Created by jielian on 15/11/26.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ModelDeviceBindedInformation : NSObject

/* 设备是否绑定 */
+ (BOOL) hasBindedDevice;
/* 保存绑定信息 */
+ (void) saveBindedDeviceInfoWithDeviceType:(NSString*)deviceType // 设备类型
                                   deviceID:(NSString*)deviceID // 设备ID
                                   deviceSN:(NSString*)deviceSN // 设备SN
                             terminalNumber:(NSString*)terminalNumber // 终端号
                             businessNumber:(NSString*)businessNumber; // 商户号
/* 清空绑定信息 */
+ (void) cleanDeviceBindedInfo;
/* 绑定的设备类型 */
+ (NSString*) deviceTypeBinded;
/* 绑定的设备id */
+ (NSString*) deviceIDBinded;
/* 绑定的设备SN */
+ (NSString*) deviceSNBinded;
/* 绑定的终端号 */
+ (NSString*) terminalNoBinded;
/* 绑定的商户号 */
+ (NSString*) businessNoBinded;

@end
