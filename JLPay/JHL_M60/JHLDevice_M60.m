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
#import "../Define_Header.h"

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
// 已识别设备列表
//      每个元素都是一个字典:[dataPath:ISDataPath*,newFlag:"new/old"]
@property (nonatomic, strong) NSMutableArray* knownDeviceList;
// 已连接设备列表
//      每个元素都是一个字典:[dataPath:ISDataPath*,terminalNum:"11111111111"]
@property (nonatomic, strong) NSMutableArray* connectedDeviceList;
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
    [self.manager disconnectAllDevices];    // 会清空已连接设备的列表
    if (self.knownDeviceList.count > 0) {
        [self.knownDeviceList removeAllObjects];
    }
    if (self.connectedDeviceList.count > 0) {
        [self.connectedDeviceList removeAllObjects];
    }
    // 重新扫描设备: 会先清空已识别设备的列表
    [self.manager scanDeviceList:ISControlManagerTypeCB];
}


/*
 * 函  数: isConnectedOnTerminalNum:
 * 功  能: 判断指定终端号的设备是否已连接;
 * 参  数: 无
 * 返  回: 无
 */
- (BOOL) isConnectedOnTerminalNum:(NSString*)terminalNum {
    BOOL result = NO;
    for (NSDictionary* dataDic in self.connectedDeviceList) {
        if ([[dataDic valueForKey:@"terminalNum"] hasPrefix:terminalNum]) {
            result = YES;
            break;
        }
    }
    return result;
}

// pragma mask : 判断指定SN号的设备是否已连接
- (BOOL) isConnectedOnSNVersionNum:(NSString*)SNVersion {
    BOOL result = NO;
    for (NSDictionary* dataDic in self.connectedDeviceList) {
        if ([[dataDic valueForKey:@"SNVersion"] isEqualToString:SNVersion]) {
            result = YES;
        }
    }
    return result;
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
    // 要更新已识别设备列表的对应关闭连接的设备的 new 状态
    for (NSDictionary* dataDic in self.knownDeviceList) {
        ISBLEDataPath* dataPath = [dataDic valueForKey:@"dataPath"];
        if ([[dataDic valueForKey:@"newOrOld"] isEqualToString:@"old"] &&
            [dataPath state] == CBPeripheralStateDisconnected) {
            [dataDic setValue:@"new" forKey:@"newOrOld"];
        }
    }
}

// 设备完成连接
- (void)accessoryDidConnect:(ISDataPath *)accessory{
    ISBLEDataPath* mAccessory = (ISBLEDataPath*)accessory;
    NSLog(@"设备[%@]已连接", mAccessory.peripheral);
    // 读取终端号,并更新已连接设备中设备的终端号(在读取数据的回调中)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self readTerminalNoWithAccessory:accessory];
    });
    
    // 更新已识别设备中的对应设备的new状态
    for (NSDictionary* dataDic in self.knownDeviceList) {
        ISDataPath* dataPath = [dataDic valueForKey:@"dataPath"];
        if ([dataPath isKindOfClass:[ISBLEDataPath class]]) {
            ISBLEDataPath* iDataPath = (ISBLEDataPath*)dataPath;
            NSLog(@"设备[%@],状态为[%@]", iDataPath.peripheral,[dataDic valueForKey:@"newOrOld"]);
            if (iDataPath.peripheral == mAccessory.peripheral &&
                [[dataDic valueForKey:@"newOrOld"] isEqualToString:@"new"]) {
                [dataDic setValue:@"old" forKey:@"newOrOld"];
                break;
            }
        }
    }
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
    
    [self onReceive:data withAccessory:accessory];
    [self  resetGetData];
}
// 完成向设备写数据:成功/失败还未知
- (void)accessoryDidWriteData:(ISDataPath *)accessory bytes:(int)bytes complete:(BOOL)complete{
    NSLog(@"蓝牙设备交互数据成功");
}
// 写设备数据失败
- (void)accessoryDidFailToWriteData:(ISDataPath *)accessory error:(NSError *)error{
    NSLog(@"蓝牙设备交互数据失败:[%@]", error);
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
    // 条件是:这个设备是新识别的
    for (ISDataPath* dataPath in devices) {
        if ([dataPath.name hasPrefix:@"JHLM60"] &&                      // 前缀
            [dataPath isKindOfClass:[ISBLEDataPath class]] )            // ISBLEDataPath
        {
            [self knownDeviceListAddObject:dataPath];
        }
    }
    
    [self compareConnectedDeviceListWithList:connectList];

    // 打开已识别列表中状态为 new 的设备
    [self openInKnownDeviceList];
}

