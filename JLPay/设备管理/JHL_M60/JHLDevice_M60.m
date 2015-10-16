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
#import "../../Define_Header.h"

@interface JHLDevice_M60()<ISControlManagerDeviceList,ISControlManagerDelegate>{
    FieldTrackData TransData;       //磁道数据
    BOOL   isAllData;
    uint8_t ByteReviceDate[Revice_MAX_LEN];
    int  nTotalDatalen;
    int  nOffsetLen;
}
@property (nonatomic, retain) ISControlManager* manager;
/* 已识别设备列表 Node
 *      + dataPath
 *      + identifier
 *      + SNVersion
 */
@property (nonatomic, strong) NSMutableArray* knownDeviceList;
// 用来标记是否自动打开设备的标记
@property (nonatomic, assign) BOOL needOpenDevices;
@end


@implementation JHLDevice_M60
@synthesize manager = _manager;
@synthesize knownDeviceList = _knownDeviceList;
@synthesize needOpenDevices;


/* ----------------
 * 设备信息列表节点值的 KEY:
 * ---------------- */
#define KeyDataPathNodeDataPath         @"KeyDataPathNodeDataPath"      // 设备dataPath
#define KeyDataPathNodeIdentifier       @"KeyDataPathNodeIdentifier"    // 设备ID
#define KeyDataPathNodeSNVersion        @"KeyDataPathNodeSNVersion"     // 设备SN号



#pragma mask ===================== [Public interface]

// pragma mask : 设置自动标记:是否自动打开设备
- (void) setOpenAutomaticaly:(BOOL)yesOrNo {
    self.needOpenDevices = yesOrNo;
}


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
    for (NSDictionary* dataDic in self.knownDeviceList) {
        ISBLEDataPath* dataPath = [dataDic objectForKey:KeyDataPathNodeDataPath];
        if ([dataPath state] == CBPeripheralStateDisconnected) {
            [self.manager connectDevice:dataPath];
        } else if (dataPath.state == CBPeripheralStateConnected &&
                   (![dataDic valueForKey:KeyDataPathNodeSNVersion] || [[dataDic valueForKey:KeyDataPathNodeSNVersion] isEqualToString: @""])) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self readSNNoWithAccessory:dataPath];
            });
        }
    }
}
- (void)closeAllDevices {
    [self.manager disconnectAllDevices];
}
// 读取所有已连接设备的SN号
- (void)readSNVersions {
    for (NSDictionary* dataDic in self.knownDeviceList) {
        ISBLEDataPath* dataPath = [dataDic objectForKey:KeyDataPathNodeDataPath];
        if ([dataPath state] == CBPeripheralStateConnected &&
            ([dataDic valueForKey:KeyDataPathNodeSNVersion] == nil || [[dataDic valueForKey:KeyDataPathNodeSNVersion] isEqualToString:@""])
            ) {
            [self readSNNoWithAccessory:dataPath];
        }
    }
}
// prama mask : ID设备获取:根据SN号获取对应设备
- (NSString*) identifierOnDeviceSN:(NSString*)SNVersion {
    NSString* identifier = nil;
    for (NSDictionary* dict in self.knownDeviceList) {
        if ([SNVersion isEqualToString:[dict valueForKey:KeyDataPathNodeSNVersion]]) {
            identifier = [dict valueForKey:KeyDataPathNodeIdentifier];
            break;
        }
    }
    return identifier;
}

// 打开指定SNVersion号的设备
- (void) openDevice:(NSString*)SNVersion {
    for (NSDictionary* dataDic in self.knownDeviceList) {
        if ([[dataDic valueForKey:KeyDataPathNodeSNVersion] isEqualToString:SNVersion]) {
            ISBLEDataPath* dataPath = [dataDic objectForKey:KeyDataPathNodeDataPath];
            [self.manager connectDevice:dataPath];
        }
    }
}
- (void) openDeviceWithIdentifier:(NSString*)identifier {
    for (NSDictionary* dataDic in self.knownDeviceList) {
        ISBLEDataPath* dataPath = [dataDic objectForKey:KeyDataPathNodeDataPath];
        if ([[[dataPath peripheral] identifier].UUIDString isEqualToString:identifier]) {
            if ([dataPath state] == CBPeripheralStateDisconnected) {
                [self.manager connectDevice:dataPath];
            }
        }
    }
}
- (void) closeDevice:(NSString *)SNVersion {
    for (NSDictionary* dataDic in self.knownDeviceList) {
        if ([[dataDic valueForKey:KeyDataPathNodeSNVersion] isEqualToString:SNVersion]) {
            ISBLEDataPath* dataPath = [dataDic objectForKey:KeyDataPathNodeDataPath];
            [self.manager disconnectDevice:dataPath];
        }
    }
}

