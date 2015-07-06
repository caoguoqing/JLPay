//
//  JHLDevice_M60.m
//  JLPay
//
//  Created by jielian on 15/7/4.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "JHLDevice_M60.h"
#import "ISControlManager.h"
#import "ISDataPath.h"
#import "ISBLEDataPath.h"
#import "ISMFiDataPath.h"

@interface JHLDevice_M60()<ISControlManagerDeviceList,ISControlManagerDelegate>{
    NSMutableArray *deviceList;   //查询到的设备名称列表
    NSMutableArray *connectedList;  //连接成功的列表
    CBPeripheralState    nstate;  //当前连接状态
    BOOL           isConnect;        //判断是否连接
    NSTimer *scannDeviceListTimer;   //查询超时时间
    NSTimer *sendDeviceListTimer;   //发送超时时间
    FieldTrackData TransData;       //磁道数据
    BOOL   isAllData;
    uint8_t ByteReviceDate[Revice_MAX_LEN];
    int  nTotalDatalen;
    int nOffsetLen;
    int connectionStatus;
}
@property (nonatomic, retain) ISControlManager* manager;
@property (nonatomic, strong) NSMutableArray* knownDeviceList;             // 已识别设备列表
@property (nonatomic, strong) NSMutableArray* connectedDeviceList;         // 已连接设备列表
@property (nonatomic, assign) BOOL needOpenDevices;
@end


@implementation JHLDevice_M60
@synthesize manager = _manager;
@synthesize knownDeviceList = _knownDeviceList;
@synthesize connectedDeviceList = _connectedDeviceList;
@synthesize needOpenDevices;


#pragma mask ===================== [Public interface]
/*
 * 函  数: openAllDevices
 * 功  能: 打开所有蓝牙设备;
 *         需要重新扫描设备列表;
 *         扫描完成后，在回调中打开所有已识别设备
 *         并读取打开设备的设备号
 * 参  数: 无
 * 返  回: 无
 */
- (void)openAllDevices {
    self.needOpenDevices = YES;
    [self startScanning];
}




/*
 * 函  数: startScanning
 * 功  能: 开始扫描所有的蓝牙设备;
 *         识别到得设备会进入列表_knownDeviceList;
 * 参  数: 无
 * 返  回: 无
 */
- (void) startScanning {
    // 设置了yes才能刷新已识别设备列表,并打开
    self.needOpenDevices = YES;
    [self.manager stopScaning];
    // 重新扫描设备
    [self.manager scanDeviceList:ISControlManagerTypeCB];
}

/*
 * 函  数: openWithTerminalNo
 * 功  能: 开始扫描所有的蓝牙设备;
 *         识别到得设备会进入列表_knownDeviceList;
 * 参  数: 无
 * 返  回: 无
 */
- (void) openWithTerminalNo:(NSString*)terminalNo {
    self.needOpenDevices = NO;
}





// 初始化::
- (instancetype)init {
    self = [super init];
    if (self) {
        _manager = [ISControlManager sharedInstance];
        [_manager setDelegate:self];    // 设备操作类的回调入口
        [_manager setDeviceList:self];  // 设备列表的回调入口
        _knownDeviceList = [[NSMutableArray alloc] init];
        _connectedDeviceList = [[NSMutableArray alloc] init];
        needOpenDevices = NO;
    }
    return self;
}


#pragma mask ===================== [Private interface]


#pragma mask --------------------- ISControlManagerDelegate
// 已经断开了跟设备的连接
- (void)accessoryDidDisconnect {
    // 要更新设备列表
}

// 设备完成连接
- (void)accessoryDidConnect:(ISDataPath *)accessory{
    // 读取设备终端号，并追加到终端号列表，并调用协议方法，去更新数据
    [self readTerminalNo];
}