/*
 * 函  数: openInKnownDeviceList
 * 功  能: 将已识别列表中得 new 状态的设备打开;
 * 参  数:
 *          (ISDataPath*)dataPath
 * 返  回: 无
 */
- (void) openInKnownDeviceList {
    for (NSDictionary* dataDic in self.knownDeviceList) {
        NSLog(@"需要打开的设备【%@】状态为[%@]", [dataDic valueForKey:@"dataPath"], [dataDic valueForKey:@"newOrOld"]);
        if ([[dataDic valueForKey:@"newOrOld"] isEqualToString:@"new"]) {
            ISBLEDataPath* dataPath = [dataDic objectForKey:@"dataPath"];
            if ([dataPath state] == CBPeripheralStateDisconnected) {
                // 并发打开设备
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [self.manager connectDevice:(ISDataPath*)dataPath];
                });
            }
        }
    }
}


/*
 * 函  数: knownDeviceListAddedObject
 * 功  能: 如果;
 * 参  数: 
 *          (ISDataPath*)dataPath
 * 返  回: 无
 */
- (void) knownDeviceListAddObject:(ISDataPath*)dataPath {
    BOOL hasElement = NO;
    ISBLEDataPath* oDataPath = (ISBLEDataPath*)dataPath;
    for (NSDictionary* dataDic in self.knownDeviceList) {
        // 逐个比对当前已识别列表中设备的序列号
        ISDataPath* innerDataPath = [dataDic valueForKey:@"dataPath"];
        if ([innerDataPath isKindOfClass:[ISBLEDataPath class]]) {
            ISBLEDataPath* path = (ISBLEDataPath*)innerDataPath;
            if (path.peripheral == oDataPath.peripheral) {
                hasElement = YES;
            }
        }
    }
    // 设备不再当前列表中才将它添加到当前列表，并设置 newOrOld 标志
    if (!hasElement) {
        NSMutableDictionary* ddic = [[NSMutableDictionary alloc] init];
        [ddic setValue:dataPath forKey:@"dataPath"];
        [ddic setValue:@"new" forKey:@"newOrOld"];
        [self.knownDeviceList addObject:ddic];
    }
}

/*
 * 函  数: compareConnectedDeviceListWithList
 * 功  能: 对比两个已连接设备列表;
 *          一个是后台蓝牙设备管理器的设备列表；
 *          一个是本管理器中的设备列表；
 *          如果本地没有，就添加到本地:并读取设备号，建立字典
 *          如果本地多余，就删除本地多余的字典
 *          但是不管怎样，两个列表最多只会相差一个
 *
 * 参  数:
 *          (ISDataPath*)dataPath
 * 返  回: 无
 */
- (void) compareConnectedDeviceListWithList:(NSArray*)connectList {
    BOOL compared = NO;
    // 先用本地跟后台列表比对，不匹配设备进入 localNotComparedList
    NSMutableArray* changedObjects = [[NSMutableArray alloc] init];
    for (NSDictionary* dataDic in self.connectedDeviceList) {
        ISDataPath* innerDataPath = [dataDic valueForKey:@"dataPath"];
        compared = NO;
        for (ISDataPath* bgDataPath in connectList) {
            ISBLEDataPath* oDataPath = (ISBLEDataPath*)bgDataPath;
            ISBLEDataPath* iDataPath = (ISBLEDataPath*)innerDataPath;
            if ([bgDataPath.name hasPrefix:@"JHLM60"] &&
                [bgDataPath isKindOfClass:[ISBLEDataPath class]] &&
                oDataPath.peripheral == iDataPath.peripheral ) {
                compared = YES;
                break;
            }
        }
        if (!compared) {
            [changedObjects addObject:dataDic];
        }
    }
    // 数组元素的删除必须在轮询结束才能操作
    if ([changedObjects count] > 0) {
        [self.connectedDeviceList removeObjectsInArray:changedObjects];
        [self renewTerminalNumbers];
        [self renewSNVersionNumbers];
    }

    
    // 用后台跟本地列表比对，不匹配设备进入 bgNotComparedList
    [changedObjects removeAllObjects];
    for (ISDataPath* bgDataPath in connectList) {
        if (![bgDataPath.name hasPrefix:@"JHLM60"] ||
            ![bgDataPath isKindOfClass:[ISBLEDataPath class]]) {
            continue;
        }
        compared = NO;
        for (NSDictionary* dataDic in self.connectedDeviceList) {
            ISDataPath* innerDataPath = [dataDic valueForKey:@"dataPath"];
            ISBLEDataPath* oDataPath = (ISBLEDataPath*)bgDataPath;
            ISBLEDataPath* iDataPath = (ISBLEDataPath*)innerDataPath;
            if (oDataPath.peripheral == iDataPath.peripheral) {
                compared = YES;
                break;
            }
        }
        if (!compared) {
            NSMutableDictionary* dataDic = [[NSMutableDictionary alloc] init];
            [dataDic setValue:bgDataPath forKey:@"dataPath"];
            [dataDic setValue:nil forKey:@"terminalNum"];
            [dataDic setValue:nil forKey:@"SNVersion"];
            [changedObjects addObject:dataDic];
        }
        if (changedObjects.count > 0) {
            [self.connectedDeviceList addObjectsFromArray:changedObjects];
        }
    }
}


