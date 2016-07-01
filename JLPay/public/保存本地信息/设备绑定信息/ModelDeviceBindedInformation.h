//
//  ModelDeviceBindedInformation.h
//  JLPay
//
//  Created by jielian on 15/11/26.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelDeviceBindedInformation : NSObject


/* 保存绑定信息 */
+ (void) saveBindedDeviceInfoWithIdentifier:(NSString*)identifier
                                 deviceName:(NSString*)deviceName
                             businessNumber:(NSString*)businessNumber
                             terminalNumber:(NSString*)terminalNumber;
/* 清空绑定信息 */
+ (void) cleanDeviceBindedInfo;


# pragma mask : 下列属性为绑定的属性

/* 设备是否绑定 */
+ (BOOL) hasBindedDevice;
/* 设备Name:绑定的 */
+ (NSString*) deviceName;
/* 设备ID:绑定的 */
+ (NSString*) deviceIdentifier;
/* 终端号:绑定的 */
+ (NSString*) terminalNoBinded;
/* 商户号: */
+ (NSString*) businessNumber;
@end
