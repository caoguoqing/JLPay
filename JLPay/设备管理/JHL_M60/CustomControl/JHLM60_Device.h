//
//  JHLM60_Device.h
//  JLPay
//
//  Created by jielian on 16/3/18.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISDataPath.h"
#import "ISControlManager.h"
#import "ISBLEDataPath.h"
#import "ISMFiDataPath.h"

@interface JHLM60_Device : NSObject

// -- 扫描设备;回调中刷新扫描到的设备列表
- (void) startScanningOnDeviceScanned:(void (^) (CBPeripheral* deviceScanned))scannedBlock;

// -- 关闭扫描
- (void) stopScanning;

// -- 连接设备
- (void) connectDevice:(CBPeripheral*)device
            onSucBlock:(void (^) (void))sucBlock
          onErrorBlock:(void (^) (NSError* error))errBlock;

// -- 断开设备
- (void) disconnect;

// -- 读取SN
- (void) readSNVersionOnReaded:(void (^) (NSString* SNVersionReaded))onReaded
                  onErrorBlock:(void (^) (NSError* error))errBlock;

// -- write mainKey
// -- write workKey
// -- card swipe
// -- pin encrypt
// -- mac encrypt

@end