/*
 * 函  数: updateConnetedListOnDevice:byTerminalNum
 * 功  能: 更新本地已连接设备列表中对应设备的终端号;
 *          终端号跟设备入口以字典形式保存着；
 *
 * 参  数:
 *          (ISDataPath*)dataPath
 *          (NSString*)terminalNum 终端编号
 * 返  回: 无
 */
- (void) updateConnetedListOnDevice:(ISDataPath*)dataPath byTerminalNum:(NSString*)terminalNum {
    ISBLEDataPath* oDataPath = (ISBLEDataPath*)dataPath;
    for (NSDictionary* dataDic in self.connectedDeviceList) {
        ISBLEDataPath* innerDataPath = [dataDic valueForKey:@"dataPath"];
        if (oDataPath.peripheral == innerDataPath.peripheral) {
            [dataDic setValue:terminalNum forKeyPath:@"terminalNum"];
            // 刷新终端号列表给外部协议
            [self renewTerminalNumbers];
            break;
        }
    }
}

/*
 * 函  数: updateConnetedListOnDevice:byTerminalNum
 * 功  能: 更新本地已连接设备列表中对应设备的终端号;
 *          终端号跟设备入口以字典形式保存着；
 *
 * 参  数:
 *          (ISDataPath*)dataPath
 *          (NSString*)terminalNum 终端编号
 * 返  回: 无
 */
- (void) updateConnetedListOnDevice:(ISDataPath*)dataPath bySNNum:(NSString*)SNNum {
    ISBLEDataPath* oDataPath = (ISBLEDataPath*)dataPath;
    for (NSDictionary* dataDic in self.connectedDeviceList) {
        ISBLEDataPath* innerDataPath = [dataDic valueForKey:@"dataPath"];
        if (oDataPath.peripheral == innerDataPath.peripheral) {
            [dataDic setValue:SNNum forKeyPath:@"SNVersion"];
            // 刷新SN号列表给外部协议
            [self renewSNVersionNumbers];
            break;
        }
    }
}


/*
 * 函  数: renewTerminalNumbers
 * 功  能: 刷新外部协议从本控制器读取的所有设备的终端号;
 *          终端号跟设备入口以字典形式保存着；
 *
 * 参  数:
 *          (ISDataPath*)dataPath
 *          (NSString*)terminalNum 终端编号
 * 返  回: 无
 */
- (void) renewTerminalNumbers {
    NSMutableArray* terminalNumbers = [[NSMutableArray alloc] init];
    for (NSDictionary* dataDic in self.connectedDeviceList) {
        NSString* terminalNumber = [dataDic valueForKey:@"terminalNum"];
        if (terminalNumber != nil) {
            [terminalNumbers addObject:terminalNumber];
        }
    }
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(renewTerminalNumbers:)]) {
        [self.delegate renewTerminalNumbers:terminalNumbers];
    }
}


/*
 * 函  数: renewSNVersionNumbers
 * 功  能: 刷新外部协议从本控制器读取的所有设备的终端号;
 *          终端号跟设备入口以字典形式保存着；
 *
 * 参  数:
 *          (ISDataPath*)dataPath
 *          (NSString*)terminalNum 终端编号
 * 返  回: 无
 */
