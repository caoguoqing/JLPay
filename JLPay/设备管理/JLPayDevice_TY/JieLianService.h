//
//  JieLianService.h
//  JieLianService
//
//  Created by xiao on 15/9/1.
//  Copyright (c) 2015年 xiao. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

#define GETCARD_CMD  0x12
#define GETTRACK_CMD 0x20
#define GETTRACKDATA_CMD 0x22  //0xE1  用户取消  0xE2 超时退出 E3 IC卡数据处理失败 0xE4 无IC卡参数 0xE5 交易终止 0xE6 操作失败,请重试
#define MAINKEY_CMD  0x34
#define PINBLOCK_CMD 0x36
#define GETMAC_CMD   0x37
#define WORKKEY_CMD  0x38
#define GETSNVERSION 0x40
#define GETTERNUMBER 0x41
#define WRITETERNUMBER   0x42
#define YY_GETTRACK_CMD 0xff

#define WriteAidParm   0x33  //AID
#define ClearAidParm   0x3A  //清空AID
#define WriteCpkParm   0x32  //公钥
#define ClearCpkParm   0x39  //清空公钥
#define ProofIcParm    0x23   //二次论证I卡数据
#define BATTERY        0x45   //获取电池电量

#define IC_STATUS      0x13   //判断卡片知否在位
#define IC_SOPEN       0x14   //IC卡打开上电
#define IC_SCLOSE      0x15   //关闭IC卡
#define IC_SWRITE      0x16   //发送APUD

#define MAmount        0x00
//默认超时时间15秒
#define WAIT_TIMEOUT   15

//磁道加密算法，0表示银联标准的只加密后8字节，1/2表示不包含长度补0/F组成8的倍数据加密，3/4表示包含长度补0/F组成8的倍数据加密，5表示尤银特殊加密）
#define TRACK_ENCRY_MODEM   0x00

//密码加密，0表示标准主账号异或加密，1表示不带主账号加密，2尤银特殊加密
#define PASSWORD_ENCRY_MODEM 0x00
#define TRACK_ENCRY_DATA  0x00 //0x00 标准数据回应 0x01 多包数据回应


#pragma mark - 回调函数
@protocol TYJieLianDelegate <NSObject>

@required
/***********************************************************
	函 数 名：onReceive:
	功能描述：数据接收处理函数,处理所有数据结果
	入口参数：data
 返回Byte数组
 Byte[0]为操作类型
 Byte[1]为判断码
 Byte[2]之后为返回的数据
	返回说明：
 **********************************************************/
- (void)onReceive:(NSData*)data;

/**********************************************************
 函 数 名：discoverPeripheralSuccess:(CBPeripheral *)peripheral
 功能描述：在StartScanning扫描到设备后回调
 入口参数：Peripheral  扫描到的蓝牙设备
 返回说明：
 *********************************************************/
- (void)discoverPeripheralSuccess:(CBPeripheral *)peripheral;


/**********************************************************
 函 数 名：accessoryDidReadData:(NSDictionary *)data;
 功能描述：操作蓝牙相关功能函数后回调
 入口参数：data  处理结果数据
 返回说明：
 *********************************************************/
/*
 例如 磁条卡:
 * cardType:卡类型00
 * cardNumber:卡号
 * encTrack2Ex:二磁道信息
 * encTrack3Ex:三磁道信息
 * cardValidDate:有效期
 * serviceCode:服务代码
 * serialNumber:流水号
 ic 卡:
 * cardType:卡类型01
 * masterSN:IC卡序列号
 * cardNumber:卡号
 * ic_authData: 55域
 * track2Data: 二磁道信息
 * cardValidDate:有效期
 * serialNumber:流水号
 */
- (void)accessoryDidReadData:(NSDictionary *)data;

/**
 *  连接设备回调
 *
 *  @param peripheral 蓝牙设备
 */
- (void)didConnectPeripheral:(CBPeripheral *)peripheral;

/**
 *  设备断开连接回调
 *
 *  @param peripheral 蓝牙设备
 */
- (void)didDisconnectPeripheral:(CBPeripheral *)peripheral;
@end



#pragma mark - 接口函数
@interface JieLianService : NSObject
@property (nonatomic, assign) id <TYJieLianDelegate> delegate;

/***********************************************************
 函 数 名：SDKVersion
 功能描述：获取当前SDK的版本
 入口参数：无
 返回说明：返回当前当前SDK的版本号
 **********************************************************/
- (NSString *)SDKVersion;