// 已经读取到设备返回的数据
- (void)accessoryDidReadData:(ISDataPath *)accessory data:(NSData *)data{
    static uint8_t ByteDate[Revice_MAX_LEN]={0x00};
    static NSInteger idx=0;
    static BOOL TrID = TRUE;
    NSUInteger len = 0;
    idx = 0;
    TrID = TRUE;
    if ([data length] > 1024-idx) {
        len = 1024-idx;
    }
    else {
        len = [data length];
    }
    [data getBytes:&ByteDate[idx] length:len];
    memcpy(ByteReviceDate+nOffsetLen, ByteDate, len);
    nOffsetLen +=len;
    if (!isAllData)  //准备接收数据,第一二个字节为大小
    {
        nTotalDatalen = ((ByteDate[0] << 8) & 0xFF00);
        nTotalDatalen |= ByteDate[1] & 0xFF;
        isAllData =true;
    }
    if (nTotalDatalen +2 !=nOffsetLen)  //数据没收全
    {
        return;
    }
    
    
    //接收到数据,复位时间
    if (sendDeviceListTimer) {
        [sendDeviceListTimer invalidate];
        sendDeviceListTimer = nil;
    }
    memset(ByteDate, 0x00, Revice_MAX_LEN);
    memcpy(ByteDate, ByteReviceDate+2, nOffsetLen-2);
    data = [[NSData alloc] initWithBytes:ByteDate length:nOffsetLen-2];
    
    [self onReceive:data];
    [self  resetGetData];
}
// 完成向设备写数据:成功/失败还未知
- (void)accessoryDidWriteData:(ISDataPath *)accessory bytes:(int)bytes complete:(BOOL)complete{
    
}
// 写设备数据失败
- (void)accessoryDidFailToWriteData:(ISDataPath *)accessory error:(NSError *)error{
    NSLog([NSString stringWithFormat:@"蓝牙设备交互数据失败:[%@]", error]);
}

#pragma mask --------------------- ISControlManagerDeviceList
/*
 * 蓝牙设备列表刷新后的回调;
 * 只保存 JHLM60 的设备
 * devices     : 已识别，但未连接
 * connectList : 已识别，且连接
 */
- (void)didGetDeviceList:(NSArray *)devices andConnected:(NSArray *)connectList {
    // 将名字前缀是 JHLM60 且是 ISBLEDataPath 类型的蓝牙设备添加到“已识别”列表
    [_knownDeviceList removeAllObjects];
    for (ISDataPath* dataPath in devices) {
        if ([dataPath.name hasPrefix:@"JHLM60"] &&                      // 前缀
            [dataPath isKindOfClass:[ISBLEDataPath class]] &&           // ISBLEDataPath
            [_knownDeviceList indexOfObject:dataPath] == NSNotFound)    // 列表中不能重复
        {
            [_knownDeviceList addObject:dataPath];
        }
    }
    
    // 将名字前缀是 JHLM60 且是 ISMFiDataPath 类型的蓝牙设备添加到“已连接”列表
    [_connectedDeviceList removeAllObjects];
    for (ISDataPath* dataPath in connectList) {
        if ([dataPath.name hasPrefix:@"JHLM60"] &&
            [dataPath isKindOfClass:[ISMFiDataPath class]] &&
            [_connectedDeviceList indexOfObject:dataPath] == NSNotFound)
        {
            [_connectedDeviceList addObject:dataPath];
        }
    }
    // 每次刷新完，先判断是否需要连接已识别的设备s
    if (self.needOpenDevices) {
        [self openInKnownDeviceList];
    }
}

/*
 * 函  数: openInKnownDeviceList
 * 功  能: 逐个打开已识别列表中得设备;
 *        一次只尝试打开一个；
 * 参  数: 无
 * 返  回: 无
 */
- (void) openInKnownDeviceList {
    ISBLEDataPath* needConnectDevice = nil;
    if (self.knownDeviceList.count > 0) {
        // 扫描设备列表，如果设备没连接就进行连接
        for (ISBLEDataPath* dataPath in self.knownDeviceList) {
            if ([dataPath state] == CBPeripheralStateDisconnected) {
                needConnectDevice = dataPath;
                break;
            }
        }
        if (needConnectDevice != nil) {
            [self.manager connectDevice:needConnectDevice];
        }
        
    }
}

#pragma mask --------------------- 设备交互
/*
 * 函  数: onReceive:
 * 功  能: 解析从蓝牙设备中读取的数据;
 * 参  数: 无
 * 返  回: 无
 */