- (void) renewSNVersionNumbers {
    NSMutableArray* SNVersionArray = [[NSMutableArray alloc] init];
    for (NSDictionary* dataDic in self.connectedDeviceList) {
        NSString* SNVersion = [dataDic valueForKey:@"SNVersion"];
        if (SNVersion != nil) {
            [SNVersionArray addObject:SNVersion];
        }
    }
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(renewSNVersionNumbers:)]) {
        [self.delegate renewSNVersionNumbers:SNVersionArray];
    }
}

    


#pragma mask --------------------- 设备交互
/*
 * 函  数: onReceive:
 * 功  能: 解析从蓝牙设备中读取的数据;
 * 参  数: 无
 * 返  回: 无
 */
-(void)onReceive:(NSData*)data withAccessory:(ISDataPath*)accessory{
    
    NSLog(@"%s %@",__func__,data);
    Byte * ByteDate = (Byte *)[data bytes];
    switch (ByteDate[0]) {
        case GETCARD_CMD:
            if (!ByteDate[1])   // 刷卡成功
            {
                NSLog(@"%s,result:%@",__func__,@"刷卡成功");
                    NSString *strPan=@"";
                    int nlen =ByteDate[2]&0xff;
                    for (int i=0; i <nlen; i++) {
                        NSString *newHexStr = [NSString stringWithFormat:@"%02x",ByteDate[i+3]&0xff];///16进制数
                        strPan = [strPan stringByAppendingString:newHexStr];
                        
                    }
                    strPan =[self stringFromHexString:strPan];
                    strPan = [@"PAN:" stringByAppendingString:strPan];
            }
            else
            {
                NSLog(@"%s,result:%@",__func__,@"刷卡失败");
                    return;
            }
            
            break;
        case CHECK_IC:
            
            if (!ByteDate[1])   // 获取卡号数据成功
            {
                NSLog(@"%s,result:%@",__func__,@"获取卡号数据成功");
            }
            else
            {
                
                
                
                NSLog(@"%s,result:%@",__func__,@"获取卡号数据失败");
            }
            break;
        case GETTRACK_CMD:
        case  GETTRACKDATA_CMD:
            if (!ByteDate[1])   // 获取卡号数据成功
            {
                NSLog(@"%s,result:%@",__func__,@"获取卡号数据成功");
                // 解析读到的卡得数据
                [self GetCard:data];
                [self cardDataUserDefult];
                // 保存读到的数据到本地
                [self.delegate didCardSwipedSucOrFail:YES withError:nil];
            }
            else
            {
                NSLog(@"%s,result:%@",__func__,@"获取卡号数据失败");
                NSString* error = nil;
                if (ByteDate[1]==0xE1 )
                    error = @"获取卡号数据失败:用户取消";
                else if (ByteDate[1]==0xE2 )
                    error = @"获取卡号数据失败:超时退出";
                else if (ByteDate[1]==0xE3 )
                    error =@"获取卡号数据失败:IC卡数据处理失败";
                else if (ByteDate[1]==0xE4 )
                    error =@"获取卡号数据失败:无IC卡参数";
                else if (ByteDate[1]==0xE5 )
                    error =@"获取卡号数据失败:交易终止";
                else if (ByteDate[1]==0x46 )
                    error =@"MPOS已关机";
                else // ByteDate[1]==0xE6,0x02,...
                    error = @"获取卡号数据失败:操作失败,请重试";;
                [self.delegate didCardSwipedSucOrFail:NO withError:error];
            }
            break;
        case YY_GETTRACK_CMD:
        {
            
            NSLog(@"%s,result:%@",__func__,@"获取卡号数据成功");
                [self GetCard:data];
        }
            break;
        case MAINKEY_CMD:
            if (!ByteDate[1])   // 主密钥设置成功
            {
                NSLog(@"%s,result:%@",__func__,@"主密钥设置成功");
                    [self.delegate didWriteMainKeySucOrFail:YES withError:nil];
            }else
            {
                    [self.delegate didWriteMainKeySucOrFail:NO withError:@"设置主密钥失败"];
            }
            break;
        case WORKKEY_CMD:
            if (!ByteDate[1])   // 工作密钥设置成功
            {
                NSLog(@"%s,result:%@",__func__,@"工作密钥设置成功");
                    [self.delegate didWriteWorkKeySucOrFail:YES withError:nil];
            }else
            {
                    [self.delegate didWriteWorkKeySucOrFail:NO withError:nil];
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
                NSLog(@"SN获取成功  %@",strSN);
                // 更新已连接设备列表的sn号
                    [self updateConnetedListOnDevice:accessory bySNNum:strSN];
            }
            break;
        case GETMAC_CMD:
            if (!ByteDate[1])   // MAC
            {
                NSLog(@"%s,result:%@",__func__,@"MAC 获取成功");
                    NSString * strMAC =@"";
                    strMAC = [NSString stringWithFormat:@"%@",data];
                    strMAC = [strMAC stringByReplacingOccurrencesOfString:@" " withString:@""];
                    strMAC =[strMAC substringFromIndex:5];
                    strMAC = [strMAC substringToIndex:16];
                    strMAC = [@"MAC值:" stringByAppendingString:strMAC];
                
            }else
            {
            }
            break;
        case WRITETERNUMBER:    // 设置终端号+商户号
            if (!ByteDate[1])   // 成功
            {
                NSLog(@"%s,result:%@",__func__,@"终端号商户号设置成功");
                [self.delegate didWriteTerminalNumSucOrFail:YES withError:nil];
            }else               // 失败
            {
                [self.delegate didWriteTerminalNumSucOrFail:NO withError:@"设置终端号+商户号失败"];
            }
            break;
        case GETTERNUMBER:  // 获取终端号
            if (!ByteDate[1])   // 成功
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    // 开个线程读取SN号
                    [self readSNNoWithAccessory:accessory];
                });
                NSString * strTerNumber =@"";
                strTerNumber = [NSString stringWithFormat:@"%@",data];
                strTerNumber = [strTerNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                strTerNumber =[strTerNumber substringFromIndex:5];
                NSLog(@"原始终端号+商户号串[%@]",strTerNumber);
                strTerNumber = [strTerNumber substringToIndex:(8+15)*2 + 1];
                NSLog(@"解析后的终端号+商户号:[%@]",[self stringFromHexString:strTerNumber]);
                /* 将读到的终端号填充到本地已连接设备列表中对应的设备 */
                    [self updateConnetedListOnDevice:accessory byTerminalNum:[self stringFromHexString:strTerNumber]];
            }
            break;
            
        case WriteAidParm:
            if (!ByteDate[1])   // 写AID成功
            {
                NSLog(@"%s,result:%@",__func__,@"IC卡Aid参数设置成功");
            }else
            {
            }
            
            break;
            
        case ClearAidParm:
            if (!ByteDate[1])   // 清除AID成功
            {
                NSLog(@"%s,result:%@",__func__,@"IC卡Aid参数清除成功");
            }else
            {
            }
            
            break;
        case WriteCpkParm:
            if (!ByteDate[1])   // 写公钥成个
            {
                NSLog(@"%s,result:%@",__func__,@"IC卡公钥参数设置成功");
            }else
            {
            }
            
            break;
        case ClearCpkParm:
            if (!ByteDate[1])   // 清除公钥成功
            {
                NSLog(@"%s,result:%@",__func__,@"IC卡公钥参数清除成功");
            }else
            {
            }
            break;
        case ProofIcParm:
            if (!ByteDate[1])   // IC卡二次论证成功
            {
                NSLog(@"%s,result:%@",__func__,@"IC卡二次论证成功");
                    NSString  *strData =@"";
                    for (int i=2; i <[data length]; i++) {
                        NSString *newHexStr = [NSString stringWithFormat:@"%02x",ByteDate[i]&0xff];///16进制数
                        strData = [strData stringByAppendingString:newHexStr];
                    }
            }else
            {
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
            }else
            {
            }
            break;
        case IC_STATUS:
            if (!ByteDate[1])   // IC卡在位
            {
                NSLog(@"%s,result:%@",__func__,@"IC卡在位");
            }else
            {
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
            }else
            {
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
            }else
            {
            }
            
            break;
        case IC_SCLOSE:
            if (!ByteDate[1])   // IC关闭
            {
                NSLog(@"%s,result:%@",__func__,@"IC关闭成功");
            }else
            {
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
 * 返  回:  
 *        BOOL : 向设备发送请求数据成功或失败
 */
- (BOOL) readTerminalNoWithAccessory:(ISDataPath *)accessory {
//    BOOL result = isConnect;
    NSLog(@"开始获取终端号");
    BOOL result = YES;

    if (!result)
        return  result;
    NSMutableData* data = [[NSMutableData alloc] init];
    Byte array[1] = {GETTERNUMBER};
    [data appendBytes:array length:1];
    result =[self writeMposData:data withAccessory:accessory];
    return result;
}

/*
 * 函  数: readTerminalNo
 * 功  能: 读取已识别列表中得设备号;
 *        一次尝试打开一批；
 * 参  数: 无
 * 返  回:
 *        BOOL : 向设备发送请求数据成功或失败
 */
- (BOOL) readSNNoWithAccessory:(ISDataPath *)accessory {
    NSLog(@"开始获取SN号");
    BOOL result = YES;
    
    if (!result)
        return  result;
    NSMutableData* data = [[NSMutableData alloc] init];
    Byte array[1] = {GETSNVERSION};
    [data appendBytes:array length:1];
    result =[self writeMposData:data withAccessory:accessory];
    return result;
}


// 写终端号+商户号
- (void) writeTerminalNum:(NSString*)terminalNumAndBusinessNum onSNVersion:(NSString*)SNVersion{
    ISBLEDataPath* dataPath = nil;
    for (NSDictionary* dataDic in self.connectedDeviceList) {
        ISBLEDataPath* iDataPath = [dataDic objectForKey:@"dataPath"];
        if ([[dataDic objectForKey:@"SNVersion"] isEqualToString:SNVersion]) {
            dataPath = iDataPath;
        }
    }
    if (dataPath == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteTerminalNumSucOrFail:withError:)]) {
            [self.delegate didWriteTerminalNumSucOrFail:NO withError:[NSString stringWithFormat:@"设备[SN:%@]未连接", SNVersion]];
        }
    } else {
        Byte bytesData[1+23] = {0x00};
        bytesData[0] = WRITETERNUMBER;
        memcpy(bytesData + 1, [terminalNumAndBusinessNum cStringUsingEncoding:NSUTF8StringEncoding], 23);
        NSData* data = [NSData dataWithBytes:bytesData length:1+23];
        [self writeMposData:data withAccessory:dataPath];
    }
}