/***********************************************************
 函 数 名：StartScanning
 功能描述：查询配对蓝牙设备
 入口参数：无
 返回说明：成功/失败
 **********************************************************/
- (int)StartScanning;

/***********************************************************
 函 数 名：stopScanning
 功能描述：停止查找蓝牙
 入口参数：无
 返回说明：成功/失败
 **********************************************************/
- (void)stopScanning;

/***********************************************************
 函 数 名：connectDevice
 功能描述：连接设备
 入口参数：device
 返回说明：成功/失败
 **********************************************************/
- (BOOL)connectDevice:(CBPeripheral *)device;

/***********************************************************
 函 数 名：connectDevice
 功能描述：连接设备
 入口参数：device
 返回说明：成功/失败
 **********************************************************/
- (BOOL)disConnectDevice;

/***********************************************************
 函 数 名：GetSnVersion
 功能描述：读取SN号版本号
 入口参数：无
 返回说明：
 **********************************************************/
- (int)GetSnVersion;

/***********************************************************
 函 数 名：MagnAmountPasswordCard
 功能描述：MPOS设备上输提示输入金额 刷卡  输入密码
 入口参数：long 	timeout 		--刷卡交易超时时间(毫秒)
 返回说明：
 **********************************************************/
- (int)MagnAmountPasswordCardAmount:(NSString *)amount TimeOut:(long)timeout;


/***********************************************************
 函 数 名：MagnAmountNoPasswordCard
 功能描述：MPOS设备上输提示输入金额 刷卡  无密码
 入口参数： long 	timeout 		--刷卡交易超时时间(毫秒)
 返回说明：
 **********************************************************/
- (int)MagnAmountNoPasswordCardAmount:(NSString *)amount TimeOut:(long)timeout;

/***********************************************************
 函 数 名：MagnNoAmountPasswordCard
 功能描述：MPOS 设备上输提 刷卡  + 输入密码   无输入金额（例如查询余额）
 入口参数：long 	timeout 		--刷卡交易超时时间(毫秒)
 返回说明：
 **********************************************************/
- (int)MagnNoAmountPasswordCard:(long)timeout;

/***********************************************************
 函 数 名：MagnNoAmountNoPasswordCard
 功能描述：MPOS 设备上输提 刷卡      无输入金额  无密码（例如信用卡预授权完成等交易）
 入口参数：long 	timeout 		--刷卡交易超时时间(毫秒)
 返回说明：
 **********************************************************/
- (int)MagnNoAmountNoPasswordCard:(long)timeout;


/***********************************************************
 函 数 名：WriteMainKey::
 功能描述：写入主密钥
 入口参数：int        len		--主密钥长度
 NSString    Datakey --主密钥数据16个字节
 返回说明：返回说明：成功/失败
 **********************************************************/
-(int)WriteMainKey:(int)len :(NSString*)Datakey;

/***********************************************************
 函 数 名：WriteWorkKey
 功能描述：写入工作密钥
 入口参数：int		len		--主密钥长度NSString
 NSString 	DataWorkkey	--工作密钥数据57个字节
 16字节PIN密钥+4个字节校验码 +16字节MAC +4个字节MAC校验码 +磁道加密密钥+磁道加密密钥校验码 4个字节  ==60 个字节
 返回说明：返回说明：成功/失败
 **********************************************************/
-(int)WriteWorkKey:(int)len :(NSString*)DataWorkkey;

/***********************************************************
 函 数 名：WriteTernumber
 功能描述：写入终端号商户号
 入口参数：NSString 	DataTernumber	--终端号+商户号=23字节 ASCII
 返回说明：成功/失败
 
 **********************************************************/
-(int)WriteTernumber:(NSString*)DataTernumber;

/***********************************************************
 
 函 数 名：ReadTernumber
 功能描述：读取端号商户号
 入口参数：
 返回说明：成功/失败
 
 **********************************************************/
-(int)ReadTernumber;

/***********************************************************
 函 数 名：GetMac
 功能描述：获取MAC
 入口参数： int		len		--Mac长度
 NSString   Datakey		---Mac数据
 返回说明：成功/失败
 **********************************************************/
-(int)GetMac:(int)len :(NSString*)Datakey;