// pragma mask : 开始扫描设备
- (void) startScanningDevices {
    [self startScanning];
}
// pragma mask : 停止扫描设备
- (void) stopScanningDevices {
    [self.manager stopScaning];
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
    [self.manager stopScaning];
    // 刷新时要先清空本地的已识别设备列表
    if (self.knownDeviceList.count > 0) {
        [self.knownDeviceList removeAllObjects];
    }
    // 重新扫描设备: 会先清空已识别设备的列表
    [self.manager scanDeviceList:ISControlManagerTypeCB];
}




// pragma mask : 判断指定SN号的设备是否已连接
- (int) isConnectedOnSNVersionNum:(NSString*)SNVersion {
    BOOL result = NO;
    BOOL inList = NO;
    for (NSDictionary* dataDic in self.knownDeviceList) {
        if ([[dataDic valueForKey:KeyDataPathNodeSNVersion] isEqualToString:SNVersion]) {
            inList = YES;
            ISBLEDataPath* dataPath = [dataDic objectForKey:KeyDataPathNodeDataPath];
            if ([dataPath state] == CBPeripheralStateConnected/* || [dataPath state] == CBPeripheralStateConnecting*/) {
                result = YES;
            }
        }
    }
    if (!inList) {
        return -1;          // 设备未打开
    } else {
        if (result) {
            return 1;       // 设备已连接
        } else {
            return 0;       // 设备已打开，但未连接
        }
    }
}

// pragma mask : 判断指定设备ID的设备是否已连接
- (int) isConnectedOnIdentifier:(NSString*)identifier {
    BOOL result = NO;
    BOOL inList = NO;
    for (NSDictionary* dataDic in self.knownDeviceList) {
        ISBLEDataPath* dataPath = [dataDic objectForKey:KeyDataPathNodeDataPath];
        if ([[[dataPath peripheral] identifier].UUIDString isEqualToString:identifier]) {
            inList = YES;
            if ([dataPath state] == CBPeripheralStateConnected/* || [dataPath state] == CBPeripheralStateConnecting*/) {
                result = YES;
            }
            else if ([dataPath state] == CBPeripheralStateDisconnected) {
                inList = NO;
            }
        }
    }
    if (!inList) {
        return -1;          // 设备未打开
    } else {
        if (result) {
            return 1;       // 设备已连接
        } else {
            return 0;       // 设备已打开，但未连接
        }
    }
}



// 初始化::
- (instancetype)initWithDelegate:(id<JHLDevice_M60_Delegate>)deviceDelegate {
    self = [super init];
    if (self) {
        [self setDelegate:deviceDelegate];
        _manager = [ISControlManager sharedInstance];
        [_manager setDelegate:self];    // 设备操作类的回调入口
        [_manager setDeviceList:self];  // 设备列表的回调入口
        _knownDeviceList = [[NSMutableArray alloc] init];
        needOpenDevices = NO;
    }
    return self;
}
- (void)dealloc {
    [self.manager setDelegate:nil];
    [self.manager setDeviceList:nil];
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _manager = [ISControlManager sharedInstance];
        [_manager setDelegate:self];    // 设备操作类的回调入口
        [_manager setDeviceList:self];  // 设备列表的回调入口
        _knownDeviceList = [[NSMutableArray alloc] init];
        needOpenDevices = NO;
    }
    return self;
}


#pragma mask ===================== [Private interface]


#pragma mask --------------------- ISControlManagerDelegate
// 已经断开了跟设备的连接
- (void)accessoryDidDisconnect:(ISDataPath *)accessory {
    // 设备断开连接了，先引发回调，然后刷新列表
    // 防止在后面的刷新列表中，重复打开设备，这里就删掉本地列表中对应的设备入口
    ISBLEDataPath* mDataPath = (ISBLEDataPath*)accessory;
    NSString* oIdentifier = [[mDataPath peripheral] identifier].UUIDString;
    NSMutableArray* objDel = [[NSMutableArray alloc] init];
    for (NSDictionary* dataDic in self.knownDeviceList) {
        ISBLEDataPath* dataPath = [dataDic objectForKey:KeyDataPathNodeDataPath];
        if ([[[dataPath peripheral] identifier].UUIDString isEqualToString:oIdentifier]) {
            [objDel addObject:dataPath];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceDisconnectOnSNVersion:)]) {
                [self.delegate deviceDisconnectOnSNVersion:[dataDic valueForKey:KeyDataPathNodeSNVersion]];
            }
        }
    }
    [self.knownDeviceList removeObjectsInArray:objDel];
}