// 设置主密钥
- (void) writeMainKey:(NSString*)mainKey onSNVersion:(NSString*)SNVersion {
    ISBLEDataPath* dataPath = nil;
    for (NSDictionary* dataDic in self.connectedDeviceList) {
        ISBLEDataPath* iDataPath = [dataDic objectForKey:@"dataPath"];
        if ([[dataDic objectForKey:@"SNVersion"] isEqualToString:SNVersion]) {
            dataPath = iDataPath;
        }
    }
    if (dataPath == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteTerminalNumSucOrFail:withError:)]) {
            [self.delegate didWriteTerminalNumSucOrFail:NO withError:[NSString stringWithFormat:@"设备[SN:%@]未连接", SNVersion]];
        }
    } else {
        NSString* dataStr = [@"340110" stringByAppendingString:mainKey];
        NSData* data = [self StrHexToByte:dataStr];
        [self writeMposData:data withAccessory:dataPath];
    }
}

// 设置工作密钥
- (void) writeWorkKey:(NSString*)workKey onTerminal:(NSString*)terminalNum {
    ISBLEDataPath* dataPath = nil;
    for (NSDictionary* dataDic in self.connectedDeviceList) {
        ISBLEDataPath* iDataPath = [dataDic objectForKey:@"dataPath"];
        if ([[dataDic objectForKey:@"terminalNum"] hasPrefix:terminalNum]) {
            dataPath = iDataPath;
        }
    }
    if (dataPath == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteTerminalNumSucOrFail:withError:)]) {
            [self.delegate didWriteTerminalNumSucOrFail:NO withError:[NSString stringWithFormat:@"设备[%@]未连接", terminalNum]];
        }
    } else {
        NSString* DataWorkkey = [@"38" stringByAppendingString:workKey];
        NSData* bytesDate =[self StrHexToByte:DataWorkkey];
        [self writeMposData:bytesDate withAccessory:dataPath];
    }
}

