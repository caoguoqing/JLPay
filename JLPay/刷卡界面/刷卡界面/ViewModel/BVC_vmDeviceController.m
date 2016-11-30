//
//  BVC_vmDeviceController.m
//  JLPay
//
//  Created by jielian on 2016/11/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "BVC_vmDeviceController.h"
#import <ReactiveCocoa.h>
#import "DeviceManager.h"
#import "ModelDeviceBindedInformation.h"
#import "Define_Header.h"
#import "MTransMoneyCache.h"


@interface BVC_vmDeviceController()

@property (nonatomic, strong) DeviceManager* deviceManager;

@end

@implementation BVC_vmDeviceController

- (void)dealloc {
    [self.deviceManager stopScanning];
    [self.deviceManager disconnectOnFinished:nil];
}


# pragma mask 4 getter

- (DeviceManager *)deviceManager {
    if (!_deviceManager) {
        _deviceManager = [DeviceManager sharedInstance];
    }
    return _deviceManager;
}


/* cmd: 设备连接 */
- (RACCommand *)cmd_deviceConnecting {
    @weakify(self);
    if (!_cmd_deviceConnecting) {
        _cmd_deviceConnecting = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                // 1.扫描
                self.stateMessage = @"正在扫描设备...";
                [subscriber sendNext:nil];
                [self.deviceManager startScanningOnDiscovered:^(CBPeripheral *peripheral) {
                    @strongify(self);
                    if ([peripheral.identifier.UUIDString isEqualToString:[ModelDeviceBindedInformation deviceIdentifier]]) {
                        // 2.连接
                        self.stateMessage = @"正在连接设备...";
                        [self.deviceManager connectPeripheral:peripheral onConnected:^(NSString *SNVersion) {
                            @strongify(self);
                            self.stateMessage = @"连接设备成功!";
                            [subscriber sendCompleted];
                        } onError:^(NSError *error) {
                            @strongify(self);
                            self.stateMessage = @"连接设备失败!";
                            [subscriber sendError:error];
                        }];
                    }
                }];
                return nil;
            }] replayLast] materialize];
        }];
    }
    return _cmd_deviceConnecting;
}

/* cmd: 断开连接 */
- (RACCommand *)cmd_deviceDisconnecting {
    if (!_cmd_deviceDisconnecting) {
        @weakify(self);
        _cmd_deviceDisconnecting = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [subscriber sendNext:nil];
                [self.deviceManager disconnectOnFinished:^{
                    [subscriber sendCompleted];
                }];
                return nil;
            }] replayLast] materialize];
        }];
    }
    return _cmd_deviceDisconnecting;
}



/* cmd: 读卡 */
- (RACCommand *)cmd_cardReading {
    @weakify(self);
    if (!_cmd_cardReading) {
        _cmd_cardReading = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [subscriber sendNext:nil];
                self.stateMessage = @"正在读取卡数据,请刷卡(或插卡)...";
                if (self.deviceManager.connected) {
                    [self.deviceManager swipeCardWithMoney:self.money onCardInfoReaded:^(NSDictionary *cardInfo) {
                        @strongify(self);
                        self.stateMessage = @"读卡成功!";
                        self.mposHasKeyboard = self.deviceManager.hasNumbersButton;
                        self.cardInfo = cardInfo;
                        [subscriber sendCompleted];
                    } onError:^(NSError *error) {
                        @strongify(self);
                        self.stateMessage = @"读卡失败!";
                        [subscriber sendError:error];
                    }];
                } else {
                    self.stateMessage = @"设备未连接";
                    [subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:@"设备未连接"]];
                }
                return nil;
            }] deliverOnMainThread] replayLast] materialize];
        }];
    }
    return _cmd_cardReading;
}

/* cmd: pin加密 */
- (RACCommand *)cmd_pinEncrypting {
    @weakify(self);
    if (!_cmd_pinEncrypting) {
        _cmd_pinEncrypting = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [subscriber sendNext: nil];
                self.stateMessage = @"正在加密密码...";
                if (self.deviceManager.connected) {
                    [self.deviceManager encryptPinSource:self.pinSource onEncrypted:^(NSString *pin) {
                        @strongify(self);
                        self.stateMessage = @"加密成功!";
                        self.pinEncrypted = pin;
                        [subscriber sendCompleted];
                    } onError:^(NSError *error) {
                        @strongify(self);
                        self.stateMessage = @"加密失败!";
                        [subscriber sendError:error];
                    }];
                } else {
                    self.stateMessage = @"设备未连接";
                    [subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:@"设备未连接"]];
                }

                return nil;
            }] replayLast] materialize];;
        }];
    }
    return _cmd_pinEncrypting;
}

/* cmd: mac计算 */
- (RACCommand *)cmd_macCalculating {
    @weakify(self);
    if (!_cmd_macCalculating) {
        _cmd_macCalculating = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [subscriber sendNext: nil];
                @strongify(self);
                self.stateMessage = @"正在计算MAC...";
                if (self.deviceManager.connected) {
                    [self.deviceManager encryptMacSource:self.macSource onEncrypted:^(NSString *mac) {
                        @strongify(self);
                        self.stateMessage = @"计算MAC成功!";
                        self.macCalculated = mac;
                        [subscriber sendCompleted];
                    } onError:^(NSError *error) {
                        @strongify(self);
                        self.stateMessage = @"计算MAC失败!";
                        [subscriber sendError:error];
                    }];
                } else {
                    self.stateMessage = @"设备未连接";
                    [subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:@"设备未连接"]];
                }
                return nil;
            }] replayLast] materialize];;
        }];
    }
    return _cmd_macCalculating;
}

- (NSString *)money {
    if (!_money) {
        _money = [NSString stringWithFormat:@"%012ld", [MTransMoneyCache sharedMoney].curMoneyUniteMinute];
    }
    return _money;
}


@end
