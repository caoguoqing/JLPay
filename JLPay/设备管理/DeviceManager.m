//
//  DeviceManager.m
//  JLPay
//
//  Created by jielian on 15/6/1.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "DeviceManager.h"
#import "Define_Header.h"
#import "ModelDeviceBindedInformation.h"

#import "DLDevice_DL01.h"
#import "LDDevice_M18.h"
#import "JLPayDevice_TY01.h"


/*
 *  厂商设备添加流程:
 *  1.interface属性中添加
 *  2.init中添加新设备操作类的初始化
 */

@interface DeviceManager()
< /* delegate */
DLDevice_DL01Delegate,
LDDevice_M18Delegate,
JLPayDevice_TY01_Delegate
>
@property (nonatomic, strong) id                device;
@property (nonatomic, strong) NSString*         deviceType;

@end


@implementation DeviceManager
@synthesize deviceType = _deviceType;
@synthesize device;
@synthesize delegate;


#pragma mask --------------------------[Public Interface]--------------------------

#pragma mask : 创建或获取设备操作入口:单例
+(DeviceManager*) sharedInstance {
    static DeviceManager* _sharedDeviceManager = nil;
    static dispatch_once_t desp;
    dispatch_once(&desp, ^{
        _sharedDeviceManager = [[DeviceManager alloc] init];
    });
    return _sharedDeviceManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

# pragma mask : 设置并创建指定的设备入口
- (void) makeDeviceEntryOnDeviceType:(NSString*)deviceType {
    if (![deviceType isEqualToString:self.deviceType]) {
        [self setDeviceType:deviceType];
        if (self.device) {
            [self setDevice:nil];
        }
    }
    if (!self.device) {
        [self makeDeviceEntry];
    }
}

#pragma mask : 打开设备,用UUID打开
- (void) openDeviceWithIdentifier:(NSString*)identifier {
    JLPrint(@"连接设备:[%@]",identifier);
    [self.device openDeviceWithIdentifier:identifier];
}

#pragma mask : 清空设备入口
- (void) clearAndCloseAllDevices {
    self.delegate = nil;
    [self.device clearAndCloseAllDevices];
    self.deviceType = nil;
    self.device = nil;
}

#pragma mask : 设备是否连接,用SN判断  *  0:已打开，未连接  1:已连接  -1:未打开
- (BOOL) isConnectedOnSNVersionNum:(NSString*)SNVersion {
    return [self.device isConnectedOnSNVersionNum:SNVersion];
}

#pragma mask : 判断指定设备ID的设备是否已连接
- (BOOL)isConnectedOnIdentifier:(NSString*)identifier {
    return  [self.device isConnectedOnIdentifier:identifier];
}

# pragma mask : 设备ID:通过SN查找
- (NSString*) deviceIdentifierOnSN:(NSString*)SNVersion {
    return [self.device deviceIdentifierOnSN:SNVersion];
}

#pragma mask : 设置设备主密钥(指定设备的SN号)
- (void) writeMainKey:(NSString*)mainKey onSNVersion:(NSString*)SNVersion {
    [self.device writeMainKey:mainKey onSNVersion:SNVersion];
}

#pragma mask : 设置设备工作密钥(指定设备的SN号)
- (void) writeWorkKey:(NSString*)workKey onSNVersion:(NSString*)SNVersion {
    [self.device writeWorkKey:workKey onSNVersion:SNVersion];
}

#pragma mask : 刷卡: 有金额+无密码, 无金额+无密码,
- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onSNVersion:(NSString*)SNVersion {
    [self.device cardSwipeWithMoney:money yesOrNot:yesOrNot onSNVersion:SNVersion];
}

#pragma mask : PIN加密
- (void) pinEncryptBySource:(NSString*)source withPan:(NSString*)pan onSNVersion:(NSString*)SNVersion {
    if ([self.device respondsToSelector:@selector(pinEncryptBySource:withPan:onSNVersion:)]) {
        [self.device pinEncryptBySource:source withPan:pan onSNVersion:SNVersion];
    }
}

# pragma mask : MAC加密
- (void) macEncryptBySource:(NSString*)source onSNVersion:(NSString*)SNVersion {
    if ([self.device respondsToSelector:@selector(macEncryptBySource:onSNVersion:)]) {
        [self.device macEncryptBySource:source onSNVersion:SNVersion];
    }
}





# pragma mask 2 DEVICE DELEGATE

# pragma mask :  * 打开了设备
- (void)didConnectedDeviceResult:(BOOL)result onSucSN:(NSString *)SNVersion onErrMsg:(NSString *)errMsg
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectedDeviceResult:onSucSN:onErrMsg:)]) {
        [self.delegate didConnectedDeviceResult:result onSucSN:SNVersion onErrMsg:errMsg];
    }
}

# pragma mask :  * 设备丢失
- (void)didDisconnectDeviceOnSN:(NSString *)SNVersion {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDisconnectDeviceOnSN:)]) {
        [self.delegate didDisconnectDeviceOnSN:SNVersion];
    }
}

# pragma mask :  * 刷卡结果
- (void) didCardSwipedResult:(BOOL)result onSucCardInfo:(NSDictionary*)cardInfo onErrMsg:(NSString*)errMsg
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedResult:onSucCardInfo:onErrMsg:)]) {
        [self.delegate didCardSwipedResult:result onSucCardInfo:cardInfo onErrMsg:errMsg];
    }
}

# pragma mask :  * 写主密钥结果
- (void) didWroteMainKeyResult:(BOOL)result onErrMsg:(NSString*)errMsg
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteMainKeyResult:onErrMsg:)]) {
        [self.delegate didWroteMainKeyResult:result onErrMsg:errMsg];
    }
}

# pragma mask :  * 写工作密钥结果
- (void) didWroteWorkKeyResult:(BOOL)result onErrMsg:(NSString*)errMsg
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didWroteWorkKeyResult:onErrMsg:)]) {
        [self.delegate didWroteWorkKeyResult:result onErrMsg:errMsg];
    }
}

# pragma mask :  * PIN加密结果
- (void) didPinEncryptResult:(BOOL)result onSucPin:(NSString*)pin onErrMsg:(NSString*)errMsg
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPinEncryptResult:onSucPin:onErrMsg:)]) {
        [self.delegate didPinEncryptResult:result onSucPin:pin onErrMsg:errMsg];
    }
}

# pragma mask :  * MAC加密结果
- (void) didMacEncryptResult:(BOOL)result onSucMacPin:(NSString*)macPin onErrMsg:(NSString*)errMsg {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMacEncryptResult:onSucMacPin:onErrMsg:)]) {
        [self.delegate didMacEncryptResult:result onSucMacPin:macPin onErrMsg:errMsg];
    }
}



#pragma mask : 设置并创建指定的设备入口
- (void) makeDeviceEntry{
    if ([self.deviceType isEqualToString:DeviceType_DL01]) {
        self.device = [[DLDevice_DL01 alloc] initWithDelegate:self];
    }
    else if ([self.deviceType isEqualToString:DeviceType_LD_M18]) {
        self.device = [[LDDevice_M18 alloc] initWithDelegate:self];
    }
    else if ([self.deviceType isEqualToString:DeviceType_JLpay_TY01]) {
        self.device = [[JLPayDevice_TY01 alloc] initWithDelegate:self];
    }

}






@end
