//
//  ModelDeviceBindedInformation.m
//  JLPay
//
//  Created by jielian on 15/11/26.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ModelDeviceBindedInformation.h"

/* ------------------------------ 信息字典: 商户绑定设备的信息
 *  KeyInfoDictOfBindedDeviceType           - 设备类型
 *  KeyInfoDictOfBindedDeviceIdentifier     - 设备id
 *  KeyInfoDictOfBindedDeviceSNVersion      - 设备SN
 *  KeyInfoDictOfBindedTerminalNum          - 终端号
 *  KeyInfoDictOfBindedBussinessNum         - 商户号 - 关联登陆账号
 ------------------------------*/
#define KeyInfoDictOfBinded                     @"KeyInfoDictOfBinded"          // 字典
#define KeyInfoDictOfBindedDeviceType           @"KeyInfoDictOfBindedDeviceType"
#define KeyInfoDictOfBindedDeviceIdentifier     @"KeyInfoDictOfBindedDeviceIdentifier"
#define KeyInfoDictOfBindedDeviceSNVersion      @"KeyInfoDictOfBindedDeviceSNVersion"
#define KeyInfoDictOfBindedTerminalNum          @"KeyInfoDictOfBindedTerminalNum"
#define KeyInfoDictOfBindedBussinessNum         @"KeyInfoDictOfBindedBussinessNum"

#define KeyDeviceBinded @"KeyDeviceBinded__"  // 设备绑定标记: YES:已绑定设备；NO:未绑定设备；



@implementation ModelDeviceBindedInformation

/* 设备是否绑定 */
+ (BOOL) hasBindedDevice {
    BOOL binded = NO;
    NSNumber* bindedFlag = [[NSUserDefaults standardUserDefaults] objectForKey:KeyDeviceBinded];
    if (bindedFlag) {
        binded = [bindedFlag boolValue];
    }
    return binded;
}

/* 保存绑定信息 */
+ (void) saveBindedDeviceInfoWithDeviceType:(NSString*)deviceType // 设备类型
                                   deviceID:(NSString*)deviceID // 设备ID
                                   deviceSN:(NSString*)deviceSN // 设备SN
                             terminalNumber:(NSString*)terminalNumber // 终端号
                             businessNumber:(NSString*)businessNumber // 商户号
{
    if ([self hasBindedDevice]) {
        [self cleanDeviceBindedInfo];
    }
    NSMutableDictionary* bindedinfo = [[NSMutableDictionary alloc] init];
    [bindedinfo setObject:deviceType forKey:KeyInfoDictOfBindedDeviceType];
    [bindedinfo setObject:deviceID forKey:KeyInfoDictOfBindedDeviceIdentifier];
    [bindedinfo setObject:deviceSN forKey:KeyInfoDictOfBindedDeviceSNVersion];
    [bindedinfo setObject:terminalNumber forKey:KeyInfoDictOfBindedTerminalNum];
    [bindedinfo setObject:businessNumber forKey:KeyInfoDictOfBindedBussinessNum];
    [self saveBindedInfo:bindedinfo];
    [self updateDeviceBindedFlag:YES];
}

/* 清空绑定信息 */
+ (void) cleanDeviceBindedInfo {
    [self cleanBindedInfo];
    [self updateDeviceBindedFlag:NO];
}
/* 绑定的设备类型 */
+ (NSString*) deviceTypeBinded {
    NSDictionary* info = [self bindedInfo];
    NSString* deviceType = nil;
    if (info) {
        deviceType = [info objectForKey:KeyInfoDictOfBindedDeviceType];
    }
    return deviceType;
}
/* 绑定的设备id*/
+ (NSString*) deviceIDBinded {
    NSDictionary* info = [self bindedInfo];
    NSString* deviceID = nil;
    if (info) {
        deviceID = [info objectForKey:KeyInfoDictOfBindedDeviceIdentifier];
    }
    return deviceID;
}
/* 绑定的设备SN */
+ (NSString*) deviceSNBinded {
    NSDictionary* info = [self bindedInfo];
    NSString* deviceSN = nil;
    if (info) {
        deviceSN = [info objectForKey:KeyInfoDictOfBindedDeviceSNVersion];
    }
    return deviceSN;
}
/* 绑定的终端号 */
+ (NSString*) terminalNoBinded {
    NSDictionary* info = [self bindedInfo];
    NSString* terminal = nil;
    if (info) {
        terminal = [info objectForKey:KeyInfoDictOfBindedTerminalNum];
    }
    return terminal;
}
/* 绑定的商户号 */
+ (NSString*) businessNoBinded {
    NSDictionary* info = [self bindedInfo];
    NSString* business = nil;
    if (info) {
        business = [info objectForKey:KeyInfoDictOfBindedBussinessNum];
    }
    return business;
}

#pragma mask ---- PRIVATE INTERFACE
+ (void) updateDeviceBindedFlag:(BOOL)bindedflag {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:bindedflag]
                                              forKey:KeyDeviceBinded];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSDictionary*) bindedInfo {
    NSDictionary* info = nil;
    info = [[NSUserDefaults standardUserDefaults] objectForKey:KeyInfoDictOfBinded];
    return info;
}
+ (void) saveBindedInfo:(NSDictionary*)info {
    [[NSUserDefaults standardUserDefaults] setObject:info forKey:KeyInfoDictOfBinded];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void) cleanBindedInfo {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KeyInfoDictOfBinded];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
