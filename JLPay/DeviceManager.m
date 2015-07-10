//
//  DeviceManager.m
//  JLPay
//
//  Created by jielian on 15/6/1.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "DeviceManager.h"
#import "Define_Header.h"
#import "JHLDevice.h"
#import "JHL_M60/ISControlManager.h"
#import "JHL_M60/JHLDevice_M60.h"

/*
 *  厂商设备添加流程:
 *  1.interface属性中添加
 *  2.init中添加新设备操作类的初始化
 *  3.
 */

@interface DeviceManager()<JHLDevice_M60_Delegate>
@property (nonatomic, assign) NSArray*          deviceManagers;     // 保存所有厂商的设备管理类入口
@property (nonatomic, strong) JHLDevice*        JHL_A60_manager;    // 音频设备管理器 锦宏霖
@property (nonatomic, strong) JHLDevice_M60*    JHL_M60_manager;    // 蓝牙设备管理器 锦宏霖
@property (nonatomic, strong) NSMutableArray*   terminalArray;      // 所有已连接设备的终端号
@property (nonatomic, strong) NSMutableArray*   SNVersionArray;

@property (nonatomic, strong) id    device;
@property (nonatomic, assign) int   manuefacturer;
@end


@implementation DeviceManager
@synthesize delegate;
@synthesize device = _device;
@synthesize manuefacturer = _manuefacturer;
//@synthesize deviceType;
@synthesize terminalArray = _terminalArray;
@synthesize SNVersionArray = _SNVersionArray;


static long timeOut = 60*1000;
static DeviceManager* _sharedDeviceManager = nil;

#pragma mask --------------------------[Public Interface]--------------------------
+(DeviceManager*) sharedInstance {
    static dispatch_once_t desp;
    dispatch_once(&desp, ^{
        _sharedDeviceManager = [[DeviceManager alloc] init];
    });
    return _sharedDeviceManager;
}


#pragma mask : 打开设备探测;  ---- 暂时无用
- (void) detecting{
    switch (self.manuefacturer) {
        case 0:
            [self.device detecting];
            break;
            
        default:
            break;
    }
}

#pragma mask : 打开设备:要匹配终端号;
- (void)open {
    // 判断是哪个厂商的设备
    // 调对应厂商的设备接口 : 打开设备
    switch (self.manuefacturer) {
        case 0:     // 锦宏霖设备
            [self.device open];
            break;
    
        default:
            break;
    }
}


#pragma mask : 关闭设备;
- (void) close {
    
}

#pragma mask : 检测设备是否连接;
- (BOOL) isConnected {
    BOOL result;
    NSString* ideviceType = [[NSUserDefaults standardUserDefaults] valueForKey:DeviceType];
    if ([ideviceType isEqualToString:DeviceType_JHL_A60]) {
//        result = [self.JHL_A60_manager isConnected];
    } else if ([ideviceType isEqualToString:DeviceType_JHL_M60]) {
        // 怎样判断 m60 设备是连接的
    }
    return result;
}

#pragma mask : 刷卡
- (int) cardSwipe{
    int result;
    
    if ([[self deviceType] isEqualToString:DeviceType_JHL_A60]) {           // 锦宏霖音频设备
        
    } else if ([[self deviceType] isEqualToString:DeviceType_JHL_M60]) {    // 锦宏霖蓝牙设备
        // 有金额+无密码 刷卡模式
    }
    
//    switch (self.manuefacturer) {
//        case 0:     // 锦宏霖设备
//            result = [self.device cardSwipeInTime:timeOut mount:0 mode:0];
//            break;
//            
//        default:
//            break;
//    }
    return result;
}


#pragma mask : 刷磁消费
-(int)TRANS_Sale:(long)timeout nAmount:(long)nAmount nPasswordlen:(int)nPasswordlen bPassKey:(NSString*)bPassKey{
    int result;
    switch (self.manuefacturer) {
        case 0:     // 锦宏霖设备
            result = [self.device TRANS_Sale:timeout :nAmount :nPasswordlen :bPassKey];
            break;
            
        default:
            break;
    }
    return result;
}





#pragma mask : 主密钥下载
- (int) mainKeyDownload{
    return 0;
}

#pragma mask : 工作密钥设置
-(int)WriteWorkKey:(int)len :(NSString*)DataWorkkey {
    int result;
    switch (self.manuefacturer) {
        case 0:     // 锦宏霖设备
            result                  = [self.device WriteWorkKey:len :DataWorkkey];
            break;
            
        default:
            break;
    }
    return result;

}


#pragma mask : 参数下载
- (int) parameterDownload{
    return 0;
}
#pragma mask : IC卡公钥下载
- (int) ICPublicKeyDownload{
    return 0;
}
#pragma mask : EMV参数下载
- (int) EMVDownload{
    return 0;
}



#pragma mask --------------------------------- 新接口

#pragma mask : 打开所有设备
- (void) openAllDevices{
    NSString* ideviceType = [[NSUserDefaults standardUserDefaults] valueForKey:DeviceType];
    if ([ideviceType isEqualToString:DeviceType_JHL_A60]) {          // 锦宏霖音频设备
        
    }
    else if ([ideviceType isEqualToString:DeviceType_JHL_M60]) {     // 锦宏霖蓝牙设备
        [self.JHL_M60_manager openAllDevices];
    }
}


// pragma mask : 判断指定终端号的设备是否已连接
- (BOOL) isConnectedOnTerminalNum:(NSString*)terminalNum {
    BOOL result = NO;
    if ([[self deviceType] isEqualToString:DeviceType_JHL_A60]) {
        
    }
    else if ([[self deviceType] isEqualToString:DeviceType_JHL_M60]) {
        result = [self.JHL_M60_manager isConnectedOnTerminalNum:terminalNum];
    }
    return result;
}