-(void)onReceive:(NSData*)data{
    
    NSLog(@"%s %@",__func__,data);
    Byte * ByteDate = (Byte *)[data bytes];
    switch (ByteDate[0]) {
        case GETCARD_CMD:
            if (!ByteDate[1])   // 刷卡成功
            {
                NSLog(@"%s,result:%@",__func__,@"刷卡成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *strPan=@"";
                    int nlen =ByteDate[2]&0xff;
                    for (int i=0; i <nlen; i++) {
                        NSString *newHexStr = [NSString stringWithFormat:@"%02x",ByteDate[i+3]&0xff];///16进制数
                        strPan = [strPan stringByAppendingString:newHexStr];
                        
                    }
                    strPan =[self stringFromHexString:strPan];
                    
//                    if (Language ==0)
//                        self.LabTip.text = @"Credit Sucess,Waiting...";
//                    else
//                        self.LabTip.text = @"刷卡成功,请等待处理..";
                    
                    strPan = [@"PAN:" stringByAppendingString:strPan];
//                    self.TextViewTip.text =strPan;
                    // [self TRANS_Sale:20000:nAmount:5:@"12345"];
                });
                
                
                
                
            }
            else
            {
                NSLog(@"%s,result:%@",__func__,@"刷卡失败");
                dispatch_async(dispatch_get_main_queue(), ^{
//                    UIAlertView *alertTip;
//                    if (Language ==0)
//                        alertTip = [[UIAlertView alloc] initWithTitle:nil message:@"Credit card failure" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    else
//                        alertTip = [[UIAlertView alloc] initWithTitle:nil message:@"刷卡失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                    
//                    
//                    
//                    [alertTip show];
                    return;
                    
                });
                
                
            }
            
            break;
        case CHECK_IC:
            
            if (!ByteDate[1])   // 获取卡号数据成功
            {
                NSLog(@"%s,result:%@",__func__,@"获取卡号数据成功");
                dispatch_async(dispatch_get_main_queue(), ^{
//                    self.LabTip.text =@"待机界面插入IC卡";
                    
                    
                });
            }
            else
            {
                
                
                
                NSLog(@"%s,result:%@",__func__,@"获取卡号数据失败");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
//                    self.LabTip.text =@"正常交易状态插入IC卡";
                    
                });
            }
            
            
            break;
        case GETTRACK_CMD:
        case  GETTRACKDATA_CMD:
            if (!ByteDate[1])   // 获取卡号数据成功
            {
                NSLog(@"%s,result:%@",__func__,@"获取卡号数据成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
//                    [self GetCard:data];
                });
            }
            else
            {
                
                
                
                NSLog(@"%s,result:%@",__func__,@"获取卡号数据失败");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    
//                    if (ByteDate[1]==0xE1 )
//                        self.LabTip.text =@"获取卡号数据失败:用户取消";
//                    else if (ByteDate[1]==0xE2 )
//                        self.LabTip.text =@"获取卡号数据失败:超时退出";
//                    else if (ByteDate[1]==0xE3 )
//                        self.LabTip.text =@"获取卡号数据失败:IC卡数据处理失败";
//                    else if (ByteDate[1]==0xE4 )
//                        self.LabTip.text =@"获取卡号数据失败:无IC卡参数";
//                    else if (ByteDate[1]==0xE5 )
//                        self.LabTip.text =@"获取卡号数据失败:交易终止";
//                    else if (ByteDate[1]==0xE6 )
//                        self.LabTip.text =@"获取卡号数据失败:操作失败,请重试";
//                    else if (ByteDate[1]==0x02 )
//                        self.LabTip.text =@"获取卡号数据失败:操作失败,请重试";
//                    else if (ByteDate[1]==0x46 )
//                    {
//                        self.LabTip.text =@"MPOS已关机";
//                        [self disconnectDevices];
                    
//                    }
                    
                    
                });
            }
            break;
            
        case YY_GETTRACK_CMD:
        {
            
            NSLog(@"%s,result:%@",__func__,@"获取卡号数据成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self GetCard:data];
            });
        }
            
            break;
        case MAINKEY_CMD:
            if (!ByteDate[1])   // 主密钥设置成功
            {
                NSLog(@"%s,result:%@",__func__,@"主密钥设置成功");
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Set MainKey Sucess";
//                    else
//                        self.LabTip.text = @"主密钥设置成功";
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Set MainKey Fail";
//                    else
//                        self.LabTip.text = @"主密钥设置失败";
                });
                
            }
            
            
            break;
        case WORKKEY_CMD:
            if (!ByteDate[1])   // 工作密钥设置成功
            {
                NSLog(@"%s,result:%@",__func__,@"工作密钥设置成功");
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Set WorkKey Sucess";
//                    else
//                        self.LabTip.text = @"工作密钥设置成功";
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Set WorkKey Fail";
//                    else
//                        self.LabTip.text = @"工作密钥设置失败";
                });
                
            }
            break;
        case GETSNVERSION:
            if (!ByteDate[1])   // SN号获取成功
            {
                NSString * strSN =@"";
                for (int i=3; i <19; i++) {
                    NSString *newHexStr = [NSString stringWithFormat:@"%02x",ByteDate[i]&0xff];///16进制数
                    strSN = [strSN stringByAppendingString:newHexStr];
                    
                }
                strSN =[self stringFromHexString:strSN];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"SN获取成功  %@",strSN);
