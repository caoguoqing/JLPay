//
//  RFDevice_BB01.m
//  JLPay
//
//  Created by jielian on 15/8/28.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "RFDevice_BB01.h"
#import <iMagPay/BluetoothHandler.h>
#import <iMagPay/EMVConfigure.h>
#import "../PublicInformation.h"
#import "../Define_Header.h"

@interface RFDevice_BB01()
<
BLEReaderDelegate,
SwipeListener
>
@property (nonatomic, strong) BluetoothHandler* deviceManager;
@property (nonatomic, strong) Settings* deviceSetter;
@property (nonatomic, strong) NSMutableArray* deviceList;
@property (nonatomic, strong) NSString* connectedIdentifier;
@end


@implementation RFDevice_BB01
@synthesize deviceManager = _deviceManager;
@synthesize deviceSetter = _deviceSetter;
@synthesize deviceList = _deviceList;
@synthesize connectedIdentifier;

#define KeyDataPathNodeDataPath         @"KeyDataPathNodeDataPath"      // 设备dataPath
#define KeyDataPathNodeIdentifier       @"KeyDataPathNodeIdentifier"    // 设备ID
#define KeyDataPathNodeSNVersion        @"KeyDataPathNodeSNVersion"     // 设备SN号

#define RFDeviceName                    @"JLRFA"                        // 睿付蓝牙设备名字


- (void)readSNVersions{}
- (void)closeDevice:(NSString *)SNVersion{}
- (void)onDisconnected:(SwipeEvent *)event{}
- (void)openDevice:(NSString *)SNVersion {}
- (void)onStopped:(SwipeEvent *)event {}
- (void)onConnected:(SwipeEvent *)event{}
- (void)onReadData:(SwipeEvent *)event {}
- (void)onReaderHere:(BOOL)isHere {}
- (void)openAllDevices{}
- (void)onStarted:(SwipeEvent *)event {}



#pragma mask : 初始化
- (instancetype)initWithDelegate:(id<RFDevice_BB01Delegate>)deviceDelegate {
    self = [super init];
    if (self) {
        self.delegate = deviceDelegate;
        [self.deviceManager setShowAPDU:YES];
        [self.deviceSetter setSwipeHandler:self.deviceManager];
        self.connectedIdentifier = nil;
    }
    return self;
}
- (void)dealloc {
    [self.deviceSetter setSwipeHandler:nil];
    [self.deviceManager setMyDelegate:nil];
    [self.deviceManager setMSwipeListener:nil];
    [self.deviceManager cancelConect];
}

# pragma mask : 开始扫描设备
- (void) startScanningDevices {
//    [self.deviceManager stopScan];
    [self.deviceList removeAllObjects];
//    [self.deviceManager cancelConect];
    [self.deviceManager scanPeripheral];
}
# pragma mask : 关闭所有蓝牙设备
- (void) closeAllDevices {
//    [self.deviceManager setMyDelegate:nil];
//    [self.deviceManager setMSwipeListener:nil];
    [self.deviceManager cancelConect];
}

# pragma mask : 停止扫描设备
- (void) stopScanningDevices {
    [self.deviceManager stopScan];
}

# pragma mask : 打开指定 identifier 号的设备
- (void) openDeviceWithIdentifier:(NSString*)identifier {
    for (NSDictionary* dict in self.deviceList) {
        if ([identifier isEqualToString:[dict valueForKey:KeyDataPathNodeIdentifier]]) {
            NSLog(@"连接设备:%@",identifier);
            self.connectedIdentifier = identifier;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                [self.deviceManager conectDiscoverPeripheral:[dict objectForKey:KeyDataPathNodeDataPath]];
            });
            break;
        }
    }
}

# pragma mask : ID设备获取:根据SN号获取对应设备
- (NSString *)identifierOnDeviceSN:(NSString *)SNVersion {
    NSString* identifier = nil;
    for (NSDictionary* dict in self.deviceList) {
        if ([SNVersion isEqualToString:[dict valueForKey:KeyDataPathNodeSNVersion]]) {
            identifier = [dict valueForKey:KeyDataPathNodeIdentifier];
            break;
        }
    }
    return identifier;
}


# pragma mask : 判断指定SN号的设备是否已连接
- (int)isConnectedOnSNVersionNum:(NSString *)SNVersion {
    BOOL isExist = NO;
    BOOL isConnect = NO;
    for (NSDictionary* dict in self.deviceList) {
        if ([SNVersion isEqualToString:[dict valueForKey:KeyDataPathNodeSNVersion]]) {
            isExist = YES;
//            CBPeripheral* peripheral = [dict objectForKey:KeyDataPathNodeDataPath];
            if ([self.deviceManager isConnected]) {
                isConnect = YES;
            }
//            if (peripheral.state == CBPeripheralStateConnected) {
//                isConnect = YES;
//            }
            break;
        }
    }
    if (isExist && isConnect) {
        return 1;
    }
    return -1;
}

