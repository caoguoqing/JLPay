//
//  DC_VMDeviceDataSource.h
//  JLPay
//
//  Created by 冯金龙 on 16/9/7.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DeviceManager.h"


@class CBPeripheral;

@interface DC_VMDeviceDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>


/* 状态信息: 外部显示用 */
@property (nonatomic, strong) NSString* deviceStatus;

/* 设备列表: 每扫描到一个设备就更新一次 */
@property (nonatomic, strong) NSArray<CBPeripheral*>* deviceList;

/* 勾选的设备 */
@property (nonatomic, copy) CBPeripheral* deviceSelected;

/* 主密钥: 传入 */
@property (nonatomic, copy) NSString* mainKeyPin;

/* 工作密钥: 传入 */
@property (nonatomic, copy) NSString* workKeyPin;

@property (nonatomic, strong) DeviceManager* deviceManager;


/* 扫描设备 */
- (void) startDeviceScanning;
/* 停止设备扫描 */
- (void) stopDeviceScanning;


/* 连接设备 */
- (void) connectDeviceOnFinished:(void (^) (void))finished onError:(void (^) (NSError* error))errorBlock;
/* 断开设备 */
- (void) disconnectDeviceOnFinished:(void (^) (void))finished;


/* 写密钥(主密钥+工作密钥) */
- (void) writeKeyPinsOnFinished:(void (^) (void))finishedBlock onError:(void (^) (NSError* error))errorBlock;



@end
