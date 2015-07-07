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

@property (nonatomic, strong) id    device;
@property (nonatomic, assign) int   manuefacturer;
@end


@implementation DeviceManager
@synthesize delegate;
@synthesize device = _device;
@synthesize manuefacturer = _manuefacturer;
@synthesize deviceType;
@synthesize terminalArray = _terminalArray;


static long timeOut = 60*1000;

#pragma mask --------------------------[Public Interface]--------------------------
static DeviceManager* _sharedDeviceManager;
+(DeviceManager*) sharedInstance {
    static dispatch_once_t desp;
    dispatch_once(&desp, ^{
        _sharedDeviceManager = [[DeviceManager alloc] init];
    });
    return _sharedDeviceManager;
}


#pragma mask : 打开设备探测;
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
    switch (self.manuefacturer) {
        case 0:     // 锦宏霖设备
            result = [self.device isConnected];
            break;
            
        default:
            break;
    }
    return result;
}

#pragma mask : 刷卡
- (int) cardSwipe{
    int result;
    switch (self.manuefacturer) {
        case 0:     // 锦宏霖设备
            result = [self.device cardSwipeInTime:timeOut mount:0 mode:0];
            break;
            
        default:
            break;
    }
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

#pragma mask : 打开所有设备
- (void) openAllDevices{
    NSString* ideviceType = [[NSUserDefaults standardUserDefaults] valueForKey:DeviceType];
    if ([ideviceType isEqualToString:DeviceType_JHL_A60]) {          // 锦宏霖音频设备
        
    }
    else if ([ideviceType isEqualToString:DeviceType_JHL_M60]) {     // 锦宏霖蓝牙设备
        [self.JHL_M60_manager openAllDevices];
    }
}
#pragma mask : 读取所有设备的终端号
- (NSArray*) terminalNumArrayOfReading{
    NSArray* terminalNumsArray;
    return terminalNumsArray;
}
#pragma mask : 仅保留指定终端号的设备
- (void) retainDeviceWithTerminalNum:(NSString*)terminalNum{
    
}



#pragma mask -------------------------- JHLDevice_M60_Delegate
// 设备获取到终端号的回调协议
//- (void)didReadingTerminalNo:(NSString *)terminalNo {
//    NSLog(@"JHLDevice_M60_Delegate 的回调:");
//    if ([self.terminalArray indexOfObject:terminalNo] == NSNotFound) {
//        [self.terminalArray addObject:terminalNo];
//        // 更新调用者的终端号列表
//        [self.delegate deviceManager:self updatedTerminalArray:self.terminalArray];
//        NSLog(@"获取到更新的终端号列表[%@]", self.terminalArray);
//    }
//}
// 设备终端号列表刷新的回调协议
- (void)renewTerminalNumbers:(NSArray *)terminalNumbers {
    [self.terminalArray removeAllObjects];
    [self.terminalArray addObjectsFromArray:terminalNumbers];
    if (self.delegate && [self.delegate respondsToSelector:@selector(deviceManager:updatedTerminalArray:)]) {
        [self.delegate deviceManager:self updatedTerminalArray:self.terminalArray];
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
        deviceType = nil;
        _JHL_A60_manager = nil;
        _JHL_M60_manager = [[JHLDevice_M60 alloc] init];
        [_JHL_M60_manager setDelegate:self];
        
        
        
        /* ------------------下面是没用了的操作，完成M60对接后可以删除了 */
        // 找到对应设备的厂商：从 userDefult 配置中读取当前设备的厂商：绑定的设备的时候设定....
        // 调度对应厂商的接口
        _manuefacturer = 1; // 锦宏霖
        
        switch (_manuefacturer) {
            case 0:
                _device = [[JHLDevice alloc] init];
                break;
                
            default:
                break;
        }

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



@end