// 设备完成连接
- (void)accessoryDidConnect:(ISDataPath *)accessory{
    // 读取终端号,并更新已连接设备中设备的终端号(在读取数据的回调中)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self readSNNoWithAccessory:accessory];
    });
    // 连接设备成功的回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(didOpenDeviceSucOrFail:withError:)]) {
        [self.delegate didOpenDeviceSucOrFail:YES withError:nil];
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
    if (nTotalDatalen +2 != nOffsetLen)  //数据没收全
    {
        return;
    }
    
    memset(ByteDate, 0x00, Revice_MAX_LEN);
    memcpy(ByteDate, ByteReviceDate+2, nOffsetLen-2);
    data = [[NSData alloc] initWithBytes:ByteDate length:nOffsetLen-2];
    
    [self onReceive:data withAccessory:accessory];
    [self  resetGetData];
}
// 完成向设备写数据:成功/失败还未知
- (void)accessoryDidWriteData:(ISDataPath *)accessory bytes:(int)bytes complete:(BOOL)complete{
}
// 写设备数据失败
- (void)accessoryDidFailToWriteData:(ISDataPath *)accessory error:(NSError *)error{
}

#pragma mask --------------------- ISControlManagerDeviceList
/*
 * 蓝牙设备列表刷新后的回调;
 * 只保存 JHLM60 的设备
 * devices     : 已识别，有连接跟未连接
 * connectList : 已识别，且连接
 * 引发事件包括:
 *      1.扫描到了新设备
 *      2.打开了设备
 *      3.关闭了设备
 * --------------------------- multipal by 20150828 : 
 *      - 扫描到设备后仅仅添加到设备列表;
 */
- (void)didGetDeviceList:(NSArray *)devices andConnected:(NSArray *)connectList {
    for (ISBLEDataPath* dataPath in devices) {
        NSString* deviceName = [dataPath advName];

        if (!deviceName || ![deviceName hasPrefix:@"JHLM60"]) {
            continue;
        }
        BOOL isExist = NO;
        for (NSDictionary* curDeviceDict in self.knownDeviceList) {
            ISBLEDataPath* curDataPath = [curDeviceDict objectForKey:KeyDataPathNodeDataPath];
            if ([dataPath.UUID.UUIDString isEqualToString:curDataPath.UUID.UUIDString]) {
                isExist = YES;
                break;
            }
        }
        if (isExist == NO) {
            // 新扫描到的设备要添加到设备列表:并回调出ID
            NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:3];
            [dict setObject:dataPath forKey:KeyDataPathNodeDataPath];
            [dict setValue:dataPath.UUID.UUIDString forKey:KeyDataPathNodeIdentifier];
            [self.knownDeviceList addObject:dict];
            if (self.delegate && [self.delegate respondsToSelector:@selector(didDiscoverDeviceOnID:)]) {
                [self.delegate didDiscoverDeviceOnID:dataPath.UUID.UUIDString];
            }
        }
    }
}


#pragma mask --------------------- 设备响应数据
/*
 * ---------------------------
 * 函  数: onReceive:withAccessory
 * 功  能: 解析从蓝牙设备中读取的数据;
 * 参  数: 无
 * 返  回: 无
 * ---------------------------
 */