//                    self.LabTip.text = @"GET  SN  Sucess";
                    NSString * SN =@"SN:";
                    SN = [SN stringByAppendingString:strSN];
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:SN delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    self.TextViewTip.text = SN;
//                    [alert show];
                });
                
            }
            break;
        case GETMAC_CMD:
            if (!ByteDate[1])   // MAC
            {
                NSLog(@"%s,result:%@",__func__,@"MAC 获取成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString * strMAC =@"";
                    strMAC = [NSString stringWithFormat:@"%@",data];
                    strMAC = [strMAC stringByReplacingOccurrencesOfString:@" " withString:@""];
                    strMAC =[strMAC substringFromIndex:5];
                    strMAC = [strMAC substringToIndex:16];
                    
                    
                    strMAC = [@"MAC值:" stringByAppendingString:strMAC];
//                    self.TextViewTip.text =strMAC;
                    
//                    if (Language ==0)
//                        self.LabTip.text = @"GET  MAC  Sucess";
//                    else
//                        self.LabTip.text = @"MAC获取成功";
                    
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"GET  MAC  Fail";
//                    else
//                        self.LabTip.text = @"MAC获取失败";
                    
                });
                
            }
            
            
            
            break;
        case WRITETERNUMBER:
            if (!ByteDate[1])   // 成功
            {
                NSLog(@"%s,result:%@",__func__,@"终端号商户号设置成功");
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Set Terid Sucess";
//                    else
//                        self.LabTip.text = @"终端号商户号设置成功";
//                    [self ReadTernumber];  //读取终端号
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Set Terid Fail";
//                    else
//                        self.LabTip.text = @"终端号商户号设置失败";
                });
                
            }
            
            break;
        case GETTERNUMBER:  // 获取终端号
            if (!ByteDate[1])   // 成功
            {
                NSString * strTerNumber =@"";
                strTerNumber = [NSString stringWithFormat:@"%@",data];
                strTerNumber = [strTerNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                strTerNumber =[strTerNumber substringFromIndex:5];
                strTerNumber = [strTerNumber substringToIndex:23];
                NSLog(@"获取到了终端号:[%@]",[self stringFromHexString:strTerNumber]);
                // 将获取到得终端号传递出去
                if (_delegate && [_delegate respondsToSelector:@selector(didReadingTerminalNo:)]) {
                    [_delegate didReadingTerminalNo:[self stringFromHexString:strTerNumber]];
                }
                
            }
            
            break;
            
        case WriteAidParm:
            if (!ByteDate[1])   // 写AID成功
            {
                NSLog(@"%s,result:%@",__func__,@"IC卡Aid参数设置成功");
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Set AID Sucess";
//                    else
//                        self.LabTip.text = @"IC卡Aid参数设置成功";
                    
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Set AID Fail";
//                    else
//                        self.LabTip.text = @"IC卡Aid参数设置失败";
                });
                
            }
            
            break;
            
        case ClearAidParm:
            if (!ByteDate[1])   // 清除AID成功
            {
                NSLog(@"%s,result:%@",__func__,@"IC卡Aid参数清除成功");
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Clear AID Sucess";
//                    else
//                        self.LabTip.text = @"IC卡Aid参数清除成功";
                    
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Clear AID Fail";
//                    else
//                        self.LabTip.text = @"IC卡Aid参数清除失败";
                });
                
            }
            
            break;
        case WriteCpkParm:
            if (!ByteDate[1])   // 写公钥成个
            {
                NSLog(@"%s,result:%@",__func__,@"IC卡公钥参数设置成功");
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Set Pubkey Sucess";
//                    else
//                        self.LabTip.text = @"IC卡公钥参数设置成功";
                    
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Set Pubkey Fail";
//                    else
//                        self.LabTip.text = @"IC卡公钥参数设置失败";
                });
                
            }
            
            break;
        case ClearCpkParm:
            if (!ByteDate[1])   // 清除公钥成功
            {
                NSLog(@"%s,result:%@",__func__,@"IC卡公钥参数清除成功");
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Clear Pubkey Sucess";
//                    else
//                        self.LabTip.text = @"IC卡公钥参数清除成功";
                    
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Clear AID Fail";
//                    else
//                        self.LabTip.text = @"IC卡Aid参数清除失败";
                });
                
            }
            
            break;
        case ProofIcParm:
            if (!ByteDate[1])   // IC卡二次论证成功
            {
                NSLog(@"%s,result:%@",__func__,@"IC卡二次论证成功");
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"IC Proof Sucess";
//                    else
//                        self.LabTip.text = @"IC卡二次论证成功";
//                    
                    NSString  *strData =@"";
                    for (int i=2; i <[data length]; i++) {
                        NSString *newHexStr = [NSString stringWithFormat:@"%02x",ByteDate[i]&0xff];///16进制数
                        strData = [strData stringByAppendingString:newHexStr];
                        
                    }
//                    self.TextViewTip.text =strData;
                    
                });
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"IC Proof Fail";
//                    else
//                        self.LabTip.text = @"IC卡二次论证失败";
                });
            }
            break;
        case BATTERY:
            if (!ByteDate[1])   // 电池电量获取成功
            {
                NSString * strBattery=@"";
                for (int i=2; i <3; i++) {
                    NSString *newHexStr = [NSString stringWithFormat:@"%02x",ByteDate[i]&0xff];///16进制数
                    strBattery = [strBattery stringByAppendingString:newHexStr];
                    
                }
                
                int nBattery =StrToNumber16([strBattery cStringUsingEncoding:NSASCIIStringEncoding]);
                strBattery =[NSString stringWithFormat:@"%d",nBattery];
                NSLog(@"%s,result:%@",__func__,@"电池电量获取成功");
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                    {
//                        NSString * strTer =@"";
//                        strTer = [@"Get Battery Sucess:" stringByAppendingString:strBattery];
//                        self.LabTip.text = strTer;
//                    }
//                    else
//                    {
//                        //self.LabTip.text = @"电池电量获取成功";
//                        NSString * strTer =@"";
//                        strTer = [@"电池电量获取成功:" stringByAppendingString:strBattery];
//                        self.LabTip.text = strTer;
//                    }
                    
                });
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"Get Battery Fail";
//                    else
//                        self.LabTip.text = @"电池电量获取失败";
                });
            }
            break;
        case IC_STATUS:
            if (!ByteDate[1])   // IC卡在位
            {
                NSLog(@"%s,result:%@",__func__,@"IC卡在位");
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"IC CARD  Insert";
//                    else
//                        self.LabTip.text = @"IC卡插入";
                    
                    
                });
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"IC CARD  NO Insert";
//                    else
//                        self.LabTip.text = @"IC卡未插入";
                });
            }
            break;
        case IC_SOPEN:
            if (!ByteDate[1])   // IC卡上电成功
            {
                
                NSString *strSTR =@"";
                NSLog(@"%s,result:%@",__func__,@"IC卡上电成功");
                for (int i=0; i <ByteDate[2]+1; i++) {
                    NSString *newHexStr = [NSString stringWithFormat:@"%02x",ByteDate[i+2]&0xff];///16进制数
                    strSTR = [strSTR stringByAppendingString:newHexStr];
                    
                }
                
                strSTR = [@"上电ATR,第一个字节为大小:" stringByAppendingString:strSTR];
                dispatch_async(dispatch_get_main_queue(), ^{
//                    self.TextViewTip.text =strSTR;
//                    if (Language ==0)
//                        self.LabTip.text = @"IC OPEN   SUCESS";
//                    else
//                        self.LabTip.text = @"IC上电成功";
                    
                    
                    
                });
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"IC OPEN FAILD";
//                    else
//                        self.LabTip.text = @"IC上电失败";
                });
            }
            
            break;
        case IC_SWRITE:
            if (!ByteDate[1])   // IC卡上电成功
            {
                
                NSString *strSTR =@"";
                NSLog(@"%s,result:%@",__func__,@"APDU指令发送成功");
                for (int i=0; i <ByteDate[2]+1; i++) {
                    NSString *newHexStr = [NSString stringWithFormat:@"%02x",ByteDate[i+2]&0xff];///16进制数
                    strSTR = [strSTR stringByAppendingString:newHexStr];
                    
                }
                
                strSTR = [@"APDU ATR,第一个字节为大小:" stringByAppendingString:strSTR];
                dispatch_async(dispatch_get_main_queue(), ^{
//                    self.TextViewTip.text =strSTR;
//                    if (Language ==0)
//                        self.LabTip.text = @"APUD GET   SUCESS";
//                    else
//                        self.LabTip.text = @"APUD发送成功";
                    
                    
                    
                });
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"APUD GET FAILD";
//                    else
//                        self.LabTip.text = @"APUD发送失败";
                });
            }
            
            break;
        case IC_SCLOSE:
            if (!ByteDate[1])   // IC关闭
            {
                NSLog(@"%s,result:%@",__func__,@"IC关闭成功");
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"IC CLOSE  SUCESS";
//                    else
//                        self.LabTip.text = @"IC关闭成功";
                    
                });
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (Language ==0)
//                        self.LabTip.text = @"IC CLOSE FAILD";
//                    else
//                        self.LabTip.text = @"IC关闭失败";
                });
            }
            break;
        default:
            break;
    }
    
    
}


