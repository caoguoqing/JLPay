//
//  DC_VMDeviceDataSource.m
//  JLPay
//
//  Created by 冯金龙 on 16/9/7.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DC_VMDeviceDataSource.h"
#import "DC_deviceSelectCell.h"
#import <ReactiveCocoa.h>




@interface DC_VMDeviceDataSource()


@end

@implementation DC_VMDeviceDataSource


/* 扫描设备 */
- (void)startDeviceScanning {
    self.deviceStatus = @"正在扫描设备...";
    @weakify(self);
    [self.deviceManager startScanningOnDiscovered:^(CBPeripheral *peripheral) {
        @strongify(self);
        NSMutableArray* curDevices = [NSMutableArray arrayWithArray:self.deviceList];
        BOOL contained = NO;
        for (CBPeripheral* device in curDevices) {
            if ([device.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                contained = YES;
            }
        }
        if (!contained) {
            [curDevices addObject:peripheral];
            self.deviceStatus = [NSString stringWithFormat:@"已扫描到[%ld]台设备...请选择", curDevices.count];
            self.deviceList = [NSArray arrayWithArray:curDevices];
        }
    }];
}

/* 关闭扫描 */
- (void)stopDeviceScanning {
    self.deviceList = [NSArray array];
    [self.deviceManager stopScanning];
}

/* 连接设备 */
- (void)connectDeviceOnFinished:(void (^)(void))finished onError:(void (^)(NSError *))errorBlock {
    @weakify(self);
    if ([self.deviceManager connected]) {
        /* 先断已连,再连接新设备 */
        [self disconnectDeviceOnFinished:^{
            @strongify(self);
            self.deviceStatus = [NSString stringWithFormat:@"正在连接设备[%@]...", self.deviceSelected.name];
            [self.deviceManager connectPeripheral:self.deviceSelected onConnected:^(NSString *SNVersion) {
                @strongify(self);
                self.deviceStatus = @"设备已连接,请点击'绑定设备'!";
                if (finished) {
                    finished();
                }
            } onError:^(NSError *error) {
                @strongify(self);
                self.deviceStatus = [NSString stringWithFormat:@"连接失败:[%@]", [error localizedDescription]];
                if (errorBlock) {
                    errorBlock(error);
                }
            }];
        }];
    }  else {
        /* 未连,直接连接新设备 */
        self.deviceStatus = [NSString stringWithFormat:@"正在连接设备[%@]...", self.deviceSelected.name];
        [self.deviceManager connectPeripheral:self.deviceSelected onConnected:^(NSString *SNVersion) {
            @strongify(self);
            self.deviceStatus = @"设备已连接,请点击'绑定设备'!";
            if (finished) {
                finished();
            }
        } onError:^(NSError *error) {
            @strongify(self);
            self.deviceStatus = [NSString stringWithFormat:@"连接失败:[%@]", [error localizedDescription]];
            if (errorBlock) {
                errorBlock(error);
            }
        }];

    }
}

/* 断开设备 */
- (void)disconnectDeviceOnFinished:(void (^)(void))finished {
    self.deviceStatus = @"正在断开设备...";
    @weakify(self);
    [self.deviceManager disconnectOnFinished:^{
        @strongify(self);
        self.deviceStatus = @"设备已断开,请重新选择";
        if (finished) {
            finished();
        }
    }];
}

/* 写主密钥+工作秘钥 */
- (void)writeKeyPinsOnFinished:(void (^)(void))finishedBlock onError:(void (^)(NSError *))errorBlock {
    @weakify(self);
    self.deviceStatus = @"正在写主密钥...";
    [self.deviceManager writeMainKey:self.mainKeyPin onFinished:^{
        @strongify(self);
        self.deviceStatus = @"正在写工作密钥...";
        [self.deviceManager writeWorkKey:self.workKeyPin onFinished:^{
            @strongify(self);
            self.deviceStatus = @"绑定设备成功!请'保存'.";
            if (finishedBlock) {
                finishedBlock();
            }
        } onError:^(NSError *error) {
            @strongify(self);
            self.deviceStatus = [NSString stringWithFormat:@"写工作密钥失败:[%@]", [error localizedDescription]];
            if (errorBlock) {
                errorBlock(error);
            }
        }];
    } onError:^(NSError *error) {
        @strongify(self);
        self.deviceStatus = [NSString stringWithFormat:@"写主密钥失败:[%@]", [error localizedDescription]];
        if (errorBlock) {
            errorBlock(error);
        }
    }];

}


# pragma mask 2  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DC_deviceSelectCell* cell = [tableView dequeueReusableCellWithIdentifier:@"dc_deviceSelectCell"];
    if (!cell) {
        cell = [[DC_deviceSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dc_deviceSelectCell"];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
        cell.contentView.layer.cornerRadius = 6.f;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    CBPeripheral* device = [self.deviceList objectAtIndex:indexPath.row];
    cell.textLabel.text = [device name];
    if ([device.identifier.UUIDString isEqualToString:self.deviceSelected.identifier.UUIDString]) {
        cell.deviceSelected = YES;
    } else {
        cell.deviceSelected = NO;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

# pragma mask 2  UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    DC_deviceSelectCell* deviceCell = (DC_deviceSelectCell*)cell;
    
    
    [deviceCell setNeedsUpdateConstraints];
    [deviceCell updateConstraintsIfNeeded];
    [deviceCell layoutIfNeeded];
    
    deviceCell.textLabel.font = [UIFont boldSystemFontOfSize:[NSString resizeFontAtHeight:deviceCell.frame.size.height scale:0.45]];
    deviceCell.checkLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:deviceCell.checkLabel.frame.size.height scale:0.8]];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CBPeripheral* curSelectedDevice = [self.deviceList objectAtIndex:indexPath.row];
    if ([self.deviceSelected.identifier.UUIDString isEqualToString:curSelectedDevice.identifier.UUIDString]) {
        self.deviceSelected = nil;
    } else {
        self.deviceSelected = [self.deviceList objectAtIndex:indexPath.row];
    }
    [tableView reloadData];
}




# pragma mask 4 getter

- (NSArray<CBPeripheral *> *)deviceList {
    if (!_deviceList) {
        _deviceList = [NSArray array];
    }
    return _deviceList;
}

- (DeviceManager *)deviceManager {
    if (!_deviceManager) {
        _deviceManager = [[DeviceManager alloc] init];
    }
    return _deviceManager;
}


@end