# pragma mask : 判断指定设备ID的设备是否已连接
- (int)isConnectedOnIdentifier:(NSString *)identifier{
    BOOL isExist = NO;
    BOOL isConnect = NO;
    for (NSDictionary* dict in self.deviceList) {
        if ([identifier isEqualToString:[dict valueForKey:KeyDataPathNodeIdentifier]]) {
            isExist = YES;
//            CBPeripheral* peripheral = [dict objectForKey:KeyDataPathNodeIdentifier];
//            if (peripheral.state == CBPeripheralStateConnected) {
//                isConnect = YES;
//            }
            if ([self.deviceManager isConnected]) {
                isConnect = YES;
            }

            break;
        }
    }
    if (isExist && isConnect) {
        return 1;
    }
    return -1;
}

# pragma mask : 设置主密钥
- (void)writeMainKey:(NSString *)mainKey onSNVersion:(NSString *)SNVersion {
    CBPeripheral* peripheral = nil;
    for (NSDictionary* dict in self.deviceList) {
        if ([SNVersion isEqualToString:[dict valueForKey:KeyDataPathNodeSNVersion]]) {
            peripheral = [dict objectForKey:KeyDataPathNodeDataPath];
            break;
        }
    }
    if (!peripheral) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteMainKeySucOrFail:withError:)]) {
            [self.delegate didWriteMainKeySucOrFail:NO withError:@"主密钥下载失败:设备未连接!"];
        }
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL result = [self.deviceSetter writeTMK:SLC :mainKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteMainKeySucOrFail:withError:)]) {
                    [self.delegate didWriteMainKeySucOrFail:YES withError:@"主密钥下载成功!"];
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteMainKeySucOrFail:withError:)]) {
                    [self.delegate didWriteMainKeySucOrFail:NO withError:@"主密钥下载失败!"];
                }
            }
        });
    });
}

# pragma mask : 设置工作密钥
- (void)writeWorkKey:(NSString *)workKey onSNVersion:(NSString *)SNVersion {
    CBPeripheral* peripheral = nil;
    for (NSDictionary* dict in self.deviceList) {
        if ([SNVersion isEqualToString:[dict valueForKey:KeyDataPathNodeSNVersion]]) {
            peripheral = [dict objectForKey:KeyDataPathNodeDataPath];
            break;
        }
    }
    if (!peripheral) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteWorkKeySucOrFail:withError:)]) {
            [self.delegate didWriteWorkKeySucOrFail:NO withError:@"工作密钥下载失败:设备未连接!"];
        }
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL result = [self.deviceSetter writeSignIn:SLC :workKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteWorkKeySucOrFail:withError:)]) {
                    [self.delegate didWriteWorkKeySucOrFail:YES withError:@"工作密钥下载成功!"];
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteWorkKeySucOrFail:withError:)]) {
                    [self.delegate didWriteWorkKeySucOrFail:NO withError:@"工作密钥下载失败!"];
                }
            }
        });
    });
}

# pragma mask : 刷卡: 有金额+无密码, 无金额+无密码,
- (void)cardSwipeWithMoney:(NSString *)money yesOrNot:(BOOL)yesOrNot onSNVersion:(NSString *)SNVersion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (![self.deviceManager sendDataEnable]) {
            sleep(0.1);
        }
        NSString* detect = [self.deviceSetter writeDetectCard];
        if (detect && [detect hasPrefix:@"00"]) {
            NSLog(@"IC在插槽,读取IC卡数据...");
            BOOL swiped = [self getICCardDataWithMoney:(long)[money intValue]];
            if (swiped) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedSucOrFail:withError:)]) {
                    [self.delegate didCardSwipedSucOrFail:YES withError:nil];
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedSucOrFail:withError:)]) {
                    [self.delegate didCardSwipedSucOrFail:NO withError:@"刷卡失败"];
                }
            }
        } else {
            NSLog(@"等待刷卡或插卡....");
        }
    });
}

#pragma mask : PIN加密
- (void) pinEncryptBySource:(NSString*)source withPan:(NSString*)pan onSNVersion:(NSString*)SNVersion {
    CBPeripheral* peripheral = nil;
    for (NSDictionary* dict in self.deviceList) {
        if ([SNVersion isEqualToString:[dict valueForKey:KeyDataPathNodeSNVersion]]) {
            peripheral = [dict objectForKey:KeyDataPathNodeDataPath];
        }
    }
    if (!peripheral) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didEncryptPinSucOrFail:pin:withError:)]) {
            [self.delegate didEncryptPinSucOrFail:NO pin:nil withError:@"PIN加密失败:设备未连接"];
        }
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString* pin;
            NSLog(@"加密[%@]的原始明文串:[%@]",pan,source);
            while (![self.deviceManager sendDataEnable]) {
                sleep(0.1);
            }
            pin = [self.deviceSetter getEncryptedPIN:SLC :pan :source];
            NSLog(@"加密后的密文串:[%@]",pin);
            pin = [PublicInformation clearSpaceCharAtContentOfString:pin];
            if (self.delegate && [self.delegate respondsToSelector:@selector(didEncryptPinSucOrFail:pin:withError:)]) {
                [self.delegate didEncryptPinSucOrFail:YES pin:[pin uppercaseString] withError:nil];
            }
        });
    }
}