// 刷卡: 有金额+无密码, 无金额+无密码,
- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onTerminal:(NSString*)terminalNum{
    ISBLEDataPath* dataPath = nil;
    for (NSDictionary* dataDic in self.connectedDeviceList) {
        ISBLEDataPath* iDataPath = [dataDic objectForKey:@"dataPath"];
        if ([[dataDic objectForKey:@"terminalNum"] hasPrefix:terminalNum]) {
            dataPath = iDataPath;
        }
    }
    if (dataPath == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteTerminalNumSucOrFail:withError:)]) {
            [self.delegate didWriteTerminalNumSucOrFail:NO withError:[NSString stringWithFormat:@"设备[%@]未连接", terminalNum]];
        }
    } else {
        memset(&TransData, 0x00, sizeof(FieldTrackData));
        Byte SendData[24]={0x00};
        SendData[0] =GETTRACKDATA_CMD;
        SendData[1] =0x00;
        SendData[2] =0x01;
        SendData[3] =0x01;
        SendData[4] =TRACK_ENCRY_MODEM;
        SendData[5] =PASSWORD_ENCRY_MODEM;
        SendData[6] =TRACK_ENCRY_DATA;
        SendData[7] =TRACK_ENCRY_DATA;
        sprintf((char *)SendData+8, "%012d", MAmount);
        NSString *strDate = [self returnDate];
        NSData* bytesDate =[self StrHexToByte:strDate];
        Byte * ByteDate = (Byte *)[bytesDate bytes];
        memcpy(SendData+20,ByteDate+1, 3);
        long ntimeout = (long)DeviceWaitingTime;
        if ((DeviceWaitingTime <20) || (DeviceWaitingTime >60))
            ntimeout = 60;
        SendData[23] =ntimeout;
        NSData *SendArryByte = [[NSData alloc] initWithBytes:SendData length:24];
        [self writeMposData:SendArryByte withAccessory:dataPath];
    }
}


