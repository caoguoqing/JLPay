//
//  ModelDeviceBindedInformation.m
//  JLPay
//
//  Created by jielian on 15/11/26.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ModelDeviceBindedInformation.h"

/* ------------------------------ 信息字典: 商户绑定设备的信息
 *  KeyInfoDictOfBindedPeripheral           - 设备
 *  KeyInfoDictOfBindedTerminalNum          - 终端号
 ------------------------------*/
#define KeyInfoDictOfBinded                     @"KeyInfoDictOfBinded"          // 字典
#define KeyInfoDictOfBindedDeviceName           @"KeyInfoDictOfBindedDeviceName"
#define KeyInfoDictOfBindedDeviceIdentifier     @"KeyInfoDictOfBindedDeviceIdentifier"
#define KeyInfoDictOfBindedTerminalNum          @"KeyInfoDictOfBindedTerminalNum"
#define KeyInfoDictOfBindedBusinessNum          @"KeyInfoDictOfBindedBusinessNum"

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
+ (void)saveBindedDeviceInfoWithIdentifier:(NSString *)identifier
                                deviceName:(NSString *)deviceName
                            businessNumber:(NSString *)businessNumber
                            terminalNumber:(NSString *)terminalNumber
{
    if ([self hasBindedDevice]) {
        [self cleanDeviceBindedInfo];
    }
    NSMutableDictionary* bindedinfo = [[NSMutableDictionary alloc] init];
    [bindedinfo setObject:identifier forKey:KeyInfoDictOfBindedDeviceIdentifier];
    [bindedinfo setObject:deviceName forKey:KeyInfoDictOfBindedDeviceName];
    [bindedinfo setObject:businessNumber forKey:KeyInfoDictOfBindedBusinessNum];
    [bindedinfo setObject:terminalNumber forKey:KeyInfoDictOfBindedTerminalNum];
    [self saveBindedInfo:bindedinfo];
    [self updateDeviceBindedFlag:YES];
}


/* 清空绑定信息 */
+ (void) cleanDeviceBindedInfo {
    [self cleanBindedInfo];
    [self updateDeviceBindedFlag:NO];
}

/* 设备Name:绑定的 */
+ (NSString*) deviceName {
    NSDictionary* info = [self bindedInfo];
    NSString* deviceName = nil;
    if (info) {
        deviceName = [info objectForKey:KeyInfoDictOfBindedDeviceName];
    }
    return deviceName;
}
/* 设备ID:绑定的 */
+ (NSString*) deviceIdentifier {
    NSDictionary* info = [self bindedInfo];
    NSString* deviceIdentifier = nil;
    if (info) {
        deviceIdentifier = [info objectForKey:KeyInfoDictOfBindedDeviceIdentifier];
    }
    return deviceIdentifier;
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

+ (NSString *)businessNumber {
    NSDictionary* info = [self bindedInfo];
    NSString* businessNum = nil;
    if (info) {
        businessNum = [info objectForKey:KeyInfoDictOfBindedBusinessNum];
    }
    return businessNum;
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
