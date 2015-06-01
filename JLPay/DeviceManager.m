//
//  DeviceManager.m
//  JLPay
//
//  Created by jielian on 15/6/1.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "DeviceManager.h"
#import "JHLDevice.h"


@interface DeviceManager()
@property (nonatomic, strong) id    device;
@property (nonatomic, assign) int   getManuefacturer;
@end



@implementation DeviceManager

@synthesize device                  = _device;
@synthesize getManuefacturer        = _getManuefacturer;



#pragma mask --------------------------[Public Interface]--------------------------

#pragma mask : 打开设备;
- (void)open {
    // 判断是哪个厂商的设备
    // 调对应厂商的设备接口 : 打开设备
    switch (self.getManuefacturer) {
        case 0:
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
    switch (self.getManuefacturer) {
        case 0:
            // 锦宏霖设备
            result                  = [self.device isConnected];
            break;
            
        default:
            break;
    }
    return result;
}

#pragma mask : 刷卡
- (int) cardSwipe{
    int result;
    switch (self.getManuefacturer) {
        case 0:
            // 锦宏霖设备
            result                  = [self.device cardSwipeInTime:20000 mount:0 mode:0];
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


#pragma mask --------------------------[Private Interface]--------------------------

/*
 *  初始化
 */
- (instancetype)init {
    self                            = [super init];
    if (self) {
        // 找到对应设备的厂商：从 userDefult 配置中读取当前设备的厂商：绑定的设备的时候设定....
        // 调度对应厂商的接口
        _getManuefacturer        = 0; // 锦宏霖
        
        switch (_getManuefacturer) {
            case 0:
                _device             = [[JHLDevice alloc] init];
                break;
                
            default:
                break;
        }

    }
    return self;
}



@end
