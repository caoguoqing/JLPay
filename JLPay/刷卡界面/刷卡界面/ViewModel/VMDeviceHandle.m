//
//  VMDeviceHandle.m
//  JLPay
//
//  Created by jielian on 16/4/21.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMDeviceHandle.h"

@implementation VMDeviceHandle

- (instancetype)init
{
    self = [super init];
    if (self) {
        RAC(self, hasNumbersButton) = RACObserve(self.deviceManager, hasNumbersButton);
    }
    return self;
}
- (void)dealloc {
    JLPrint(@"-=-=-=-=-=-= dealloc:: VMDeviceHandle =-=-=-=-=-=-");
    [self.deviceManager stopScanning];
    [self.deviceManager disconnectOnFinished:nil];
}


// -- 1. 直接连接: 在dealloc中断开连接
- (void) connectDeviceOnFinished:(void (^) (void)) finished
                         onError:(void (^) (NSError* error)) errorBlock
{
    NameWeakSelf(wself);
    self.stateMessage = @"扫描设备中...";
    self.deviceState = VMDeviceStateScanning;
    [self.deviceManager startScanningOnDiscovered:^(CBPeripheral *peripheral) {
        
        if ([peripheral.identifier.UUIDString isEqualToString:[ModelDeviceBindedInformation deviceIdentifier]]) {
            wself.stateMessage = @"已扫描到需连接的设备";
            wself.deviceState = VMDeviceStateScanned;
            [wself.deviceManager stopScanning];
            
            if (![wself.deviceManager connected]) {
                if (wself.deviceState == VMDeviceStateScanned) { // do connect only if self.deviceState == VMDeviceStateScanned
                    wself.stateMessage = @"正在连接设备...";
                    wself.deviceState = VMDeviceStateConnecting;
                    [wself.deviceManager connectPeripheral:peripheral onConnected:^(NSString *SNVersion) {
                        if (wself.deviceState != VMDeviceStateConnecting) {
                            wself.deviceState = VMDeviceStateDisconnecting;
                            [wself.deviceManager disconnectOnFinished:^{
                                wself.deviceState = VMDeviceStateDisconnected;
                            }];
                            if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:9 localizedDescription:@"设备丢失"]);
                        } else {
                            wself.stateMessage = @"连接设备成功!";
                            wself.deviceState = VMDeviceStateConnected;
                            if (finished) finished();
                        }
                    } onError:^(NSError *error) {
                        wself.deviceState = VMDeviceStateDisconnected;
                        wself.stateMessage = @"连接设备失败!";
                        if (errorBlock) errorBlock(error);
                    }];
                }
            }
        }
        
    }];
}

// -- 2. 刷卡
- (void)swipeCardWithMoney:(NSString *)money
          onCardInfoReaded:(void (^)(NSDictionary *))cardInfoReaded
                   onError:(void (^)(NSError *))errorBlock
{
    self.stateMessage = @"设备已连接，请刷(插)卡...(IC卡请勿拔出)";
    NameWeakSelf(wself);
    [self.deviceManager swipeCardWithMoney:money onCardInfoReaded:^(NSDictionary *cardInfo) {
        if (cardInfoReaded) cardInfoReaded(cardInfo);
    } onError:^(NSError *error) {
        wself.stateMessage = @"刷(读)卡失败!";
        if (errorBlock) errorBlock(error);
    }];
}

// -- 3. 加密PIN: if hasNumbersButton == NO;
- (void) encryptPinSource:(NSString*)souce
           onEncryptedPIN:(void (^) (NSString* pin))encryptedPin
                  onError:(void (^) (NSError* error))errorBlock
{
    self.stateMessage = @"密码加密中...";
    NameWeakSelf(wself);
    [self.deviceManager encryptPinSource:souce onEncrypted:^(NSString *pin) {
        wself.stateMessage = @"密码加密成功!";
        if (encryptedPin) encryptedPin(pin);
    } onError:^(NSError *error) {
        wself.stateMessage = @"密码加密失败!";
        if (errorBlock) errorBlock(error);
    }];
}

// -- 4. 加密MAC
- (void) encryptMacSource:(NSString*)souce
           onEncryptedMac:(void (^) (NSString* mac))encryptedMac
                  onError:(void (^) (NSError* error))errorBlock
{
    self.stateMessage = @"MAC加密中...";
    NameWeakSelf(wself);
    [self.deviceManager encryptMacSource:souce onEncrypted:^(NSString *mac) {
        wself.stateMessage = @"MAC加密成功!";
        if (encryptedMac) encryptedMac(mac);
    } onError:^(NSError *error) {
        wself.stateMessage = @"MAC加密失败!";
        if (errorBlock) errorBlock(error);
    }];
}

// -- 5. 断开连接
- (void) disconnectOnFinished:(void (^) (void))finished {
    [self.deviceManager stopScanning];
    self.stateMessage = @"正在断开设备...";

    /* 直接断开 */
    self.deviceState = VMDeviceStateDisconnecting;
    [self.deviceManager disconnectOnFinished:^{
        self.stateMessage = @"设备已断开";
        self.deviceState = VMDeviceStateDisconnected;
        if (finished) finished();
    }];

}




# pragma mask 4 getter
- (DeviceManager *)deviceManager {
    if (!_deviceManager) {
        _deviceManager = [DeviceManager sharedInstance];
    }
    return _deviceManager;
}


@end