-(void)onReceive:(NSData*)data withAccessory:(ISDataPath*)accessory{
    Byte * ByteDate = (Byte *)[data bytes];
    switch (ByteDate[0]) {
        case GETCARD_CMD:
            if (!ByteDate[1])   // 刷卡成功
            {
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
                    return;
            }
            
            break;
        case  GETTRACK_CMD:
        case  GETTRACKDATA_CMD:
            if (!ByteDate[1])   // 获取卡号数据成功
            {
                // 解析读到的卡得数据
                [self GetCard:data];
                NSDictionary* cardInfo = [self cardInfoOfReading];
                if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedSucOrFail:withError:andCardInfo:)]) {
                    [self.delegate didCardSwipedSucOrFail:YES withError:nil andCardInfo:cardInfo];
                }
            }
            else
            {
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
                if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedSucOrFail:withError:andCardInfo:)]) {
                    [self.delegate didCardSwipedSucOrFail:NO withError:error andCardInfo:nil];
                }

            }
            break;
        case MAINKEY_CMD:
            if (!ByteDate[1])   // 主密钥设置成功
            {
                    [self.delegate didWriteMainKeySucOrFail:YES withError:nil];
            }else
            {
                    [self.delegate didWriteMainKeySucOrFail:NO withError:@"设置主密钥失败"];
            }
            break;
        case WORKKEY_CMD:
            if (!ByteDate[1])   // 工作密钥设置成功
            {
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
                strSN =[PublicInformation stringFromHexString:strSN];
                // 更新已连接设备列表的sn号
                ISBLEDataPath* oDataPath = (ISBLEDataPath*)accessory;
                for (NSDictionary* dict in self.knownDeviceList) {
                    ISBLEDataPath* dataPath = [dict objectForKey:KeyDataPathNodeDataPath];
                    if ([dataPath.peripheral.identifier.UUIDString isEqualToString:oDataPath.peripheral.identifier.UUIDString]) {
                        [dict setValue:strSN forKey:KeyDataPathNodeSNVersion];
                    }
                }
                // SN号读取结果回调
                if (self.delegate && [self.delegate respondsToSelector:@selector(didReadSNVersion:sucOrFail:withError:)]) {
                    [self.delegate didReadSNVersion:strSN sucOrFail:YES withError:nil];
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didReadSNVersion:sucOrFail:withError:)]) {
                    [self.delegate didReadSNVersion:nil sucOrFail:NO withError:@"读取SN号失败"];
                }
            }
            break;
        case GETMAC_CMD:
            if (!ByteDate[1])   // MAC
            {
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
            }else
            {
            }
            break;
        default:
            break;
    }
    
    
}



/*
 * 函  数: readSNNo
 * 功  能: 读取已识别列表中得设备号;
 *        一次尝试打开一批；
 * 参  数: 无
 * 返  回:
 *        BOOL : 向设备发送请求数据成功或失败
 */
- (BOOL) readSNNoWithAccessory:(ISDataPath *)accessory {
    NSMutableData* data = [[NSMutableData alloc] init];
    Byte array[1] = {GETSNVERSION};
    [data appendBytes:array length:1];
    BOOL result =[self writeMposData:data withAccessory:accessory];
    return result;
}



// 设置主密钥
- (void) writeMainKey:(NSString*)mainKey onSNVersion:(NSString*)SNVersion {
    ISBLEDataPath* dataPath = nil;
    for (NSDictionary* dataDic in self.knownDeviceList) {
        ISBLEDataPath* iDataPath = [dataDic objectForKey:KeyDataPathNodeDataPath];
        if ([[dataDic objectForKey:KeyDataPathNodeSNVersion] isEqualToString:SNVersion]) {
            dataPath = iDataPath;
        }
    }
    if (dataPath == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteMainKeySucOrFail:withError:)]) {
            [self.delegate didWriteMainKeySucOrFail:NO withError:[NSString stringWithFormat:@"设备[SN:%@]未连接",SNVersion]];
        }
    } else {
        NSString* dataStr = [@"340110" stringByAppendingString:mainKey];
        NSData* data = [self StrHexToByte:dataStr];
        [self writeMposData:data withAccessory:dataPath];
    }
}


// 设置工作密钥 with SNVersion
- (void) writeWorkKey:(NSString*)workKey onSNVersion:(NSString*)SNVersion {
    ISBLEDataPath* dataPath = nil;
    for (NSDictionary* dataDic in self.knownDeviceList) {
        ISBLEDataPath* iDataPath = [dataDic objectForKey:KeyDataPathNodeDataPath];
        if ([[dataDic objectForKey:KeyDataPathNodeSNVersion] hasPrefix:SNVersion]) {
            dataPath = iDataPath;
        }
    }
    if (dataPath == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteWorkKeySucOrFail:withError:)]) {
            [self.delegate didWriteWorkKeySucOrFail:NO withError:[NSString stringWithFormat:@"设备[%@]未连接", SNVersion]];
        }
    } else {
        Byte byteData = WORKKEY_CMD;
        NSData* data = [self StrHexToByte:workKey];
        Byte* writeBytes = (Byte*)malloc((int)[data length] + 1);
        writeBytes[0] = byteData;
        memcpy(writeBytes + 1, [data bytes], [data length]);
        [self writeMposData:[NSData dataWithBytes:writeBytes length:[data length] + 1] withAccessory:dataPath];
    }
}