#pragma mask : ------------ BLEReaderDelegate

#pragma mask : 设备扫描成功
- (void)discoverPeripheralSuccess:(CBPeripheral *)peripheral RSSI:(NSNumber *)rssi {
    if (![peripheral.name hasPrefix:RFDeviceName]) {
        return;
    }
    BOOL isExist = NO;
    for (NSDictionary* dict in self.deviceList) {
        if ([peripheral.identifier.UUIDString isEqualToString:[dict valueForKey:KeyDataPathNodeIdentifier]]) {
            isExist = YES;
            break;
        }
    }
    if (!isExist) {
        NSLog(@"扫描到设备%@:%@",peripheral.name,peripheral.identifier.UUIDString);
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:3];
        [dict setObject:peripheral forKey:KeyDataPathNodeDataPath];
        [dict setValue:peripheral.identifier.UUIDString forKey:KeyDataPathNodeIdentifier];
        [self.deviceList addObject:dict];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDiscoverDeviceOnID:)]) {
            [self.delegate didDiscoverDeviceOnID:peripheral.identifier.UUIDString];
        }
    }
}

#pragma mask : 连接设备成功
- (void)conectPeripheralSuccess {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"设备连接成功");
        while (![self.deviceManager sendDataEnable]) {
            sleep(0.1);
        }
        // 读取SN号:连接成功之后,且状态为可操作的
        NSString* SNVersion = [self.deviceSetter getSN];
        // SN号格式处理:转换大写、去掉后面FF...字符串
        SNVersion = [PublicInformation clearSpaceCharAtContentOfString:[SNVersion uppercaseString]];
        if ([SNVersion containsString:@"FF"]) {
            NSRange range = [SNVersion rangeOfString:@"FF"];
            SNVersion = [SNVersion substringToIndex:range.location];
        }
        NSLog(@"设备[SN:%@]连接成功",SNVersion);
        if (!SNVersion || SNVersion.length == 0) {
            return;
        }
        // 待修改: 目前SDK只支持一个设备,后面要改为多设备
        for (NSDictionary* dict in self.deviceList) {
            if ([self.connectedIdentifier isEqualToString:[dict valueForKey:KeyDataPathNodeIdentifier]]) {
                [dict setValue:SNVersion forKey:KeyDataPathNodeSNVersion];
                if (self.delegate && [self.delegate respondsToSelector:@selector(didReadSNVersion:sucOrFail:withError:)]) {
                    [self.delegate didReadSNVersion:SNVersion sucOrFail:YES withError:nil];
                }
                break;
            }
        }
//        NSMutableDictionary* dict = [self.deviceList objectAtIndex:0];
//        [dict setValue:SNVersion forKey:KeyDataPathNodeSNVersion];
        
    });
}




#pragma mask : 解析数据
-(void)onParseData:(SwipeEvent*)event{
    NSLog(@"onParseData -> %@",[event getValue]);
    
    NSMutableString *ss = [[NSMutableString alloc]init];
    [ss appendString:@"final(16)=> "];
    [ss appendString:[event getValue]];
    [ss appendString:@"\n"];
    [ss appendString:@"final(10)=> "];
    [ss appendString:[StringUtils hex_to_str:[event getValue]]];
}


#pragma mask : 刷卡回调
- (void)onCardDetected:(SwipeEvent *)event {
    BOOL __block swiped = NO;
    int type = [event getType];
    if (type == EVENT_TYPE_IC_INSERTED) {
        sleep(1);
        NSLog(@"检测到IC卡,正在读取数据中...");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while (![self.deviceManager sendDataEnable]) {
                sleep(0.1);
            }
            swiped = [self getICCardDataWithMoney:100];
            // 刷卡回调
            if (swiped) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedSucOrFail:withError:)]) {
                    [self.delegate didCardSwipedSucOrFail:YES withError:nil];
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedSucOrFail:withError:)]) {
                    [self.delegate didCardSwipedSucOrFail:NO withError:@"刷卡失败"];
                }
            }

        });
    } else if (type == EVENT_TYPE_IC_REMOVED) {
        NSLog(@"IC卡已拔出...");
    } else if (type == EVENT_TYPE_MAG_SWIPED) {
        swiped = [self getTrackCardData];
        // 刷卡回调
        if (swiped) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedSucOrFail:withError:)]) {
                [self.delegate didCardSwipedSucOrFail:YES withError:nil];
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedSucOrFail:withError:)]) {
                [self.delegate didCardSwipedSucOrFail:NO withError:@"刷卡失败"];
            }
        }
    }
    
}



