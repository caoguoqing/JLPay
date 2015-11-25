//
//  ViewModelTCPHandleWithDevice.h
//  JLPay
//
//  Created by jielian on 15/11/24.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 * 设备操作的 TCP model : 包含工作密钥、主密钥的获取
 */

@class ViewModelTCPHandleWithDevice;
@protocol ViewModelTCPHandleWithDeviceDelegate <NSObject>

@optional
/* 回调: 主密钥 */
- (void) didDownloadedMainKeyResult:(BOOL)result withMainKey:(NSString*)mainKey;
/* 回调: 工作密钥 */
- (void) didDownloadedWorkKeyResult:(BOOL)result withWorkKey:(NSString*)workKey;

@end


@interface ViewModelTCPHandleWithDevice : NSObject

/* 下载主密钥 */
- (void) downloadMainKeyWithBusinessNum:(NSString*)businessNum andTerminalNum:(NSString*)terminalNum;
/* 下载工作密钥 */
- (void) downloadWorkKeyWithBusinessNum:(NSString*)businessNum andTerminalNum:(NSString*)terminalNum;

@end