// 刷卡:使用SNVersion匹配设备-- 新版修改:使用 ID而不是SN匹配
- (void) cardSwipeWithMoney:(NSString*)money yesOrNot:(BOOL)yesOrNot onSNVersion:(NSString*)SNVersion {
    ISBLEDataPath* dataPath = nil;
    for (NSDictionary* dataDic in self.knownDeviceList) {
        ISBLEDataPath* iDataPath = [dataDic objectForKey:KeyDataPathNodeDataPath];
        if ([[dataDic objectForKey:KeyDataPathNodeSNVersion] isEqualToString:SNVersion]) {
            dataPath = iDataPath;
        }
    }
    if (dataPath == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didCardSwipedSucOrFail:withError:andCardInfo:)]) {
            [self.delegate didCardSwipedSucOrFail:NO withError:[NSString stringWithFormat:@"设备[%@]未连接", SNVersion] andCardInfo:nil];
        }
    } else {
        memset(&TransData, 0x00, sizeof(FieldTrackData));
        Byte SendData[24]={0x00};
        SendData[0] =GETTRACKDATA_CMD;
        SendData[1] =0x00;  // 不输金额
        SendData[2] =0x01;  // 输密码
        SendData[3] =0x01;
        SendData[4] =TRACK_ENCRY_MODEM;
        SendData[5] =PASSWORD_ENCRY_MODEM;
        SendData[6] =TRACK_ENCRY_DATA;
        SendData[7] =TRACK_ENCRY_DATA;
        memcpy((char*)SendData+8, [money cStringUsingEncoding:NSUTF8StringEncoding], 12);
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
        
        dwWriteBytes += dwCopyBytes ;
    }
    return SUCESS;
}




#pragma mask -------------------------- 数据处理工具:私有

- (NSDictionary*) cardInfoOfReading {
    NSMutableDictionary* cardInfo = [[NSMutableDictionary alloc] init];
    Byte dataStr[512] = {0x00};
    
    // 2 卡号
    memset(dataStr, 0, 512);
    NSString* cardNum = [[NSString alloc] initWithCString:(const char*)TransData.TrackPAN encoding:NSASCIIStringEncoding];
    [cardInfo setValue:cardNum forKey:@"2"];
    
    // 14 卡片有效期 Card_DeadLineTime
    memset(dataStr, 0, 512);
    [cardInfo setValue:[NSString stringWithFormat:@"%s",(char*)TransData.CardValid] forKey:@"14"];
    
    // 22 服务码输入方式
    memset(dataStr, 0, 512);
    [self BcdToAsc:dataStr :TransData.szEntryMode :2];
    NSString* f22 = [NSString stringWithFormat:@"%s",dataStr];
    [cardInfo setValue:f22 forKey:@"22"];
    
    // 35 2磁道加密数据
    memset(dataStr, 0, 512);
    [self BcdToAsc:dataStr :TransData.szEncryTrack2 :TransData.nEncryTrack2Len];
    [cardInfo setValue:[NSString stringWithFormat:@"%s",dataStr] forKey:@"35"];
    
    // 36 3磁道加密数据
    memset(dataStr, 0, 512);
    [self BcdToAsc:dataStr :TransData.szEncryTrack3 :TransData.nEncryTrack3Len];
    if (strlen((char*)dataStr) > 0) {
        [cardInfo setValue:[NSString stringWithFormat:@"%s",dataStr] forKey:@"36"];
    }
    
    // 52 PINBLOCK -- 密文密码
    memset(dataStr, 0, 512);
    [self BcdToAsc:dataStr :TransData.sPIN :(int)strlen((char*)TransData.sPIN)];
    [cardInfo setValue:[NSString stringWithFormat:@"%s",dataStr] forKey:@"52"];
    if (strlen((char*)dataStr) > 0) {
        [cardInfo setValue:@"2600000000000000" forKey:@"53"];
    } else {
        [cardInfo setValue:@"0600000000000000" forKey:@"53"];
    }
    
    // 23 IC卡序列号
    memset(dataStr, 0, 512);
    [self BcdToAsc:dataStr :TransData.CardSeq :1];
    NSString* f23 = [NSString stringWithFormat:@"%04d", atoi((const char*)dataStr)];
    if ([f22 hasPrefix:@"05"]) {
        [cardInfo setValue:f23 forKey:@"23"];
    }
    
    // 55 芯片数据55域信息
    if (TransData.IccdataLen > 0) {
        memset(dataStr, 0, 512);
        [self BcdToAsc:dataStr :TransData.Field55Iccdata :TransData.IccdataLen];
        [cardInfo setValue:[NSString stringWithFormat:@"%s",dataStr] forKey:@"55"];
    }
    
    return cardInfo;
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
        if((TransData.szServiceCode[0] == '2') || (TransData.szServiceCode[0] == '6'))
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
    len = (int)strlen(str);
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
    free(myBuffer);
    return unicodeString;
    
    
}

@end
