//
//  TCPKeysVModel.h
//  JLPay
//
//  Created by jielian on 16/4/18.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelTCPTransPacking.h"
#import "TcpClientService.h"
#import "PublicInformation.h"
#import "Packing8583.h"
#import "Unpacking8583.h"
#import "EncodeString.h"
#import "MLoginSavedResource.h"
#import "NSError+Custom.h"

/* ***** 等后面重写了socket后再换block的VM ****** */
#import "ViewModelTCPHandleWithDevice.h"


@interface TCPKeysVModel : NSObject
<ViewModelTCPHandleWithDeviceDelegate>

@property (nonatomic, copy) NSString* terminalNumber;
@property (nonatomic, copy) NSString* mainKey;
@property (nonatomic, copy) NSString* workKey;

@property (nonatomic, strong) NSString* stateMessage; // 在控制器中监控，并显示状态信息


@property (nonatomic, strong) ViewModelTCPHandleWithDevice* tcpHandle;

@property (nonatomic, copy) void (^ finishedBlock) (void);
@property (nonatomic, copy) void (^ errorBlock) (NSError* error);


- (void) gettingKeysOnFinished:(void (^) (void))finished onError:(void (^) (NSError* error))errorBlock;

@end