/***********************************************************
 函 数 名：WriteEmvParm
 功能描述：设置（AID）参数
 入口参数：NSString  DataPack --参数结构体数据
  
 typedef struct{
            unsigned char AppName[33];       //本地应用名，以'\x00'结尾的字符串
            unsigned char AID[17];           //应用标志
            unsigned char AidLen;            //AID的长度
            unsigned char SelFlag;           //选择标志( 部分匹配/全匹配)
            unsigned char Priority;          //优先级标志
            unsigned char TargetPer;         //目标百分比数
            unsigned char MaxTargetPer;      //最大目标百分比数
            unsigned char FloorLimitCheck;   //是否检查最低限额
            unsigned char RandTransSel;      //是否进行随机交易选择
            unsigned char VelocityCheck;     //是否进行频度检测
            unsigned long FloorLimit;        //最低限额
            unsigned long Threshold;         //阀值
            unsigned char TACDenial[6];      //终端行为代码(拒绝)
            unsigned char TACOnline[6];      //终端行为代码(联机)
            unsigned char TACDefault[6];     //终端行为代码(缺省)
            unsigned char AcquierId[7];      //收单行标志
            unsigned char dDOL[256];         //终端缺省DDOL   len+data
            unsigned char tDOL[256];         //终端缺省TDOL   len+data
            unsigned char Version[3];        //应用版本
            unsigned char RiskManData[10];   //风险管理数据   len+data
 unsigned char EC_bTermLimitCheck;      //是否支持终端交易限额
 unsigned long EC_TermLimit;            //终端交易限额，
 unsigned char CL_bStatusCheck;         //是否支持qPBOC状态检查
 unsigned long CL_FloorLimit;        //非接触终端最低限额
 unsigned long CL_TransLimit;        //非接触终端交易限额
 unsigned long CL_CVMLimit;          //非接触终端CVM限
 unsigned char TermQuali_byte2;      //交易金额与每个AID限额的判断结果，在刷卡前处理，通过此变量缓存判断结果
 }STRUCT_PACK EMV_APPLIST;
 返回说明：成功/失败
 **********************************************************/
- (int)WriteEmvAidParm:(NSString*)DataPack;

/***********************************************************
 函 数 名：ClearEmvParm
 功能描述：清空（AID）参数
 入口参数：
 返回说明：成功/失败
 **********************************************************/
- (int)ClearEmvAidParm;

/***********************************************************
 函 数 名：WriteEmvCapk
 功能描述：设置公钥
 入口参数：NSString 	DataPack	--公钥结构体数据
 typedef struct {
 unsigned char RID[5];            //应用注册服务商ID
 unsigned char KeyID;             //密钥索引
 unsigned char HashInd;           //HASH算法标志
 unsigned char ArithInd;          //RSA算法标志
 unsigned char ModulLen;          //模长度
 unsigned char Modul[248];        //模
 unsigned char ExponentLen;       //指数长度
 unsigned char Exponent[3];       //指数
 unsigned char ExpDate[3];        //有效期(YYMMDD)
 unsigned char CheckSum[20];      //密钥校验和
 }
 返回说明：成功/失败
 **********************************************************/
-(int)WriteEmvCapkParm:(NSString*)DataPack;

/***********************************************************
 函 数 名：ClearCapkParm
 功能描述：清空公钥
 入口参数：
 返回说明：成功/失败
 **********************************************************/
-(int)ClearCapkParm;

/***********************************************************
 函 数 名：ProofIcData
 功能描述：交易后论证
 入口参数：NSString 	IcData	--交易后论证数据
 返回说明：成功/失败
 **********************************************************/
-(int)ProofIcData:(NSString*)IcData;

/***********************************************************
 函 数 名：ReadBattery
 功能描述：获取电池电量
 入口参数：
 返回说明：成功/失败
 **********************************************************/
-(int)ReadBattery;

/***********************************************************
 函 数 名：IC_GetStatus
 功能描述：判断卡片是否在位
 入口参数：
 返回说明：成功/失败
 **********************************************************/
-(int)IC_GetStatus;

/***********************************************************
 函 数 名：IC_Open
 功能描述：IC卡打开上电 返回 数据大小 +上电复位数据
 入口参数：
 返回说明：成功/失败
 **********************************************************/
-(int)IC_Open;

/***********************************************************
 函 数 名：IC_WriteApdu
 功能描述：发送APUD数据
 入口参数：Len    APDU 大小
 ApduData  APDU数据
 返回说明：成功/失败
 **********************************************************/
-(int)IC_WriteApdu:(int)nLen :(NSString*)ApduData;

/************************************************************
 函 数 名：IC_Close
 功能描述：关闭IC卡下电
 入口参数：
 返回说明：成功/失败
 **********************************************************/
-(int)IC_Close;

@end