/*
 * 函  数: writeMposData:
 * 功  能: 蓝牙设备数据交互;
 *        数据可读可写;在协议回调中接收数据
 * 参  数: 无
 * 返  回: 无
 */
- (BOOL)writeMposData:(NSData *)data withAccessory:(ISDataPath *)accessory
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
        if (accessory == nil) {
            [[ISControlManager sharedInstance] writeData:Sendata];
        } else {
            [[ISControlManager sharedInstance] writeData:Sendata withAccessory:accessory];
        }
        
        //[NSThread sleepForTimeInterval:0.001];
        dwWriteBytes += dwCopyBytes ;
    }
    
//    sendDeviceListTimer = [NSTimer scheduledTimerWithTimeInterval:WAIT_TIMEOUT target:self selector:@selector(sendDevictTimeout) userInfo:nil repeats:YES];
    return SUCESS;
}




#pragma mask -------------------------- 数据处理工具:私有
// 将读到的卡数据保存到本地
- (void) cardDataUserDefult {
    Byte dataStr[512] = {0x00};
    
    // 卡片有效期 Card_DeadLineTime
    memset(dataStr, 0, 512);
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%s",(char*)TransData.CardValid] forKey:Card_DeadLineTime];
    
    // 2磁道加密数据
    memset(dataStr, 0, 512);
    [self BcdToAsc:dataStr :TransData.szEncryTrack2 :TransData.nEncryTrack2Len];
    NSLog(@"2磁数据:[%s]", dataStr);
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%s",dataStr] forKey:Two_Track_Data];
    
    // 2磁道数据
    memset(dataStr, 0, 512);
    [self BcdToAsc:dataStr :TransData.szTrack2 :TransData.nTrack2Len];

    // PINBLOCK -- 密文密码
    memset(dataStr, 0, 512);
    [self BcdToAsc:dataStr :TransData.sPIN :(int)strlen((char*)TransData.sPIN)];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%s",dataStr] forKey:Sign_in_PinKey];
    
    // 芯片数据55域信息
    if (TransData.IccdataLen > 0) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CardTypeIsTrack];  // 设置读卡方式:芯片
        memset(dataStr, 0, 512);
        [self BcdToAsc:dataStr :TransData.Field55Iccdata :TransData.IccdataLen];
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%s",dataStr] forKey:BlueIC55_Information];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CardTypeIsTrack];  // 设置读卡方式:磁条
    }
    
    // 芯片序列号23域值
    memset(dataStr, 0, 512);
    strcpy((char*)dataStr, "0001"); // 不从卡读取了，直接赋值
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%s",dataStr] forKey:ICCardSeq_23];
    
    // 卡号
    memset(dataStr, 0, 512);
    NSString *strData ;
    strData = [[NSString alloc] initWithCString:(const char*)TransData.TrackPAN encoding:NSASCIIStringEncoding];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@*****%@",[strData substringWithRange:NSMakeRange(0, [strData length]-9)],[strData substringWithRange:NSMakeRange([strData length]-4, 4)]] forKey:GetCurrentCard_NotAll];
    [[NSUserDefaults  standardUserDefaults]setObject:strData forKey:Card_Number];
    
    [[NSUserDefaults standardUserDefaults]synchronize];
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
        strncpy((char*)TransData.CardValid, (char *)szTrack2+nIndexlen + 1, 4);
        strncpy(TransData.szServiceCode, (char *)szTrack2+nIndexlen + 5, 3);	//服务代码
        if((TransData.szServiceCode[0] == '2') ||(TransData.szServiceCode[0] == '6'))
            TransData.iCardtype =1;
        else
            TransData.iCardtype =0;
    }
    
    return  SUCESS;
}