/*
 * 函  数: readTerminalNo
 * 功  能: 读取已识别列表中得设备号;
 *        一次尝试打开一批；
 * 参  数: 无
 * 返  回: 无
 */
- (BOOL) readTerminalNo {
//    BOOL result = isConnect;
    BOOL result = YES;

    if (!result)
        return  result;
    NSMutableData* data = [[NSMutableData alloc] init];
    Byte array[1] = {GETTERNUMBER};
    [data appendBytes:array length:1];
    result =[self writeMposData:data];
    return result;
}


/*
 * 函  数: writeMposData:
 * 功  能: 蓝牙设备数据交互;
 *        数据可读可写;在协议回调中接收数据
 * 参  数: 无
 * 返  回: 无
 */
- (BOOL)writeMposData:(NSData *)data
{
    NSUInteger nlen =0,dwWriteBytes =0,dwCopyBytes =0;
    Byte templen[2]={0};
    Byte szSendBlock[BLUE_MAX_PACKET_SIZE_EP]={0x00};
    [self  resetGetData];
//    if (sendDeviceListTimer) {
//        [sendDeviceListTimer invalidate];
//        sendDeviceListTimer = nil;
//    }
    nlen =[data length];
    templen[0]	= (((nlen)>>8)&0xff);
    templen[1] = (nlen)&0xff;
    NSString *hexStr=@"";
    for(int i=0;i<2;i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%02x",templen[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    
    
    NSMutableData *_writeData =NULL;
    if (_writeData == nil) {
        // NSLog(@"[MFiDataPath] writeData1: %@", data);
        _writeData = [[NSMutableData alloc] init];
    }
    [_writeData appendData:[self StrHexToByte:hexStr]];
    [_writeData appendData:data];
    nlen =[_writeData length];
    Byte *SendByte = (Byte *)[_writeData bytes];
    //循环发送
    while(dwWriteBytes<nlen)
    {
        memset(szSendBlock, 0x00, BLUE_MAX_PACKET_SIZE_EP);
        if( (nlen-dwWriteBytes) < BLUE_MAX_PACKET_SIZE_EP )
        {
            memcpy(szSendBlock, SendByte+dwWriteBytes, nlen-dwWriteBytes) ;
            dwCopyBytes = nlen-dwWriteBytes ;
        }
        else
        {
            memcpy(szSendBlock, SendByte+dwWriteBytes, BLUE_MAX_PACKET_SIZE_EP) ;
            dwCopyBytes = BLUE_MAX_PACKET_SIZE_EP ;
        }
        NSData *Sendata = [[NSData alloc] initWithBytes:szSendBlock length:dwCopyBytes];
        //NSLog(@"[MFiDataPath] writeData1: %@", Sendata);
        [[ISControlManager sharedInstance] writeData:Sendata];
        
        //[NSThread sleepForTimeInterval:0.001];
        dwWriteBytes += dwCopyBytes ;
    }
    
    
//    sendDeviceListTimer = [NSTimer scheduledTimerWithTimeInterval:WAIT_TIMEOUT target:self selector:@selector(sendDevictTimeout) userInfo:nil repeats:YES];
    
//    [_writeData release];
    return SUCESS;
}

- (void) resetGetData
{
    isAllData =false;
    memset(ByteReviceDate, 0x00, Revice_MAX_LEN);
    nTotalDatalen=0;
    nOffsetLen =0;
}

// 解析读卡数据
-(int)GetCard:(NSData*)TrackData
{
    /*
     20 00 0210
     136210985800012004611d491212061006000000
     136210985800012004611df5f98f2fb41d89000f
     34996210985800012004611d1561560000000000000003000000114000049121d000000000000d000000000000d00000 0061006000
     34996210985800012004611d1561560000000000000003000000114000049121d000000000000d0000000000450b3e bc742369 7f
     000000
     08cb59e6ea6d58c338
     00
     */
    
    int nIndex =0,nIndexlen=0;
    Byte  ByteData[512] ={0x00};
    Byte  szTrack2[80] ={0x00};
    //NSUInteger len = [TrackData length];
    memcpy(ByteData, (Byte *)[TrackData bytes], [TrackData length]);
    
    
    
    
    if  (TRACK_ENCRY_DATA==0x01)
    {
        TransData.YyEncrydataLen = ((ByteData[2] << 8) & 0xFF00);
        TransData.YyEncrydataLen |= ByteData[3] & 0xFF;
        memcpy(TransData.FieldEncrydata, ByteData, TransData.YyEncrydataLen +4);
        nIndex =TransData.YyEncrydataLen +4;
        
    }
    
    
    nIndex ++;
    TransData.iCardmodem =ByteData[nIndex];
    nIndex ++;
    memcpy(&TransData.szEntryMode, ByteData+nIndex, 2);
    nIndex +=2;
    
    /*
     //pan
     nIndexlen =ByteData[nIndex];
     memcpy(&TransData.TrackPAN, ByteData+nIndex+1, nIndexlen);
     nIndex +=1;
     nIndex +=nIndexlen;
     */
    //2磁道数据
    TransData.nTrack2Len =ByteData[nIndex];
    memcpy(&TransData.szTrack2, ByteData+nIndex+1, TransData.nTrack2Len);
    nIndex +=1;
    nIndex +=TransData.nTrack2Len;
    
    //2磁道加密数据
    TransData.nEncryTrack2Len =ByteData[nIndex];
    memcpy(&TransData.szEncryTrack2, ByteData+nIndex+1, TransData.nEncryTrack2Len);
    nIndex +=1;
    nIndex +=TransData.nEncryTrack2Len;
    
    
    //3磁道数据
    TransData.nTrack3Len =ByteData[nIndex];
    memcpy(&TransData.szTrack3, ByteData+nIndex+1, TransData.nTrack3Len);
    nIndex +=1;
    nIndex +=TransData.nTrack3Len;
    //3磁道加密数据
    TransData.nEncryTrack3Len =ByteData[nIndex];
    memcpy(&TransData.szEncryTrack3, ByteData+nIndex+1, TransData.nEncryTrack3Len);
    nIndex +=1;
    nIndex +=TransData.nEncryTrack3Len;
    
    //IC卡数据长度
    TransData.IccdataLen = ((ByteData[nIndex] << 8) & 0xFF00);
    TransData.IccdataLen |= ByteData[nIndex+1] & 0xFF;
    nIndex +=2;
    memcpy(&TransData.Field55Iccdata, ByteData+nIndex, TransData.IccdataLen);
    nIndex+= TransData.IccdataLen;
    //PINBLOCK
    nIndexlen=ByteData[nIndex];
    memcpy(&TransData.sPIN, ByteData+nIndex+1, nIndexlen);
    nIndex +=1;
    nIndex +=nIndexlen;
    //卡片序列号
    nIndexlen=ByteData[nIndex];
    memcpy(&TransData.CardSeq, ByteData+nIndex+1, nIndexlen);
    nIndex +=1;
    nIndex +=nIndexlen;
    //交易金额
    nIndexlen=ByteData[nIndex];
    memcpy(&TransData.szAmount, ByteData+nIndex+1, nIndexlen);
    nIndex +=1;
    nIndex +=nIndexlen;
    
    
    [self BcdToAsc:szTrack2:TransData.szTrack2:80];
    for(int i=0;i<80;i++)		// convert 'D' to '='
    {
        if( szTrack2[i]=='D' )
        {
            nIndexlen =i;
            break;
        }
    }
    if(nIndexlen >0)
    {
        strncpy(TransData.TrackPAN,(char *)szTrack2, nIndexlen);
        strncpy(TransData.CardValid, (char *)szTrack2+nIndexlen + 1, 4);
        strncpy(TransData.szServiceCode, (char *)szTrack2+nIndexlen + 5, 3);	//服务代码
        if((TransData.szServiceCode[0] == '2') ||(TransData.szServiceCode[0] == '6'))
            TransData.iCardtype =1;
        else
            TransData.iCardtype =0;
    }
    
    NSString *strData ;
    NSString *strAmout ;
    strData = [[NSString alloc] initWithCString:(const char*)TransData.TrackPAN encoding:NSASCIIStringEncoding];
    
    strData = [@"PAN:" stringByAppendingString:strData];
    
    strAmout= [[NSString alloc] initWithCString:(const char*)TransData.szAmount encoding:NSASCIIStringEncoding];
    
    
//    self.TextViewTip.text  =strData;
//    if (Language ==0)
//    {
//        strAmout = [@"Credit Sucess,Amout:" stringByAppendingString:strAmout];
//        
//        self.LabTip.text = strAmout;
//    }
//    else
//    {
//        strAmout = [@"刷卡成功,金额:" stringByAppendingString:strAmout];
//        
//        self.LabTip.text =strAmout;
//    }
    
    return  SUCESS;
}










-(void) BcdToAsc:(Byte *)Dest:(Byte *)Src:(int)Len
{
    int i;
    for(i=0;i<Len;i++)
    {
        //高Nibble转换
        if(((*(Src + i) & 0xF0) >> 4) <= 9)
        {
            *(Dest + 2*i) = ((*(Src + i) & 0xF0) >> 4) + 0x30;
        }
        else
        {
            *(Dest + 2*i)  = ((*(Src + i) & 0xF0) >> 4) + 0x37;   //大写A~F
        }
        //低Nibble转换
        if((*(Src + i) & 0x0F) <= 9)
        {
            *(Dest + 2*i + 1) = (*(Src + i) & 0x0F) + 0x30;
        }
        else
        {
            *(Dest + 2*i + 1) = (*(Src + i) & 0x0F) + 0x37;   //大写A~F
        }
    }
}


int Char16ToInt(char c)
{
    int num = 0;
    if (c >= '0' && c <= '9') {
        num = c - ('0' - 0);
    } else if (c >= 'a' && c <= 'f') {
        num = c - ('a' - 10);
    } else if (c >= 'A' && c <= 'F') {
        num = c - ('A' - 10);
    }
//    switch (c)
//    {
//        case '0':
//            num = 0;
//            break;
//        case '1':
//            num = 1;
//            break;
//        case '2':
//            num = 2;
//            break;
//        case '3':
//            num = 3;
//            break;
//        case '4':
//            num = 4;
//            break;
//        case '5':
//            num = 5;
//            break;
//        case '6':
//            num = 6;
//            break;
//        case '7':
//            num = 7;
//            break;
//        case '8':
//            num = 8;
//            break;
//        case '9':
//            num = 9;
//            break;
//        case 'a':
//        case 'A':
//            num = 10;
//            break;
//        case 'b':
//        case 'B':
//            num = 11;
//            break;
//        case 'c':
//        case 'C':
//            num = 12;
//            break;
//        case 'd':
//        case 'D':
//            num = 13;
//            break;
//        case 'e':
//        case 'E':
//            num = 14;
//            break;
//        case 'f':
//        case 'F':
//            num = 15;
//            break;
//        default:
//            break;
//    }
    return num;
}

int StrToNumber16(const char *str)
{
    int len,i,num;
    num = 0;//使用数据必须初始化否则产生不确定值
    len = strlen(str);
    for (i = 0; i < len; i++)
    {
        num = num*16 + Char16ToInt(str[i]);/*十六进制字符串与10进制的对应数据*/
    }
    return num;
}

// 十六进制字符串转换为byte型
-(NSData*)StrHexToByte:(NSString*)strHex
{
    NSString *hexString=[[strHex uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

// 十六进制转换为普通字符串的。
-(NSString *)stringFromHexString:(NSString *)hexString { //
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
    
    
}
@end