// pragma mask : 判断指定SN号的设备是否已连接
- (BOOL) isConnectedOnSNVersionNum:(NSString*)SNVersion {
    BOOL result = NO;
    if ([[self deviceType] isEqualToString:DeviceType_JHL_A60]) {
        
    }
    else if ([[self deviceType] isEqualToString:DeviceType_JHL_M60]) {
        result = [self.JHL_M60_manager isConnectedOnSNVersionNum:SNVersion];
    }
    return result;
}

// pragma mask : 设置设备的终端号+商户号(指定设备的SN号)
- (void) writeTerminalNum:(NSString*)terminalNumAndBusinessNum onSNVersion:(NSString*)SNVersion {
    if ([[self deviceType] isEqualToString:DeviceType_JHL_A60]) {
        
    }
    else if ([[self deviceType] isEqualToString:DeviceType_JHL_M60]) {
        [self.JHL_M60_manager writeTerminalNum:terminalNumAndBusinessNum onSNVersion:SNVersion];
    }
}
// pragma mask : 设置设备主密钥(指定设备的SN号)
- (void) writeMainKey:(NSString*)mainKey onSNVersion:(NSString*)SNVersion {
    if ([[self deviceType] isEqualToString:DeviceType_JHL_A60]) {
        
    }
    else if ([[self deviceType] isEqualToString:DeviceType_JHL_M60]) {
        [self.JHL_M60_manager writeMainKey:mainKey onSNVersion:SNVersion];
    }

}
// pragma mask : 设置设备工作密钥(指定设备的终端号)
- (void) writeWorkKey:(NSString*)workKey onTerminal:(NSString*)terminalNum {
    if ([[self deviceType] isEqualToString:DeviceType_JHL_A60]) {
        
    }
    else if ([[self deviceType] isEqualToString:DeviceType_JHL_M60]) {
        [self.JHL_M60_manager writeWorkKey:workKey onTerminal:terminalNum];
    }

}
// pragma mask : 刷卡: 有金额+无密码, 无金额+无密码,
- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onTerminal:(NSString*)terminalNum {
    if ([[self deviceType] isEqualToString:DeviceType_JHL_A60]) {
        
    }
    else if ([[self deviceType] isEqualToString:DeviceType_JHL_M60]) {
        [self.JHL_M60_manager cardSwipeWithMoney:money yesOrNot:yesOrNot onTerminal:terminalNum];
    }

}


#pragma mask -------------------------- JHLDevice_M60_Delegate
// 设备终端号列表刷新的回调协议
- (void)renewTerminalNumbers:(NSArray *)terminalNumbers {
    [self.terminalArray removeAllObjects];
    [self.terminalArray addObjectsFromArray:terminalNumbers];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(deviceManager:updatedTerminalArray:)]) {
        [self.delegate deviceManager:self updatedTerminalArray:self.terminalArray];
    }
}
// SN号的更新回调
- (void)renewSNVersionNumbers:(NSArray *)SNVersionNumbers {
    [self.SNVersionArray removeAllObjects];
    [self.SNVersionArray addObjectsFromArray:SNVersionNumbers];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(deviceManager:updatedSNVersionArray:)]) {
        [self.delegate deviceManager:self updatedSNVersionArray:self.SNVersionArray];
    }
}
// 设置终端号+商户号的回调
- (void)didWriteTerminalNumSucOrFail:(BOOL)yesOrNo withError:(NSString *)error {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(deviceManager:didWriteTerminalSuccessOrNot:withMessage:)]) {
        [self.delegate deviceManager:self didWriteTerminalSuccessOrNot:yesOrNo withMessage:error];
    }
}
// 设置主密钥的回调
- (void)didWriteMainKeySucOrFail:(BOOL)yesOrNo withError:(NSString *)error {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(deviceManager:didWriteMainKeySuccessOrNot:withMessage:)]) {
        [self.delegate deviceManager:self didWriteMainKeySuccessOrNot:yesOrNo withMessage:error];
    }
}
// 设置工作密钥的回调
- (void)didWriteWorkKeySucOrFail:(BOOL)yesOrNo withError:(NSString *)error {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(deviceManager:didWriteWorkKeySuccessOrNot:)]) {
        [self.delegate deviceManager:self didWriteWorkKeySuccessOrNot:yesOrNo];
    }
}
// 刷卡的回调
- (void)didCardSwipedSucOrFail:(BOOL)yesOrNo withError:(NSString *)error {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(deviceManager:didSwipeSuccessOrNot:withMessage:)]) {
        [self.delegate deviceManager:self didSwipeSuccessOrNot:yesOrNo withMessage:error];
    }
}

#pragma mask --------------------------[Private Interface]--------------------------

/*
 *  初始化
 *  所有厂商设备的管理器都要初始化;
 */
- (instancetype)init {
    self = [super init];
    if (self) {
        _JHL_A60_manager = nil;
        _JHL_M60_manager = [[JHLDevice_M60 alloc] init];
        [_JHL_M60_manager setDelegate:self];

    }
    return self;
}
// 所有已连接设备的终端号
- (NSMutableArray *)terminalArray {
    if (_terminalArray == nil) {
        _terminalArray = [[NSMutableArray alloc] init];
    }
    return _terminalArray;
}
// 所有已连接设备的SN号
- (NSMutableArray *)SNVersionArray {
    if (_SNVersionArray == nil) {
        _SNVersionArray = [[NSMutableArray alloc] init];
    }
    return _SNVersionArray;
}
// 获取配置中的设备类型
- (NSString*) deviceType {
    return [[NSUserDefaults standardUserDefaults] valueForKey:DeviceType];
}

@end