-(NSString *)returnDate
{
    NSDate *theDate = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
    NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:theDate];
    
    
    NSString *returnString = [NSString stringWithFormat:@"%02i%02i%02i",(int)[components year],(int)[components month],(int)[components day]];
    
    
    return returnString;
}


-(void) BcdToAsc:(Byte *)Dest :(Byte *)Src :(int)Len
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

// 16进制字符转换为对应的int
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
    return num;
}
// 将16进制字符串转换为整型
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
    free(myBuffer);
    return unicodeString;
    
    
}
// 打印读到的芯片卡得数据
- (void) logTransData {
    NSMutableString* logStr = [[NSMutableString alloc] initWithString:@"\n----\nTransData:[\n"];
    /*
     unsigned char iTransNo;         //交易类型,指的什么交易 目前暂未使用
     int iCardtype;                          //刷卡卡类型  磁条卡 IC卡
     int iCardmodem;                         //刷卡模式
     char TrackPAN[21];                      //域2  主帐号
     unsigned char CardValid[5];       //域14 卡有效期
     char szServiceCode[4];                  //服务代码
     unsigned char CardSeq[2];       //域23 卡片序列号
     unsigned char szEntryMode[3];     //域22 服务点输入方式
     unsigned char szTrack2[40];       //域35 磁道2数据
     unsigned char szEncryTrack2[40];    //域35 磁道2加密数据 第一个字节为长度
     unsigned char szTrack3[108];      //域36 磁道3数据
     unsigned char szEncryTrack3[108];   //域36 磁道3加密数据
     unsigned char sPIN[13];         //域52 个人标识数据(pind ata)
     unsigned char Field55Iccdata[300];    //的55域信息512->300
     unsigned char FieldEncrydata[300];    //随机加密数据 //针对客户
     */
//    [logStr appendString:[NSString stringWithFormat:@"iTransNo = [%c]\n", TransData.iTransNo]];
    [logStr appendString:[NSString stringWithFormat:@"iCardtype = [%d]\n", TransData.iCardtype]];
    [logStr appendString:[NSString stringWithFormat:@"iCardmodem = [%d]\n", TransData.iCardmodem]];
    [logStr appendString:[NSString stringWithFormat:@"TrackPAN = [%s]\n", TransData.TrackPAN]];
    [logStr appendString:[NSString stringWithFormat:@"CardValid = [%s]\n", TransData.CardValid]];
    [logStr appendString:[NSString stringWithFormat:@"szServiceCode = [%s]\n", TransData.szServiceCode]];
    [logStr appendString:[NSString stringWithFormat:@"CardSeq = [%s]\n", TransData.CardSeq]];
    [logStr appendString:[NSString stringWithFormat:@"szEntryMode = [%s]\n", TransData.szEntryMode]];
    [logStr appendString:[NSString stringWithFormat:@"szTrack2 = [%s]\n", TransData.szTrack2]];
    [logStr appendString:[NSString stringWithFormat:@"szEncryTrack2 = [%s]\n", TransData.szEncryTrack2]];
    [logStr appendString:[NSString stringWithFormat:@"szTrack3 = [%s]\n", TransData.szTrack3]];
    [logStr appendString:[NSString stringWithFormat:@"szEncryTrack3 = [%s]\n", TransData.szEncryTrack3]];
    [logStr appendString:[NSString stringWithFormat:@"sPIN = [%s]\n", TransData.sPIN]];
    [logStr appendString:[NSString stringWithFormat:@"Field55Iccdata = [%s]\n", TransData.Field55Iccdata]];
    [logStr appendString:[NSString stringWithFormat:@"FieldEncrydata = [%s]\n", TransData.FieldEncrydata]];
    [logStr appendString:[NSString stringWithFormat:@"iccDataLen = [%d]\n", TransData.IccdataLen]];
    
    
    [logStr appendString:@"]----\n"];
    NSLog(@"%@",logStr);
    
}

@end