#pragma mask -------- private interface

#pragma mask : IC卡数据读取
- (BOOL) getICCardDataWithMoney:(long)money {
    NSString* reset = [self.deviceSetter icReset];
    NSLog(@"ic reset = [%@]",reset);
    if (!reset || [reset hasPrefix:@"ff 3f"] || [reset hasPrefix:@"32 ff"]) {
        return NO;
    }
    // 参数设置
    EMVConfigure* configure = [[EMVConfigure alloc] init];
    [configure setAuthAmnt:money];
    // EMV流程
    [self.deviceManager icReset];
    [self.deviceManager emvProcess:[configure getEmvConfig]];
    // IC下电
    [self.deviceManager icOff];
    
    NSLog(@"IC 卡号:%@", [self.deviceManager getIcPan]);
    NSLog(@"IC 序列号:%@", [self.deviceManager getIcSeq]);
    NSLog(@"IC 55数据:%@", [self.deviceManager getIcField55]);
    NSLog(@"IC 二磁:%@", [self.deviceManager getICEncryptedTrack2Data]);
    NSLog(@"IC 有效期:%@", [self.deviceManager getIcEffDate]);
    NSLog(@"IC 失效期:%@", [self.deviceManager getIcExpDate]);
    // 数据 - 卡号
    NSString* panStr = [self.deviceManager getIcPan];
    if (panStr && panStr.length > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:panStr forKey:Card_Number];
    }
    // 数据 - IC序列号
    NSString* icSeq = [self.deviceManager getIcSeq];
    if (icSeq && icSeq.length > 0) {
        while (icSeq.length < 4) {
            icSeq = [@"0" stringByAppendingString:icSeq];
        }
        [[NSUserDefaults standardUserDefaults] setValue:icSeq forKey:ICCardSeq_23];
    }
    // 数据 - IC卡55域
    NSString* icData = [self.deviceManager getIcField55];
    if (icData && icData.length > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:[icData uppercaseString] forKey:BlueIC55_Information];
    }
    // 数据 - 二磁加密数据
    NSString* track2 = [self.deviceManager getICEncryptedTrack2Data];
    if (track2 && track2.length > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:[[track2 substringFromIndex:2] uppercaseString] forKey:Two_Track_Data];
    }
    // 数据 - 有效期
    NSString* expDate = [self.deviceManager getIcExpDate];
    if (expDate && expDate.length > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:[expDate substringToIndex:4] forKey:Card_DeadLineTime];
    }
    
    // IC卡片标志
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CardTypeIsTrack];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}
#pragma mask : 磁条卡数据读取
- (BOOL) getTrackCardData {
    NSLog(@"磁条 卡号:%@", [self.deviceManager getMagPan]);
    NSLog(@"磁条 二磁:%@", [self.deviceManager getTrack2Data]);
    NSLog(@"磁条 三磁:%@", [self.deviceManager getTrack3Data]);
    
    NSLog(@"磁条 有效期:%@", [self.deviceManager getMagExpDate]);
    
    // 卡号
    NSString* pan = [self.deviceManager getMagPan];
    if (pan && pan.length > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:pan forKey:Card_Number];
    }
    // 二磁加密数据
    NSString* track2 = [self.deviceManager getTrack2Data];
    if (track2 && track2.length > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:[[track2 substringFromIndex:2] uppercaseString] forKey:Two_Track_Data];
    }
    // 三磁加密数据
    NSString* track3 = [self.deviceManager getTrack3Data];
    if (track3 && track3.length > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:[[track3 substringFromIndex:4] uppercaseString] forKey:F36_ThreeTrackData];
    }
    // 有效期
    NSString* expDate = [self.deviceManager getMagExpDate];
    if (expDate && expDate.length > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:expDate forKey:Card_DeadLineTime];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CardTypeIsTrack];

    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}


#pragma mask : getter & setter
- (BluetoothHandler *)deviceManager {
    if (_deviceManager == nil) {
        _deviceManager = [[BluetoothHandler alloc] init];
        [_deviceManager setMyDelegate:self];
        [_deviceManager setMSwipeListener:self];
    }
    return _deviceManager;
}
- (Settings *)deviceSetter {
    if (_deviceSetter == nil) {
        _deviceSetter = [[Settings alloc] init];
    }
    return _deviceSetter;
}
- (NSMutableArray *)deviceList {
    if (_deviceList == nil) {
        _deviceList = [[NSMutableArray alloc] init];
    }
    return _deviceList;
}

@end
